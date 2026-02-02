from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    BUCKET_NAME: str = "ezcaptions-outputs"

    class Config:
        env_file = ".env"
