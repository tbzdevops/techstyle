# TechStyle Online Shop

A fashion e-commerce app for developers. Built with Python Flask + SQLite.

## Quick Start

```bash
pip install -r requirements.txt
python seed_data.py
python app.py
```

Open http://localhost:5000

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
- Run `python seed_data.py` again to reset products
- Admin panel has no login — it's fine for now
