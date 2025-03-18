import asyncio
import json
import random
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.staticfiles import StaticFiles

app = FastAPI()

# خدمة الملفات الثابتة (static)
app.mount("/", StaticFiles(directory="static", html=True), name="static")

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
            if connected_clients:  # التأكد من أن هناك عملاء متصلين قبل الإرسال
                stock_data = {stock: round(random.uniform(100, 1500), 2) for stock in stocks}
                message = json.dumps(stock_data)
                
                await asyncio.gather(*(client.send_text(message) for client in connected_clients))
            
            await asyncio.sleep(2)
    except WebSocketDisconnect:
        connected_clients.discard(websocket)  # استخدام discard لتجنب الخطأ إذا لم يكن موجودًا

@app.get("/health")
def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=80)
