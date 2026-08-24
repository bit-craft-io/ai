# from pydantic_settings import BaseSettings
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict

# config.py から見た .env の場所を指定
ENV_FILE_PATH = Path(__file__).resolve().parent.parent / ".env"

class Settings(BaseSettings):
    voicevox_url: str = "http://localhost:9999"

    dify_base_url: str = "http://localhost/v1"
    dify_api_key: str = ""
    dify_user_id: str = "ws-user"
    dify_state_endpoint: str = ""  # 任意: 定期監視(push_loop)用エンドポイント。空なら無効
    dify_timeout_sec: int = 30

    websocket_port: int = 8765

    voicevox_speaker_id: int = 1
    voicevox_speed_scale: float = 1.0

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()