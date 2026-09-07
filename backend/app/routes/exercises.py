from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.exercise import (
    Exercise,
    ExerciseListResponse,
    OptionListResponse,
)
from app.services import exercise_service


router = APIRouter(
    prefix="/api/v1",
    tags=["Exercises"],
)


@router.get(
    "/exercises",
    response_model=ExerciseListResponse,
)
def read_exercises(
    session: Annotated[Session, Depends(get_db)],
    muscle: str | None = None,
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
):
    return exercise_service.list_exercises(
        session=session,
        muscle=muscle,
        page=page,
        page_size=page_size,
    )


@router.get(
    "/muscles",
    response_model=OptionListResponse,
)
def get_muscles(
    session: Annotated[Session, Depends(get_db)],
):
    muscles = exercise_service.get_muscles(session)

    return {
        "total": len(muscles),
        "items": muscles,
    }


@router.get(
    "/equipment",
    response_model=OptionListResponse,
)
def get_equipment(
    session: Annotated[Session, Depends(get_db)],
):
    equipment = exercise_service.get_equipment(session)

    return {
        "total": len(equipment),
        "items": equipment,
    }


@router.get(
    "/body-parts",
    response_model=OptionListResponse,
)
def get_body_parts(
    session: Annotated[Session, Depends(get_db)],
):
    body_parts = exercise_service.get_body_parts(session)

    return {
        "total": len(body_parts),
        "items": body_parts,
    }


@router.get(
    "/exercises/{exercise_id}",
    response_model=Exercise,
)
def get_exercise_by_id(
    exercise_id: str,
    session: Annotated[Session, Depends(get_db)],
):
    exercise = exercise_service.get_exercise_by_id(session, exercise_id)

    if exercise is None:
        raise HTTPException(
            status_code=404,
            detail="Ejercicio no encontrado",
        )

    return exercise
