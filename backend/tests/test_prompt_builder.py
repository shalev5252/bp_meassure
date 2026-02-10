"""Unit tests for the prompt builder."""

from app.models.ai import AiAnalyzeRequest, PatientInfo
from app.services.prompt_builder import build_user_prompt


def test_basic_prompt(sample_request: AiAnalyzeRequest):
    prompt = build_user_prompt(sample_request)
    assert "Test Patient" in prompt
    assert "Sex: male" in prompt
    assert "Age: 45" in prompt


def test_risk_factors_in_prompt(sample_request: AiAnalyzeRequest):
    prompt = build_user_prompt(sample_request)
    assert "diabetes_type2" in prompt
    assert "obesity_bmi30" in prompt
    # Inactive risk factor should not appear in active list
    assert "smoker_current" not in prompt.split("Active risk factors:")[1].split("\n")[0]


def test_medications_in_prompt(sample_request: AiAnalyzeRequest):
    prompt = build_user_prompt(sample_request)
    assert "Amlodipine" in prompt


def test_readings_in_prompt(sample_request: AiAnalyzeRequest):
    prompt = build_user_prompt(sample_request)
    assert "135/88" in prompt
    assert "142/92" in prompt


def test_user_question_in_prompt(sample_request: AiAnalyzeRequest):
    prompt = build_user_prompt(sample_request)
    assert "morning readings higher" in prompt


def test_prompt_without_optional_fields():
    req = AiAnalyzeRequest(
        patient=PatientInfo(display_name="Minimal"),
        ui_locale="en",
    )
    prompt = build_user_prompt(req)
    assert "Minimal" in prompt
    assert "UI locale: en" in prompt
    # No optional fields should appear
    assert "Sex:" not in prompt
    assert "Age:" not in prompt
    assert "Active risk factors" not in prompt


def test_computed_metrics_in_prompt(sample_request: AiAnalyzeRequest):
    prompt = build_user_prompt(sample_request)
    assert "avg_systolic=138.3" in prompt
    assert "pct_above_threshold=33.3" in prompt


def test_readings_capped_at_10():
    """Prompt should include at most 10 readings inline."""
    readings = [
        {"systolic": 130 + i, "diastolic": 80, "taken_at": f"2025-01-{i+1:02d}T08:00:00"}
        for i in range(15)
    ]
    req = AiAnalyzeRequest(
        patient=PatientInfo(display_name="Many Readings"),
        readings=readings,
        ui_locale="en",
    )
    prompt = build_user_prompt(req)
    assert "... and 5 more" in prompt
