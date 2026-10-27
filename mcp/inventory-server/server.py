#!/usr/bin/env python3
"""Inkwell Books inventory MCP server (FastMCP, stdio)."""
import sqlite3
from pathlib import Path

from mcp.server.fastmcp import FastMCP

from seed import DB, seed

mcp = FastMCP("inkwell-inventory")


def _con() -> sqlite3.Connection:
    if not Path(DB).exists():
        seed()
    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row
    return con


@mcp.tool()
def get_book_stock(isbn: str) -> dict:
    """Return title, stock and price (USD) for one ISBN-13, or an error if unknown."""
    con = _con()
    try:
        row = con.execute("SELECT * FROM books WHERE isbn = ?", (isbn,)).fetchone()
    finally:
        con.close()
    if row is None:
        return {"error": f"unknown isbn {isbn}"}
    return {
        "isbn": row["isbn"],
        "title": row["title"],
        "stock": row["stock"],
        "price_usd": row["price_cents"] / 100.0,  # amount scale: stored in cents
    }


@mcp.tool()
def low_stock_report(threshold: int = 5) -> list[dict]:
    """List books with stock at or below `threshold`, lowest stock first."""
    con = _con()
    try:
        rows = con.execute(
            "SELECT isbn, title, stock FROM books WHERE stock <= ? ORDER BY stock, title",
            (threshold,),
        ).fetchall()
    finally:
        con.close()
    return [dict(r) for r in rows]


if __name__ == "__main__":
    mcp.run()
