"""Builds the system and user prompts for the AI analyze endpoint."""

from app.models.ai import AiAnalyzeRequest

SYSTEM_PROMPT = """You are a health data assistant that analyzes blood pressure readings.

STRICT RULES — you MUST follow all of these:
1. You are NOT a doctor. Never diagnose, prescribe, or suggest specific medications.
2. Never tell the user to stop, start, or adjust any medication.
3. Never provide emergency medical advice or protocols.
4. Never claim the user has a specific medical condition based on readings.
5. Always recommend consulting a healthcare provider for any medical decisions.
6. Respond in the language specified by the ui_locale field.
7. Be empathetic, clear, and educational.
8. Focus on patterns, trends, lifestyle factors, and general wellness guidance.
9. If safety_flags.has_red_flag is true, do NOT provide any analysis — return only a safety override message.

RESPONSE FORMAT — return JSON with exactly these fields:
{
  "summary": "Brief overview of the readings (2-3 sentences)",
  "pattern_analysis": "Analysis of trends and patterns in the data",
  "contributing_factors": "How risk factors and lifestyle may relate to the readings",
  "lifestyle_guidance": "General, non-prescriptive lifestyle suggestions",
  "consult_recommendation": "Recommendation about discussing findings with a doctor",
  "doctor_questions": ["List of questions the user could ask their doctor"]
}"""


def build_user_prompt(req: AiAnalyzeRequest) -> str:
    """Build the user-facing prompt from the analyze request."""
    parts: list[str] = []

    parts.append(f"Patient: {req.patient.display_name}")
    if req.patient.sex:
        parts.append(f"Sex: {req.patient.sex}")
    if req.patient.age_years:
        parts.append(f"Age: {req.patient.age_years}")

    if req.risk_factors:
        active = [k for k, v in req.risk_factors.items() if v]
        if active:
            parts.append(f"Active risk factors: {', '.join(active)}")

    if req.medications:
        med_names = [
            m.get("name", "unknown")
            for m in req.medications
            if m.get("active", True)
        ]
        if med_names:
            parts.append(f"Current medications: {', '.join(med_names)}")

    if req.computed_metrics:
        m = req.computed_metrics
        metrics = []
        for key in [
            "avg_systolic",
            "avg_diastolic",
            "avg_pulse",
            "std_dev_systolic",
            "trend_slope_systolic",
            "pct_above_threshold",
            "reading_count",
        ]:
            if key in m:
                metrics.append(f"{key}={m[key]}")
        if metrics:
            parts.append(f"Computed metrics: {', '.join(metrics)}")

    if req.readings:
        parts.append(f"Recent readings ({len(req.readings)}):")
        for r in req.readings[:10]:  # Cap to keep prompt short
            line = f"  {r.get('taken_at', '?')}: {r.get('systolic', '?')}/{r.get('diastolic', '?')}"
            if r.get("pulse"):
                line += f" pulse={r['pulse']}"
            if r.get("category"):
                line += f" ({r['category']})"
            parts.append(line)
        if len(req.readings) > 10:
            parts.append(f"  ... and {len(req.readings) - 10} more")

    parts.append(f"Safety flags: {req.safety_flags}")
    parts.append(f"UI locale: {req.ui_locale}")

    if req.user_question:
        parts.append(f"User question: {req.user_question}")

    return "\n".join(parts)
