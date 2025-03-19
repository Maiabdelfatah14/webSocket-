FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
COPY main.py .
COPY static ./static

RUN apt update && apt upgrade -y && apt install -y \
    build-essential libffi-dev zlib1g-dev \
    && apt remove --purge -y perl-base \
    && apt autoremove -y && apt clean \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir --upgrade setuptools==70.0.0  
RUN pip install --no-cache-dir -r requirements.txt

ENV PORT=80
EXPOSE 80
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80", "--workers", "4"]
