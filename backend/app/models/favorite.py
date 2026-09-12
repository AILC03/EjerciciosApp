from datetime import datetime

from pydantic import BaseModel, ConfigDict

from app.models.exercise import Exercise


class FavoriteResponse(BaseModel):
    exercise_id: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class FavoriteListResponse(BaseModel):
    total: int
    items: list[Exercise]