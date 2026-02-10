"""Integration tests for the API endpoints."""

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest_asyncio.fixture
async def client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c


@pytest.mark.asyncio
async def test_health(client: AsyncClient):
    resp = await client.get("/health")
    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "ok"
    assert "version" in data


@pytest.mark.asyncio
async def test_supported_locales(client: AsyncClient):
    resp = await client.get("/meta/supported-locales")
    assert resp.status_code == 200
    data = resp.json()
    assert "locales" in data
    codes = [loc["code"] for loc in data["locales"]]
    assert "en" in codes
    assert "he" in codes


@pytest.mark.asyncio
async def test_analyze_requires_auth(client: AsyncClient):
    """POST /v1/ai/analyze without a token should return 403."""
    resp = await client.post(
        "/v1/ai/analyze",
        json={
            "patient": {"display_name": "Test"},
            "ui_locale": "en",
        },
    )
    assert resp.status_code == 403


@pytest.mark.asyncio
async def test_analyze_invalid_token(client: AsyncClient):
    """POST /v1/ai/analyze with an invalid token should return 401."""
    resp = await client.post(
        "/v1/ai/analyze",
        json={
            "patient": {"display_name": "Test"},
            "ui_locale": "en",
        },
        headers={"Authorization": "Bearer invalid-token"},
    )
    assert resp.status_code == 401


@pytest.mark.asyncio
async def test_health_returns_request_id(client: AsyncClient):
    """Responses should include X-Request-ID header."""
    resp = await client.get("/health")
    assert "x-request-id" in resp.headers


@pytest.mark.asyncio
async def test_health_echoes_request_id(client: AsyncClient):
    """If X-Request-ID is sent, the same ID should be echoed back."""
    resp = await client.get(
        "/health", headers={"X-Request-ID": "test-123"}
    )
    assert resp.headers["x-request-id"] == "test-123"
