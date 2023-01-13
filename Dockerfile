FORM 3.8.16-slim

WORKDIR /usr/src/app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY main_api_app.py

CMD [ "uvicorn", "./main_api_app:app", "--reload" ]