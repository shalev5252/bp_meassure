import firebase_admin
from firebase_admin import auth, credentials
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.config import settings
from app.logging_config import get_logger

logger = get_logger(__name__)

_firebase_initialised = False
_bearer_scheme = HTTPBearer()


def _ensure_firebase() -> None:
    """Initialise Firebase Admin SDK once."""
    global _firebase_initialised
    if _firebase_initialised:
        return
    try:
        firebase_admin.get_app()
    except ValueError:
        if settings.firebase_project_id:
            firebase_admin.initialize_app(
                options={"projectId": settings.firebase_project_id},
            )
        else:
            # Use default credentials (GOOGLE_APPLICATION_CREDENTIALS env var)
            firebase_admin.initialize_app()
    _firebase_initialised = True


def verify_firebase_token(token: str) -> dict:
    """Verify a Firebase ID token and return the decoded claims."""
    _ensure_firebase()
    try:
        return auth.verify_id_token(token)
    except Exception as exc:
        logger.warning("Token verification failed: %s", type(exc).__name__)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        ) from exc


async def get_current_user_id(
    cred: HTTPAuthorizationCredentials = Depends(_bearer_scheme),
) -> str:
    """FastAPI dependency – extracts and verifies the Firebase user ID."""
    claims = verify_firebase_token(cred.credentials)
    uid: str = claims.get("uid", "")
    if not uid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token missing uid claim",
        )
    return uid
