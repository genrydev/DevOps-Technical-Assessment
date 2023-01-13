from fastapi import FastAPI
from pydantic import BaseModel

class Item(BaseModel):
    message: str
    to: str
    from_: str
    timeToLifeSec: int

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

# @app.get("/items/{item_id}")
# def read_item(item_id: int, q: str = None):
#     return {"item_id": item_id, "q": q}

@app.post("/DevOps")
async def create_item(item: Item):
    item_name = item["to"]
    response_message = f"Hello {item_name} your messaje will be send"
    return {
        "message": response_message
    }

# {
# “message” : “This is a test”,
# “to”: “Juan Perez”,
# “from”: “Rita Asturia”,
# “timeToLifeSec” : 45
# }