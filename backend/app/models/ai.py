from pydantic import BaseModel, Field


class PatientInfo(BaseModel):
    display_name: str
    sex: str | None = None
    age_years: int | None = None


class AiAnalyzeRequest(BaseModel):
    patient: PatientInfo
    risk_factors: dict[str, bool] = Field(default_factory=dict)
    medications: list[dict] = Field(default_factory=list)
    readings: list[dict] = Field(default_factory=list)
    computed_metrics: dict = Field(default_factory=dict)
    safety_flags: dict = Field(default_factory=dict)
    ui_locale: str = "en"
    user_question: str | None = None


class AiAnalyzeResponse(BaseModel):
    summary: str = ""
    pattern_analysis: str = ""
    contributing_factors: str = ""
    lifestyle_guidance: str = ""
    consult_recommendation: str = ""
    doctor_questions: list[str] = Field(default_factory=list)
    disclaimer: str = ""
    safety_override_applied: bool = False
    request_id: str = ""
