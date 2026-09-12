from typing import Annotated
from app.models.user import (
    TokenResponse,
    UserCreate,
    UserLogin,
    UserResponse,
)
from app.db_models import UserModel
from app.security.dependencies import get_current_user
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.services.user_service import (
    InactiveUserError,
    InvalidCredentialsError,
    UserAlreadyExistsError,
    authenticate_user,
    register_user,
)
from app.services.user_service import (
    InactiveUserError,
    InvalidCredentialsError,
    UserAlreadyExistsError,
    authenticate_user,
    register_user,
)
from app.security.tokens import create_access_token

router = APIRouter(
    prefix="/api/v1/auth",
    tags=["Authentication"],
)


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(
    user_data: UserCreate,
    session: Annotated[Session, Depends(get_db)],
):
    try:
        return register_user(
            session=session,
            user_data=user_data,
        )
    except UserAlreadyExistsError as error:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(error),
        ) from error

@router.post(
    "/login",
    response_model=TokenResponse,
)
def login(
    login_data: UserLogin,
    session: Annotated[Session, Depends(get_db)],
):
    try:
        user = authenticate_user(
            session=session,
            login_data=login_data,
        )
    except InvalidCredentialsError as error:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(error),
            headers={"WWW-Authenticate": "Bearer"},
        ) from error
    except InactiveUserError as error:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(error),
        ) from error

    token = create_access_token(str(user.id))

    return TokenResponse(
        access_token=token,
        token_type="bearer",
    )

@router.get(
    "/me",
    response_model=UserResponse,
)
def get_me(
    current_user: Annotated[
        UserModel,
        Depends(get_current_user),
    ],
):
    return current_user