from fastapi import APIRouter, HTTPException, Query

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
def get_exercises(
    muscle: str | None = Query(
        default=None,
        description="Músculo principal",
    ),
    search: str | None = Query(
        default=None,
        description="Texto incluido en el nombre",
    ),
    equipment: str | None = Query(
        default=None,
        description="Equipo requerido",
    ),
    body_part: str | None = Query(
        default=None,
        description="Parte general del cuerpo",
    ),
    page: int = Query(
        default=1,
        ge=1,
        description="Número de página",
    ),
    page_size: int = Query(
        default=20,
        ge=1,
        le=100,
        description="Ejercicios por página",
    ),
):
    exercises, total = exercise_service.get_exercises(
        muscle=muscle,
        search=search,
        equipment=equipment,
        body_part=body_part,
        page=page,
        page_size=page_size,
    )

    pages = (total + page_size - 1) // page_size

    return {
        "total": total,
        "page": page,
        "page_size": page_size,
        "pages": pages,
        "muscle": muscle,
        "search": search,
        "equipment": equipment,
        "body_part": body_part,
        "items": exercises,
    }

@router.get(
    "/muscles",
    response_model=OptionListResponse,
)
def get_muscles():
    muscles = exercise_service.get_muscles()

    return {
        "total": len(muscles),
        "items": muscles,
    }

@router.get(
    "/equipment",
    response_model=OptionListResponse,
)
def get_equipment():
    equipment = exercise_service.get_equipment()

    return {
        "total": len(equipment),
        "items": equipment,
    }


@router.get(
    "/body-parts",
    response_model=OptionListResponse,
)
def get_body_parts():
    body_parts = exercise_service.get_body_parts()

    return {
        "total": len(body_parts),
        "items": body_parts,
    }


@router.get(
    "/exercises/{exercise_id}",
    response_model=Exercise,
)
def get_exercise_by_id(exercise_id: str):
    exercise = exercise_service.get_exercise_by_id(exercise_id)

    if exercise is None:
        raise HTTPException(
            status_code=404,
            detail="Ejercicio no encontrado",
        )

    return exercise