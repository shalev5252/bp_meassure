from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from app.config import settings
from app.logging_config import setup_logging
from app.middleware.request_id import RequestIdMiddleware
from app.routers import ai, meta

setup_logging()

limiter = Limiter(key_func=get_remote_address, default_limits=[settings.rate_limit])

app = FastAPI(
    title=settings.app_title,
    version=settings.app_version,
)

# Middleware (order matters: outermost first)
app.add_middleware(RequestIdMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Rate limiting
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Routers
app.include_router(meta.router)
app.include_router(ai.router)


@app.get("/health")
async def health() -> dict:
    return {"status": "ok", "version": settings.app_version}
