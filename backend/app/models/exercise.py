from datetime import datetime

from pydantic import BaseModel, ConfigDict


class Exercise(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    category: str
    body_part: str
    equipment: str
    instructions: dict[str, str | list[str]]
    instruction_steps: dict[str, list[str]] | list[str]
    muscle_group: str
    secondary_muscles: list[str]
    target: str
    media_id: str
    image: str
    gif_url: str
    attribution: str
    created_at: datetime

class ExerciseSummary(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    body_part: str
    target: str
    muscle_group: str
    equipment: str
    image: str
    gif_url: str

class ExerciseListResponse(BaseModel):
    total: int
    page: int
    page_size: int
    pages: int
    muscle: str | None
    search: str | None
    equipment: str | None
    body_part: str | None
    items: list[ExerciseSummary]

class OptionListResponse(BaseModel):
    total: int
    items: list[str]
