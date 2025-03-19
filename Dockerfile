FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
COPY main.py .
COPY static ./static

RUN apt-get update && apt-get install --no-install-recommends -y \
    && pip install --upgrade setuptools \
    && rm -rf /var/lib/apt/lists/*  
RUN pip install --no-cache-dir -r requirements.txt

ENV PORT=80
EXPOSE 80
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
