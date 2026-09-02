import json
from pathlib import Path


DATA_FILE = (
    Path(__file__).resolve().parents[2]
    / "data"
    / "exercises.json"
)


def load_exercises() -> list[dict]:
    with DATA_FILE.open(
        mode="r",
        encoding="utf-8",
    ) as file:
        return json.load(file)


exercises = load_exercises()


def get_all() -> list[dict]:
    return exercises


def get_by_id(exercise_id: str) -> dict | None:
    return next(
        (
            exercise
            for exercise in exercises
            if exercise.get("id") == exercise_id
        ),
        None,
    )