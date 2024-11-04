FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Запуск бота в виртуальной среде 
CMD ["myenv/bin/python", "VPNBOT.py"]  # Замените 'myenv'  на  имя  вашей  среды
