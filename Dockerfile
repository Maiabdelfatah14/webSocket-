FROM python:3.11-alpine

WORKDIR /app

COPY requirements.txt .
COPY main.py .
COPY static ./static

# إزالة perl-base لتقليل المخاطر الأمنية
RUN apk del perl-base || true

# تثبيت المكتبات الأساسية مع تجنب المشاكل الأمنية
RUN apk add --no-cache gcc musl-dev libffi-dev zlib-dev \
    && pip install --no-cache-dir --upgrade pip setuptools==70.0.0

# تثبيت المتطلبات
RUN pip install --no-cache-dir -r requirements.txt

# تعريف متغيرات البيئة
ENV PORT=80
EXPOSE 80

# تشغيل التطبيق
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80", "--workers", "4"]


