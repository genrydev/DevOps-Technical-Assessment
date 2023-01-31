from fastapi import FastAPI
from pydantic import BaseModel, BaseSettings
from fastapi.responses import JSONResponse
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

app = FastAPI(openapi_url=settings.openapi_url)

@app.post("/DevOps")
async def create_item(item: Item):
    response_message = f"Hello {item.to} your messaje will be send"
    content = { "message": response_message }
    return JSONResponse(content=content, headers=headers_json)

@app.get("/")
def create_item():
    return JSONResponse(content={ "ok": "ok" })

# @app.api_route("/{path_name:path}")
# async def catch_all():
#     content = "ERROR"
#     return JSONResponse(content=content, headers=headers_json)

# {
# “message” : “This is a test”,
# “to”: “Juan Perez”,
# “from”: “Rita Asturia”,
# “timeToLifeSec” : 45
# }