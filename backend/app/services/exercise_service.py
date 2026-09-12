from math import ceil

from sqlalchemy.orm import Session

from app.config import DATASET_MEDIA_BASE_URL
from app.models.exercise import Exercise, ExerciseSummary
from app.repositories import exercise_repository


def _absolute_media_url(path: str) -> str:
    if not path or path.startswith(("http://", "https://")):
        return path

    return f"{DATASET_MEDIA_BASE_URL.rstrip('/')}/{path.lstrip('/')}"


def serialize_exercise(exercise, schema):
    data = schema.model_validate(exercise).model_dump()
    data["image"] = _absolute_media_url(data["image"])
    data["gif_url"] = _absolute_media_url(data["gif_url"])
    return data


def list_exercises(
    session: Session,
    muscle: str | None,
    page: int,
    page_size: int,
):
    exercises, total = exercise_repository.get_exercises(
        session=session,
        muscle=muscle,
        page=page,
        page_size=page_size,
    )

    return {
        "items": [
            serialize_exercise(exercise, ExerciseSummary)
            for exercise in exercises
        ],
        "total": total,
        "page": page,
        "page_size": page_size,
        "pages": ceil(total / page_size),
        "muscle": muscle,
        "search": None,
        "equipment": None,
        "body_part": None,
    }


def get_exercise_by_id(session: Session, exercise_id: str):
    exercise = exercise_repository.get_exercise_by_id(session, exercise_id)

    if exercise is None:
        return None

    return serialize_exercise(exercise, Exercise)


def get_muscles(session: Session) -> list[str]:
    return exercise_repository.get_muscles(session)


def get_equipment(session: Session) -> list[str]:
    return exercise_repository.get_equipment(session)


def get_body_parts(session: Session) -> list[str]:
    return exercise_repository.get_body_parts(session)
