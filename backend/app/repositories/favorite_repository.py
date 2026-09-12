from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db_models import ExerciseModel, FavoriteModel


def get_favorite(
    session: Session,
    user_id: UUID,
    exercise_id: str,
) -> FavoriteModel | None:
    return session.get(
        FavoriteModel,
        (user_id, exercise_id),
    )


def get_favorite_exercises(
    session: Session,
    user_id: UUID,
) -> list[ExerciseModel]:
    statement = (
        select(ExerciseModel)
        .join(
            FavoriteModel,
            FavoriteModel.exercise_id == ExerciseModel.id,
        )
        .where(FavoriteModel.user_id == user_id)
        .order_by(FavoriteModel.created_at.desc())
    )

    return list(session.scalars(statement).all())


def create_favorite(
    session: Session,
    user_id: UUID,
    exercise_id: str,
) -> FavoriteModel:
    favorite = FavoriteModel(
        user_id=user_id,
        exercise_id=exercise_id,
    )

    session.add(favorite)

    try:
        session.commit()
    except Exception:
        session.rollback()
        raise

    session.refresh(favorite)

    return favorite


def delete_favorite(
    session: Session,
    favorite: FavoriteModel,
) -> None:
    session.delete(favorite)

    try:
        session.commit()
    except Exception:
        session.rollback()
        raise