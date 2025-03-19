import asyncio
import json
import random
import uvicorn
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.staticfiles import StaticFiles
from fastapi import FastAPI, HTTPException


app = FastAPI()

# خدمة الملفات الثابتة (static)
app.mount("/", StaticFiles(directory="static", html=True), name="static")

connected_clients = set()
stocks = ["AAPL", "GOOGL", "AMZN", "MSFT"]

@app.get("/")
def home():
    return {"message": "🚀 WebSocket server is running!", "status": "healthy"}


# for test
@app.get("/crash")
async def crash():
    raise HTTPException(status_code=500, detail="Simulated Server Error")


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

@app.get("/")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=80, reload=False)
