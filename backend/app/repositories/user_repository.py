from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db_models import UserModel


def get_user_by_email(
    session: Session,
    email: str,
) -> UserModel | None:
    statement = select(UserModel).where(
        UserModel.email == email
    )

    return session.scalar(statement)


def get_user_by_id(
    session: Session,
    user_id: UUID,
) -> UserModel | None:
    return session.get(UserModel, user_id)


def create_user(
    session: Session,
    email: str,
    password_hash: str,
) -> UserModel:
    user = UserModel(
        email=email,
        password_hash=password_hash,
    )

    session.add(user)

    try:
        session.commit()
    except Exception:
        session.rollback()
        raise

    session.refresh(user)

    return user