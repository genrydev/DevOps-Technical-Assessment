FROM python:3.8.16-slim

WORKDIR /usr/src/app

EXPOSE 8000

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY main_api_app.py ./

CMD [ "uvicorn", "main_api_app:app", "--host", "0.0.0.0", "--port", "8000", "--reload" ]