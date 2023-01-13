FROM python:3.8.16-slim

ARG APP_VERSION=00000000
ENV APP_VERSION=$APP_VERSION

# ARG UID=1000
# ARG GID=1000

# RUN groupadd -g "${GID}" python && \
#     useradd --create-home --no-log-init -u "${UID}" -g "${GID}" python

# USER python

WORKDIR /usr/src/app

EXPOSE 8000

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY main_api_app.py ./

CMD [ "uvicorn", "main_api_app:app", "--host", "0.0.0.0", "--port", "8000", "--reload" ]