from fastapi import APIRouter, Depends, Request

from app.middleware.firebase_auth import get_current_user_id
from app.middleware.request_id import request_id_var
from app.models.ai import AiAnalyzeRequest, AiAnalyzeResponse
from app.services.ai_service import analyze_readings

router = APIRouter(prefix="/v1/ai", tags=["ai"])


@router.post("/analyze", response_model=AiAnalyzeResponse)
async def analyze(
    request: Request,
    body: AiAnalyzeRequest,
    user_id: str = Depends(get_current_user_id),
) -> AiAnalyzeResponse:
    rid = request_id_var.get() or ""
    return await analyze_readings(body, request_id=rid)
