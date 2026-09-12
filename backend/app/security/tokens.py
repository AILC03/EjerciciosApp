from datetime import datetime, timedelta, timezone

import jwt
from jwt.exceptions import InvalidTokenError

from app.config import settings


class InvalidAccessTokenError(Exception):
    pass


def create_access_token(subject: str) -> str:
    expires_at = datetime.now(timezone.utc) + timedelta(
        minutes=settings.access_token_expire_minutes
    )

    payload = {
        "sub": subject,
        "exp": expires_at,
    }

    return jwt.encode(
        payload,
        settings.jwt_secret_key,
        algorithm=settings.jwt_algorithm,
    )


def decode_access_token(token: str) -> str:
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret_key,
            algorithms=[settings.jwt_algorithm],
        )
    except InvalidTokenError as error:
        raise InvalidAccessTokenError(
            "Token inválido o expirado"
        ) from error

    subject = payload.get("sub")

    if not isinstance(subject, str) or not subject:
        raise InvalidAccessTokenError(
            "El token no contiene un usuario válido"
        )

    return subject