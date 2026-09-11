# TechStyle Online Shop

A fashion e-commerce app for developers. Built with Python Flask + SQLite.

## Quick Start

```bash
./run_dev.sh
```

This creates a virtual environment, installs dependencies, seeds the database, and starts the dev server.

Open http://localhost:5000

### Manual setup (without the script)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python seed_data.py
python app.py
```

## Deploy to Production

```bash
./deploy.sh
```

Make sure `~/.ssh/techstyle_prod.pem` exists and the server IP in `deploy.sh` is correct.

## Features

- Product catalogue (20 items, multiple categories)
- Session-based shopping cart
- Checkout (no real payment)
- Admin panel at /admin

## Notes

- Database is stored at `/tmp/techstyle.db`
- Run `python seed_data.py` again to reset products (activate venv first)
- Admin panel has no login — it's fine for now
