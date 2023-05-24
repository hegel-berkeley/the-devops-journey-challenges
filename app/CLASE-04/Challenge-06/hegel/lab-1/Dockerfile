#Imagen que voy a utilizar como base
FROM python:3.8.16-alpine

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY src .

EXPOSE 8000

CMD ["python3", "./app.py"]