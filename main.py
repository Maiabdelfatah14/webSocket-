import uvicorn
import asyncio
import random
import json
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.staticfiles import StaticFiles
from starlette.responses import FileResponse

app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/favicon.ico")
async def favicon():
    return FileResponse("static/favicon.ico")

stocks = ["AAPL", "GOOGL", "AMZN", "MSFT", "TSLA"]
connected_clients = set()

@app.get("/")
def home():
    return {"message": "WebSocket server is running!"}

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
    uvicorn.run("main:app", host="0.0.0.0", port=8800, reload=True)
