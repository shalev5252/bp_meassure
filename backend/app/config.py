import os


class Settings:
    """Application configuration loaded from environment variables."""

    app_title: str = "BP Monitor API"
    app_version: str = "1.0.0"

    # OpenAI
    openai_api_key: str = os.getenv("OPENAI_API_KEY", "")
    openai_model: str = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

    # Firebase
    firebase_project_id: str = os.getenv("FIREBASE_PROJECT_ID", "")

    # Rate limiting
    rate_limit: str = os.getenv("RATE_LIMIT", "10/minute")

    # CORS
    cors_origins: list[str] = os.getenv(
        "CORS_ORIGINS", "*"
    ).split(",")


settings = Settings()
