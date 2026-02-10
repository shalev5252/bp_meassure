"""Safety rules for the AI service."""

from app.models.ai import AiAnalyzeRequest, AiAnalyzeResponse

DISCLAIMERS = {
    "en": (
        "This is not medical advice. The information provided is for educational "
        "purposes only. Always consult your healthcare provider before making any "
        "changes to your treatment or lifestyle."
    ),
    "he": (
        "זו אינה ייעוץ רפואי. המידע המוסק מיועד למטרות חינוכיות בלבד. "
        "התייעצו תמיד עם ספק שירותי הבריאות שלכם לפני ביצוע שינויים "
        "בטיפול או באורח החיים."
    ),
}

SAFETY_OVERRIDE_MESSAGES = {
    "en": (
        "Your recent blood pressure reading is critically high. "
        "AI analysis is unavailable in this situation. "
        "Please seek medical attention immediately and consult your doctor."
    ),
    "he": (
        "מדידת לחץ הדם האחרונה שלך גבוהה באופן קריטי. "
        "ניתוח AI אינו זמין במצב זה. "
        "אנא פנה לטיפול רפואי מיידי והתייעץ עם הרופא שלך."
    ),
}


def has_bp_red_flag(req: AiAnalyzeRequest) -> bool:
    """Check if the request contains a BP red flag."""
    return bool(req.safety_flags.get("has_bp_red_flag") or req.safety_flags.get("has_red_flag"))


def build_safety_override_response(
    req: AiAnalyzeRequest, request_id: str
) -> AiAnalyzeResponse:
    """Build a response when safety override blocks AI analysis."""
    locale = req.ui_locale if req.ui_locale in SAFETY_OVERRIDE_MESSAGES else "en"
    msg = SAFETY_OVERRIDE_MESSAGES[locale]
    disclaimer = DISCLAIMERS.get(locale, DISCLAIMERS["en"])

    return AiAnalyzeResponse(
        summary=msg,
        pattern_analysis="",
        contributing_factors="",
        lifestyle_guidance="",
        consult_recommendation=msg,
        doctor_questions=[],
        disclaimer=disclaimer,
        safety_override_applied=True,
        request_id=request_id,
    )


def get_disclaimer(locale: str) -> str:
    """Get the localized disclaimer."""
    return DISCLAIMERS.get(locale, DISCLAIMERS["en"])
