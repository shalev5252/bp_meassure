"""Unit tests for safety rules."""

from app.models.ai import AiAnalyzeRequest, PatientInfo
from app.services.safety import (
    build_safety_override_response,
    get_disclaimer,
    has_bp_red_flag,
)


def test_red_flag_detected(red_flag_request: AiAnalyzeRequest):
    assert has_bp_red_flag(red_flag_request) is True


def test_no_red_flag(sample_request: AiAnalyzeRequest):
    assert has_bp_red_flag(sample_request) is False


def test_red_flag_alternate_key():
    """Supports both 'has_bp_red_flag' and 'has_red_flag' keys."""
    req = AiAnalyzeRequest(
        patient=PatientInfo(display_name="Alt"),
        safety_flags={"has_red_flag": True},
        ui_locale="en",
    )
    assert has_bp_red_flag(req) is True


def test_safety_override_response_en(red_flag_request: AiAnalyzeRequest):
    resp = build_safety_override_response(red_flag_request, "req-123")
    assert resp.safety_override_applied is True
    assert resp.request_id == "req-123"
    assert "critically high" in resp.summary
    assert "medical advice" in resp.disclaimer.lower()


def test_safety_override_response_he(hebrew_red_flag_request: AiAnalyzeRequest):
    resp = build_safety_override_response(hebrew_red_flag_request, "req-456")
    assert resp.safety_override_applied is True
    assert "קריטי" in resp.summary
    assert "רפואי" in resp.disclaimer


def test_disclaimer_en():
    d = get_disclaimer("en")
    assert "medical advice" in d.lower()


def test_disclaimer_he():
    d = get_disclaimer("he")
    assert "רפואי" in d


def test_disclaimer_fallback():
    d = get_disclaimer("fr")
    assert d == get_disclaimer("en")


def test_no_red_flag_empty_flags():
    req = AiAnalyzeRequest(
        patient=PatientInfo(display_name="Empty"),
        safety_flags={},
        ui_locale="en",
    )
    assert has_bp_red_flag(req) is False
