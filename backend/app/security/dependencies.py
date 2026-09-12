from typing import Annotated
from uuid import UUID

from fastapi import Depends, HTTPException, status
from fastapi.security import (
    HTTPAuthorizationCredentials,
    HTTPBearer,
)
from sqlalchemy.orm import Session

from app.database import get_db
from app.db_models import UserModel
from app.repositories import user_repository
from app.security.tokens import (
    InvalidAccessTokenError,
    decode_access_token,
)


bearer_scheme = HTTPBearer(auto_error=False)


def unauthorized_error() -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudo validar la sesión",
        headers={"WWW-Authenticate": "Bearer"},
    )


def get_current_user(
    credentials: Annotated[
        HTTPAuthorizationCredentials | None,
        Depends(bearer_scheme),
    ],
    session: Annotated[Session, Depends(get_db)],
) -> UserModel:
    if credentials is None:
        raise unauthorized_error()

    try:
        subject = decode_access_token(credentials.credentials)
        user_id = UUID(subject)
    except (InvalidAccessTokenError, ValueError) as error:
        raise unauthorized_error() from error

    user = user_repository.get_user_by_id(
        session=session,
        user_id=user_id,
    )

    if user is None or not user.is_active:
        raise unauthorized_error()

    return user