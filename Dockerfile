FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
COPY main.py .
COPY static ./static

RUN pip install --no-cache-dir -r requirements.txt

# تعيين متغير البيئة للمنفذ
ENV PORT 80

# تعيين المنافذ التي سيتم كشفها من الحاوية
EXPOSE 80 8800

# تشغيل التطبيق على المنفذ 80 فقط
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
