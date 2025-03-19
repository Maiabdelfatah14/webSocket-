FROM python:3.11-alpine

WORKDIR /app

COPY requirements.txt .
COPY main.py .
COPY static ./static

# تثبيت setuptools وتحديث النظام
RUN apk update && apk add --no-cache gcc musl-dev libffi-dev \
    && pip install --upgrade setuptools==70.0.0

# تثبيت المتطلبات
RUN pip install --no-cache-dir -r requirements.txt

ENV PORT=80
EXPOSE 80

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
