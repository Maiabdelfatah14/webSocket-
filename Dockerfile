FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
COPY main.py .
COPY static ./static

RUN pip install --no-cache-dir -r requirements.txt

# تعيين متغير البيئة للمنفذ
ENV PORT 80

# تعيين المنفذ الذي سيتم تشغيل التطبيق عليه
EXPOSE 80

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
