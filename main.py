import asyncio
import json
import random
import uvicorn
import jwt
import datetime
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException, Query
from fastapi.staticfiles import StaticFiles
from typing import Optional

app = FastAPI()

SECRET_KEY = "your_secret_key"
ALGORITHM = "HS256"

# إنشاء JWT
def create_jwt_token(user_id: str):
    payload = {
        "sub": user_id,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=1)
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

# التحقق من JWT
def verify_jwt(token: str) -> str:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload["sub"]
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

connected_clients = set()
clients_lock = asyncio.Lock()  # قفل لحماية العمليات التعاونية
stocks = ["AAPL", "GOOGL", "AMZN", "MSFT"]

@app.websocket("/ws/stocks")
async def websocket_stocks(websocket: WebSocket):
    await websocket.accept()
    
    try:
        # استلام التوكن بعد الاتصال مباشرة
        token = await websocket.receive_text()
        user_id = verify_jwt(token)  # التحقق من صحة التوكن
        
        await websocket.send_text(f"Welcome {user_id}, you are now connected to stock updates.")
        
        # إضافة العميل إلى القائمة
        async with clients_lock:
            connected_clients.add(websocket)
        
        # إرسال تحديثات الأسهم بشكل مستمر
        while True:
            async with clients_lock:
                if connected_clients:
                    stock_data = {stock: round(random.uniform(100, 1500), 2) for stock in stocks}
                    message = json.dumps(stock_data)
                    await asyncio.gather(*(client.send_text(message) for client in connected_clients))
            await asyncio.sleep(2)

    except (WebSocketDisconnect, HTTPException):
        async with clients_lock:
            connected_clients.discard(websocket)
        await websocket.close(code=1008)  # إغلاق الاتصال عند حدوث خطأ أو فصل العميل

# نقطة نهاية لفحص حالة الخادم
@app.get("/")
async def health_check():
    return {"status": "healthy"}

# نقطة نهاية لاختبار تعطل الخادم
@app.get("/crash")
async def crash():
    raise HTTPException(status_code=500, detail="خطأ تجريبي في الخادم")

# خدمة الملفات الثابتة (تغيير المسار إلى /static)
app.mount("/static", StaticFiles(directory="static", html=True), name="static")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=80, reload=False)
