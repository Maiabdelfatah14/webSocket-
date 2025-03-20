# استخدم صورة Python الرسمية (صورة خفيفة الوزن)
FROM python:3.11-slim

# تحديد مجلد العمل داخل الحاوية
WORKDIR /app

# نسخ متطلبات المشروع أولاً لتسريع الـ Caching
COPY requirements.txt .

# تثبيت المكتبات المطلوبة مع تقليل الحجم
RUN pip install --no-cache-dir -r requirements.txt

# نسخ باقي ملفات المشروع
COPY main.py .
COPY static ./static

# إضافة مستخدم غير الجذر لأمان أعلى
RUN useradd -m appuser
USER appuser

# تعيين المنفذ البيئي للتطبيق
ENV PORT=80
EXPOSE 80

# تشغيل التطبيق باستخدام Uvicorn مع 4 عمال لتحسين الأداء
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80", "--workers", "4"]

