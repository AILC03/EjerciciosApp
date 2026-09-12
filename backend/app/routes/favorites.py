from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.db_models import UserModel
from app.models.favorite import FavoriteListResponse, FavoriteResponse
from app.security.dependencies import get_current_user
from app.services import favorite_service


router = APIRouter(
    prefix="/api/v1/favorites",
    tags=["Favorites"],
)


@router.get(
    "",
    response_model=FavoriteListResponse,
)
def get_favorites(
    session: Annotated[Session, Depends(get_db)],
    current_user: Annotated[
        UserModel,
        Depends(get_current_user),
    ],
):
    return favorite_service.list_favorites(
        session=session,
        user_id=current_user.id,
    )


@router.post(
    "/{exercise_id}",
    response_model=FavoriteResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_favorite(
    exercise_id: str,
    session: Annotated[Session, Depends(get_db)],
    current_user: Annotated[
        UserModel,
        Depends(get_current_user),
    ],
):
    try:
        return favorite_service.add_favorite(
            session=session,
            user_id=current_user.id,
            exercise_id=exercise_id,
        )
    except favorite_service.ExerciseNotFoundError as error:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(error),
        ) from error
    except favorite_service.FavoriteAlreadyExistsError as error:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(error),
        ) from error


@router.delete(
    "/{exercise_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_model=None,
)
def delete_favorite(
    exercise_id: str,
    session: Annotated[Session, Depends(get_db)],
    current_user: Annotated[
        UserModel,
        Depends(get_current_user),
    ],
) -> Response:
    try:
        favorite_service.remove_favorite(
            session=session,
            user_id=current_user.id,
            exercise_id=exercise_id,
        )
    except favorite_service.FavoriteNotFoundError as error:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(error),
        ) from error

    return Response(status_code=status.HTTP_204_NO_CONTENT)