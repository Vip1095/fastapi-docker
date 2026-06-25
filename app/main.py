import os
from fastapi import FastAPI, HTTPException

app = FastAPI(title="My Docker App", version="1.0.0")

# Read DB config from environment variables (injected by Docker Compose)
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "mydb")
APP_ENV = os.getenv("APP_ENV", "development")

ITEMS = {
    1: {"id": 1, "name": "Laptop", "price": 999.99},
    2: {"id": 2, "name": "Mouse", "price": 29.99},
    3: {"id": 3, "name": "Keyboard", "price": 79.99},
}


@app.get("/")
def root():
    return {
        "message": "Welcome to FastAPI on Docker!",
        "environment": APP_ENV,
        "database_host": DB_HOST,
        "docs": "/docs",
    }


@app.get("/health")
def health_check():
    return {"status": "healthy", "env": APP_ENV}


@app.get("/items")
def list_items():
    return list(ITEMS.values())


@app.get("/items/{item_id}")
def get_item(item_id: int):
    if item_id not in ITEMS:
        raise HTTPException(status_code=404, detail=f"Item {item_id} not found")
    return ITEMS[item_id]
