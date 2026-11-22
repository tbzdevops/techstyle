"""DORA-Metriken aus einem Deployment-Protokoll berechnen.

Ein fertiges Werkzeug: Ihr müsst hier nichts programmieren. Eure Arbeit ist,
die Daten richtig aufzubereiten, das Ergebnis nachzuprüfen und einzuordnen.

Aufruf:
    python dora.py data/woche.csv --tage 7
    python dora.py data/team-kasse.csv --tage 28

Das Protokoll ist eine CSV-Datei mit einer Zeile pro Deployment in Produktion:

    deployed_at    Zeitpunkt des Deployments (ISO 8601, z.B. 2026-11-02T09:15:00Z)
    committed_at   Zeitpunkt des ersten Commits der ausgelieferten Änderung
    failed         ja, wenn das Deployment sofort eingreifen musste (Rollback, Hotfix)
    restored_at    Zeitpunkt, an dem der Shop wieder normal lief (nur bei failed = ja)
    rework         ja, wenn das Deployment ungeplant war, ausgelöst durch einen Vorfall

Weitere Spalten (z.B. umgebung oder notiz) stören nicht, dora.py ignoriert
sie. Dasselbe Format nutzen das Spielprotokoll aus Nimbus und im Projekt
scripts/dora_collect.py. Darum funktioniert dieses Werkzeug für alle drei.
"""

import argparse
import csv
import statistics
from datetime import datetime, timedelta

STUFEN = ("Elite", "Hoch", "Mittel", "Niedrig")


# ---------------------------------------------------------------------------
# Protokoll einlesen und Hilfsfunktionen
# ---------------------------------------------------------------------------

def parse_time(text):
    """ISO-Zeitstempel in ein datetime-Objekt umwandeln, leer ergibt None."""
    text = (text or "").strip()
    if not text:
        return None
    return datetime.fromisoformat(text.replace("Z", "+00:00"))


def parse_bool(text):
    """'ja', 'true', '1' oder 'yes' ergibt True, alles andere False."""
    return (text or "").strip().lower() in ("ja", "true", "1", "yes")


def load(path):
    """Protokoll lesen. Ergebnis: Liste von Dicts, sortiert nach deployed_at."""
    with open(path, newline="", encoding="utf-8") as handle:
        rows = [
            {
                "deployed_at": parse_time(row["deployed_at"]),
                "committed_at": parse_time(row["committed_at"]),
                "failed": parse_bool(row.get("failed")),
                "restored_at": parse_time(row.get("restored_at")),
                "rework": parse_bool(row.get("rework")),
            }
            for row in csv.DictReader(handle)
        ]
    return sorted(rows, key=lambda d: d["deployed_at"])


def hours(delta: timedelta) -> float:
    """Zeitspanne in Stunden."""
    return delta.total_seconds() / 3600


def period_days(deployments):
    """Kalendertage vom ersten bis zum letzten Deployment, beide mitgezählt."""
    if not deployments:
        return 0
    first = min(d["deployed_at"] for d in deployments).date()
    last = max(d["deployed_at"] for d in deployments).date()
    return (last - first).days + 1


# ---------------------------------------------------------------------------
# Die fünf Metriken und die Einordnung nach der Kursskala
# ---------------------------------------------------------------------------

def deployment_frequency(deployments, days):
    """Durchsatz: Deployments pro Tag im Messzeitraum von «days» Tagen."""
    if not deployments or not days:
        return 0
    return len(deployments) / days


def lead_time_hours(deployments):
    """Durchsatz: Median von (deployed_at - committed_at) in Stunden.

    Zeilen ohne committed_at (z.B. ein Feature Flag ohne Commit) zählen
    nicht mit. Ohne solche Deployments: None.
    """
    times = [hours(d["deployed_at"] - d["committed_at"])
             for d in deployments if d["committed_at"]]
    return statistics.median(times) if times else None


def change_failure_rate(deployments):
    """Instabilität: Anteil der Deployments mit failed = ja (0.0 bis 1.0).

    Ohne Deployments: None.
    """
    if not deployments:
        return None
    return sum(1 for d in deployments if d["failed"]) / len(deployments)


