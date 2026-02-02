from pydantic import BaseModel


class BurnVideoRequest(BaseModel):
    video: str
    ass: str
