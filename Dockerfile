FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
COPY main.py .
COPY static ./static

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8800

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8800", "--reload"]
