import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "artisan_hub.db")

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            tags TEXT,
            maker_story TEXT,
            material_cost REAL,
            hours_worked REAL,
            cost_floor REAL,
            buyer_price REAL,
            category TEXT,
            image_url TEXT,
            status TEXT DEFAULT 'Active',
            ready_stock INTEGER DEFAULT 1,
            lead_time_days INTEGER DEFAULT 3,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    conn.close()

def get_all_products():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, description, tags, maker_story, material_cost, hours_worked, cost_floor, buyer_price, category, image_url, status, ready_stock, lead_time_days, created_at FROM products ORDER BY id DESC")
    rows = cursor.fetchall()
    conn.close()
    
    products = []
    for r in rows:
        products.append({
            "id": r[0],
            "title": r[1],
            "description": r[2],
            "tags": r[3].split(",") if r[3] else [],
            "maker_story": r[4],
            "material_cost": r[5],
            "hours_worked": r[6],
            "cost_floor": r[7],
            "buyer_price": r[8],
            "category": r[9],
            "image_url": r[10],
            "status": r[11],
            "ready_stock": r[12],
            "lead_time_days": r[13],
            "created_at": r[14]
        })
    return products

def save_product(data: dict):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    tags_str = ",".join(data.get("tags", [])) if isinstance(data.get("tags"), list) else data.get("tags", "")
    cursor.execute('''
        INSERT INTO products (title, description, tags, maker_story, material_cost, hours_worked, cost_floor, buyer_price, category, image_url, status, ready_stock, lead_time_days)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        data.get("title", "Untitled Craft"),
        data.get("description", ""),
        tags_str,
        data.get("maker_story", ""),
        data.get("material_cost", 0.0),
        data.get("hours_worked", 0.0),
        data.get("cost_floor", 0.0),
        data.get("buyer_price", 0.0),
        data.get("category", "Textile"),
        data.get("image_url", ""),
        data.get("status", "Active"),
        data.get("ready_stock", 1),
        data.get("lead_time_days", 3)
    ))
    item_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return item_id
