from uuid import UUID

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.exercise import Exercise
from app.repositories import exercise_repository
from app.repositories import favorite_repository
from app.services.exercise_service import serialize_exercise


class ExerciseNotFoundError(Exception):
    pass


class FavoriteAlreadyExistsError(Exception):
    pass


class FavoriteNotFoundError(Exception):
    pass


def list_favorites(
    session: Session,
    user_id: UUID,
):
    exercises = favorite_repository.get_favorite_exercises(
        session=session,
        user_id=user_id,
    )

    return {
        "total": len(exercises),
        "items": [
            serialize_exercise(exercise, Exercise)
            for exercise in exercises
        ],
    }


def add_favorite(
    session: Session,
    user_id: UUID,
    exercise_id: str,
):
    normalized_exercise_id = exercise_id.strip()

    exercise = exercise_repository.get_exercise_by_id(
        session=session,
        exercise_id=normalized_exercise_id,
    )

    if exercise is None:
        raise ExerciseNotFoundError(
            "El ejercicio no existe"
        )

    existing_favorite = favorite_repository.get_favorite(
        session=session,
        user_id=user_id,
        exercise_id=normalized_exercise_id,
    )

    if existing_favorite is not None:
        raise FavoriteAlreadyExistsError(
            "El ejercicio ya está en favoritos"
        )

    try:
        return favorite_repository.create_favorite(
            session=session,
            user_id=user_id,
            exercise_id=normalized_exercise_id,
        )
    except IntegrityError as error:
        raise FavoriteAlreadyExistsError(
            "El ejercicio ya está en favoritos"
        ) from error


def remove_favorite(
    session: Session,
    user_id: UUID,
    exercise_id: str,
) -> None:
    normalized_exercise_id = exercise_id.strip()

    favorite = favorite_repository.get_favorite(
        session=session,
        user_id=user_id,
        exercise_id=normalized_exercise_id,
    )

    if favorite is None:
        raise FavoriteNotFoundError(
            "El ejercicio no está en favoritos"
        )

    favorite_repository.delete_favorite(
        session=session,
        favorite=favorite,
    )