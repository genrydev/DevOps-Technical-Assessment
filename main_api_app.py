from fastapi import Depends, FastAPI, Security, HTTPException
from pydantic import BaseModel, BaseSettings
from fastapi.responses import JSONResponse
from fastapi.security.api_key import APIKeyHeader
from starlette.status import HTTP_403_FORBIDDEN
import os

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

api_key = os.getenv('API_KEY')
api_key_header = APIKeyHeader(name="X-Parse-REST-API-Key", auto_error=False)

async def get_api_key(api_key_header: str = Security(api_key_header)):
    if api_key_header == api_key:
        return api_key_header
    else:
        raise HTTPException(
            status_code=HTTP_403_FORBIDDEN, detail="Could not validate API KEY"
        )

app = FastAPI(openapi_url=settings.openapi_url)

@app.post("/DevOps", dependencies=[Depends(get_api_key)])
async def create_item(item: Item):
    response_message = f"Hello {item.to} your messaje will be send"
    content = { "message": response_message }
    return JSONResponse(content=content, headers=headers_json)

@app.api_route("/{path_name:path}")
async def catch_all():
    content = "ERROR"
    return JSONResponse(content=content, headers=headers_json)
