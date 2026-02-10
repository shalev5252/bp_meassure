from fastapi import APIRouter

router = APIRouter(prefix="/meta", tags=["meta"])

SUPPORTED_LOCALES = [
    {"code": "en", "name": "English", "direction": "ltr"},
    {"code": "he", "name": "עברית", "direction": "rtl"},
]


@router.get("/supported-locales")
async def supported_locales() -> dict:
    return {"locales": SUPPORTED_LOCALES}
