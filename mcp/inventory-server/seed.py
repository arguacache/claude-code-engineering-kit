#!/usr/bin/env python3
"""Create the bundled SQLite fixture (inventory.sqlite) for the inventory MCP server."""
import sqlite3
import sys
from pathlib import Path

DB = Path(__file__).resolve().parent / "inventory.sqlite"

BOOKS = [
    ("9780000000011", "The Quiet Margin", "A. Reyes", 1899, 14),
    ("9780000000028", "Ink and Ledger", "M. Okafor", 2450, 3),
    ("9780000000035", "Salt Roads", "L. Brandt", 1600, 0),
    ("9780000000042", "Paper Lanterns", "S. Ito", 2199, 7),
    ("9780000000059", "A Field Guide to Fog", "J. Moreau", 2799, 2),
]


def seed(path: Path = DB) -> Path:
    path.unlink(missing_ok=True)
    con = sqlite3.connect(path)
    con.execute("""CREATE TABLE books (
        isbn TEXT PRIMARY KEY, title TEXT NOT NULL, author TEXT NOT NULL,
        price_cents INTEGER NOT NULL, stock INTEGER NOT NULL)""")
    con.executemany("INSERT INTO books VALUES (?,?,?,?,?)", BOOKS)
    con.commit()
    con.close()
    return path


if __name__ == "__main__":
    print(f"seeded {seed()}", file=sys.stderr)
