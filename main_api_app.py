from fastapi import Depends, FastAPI
from pydantic import BaseModel, BaseSettings
from fastapi.responses import JSONResponse
from fastapi.security.api_key import APIKey
import os
import auth

class Item(BaseModel):
    message: str
    to: str
    from_: str
    timeToLifeSec: int

class Settings(BaseSettings):
    openapi_url: str = ""

settings = Settings()
APP_VERSION = os.getenv('APP_VERSION')
INSTANCE_ID = os.getenv('HOSTNAME')
headers_json = { "X-App-Version": APP_VERSION, "X-Container-Instance-Id": INSTANCE_ID }

app = FastAPI(openapi_url=settings.openapi_url)

@app.post("/DevOps")
async def create_item(item: Item, api_key: APIKey = Depends(auth.get_api_key)):
    response_message = f"Hello {item.to} your messaje will be send"
    content = { "message": response_message }
    return JSONResponse(content=content, headers=headers_json)

@app.api_route("/{path_name:path}")
async def catch_all():
    content = "ERROR"
    return JSONResponse(content=content, headers=headers_json)
