from fastapi import FastAPI
from . import schemas, services

app = FastAPI(title="EzCaptions API", description="Simple API to create Captions", version="1.0.0")


@app.get("/")
async def root() -> bool:
    return True


@app.post("/burn")
async def burnn(request: schemas.BurnVideoRequest):
    return services.burn_and_upload(request.video, request.ass)
