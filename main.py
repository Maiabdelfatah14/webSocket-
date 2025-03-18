import asyncio
import json
import random
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.staticfiles import StaticFiles


app = FastAPI()

# خدمة الملفات الثابتة (static)
app.mount("/", StaticFiles(directory="static", html=True), name="static")


app = FastAPI()

connected_clients = set()
stocks = ["AAPL", "GOOGL", "AMZN", "MSFT"]

@app.get("/")
def home():
    return {"message": "🚀 WebSocket server is running!"}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    connected_clients.add(websocket)

    try:
        while True:
            stock_data = {stock: round(random.uniform(100, 1500), 2) for stock in stocks}
            message = json.dumps(stock_data)

            for client in connected_clients:
                await client.send_text(message)

            await asyncio.sleep(2)
    except WebSocketDisconnect:
        connected_clients.remove(websocket)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=80)

@app.get("/health")
def health():
    return {"status": "ok"}

