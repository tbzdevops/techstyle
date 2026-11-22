"""Deployment-Protokoll für scripts/dora.py aus der GitHub-API erzeugen.

Ein Deployment ist ein erfolgreicher Lauf des Workflows DORA_WORKFLOW auf dem
Branch DORA_BRANCH. Ein fehlgeschlagenes Deployment ist eines, das in einem
Issue mit dem Label «incident» per Commit-SHA genannt wird. Ein Deployment ist
Rework, wenn seine Commit-Nachricht ein solches Issue nennt (z.B. «Fixes #12»).

Aufruf (lokal mit der GitHub CLI angemeldet):
    GITHUB_REPOSITORY=<owner>/<repo> GITHUB_TOKEN=$(gh auth token) \
        python scripts/dora_collect.py deployments.csv

Umgebungsvariablen:
    GITHUB_REPOSITORY   owner/repo (in GitHub Actions automatisch gesetzt)
    GITHUB_TOKEN        Token mit Leserechten auf Actions, Inhalte und Issues
    DORA_WORKFLOW       Workflow-Datei, die als Deployment zählt (deploy-aws.yml)
    DORA_BRANCH         Branch der Produktion (main)
    DORA_TAGE           Messzeitraum in Tagen bis heute (28)
"""

import csv
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone

API = os.environ.get("GITHUB_API_URL", "https://api.github.com")
REPO = os.environ["GITHUB_REPOSITORY"]
TOKEN = os.environ.get("GITHUB_TOKEN", "")
WORKFLOW = os.environ.get("DORA_WORKFLOW") or "deploy-aws.yml"
BRANCH = os.environ.get("DORA_BRANCH") or "main"
DAYS = int(os.environ.get("DORA_TAGE") or 28)


def get(path):
    """Eine Anfrage an die GitHub-API, Antwort als JSON."""
    request = urllib.request.Request(API + path, headers={
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        **({"Authorization": f"Bearer {TOKEN}"} if TOKEN else {}),
    })
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)


def get_all(path, key=None, max_pages=10):
    """Alle Seiten einer Liste abholen (je 100 Einträge)."""
    items = []
    sep = "&" if "?" in path else "?"
    for page in range(1, max_pages + 1):
        data = get(f"{path}{sep}per_page=100&page={page}")
        batch = data[key] if key else data
        items.extend(batch)
        if len(batch) < 100:
            break
    return items


def ts(text):
    """GitHub-Zeitstempel in UTC-datetime."""
    return datetime.fromisoformat(text.replace("Z", "+00:00")).astimezone(timezone.utc)


def iso(moment):
    return moment.strftime("%Y-%m-%dT%H:%M:%SZ") if moment else ""


def first_commit_time(previous_sha, sha, fallback):
    """Ältester Commit, der mit diesem Deployment neu in Produktion kam."""
    if previous_sha and previous_sha != sha:
        try:
            compare = get(f"/repos/{REPO}/compare/{previous_sha}...{sha}")
            dates = [ts(c["commit"]["committer"]["date"]) for c in compare.get("commits", [])]
            if dates:
                return min(dates)
        except urllib.error.HTTPError:
            pass  # z.B. nach einem Force-Push: Commit des Deployments verwenden
    return fallback


def collect_deployments(since):
    query = urllib.parse.urlencode({"branch": BRANCH, "status": "success",
                                    "created": f">={since:%Y-%m-%d}"})
    runs = get_all(f"/repos/{REPO}/actions/workflows/{WORKFLOW}/runs?{query}", key="workflow_runs")
    runs.sort(key=lambda r: r["updated_at"])
    deployments, previous_sha = [], None
    for run in runs:
        head = run.get("head_commit") or {}
        head_time = ts(head["timestamp"]) if head.get("timestamp") else ts(run["created_at"])
        deployments.append({
            "sha": run["head_sha"],
            "message": head.get("message", ""),
            "deployed_at": ts(run["updated_at"]),
            "committed_at": first_commit_time(previous_sha, run["head_sha"], head_time),
            "failed": False,
            "restored_at": None,
            "rework": False,
        })
        previous_sha = run["head_sha"]
    return deployments


def apply_incidents(deployments, since):
    query = urllib.parse.urlencode({"labels": "incident", "state": "all", "since": iso(since)})
    issues = [i for i in get_all(f"/repos/{REPO}/issues?{query}") if "pull_request" not in i]
    for issue in issues:
        text = f"{issue.get('title', '')}\n{issue.get('body') or ''}"
        shas = set(re.findall(r"\b[0-9a-f]{7,40}\b", text))
        closed = ts(issue["closed_at"]) if issue.get("closed_at") else None
        for dep in deployments:
            if any(dep["sha"].startswith(s) for s in shas):
                dep["failed"] = True
                if closed and (dep["restored_at"] is None or closed < dep["restored_at"]):
                    dep["restored_at"] = closed
            if re.search(rf"#{issue['number']}\b", dep["message"]):
                dep["rework"] = True
    return len(issues)


def main():
    since = datetime.now(timezone.utc) - timedelta(days=DAYS)
    deployments = collect_deployments(since)
    incidents = apply_incidents(deployments, since)
    out = open(sys.argv[1], "w", newline="", encoding="utf-8") if len(sys.argv) > 1 else sys.stdout
    writer = csv.writer(out, lineterminator="\n")
    writer.writerow(["deployed_at", "committed_at", "failed", "restored_at", "rework"])
    for dep in deployments:
        writer.writerow([iso(dep["deployed_at"]), iso(dep["committed_at"]),
                         "ja" if dep["failed"] else "nein", iso(dep["restored_at"]),
                         "ja" if dep["rework"] else "nein"])
    if out is not sys.stdout:
        out.close()
    print(f"{len(deployments)} Deployments aus {WORKFLOW}, {incidents} Vorfälle "
          f"(letzte {DAYS} Tage, Branch {BRANCH})", file=sys.stderr)


if __name__ == "__main__":
    main()
