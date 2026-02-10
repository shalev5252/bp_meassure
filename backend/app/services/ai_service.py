"""AI analysis service — orchestrates prompt building, OpenAI call, and response parsing."""

import json

from openai import AsyncOpenAI

from app.config import settings
from app.logging_config import get_logger
from app.models.ai import AiAnalyzeRequest, AiAnalyzeResponse
from app.services.prompt_builder import SYSTEM_PROMPT, build_user_prompt
from app.services.safety import (
    build_safety_override_response,
    get_disclaimer,
    has_bp_red_flag,
)

logger = get_logger(__name__)

_client: AsyncOpenAI | None = None


def _get_client() -> AsyncOpenAI:
    global _client
    if _client is None:
        _client = AsyncOpenAI(api_key=settings.openai_api_key)
    return _client


# Words that indicate the AI is trying to diagnose — we filter these out.
_DIAGNOSTIC_PHRASES = [
    "you have",
    "you are diagnosed",
    "i diagnose",
    "your diagnosis is",
    "you should stop taking",
    "you should start taking",
    "increase your dosage",
    "decrease your dosage",
    "call 911",
    "call emergency",
    "go to the emergency room",
]


def _filter_content(text: str) -> str:
    """Remove or flag any diagnostic language that slipped through."""
    lower = text.lower()
    for phrase in _DIAGNOSTIC_PHRASES:
        if phrase in lower:
            logger.warning("Filtered diagnostic phrase: %s", phrase)
            text = text.replace(phrase, "[removed]")
            # Case-insensitive replacement
            import re
            text = re.sub(re.escape(phrase), "[removed]", text, flags=re.IGNORECASE)
    return text


def _parse_response(raw: str, request_id: str, locale: str) -> AiAnalyzeResponse:
    """Parse the LLM response JSON into our response model."""
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        logger.warning("Failed to parse AI JSON response, using raw text")
        return AiAnalyzeResponse(
            summary=_filter_content(raw),
            disclaimer=get_disclaimer(locale),
            request_id=request_id,
        )

    return AiAnalyzeResponse(
        summary=_filter_content(data.get("summary", "")),
        pattern_analysis=_filter_content(data.get("pattern_analysis", "")),
        contributing_factors=_filter_content(data.get("contributing_factors", "")),
        lifestyle_guidance=_filter_content(data.get("lifestyle_guidance", "")),
        consult_recommendation=_filter_content(data.get("consult_recommendation", "")),
        doctor_questions=[
            _filter_content(q) for q in data.get("doctor_questions", [])
        ],
        disclaimer=get_disclaimer(locale),
        safety_override_applied=False,
        request_id=request_id,
    )


async def analyze_readings(
    req: AiAnalyzeRequest, *, request_id: str = ""
) -> AiAnalyzeResponse:
    """Run AI analysis on the given readings, respecting safety rules."""

    # Safety override — block AI for BP red flags.
    if has_bp_red_flag(req):
        logger.info("Safety override applied for request %s", request_id)
        return build_safety_override_response(req, request_id)

    user_prompt = build_user_prompt(req)
    logger.info(
        "AI analyze: locale=%s, readings=%d, request_id=%s",
        req.ui_locale,
        len(req.readings),
        request_id,
    )

    client = _get_client()
    response = await client.chat.completions.create(
        model=settings.openai_model,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt},
        ],
        response_format={"type": "json_object"},
        temperature=0.3,
        max_tokens=1500,
    )

    raw = response.choices[0].message.content or ""
    return _parse_response(raw, request_id, req.ui_locale)
