from app.config import DATASET_MEDIA_BASE_URL
from app.repositories import exercise_repository


def add_media_urls(exercise: dict) -> dict:
    exercise_with_urls = exercise.copy()

    image_path = exercise.get("image")
    gif_path = exercise.get("gif_url")

    if image_path:
        exercise_with_urls["image"] = (
            f"{DATASET_MEDIA_BASE_URL}/{image_path}"
        )

    if gif_path:
        exercise_with_urls["gif_url"] = (
            f"{DATASET_MEDIA_BASE_URL}/{gif_path}"
        )

    return exercise_with_urls


def get_exercises(
    muscle: str | None = None,
    search: str | None = None,
    equipment: str | None = None,
    body_part: str | None = None,
    page: int = 1,
    page_size: int = 20,
) -> tuple[list[dict], int]:
    exercises = exercise_repository.get_all()

    if muscle:
        normalized_muscle = muscle.strip().casefold()

        exercises = [
            exercise
            for exercise in exercises
            if exercise.get("target", "").strip().casefold()
            == normalized_muscle
        ]

    if search:
        normalized_search = search.strip().casefold()

        exercises = [
            exercise
            for exercise in exercises
            if normalized_search
            in exercise.get("name", "").casefold()
        ]

    if equipment:
        normalized_equipment = equipment.strip().casefold()

        exercises = [
            exercise
            for exercise in exercises
            if exercise.get("equipment", "").strip().casefold()
            == normalized_equipment
        ]

    if body_part:
        normalized_body_part = body_part.strip().casefold()

        exercises = [
            exercise
            for exercise in exercises
            if exercise.get("body_part", "").strip().casefold()
            == normalized_body_part
        ]

    total = len(exercises)

    start = (page - 1) * page_size
    end = start + page_size

    paginated_exercises = exercises[start:end]

    exercises_with_media_urls = [
        add_media_urls(exercise)
        for exercise in paginated_exercises
    ]

    return exercises_with_media_urls, total

def get_unique_values(field: str) -> list[str]:
    exercises = exercise_repository.get_all()

    return sorted(
        {
            exercise.get(field, "").strip()
            for exercise in exercises
            if exercise.get(field)
        }
    )


def get_muscles() -> list[str]:
    return get_unique_values("target")


def get_equipment() -> list[str]:
    return get_unique_values("equipment")


def get_body_parts() -> list[str]:
    return get_unique_values("body_part")


def get_exercise_by_id(exercise_id: str) -> dict | None:
    exercise = exercise_repository.get_by_id(exercise_id)

    if exercise is None:
        return None

    return add_media_urls(exercise)