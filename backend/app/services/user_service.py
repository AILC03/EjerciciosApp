from sqlalchemy.orm import Session
from app.models.user import UserCreate, UserLogin
from app.repositories import user_repository
from app.security.passwords import (
    hash_password,
    verify_password,
)
from app.models.user import UserCreate
from app.repositories import user_repository
from app.security.passwords import hash_password

class InvalidCredentialsError(Exception):
    pass


class InactiveUserError(Exception):
    pass

class UserAlreadyExistsError(Exception):
    pass


def register_user(
    session: Session,
    user_data: UserCreate,
):
    normalized_email = str(user_data.email).strip().lower()

    existing_user = user_repository.get_user_by_email(
        session=session,
        email=normalized_email,
    )

    if existing_user is not None:
        raise UserAlreadyExistsError(
            "Ya existe un usuario con ese correo"
        )

    hashed_password = hash_password(user_data.password)

    return user_repository.create_user(
        session=session,
        email=normalized_email,
        password_hash=hashed_password,
    )
def authenticate_user(
    session: Session,
    login_data: UserLogin,
):
    normalized_email = str(login_data.email).strip().lower()

    user = user_repository.get_user_by_email(
        session=session,
        email=normalized_email,
    )

    if user is None:
        raise InvalidCredentialsError(
            "Correo o contraseña incorrectos"
        )

    if not verify_password(
        login_data.password,
        user.password_hash,
    ):
        raise InvalidCredentialsError(
            "Correo o contraseña incorrectos"
        )

    if not user.is_active:
        raise InactiveUserError(
            "La cuenta está desactivada"
        )

    return user