# inventory-server

Minimal MCP server (FastMCP, stdio) over a bundled SQLite fixture.

Tools:
- `get_book_stock(isbn)`: title, stock, price in USD (stored as cents, converted once).
- `low_stock_report(threshold=5)`: books at or below the threshold.

## Run
```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
python seed.py        # optional; the server seeds on first use
python server.py
```

## Register
Copy the root `.mcp.json` into your project (adjust the path):
```json
{
  "mcpServers": {
    "inkwell-inventory": {
      "command": "python3",
      "args": ["mcp/inventory-server/server.py"]
    }
  }
}
```
