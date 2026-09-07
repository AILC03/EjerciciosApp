from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.db_models import ExerciseModel


def get_exercises(
    session: Session,
    muscle: str | None,
    page: int,
    page_size: int,
) -> tuple[list[ExerciseModel], int]:
    filters = []

    if muscle:
        filters.append(
            func.lower(ExerciseModel.target) == muscle.strip().lower()
        )

    count_statement = (
        select(func.count())
        .select_from(ExerciseModel)
        .where(*filters)
    )

    total = session.scalar(count_statement) or 0

    statement = (
        select(ExerciseModel)
        .where(*filters)
        .order_by(ExerciseModel.name)
        .offset((page - 1) * page_size)
        .limit(page_size)
    )

    exercises = list(session.scalars(statement).all())

    return exercises, total


def get_exercise_by_id(
    session: Session,
    exercise_id: str,
) -> ExerciseModel | None:
    return session.get(ExerciseModel, exercise_id)


def get_muscles(session: Session) -> list[str]:
    return _get_distinct_values(session, ExerciseModel.target)


def get_equipment(session: Session) -> list[str]:
    return _get_distinct_values(session, ExerciseModel.equipment)


def get_body_parts(session: Session) -> list[str]:
    return _get_distinct_values(session, ExerciseModel.body_part)


def _get_distinct_values(session: Session, column) -> list[str]:
    statement = (
        select(column)
        .where(column.is_not(None), column != "")
        .distinct()
        .order_by(column)
    )
    return list(session.scalars(statement).all())
