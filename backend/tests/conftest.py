import pytest
from httpx import ASGITransport, AsyncClient

from app.models.ai import AiAnalyzeRequest, PatientInfo


@pytest.fixture
def sample_request() -> AiAnalyzeRequest:
    """A typical AI analyze request for testing."""
    return AiAnalyzeRequest(
        patient=PatientInfo(
            display_name="Test Patient",
            sex="male",
            age_years=45,
        ),
        risk_factors={
            "diabetes_type2": True,
            "smoker_current": False,
            "obesity_bmi30": True,
        },
        medications=[
            {
                "name": "Amlodipine",
                "dose": "5mg",
                "frequency": "daily",
                "active": True,
            },
        ],
        readings=[
            {
                "systolic": 135,
                "diastolic": 88,
                "pulse": 72,
                "taken_at": "2025-01-15T08:30:00",
                "category": "highNormal",
            },
            {
                "systolic": 142,
                "diastolic": 92,
                "pulse": 76,
                "taken_at": "2025-01-16T08:30:00",
                "category": "grade1",
            },
            {
                "systolic": 138,
                "diastolic": 87,
                "pulse": 70,
                "taken_at": "2025-01-17T08:30:00",
                "category": "highNormal",
            },
        ],
        computed_metrics={
            "avg_systolic": 138.3,
            "avg_diastolic": 89.0,
            "avg_pulse": 72.7,
            "std_dev_systolic": 2.9,
            "trend_slope_systolic": 0.5,
            "pct_above_threshold": 33.3,
            "reading_count": 3,
        },
        safety_flags={"has_bp_red_flag": False},
        ui_locale="en",
        user_question="Why are my morning readings higher?",
    )


@pytest.fixture
def red_flag_request() -> AiAnalyzeRequest:
    """A request with a BP red flag."""
    return AiAnalyzeRequest(
        patient=PatientInfo(display_name="Crisis Patient"),
        readings=[
            {
                "systolic": 185,
                "diastolic": 125,
                "taken_at": "2025-01-15T08:30:00",
                "category": "crisis",
            },
        ],
        safety_flags={"has_bp_red_flag": True},
        ui_locale="en",
    )


@pytest.fixture
def hebrew_red_flag_request() -> AiAnalyzeRequest:
    """A red flag request in Hebrew locale."""
    return AiAnalyzeRequest(
        patient=PatientInfo(display_name="מטופל"),
        readings=[
            {
                "systolic": 190,
                "diastolic": 130,
                "taken_at": "2025-01-15T08:30:00",
                "category": "crisis",
            },
        ],
        safety_flags={"has_bp_red_flag": True},
        ui_locale="he",
    )


@pytest.fixture
def async_client():
    """Async test client for the FastAPI app (for integration tests)."""
    from app.main import app

    async def _make():
        transport = ASGITransport(app=app)
        return AsyncClient(transport=transport, base_url="http://test")

    return _make
