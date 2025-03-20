import asyncio
import json
import random
import uvicorn
import jwt
import datetime
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.staticfiles import StaticFiles

app = FastAPI()

SECRET_KEY = "your_secret_key"

# دالة لإنشاء توكن JWT
def create_jwt_token(user_id: str):
    payload = {
        "sub": user_id,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=1)
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
    return token

# دالة للتحقق من صحة التوكن
def verify_jwt(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return payload["sub"]
    except jwt.ExpiredSignatureError:
        raise ValueError("انتهت صلاحية التوكن")
    except jwt.InvalidTokenError:
        raise ValueError("توكن غير صالح")

# ويب سوكيت للمصادقة والتحقق من التوكن
@app.websocket("/ws/auth")
async def websocket_auth(websocket: WebSocket):
    await websocket.accept()
    try:
        token = await websocket.receive_text()  # استلام التوكن من العميل بعد الاتصال
        user_id = verify_jwt(token)  # التحقق من التوكن
        await websocket.send_text(f"مرحبًا {user_id}، تم التحقق من التوكن بنجاح!")
    except ValueError as e:
        await websocket.send_text(str(e))
        await websocket.close(code=1008)  # 1008 = فشل المصادقة

# ويب سوكيت لبث بيانات الأسهم
connected_clients = set()
stocks = ["AAPL", "GOOGL", "AMZN", "MSFT"]

@app.websocket("/ws/stocks")
async def websocket_stocks(websocket: WebSocket):
    await websocket.accept()
    connected_clients.add(websocket)
    
    try:
        while True:
            if connected_clients:
                stock_data = {stock: round(random.uniform(100, 1500), 2) for stock in stocks}
                message = json.dumps(stock_data)
                await asyncio.gather(*(client.send_text(message) for client in connected_clients))
            await asyncio.sleep(2)
    except WebSocketDisconnect:
        connected_clients.discard(websocket)

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