def recovery_time_hours(deployments):
    """Durchsatz: Failed Deployment Recovery Time.

    Median von (restored_at - deployed_at) in Stunden, nur über
    fehlgeschlagene Deployments, die ein restored_at haben.
    Gibt es keine solchen Deployments: None.
    """
    times = [hours(d["restored_at"] - d["deployed_at"])
             for d in deployments if d["failed"] and d["restored_at"]]
    return statistics.median(times) if times else None


def rework_rate(deployments):
    """Instabilität: Anteil der Deployments mit rework = ja (0.0 bis 1.0).

    Ohne Deployments: None.
    """
    if not deployments:
        return None
    return sum(1 for d in deployments if d["rework"]) / len(deployments)


def classify(metric, value):
    """Einordnung eines Werts nach der Kursskala.

    metric ist "frequency", "lead_time", "change_failure_rate" oder "recovery".
    Rückgabe: "Elite", "Hoch", "Mittel" oder "Niedrig"; bei value None: "–".

    Kursskala (vereinfacht, angelehnt an DORA 2024):

        frequency (pro Tag)     Elite >= 1      Hoch >= 1/7     Mittel >= 1/30
        lead_time (Stunden)     Elite < 24      Hoch < 168      Mittel < 720
        change_failure_rate     Elite <= 0.05   Hoch <= 0.10    Mittel <= 0.20
        recovery (Stunden)      Elite < 1       Hoch < 24       Mittel < 168

    Alles, was keine dieser Bedingungen erfüllt, ist "Niedrig".
    """
    if value is None:
        return "–"
    if metric == "frequency":
        limits = (value >= 1, value >= 1 / 7, value >= 1 / 30)
    elif metric == "lead_time":
        limits = (value < 24, value < 168, value < 720)
    elif metric == "change_failure_rate":
        limits = (value <= 0.05, value <= 0.10, value <= 0.20)
    elif metric == "recovery":
        limits = (value < 1, value < 24, value < 168)
    else:
        raise ValueError(f"Unbekannte Metrik: {metric}")
    for stufe, erfuellt in zip(STUFEN, limits):
        if erfuellt:
            return stufe
    return STUFEN[-1]


# ---------------------------------------------------------------------------
# Bericht als Markdown-Tabelle
# ---------------------------------------------------------------------------

def _fmt(value, unit):
    if value is None:
        return "–"
    if unit == "%":
        return f"{value * 100:.0f} %"
    return f"{value:.1f} {unit}"


def report(deployments, days):
    """Markdown-Tabelle mit allen fünf Metriken und ihrer Stufe."""
    freq = deployment_frequency(deployments, days)
    lead = lead_time_hours(deployments)
    cfr = change_failure_rate(deployments)
    recovery = recovery_time_hours(deployments)
    rework = rework_rate(deployments)
    lines = [
        f"Messzeitraum: {days} Tage, {len(deployments)} Deployments",
        "",
        "| Metrik | Wert | Stufe |",
        "|--------|------|-------|",
        f"| Deployment Frequency | {_fmt(freq, 'pro Tag')} | {classify('frequency', freq)} |",
        f"| Lead Time for Changes | {_fmt(lead, 'h')} | {classify('lead_time', lead)} |",
        f"| Change Failure Rate | {_fmt(cfr, '%')} | {classify('change_failure_rate', cfr)} |",
        f"| Failed Deployment Recovery Time | {_fmt(recovery, 'h')} | {classify('recovery', recovery)} |",
        f"| Rework Rate | {_fmt(rework, '%')} | – |",
    ]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="DORA-Metriken aus einem Deployment-Protokoll")
    parser.add_argument("csv", help="Pfad zum Protokoll, z.B. data/team-kasse.csv")
    parser.add_argument("--tage", type=int, help="Länge des Messzeitraums in Tagen")
    args = parser.parse_args()
    deployments = load(args.csv)
    days = args.tage or period_days(deployments) or 1
    print(report(deployments, days))


if __name__ == "__main__":
    main()
