from datetime import datetime, timezone
import json
from pathlib import Path

from sqlalchemy import select

from app.database import SessionLocal
from app.db_models import ExerciseModel


JSON_PATH = Path(__file__).resolve().parents[1] / "data" / "exercises.json"


def load_exercises() -> list[dict]:
    with JSON_PATH.open(encoding="utf-8") as file:
        data = json.load(file)

    if not isinstance(data, list):
        raise ValueError("El archivo exercises.json debe contener una lista")

    return data


def normalize_list(value) -> list[str]:
    if value is None:
        return []

    if isinstance(value, list):
        return [str(item).strip() for item in value if str(item).strip()]

    if isinstance(value, str):
        return [value.strip()] if value.strip() else []

    return []


def normalize_translations(value) -> dict[str, str | list[str]]:
    if not isinstance(value, dict):
        return {}

    return {
        str(language): content
        for language, content in value.items()
        if isinstance(content, (str, list))
    }


def create_exercise(item: dict) -> ExerciseModel:
    return ExerciseModel(
        id=str(item.get("id", "")).strip(),
        name=str(item.get("name", "")).strip(),
        category=str(item.get("category", "")).strip(),
        body_part=str(
            item.get("body_part")
            or item.get("bodyPart")
            or ""
        ).strip(),
        equipment=str(item.get("equipment", "")).strip(),
        instructions=normalize_translations(item.get("instructions")),
        instruction_steps=normalize_translations(
            item.get("instruction_steps")
            or item.get("instructionSteps")
        ),
        muscle_group=str(
            item.get("muscle_group")
            or item.get("muscleGroup")
            or ""
        ).strip(),
        secondary_muscles=normalize_list(
            item.get("secondary_muscles")
            or item.get("secondaryMuscles")
        ),
        target=str(item.get("target", "")).strip(),
        media_id=str(
            item.get("media_id")
            or item.get("mediaId")
            or ""
        ).strip(),
        image=str(item.get("image", "")).strip(),
        gif_url=str(
            item.get("gif_url")
            or item.get("gifUrl")
            or ""
        ).strip(),
        attribution=item.get("attribution"),
        created_at=datetime.now(timezone.utc)
    )


def seed_exercises() -> None:
    exercises = load_exercises()

    inserted = 0
    updated = 0
    skipped = 0

    with SessionLocal() as session:
        existing_exercises = {
            exercise.id: exercise
            for exercise in session.scalars(select(ExerciseModel)).all()
        }

        for item in exercises:
            exercise_id = str(item.get("id", "")).strip()

            if not exercise_id:
                print("Ejercicio omitido: no tiene ID")
                skipped += 1
                continue

            existing = existing_exercises.get(exercise_id)

            if existing is not None:
                instructions = normalize_translations(item.get("instructions"))
                instruction_steps = normalize_translations(
                    item.get("instruction_steps")
                    or item.get("instructionSteps")
                )

                if (
                    existing.instructions != instructions
                    or existing.instruction_steps != instruction_steps
                ):
                    existing.instructions = instructions
                    existing.instruction_steps = instruction_steps
                    updated += 1
                else:
                    skipped += 1
                continue

            exercise = create_exercise(item)
            session.add(exercise)
            existing_exercises[exercise_id] = exercise
            inserted += 1

        session.commit()

    print(f"Registros encontrados: {len(exercises)}")
    print(f"Registros insertados: {inserted}")
    print(f"Registros actualizados: {updated}")
    print(f"Registros omitidos: {skipped}")


if __name__ == "__main__":
    seed_exercises()
