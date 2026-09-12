from uuid import uuid4

from fastapi.testclient import TestClient
from sqlalchemy import delete

from app.database import SessionLocal
from app.db_models import UserModel
from app.main import app


client = TestClient(app)


def delete_test_user(email: str) -> None:
    with SessionLocal() as session:
        session.execute(
            delete(UserModel).where(UserModel.email == email)
        )
        session.commit()


def register_and_get_headers(
    email: str,
    password: str,
) -> dict[str, str]:
    register_response = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": password,
        },
    )

    assert register_response.status_code == 201

    login_response = client.post(
        "/api/v1/auth/login",
        json={
            "email": email,
            "password": password,
        },
    )

    assert login_response.status_code == 200

    token = login_response.json()["access_token"]

    return {
        "Authorization": f"Bearer {token}",
    }


def get_existing_exercise_id() -> str:
    response = client.get(
        "/api/v1/exercises",
        params={
            "page": 1,
            "page_size": 1,
        },
    )

    assert response.status_code == 200

    return response.json()["items"][0]["id"]


def test_favorites_require_authentication():
    exercise_id = get_existing_exercise_id()

    list_response = client.get("/api/v1/favorites")
    create_response = client.post(
        f"/api/v1/favorites/{exercise_id}"
    )
    delete_response = client.delete(
        f"/api/v1/favorites/{exercise_id}"
    )

    assert list_response.status_code == 401
    assert create_response.status_code == 401
    assert delete_response.status_code == 401


def test_complete_favorites_flow():
    email = f"favorites-{uuid4()}@example.com"
    password = "MiClaveSegura123"

    try:
        headers = register_and_get_headers(
            email=email,
            password=password,
        )
        exercise_id = get_existing_exercise_id()

        initial_response = client.get(
            "/api/v1/favorites",
            headers=headers,
        )

        assert initial_response.status_code == 200
        assert initial_response.json() == {
            "total": 0,
            "items": [],
        }

        create_response = client.post(
            f"/api/v1/favorites/{exercise_id}",
            headers=headers,
        )

        assert create_response.status_code == 201
        assert create_response.json()["exercise_id"] == exercise_id
        assert create_response.json()["created_at"]

        duplicate_response = client.post(
            f"/api/v1/favorites/{exercise_id}",
            headers=headers,
        )

        assert duplicate_response.status_code == 409

        list_response = client.get(
            "/api/v1/favorites",
            headers=headers,
        )

        assert list_response.status_code == 200

        favorites = list_response.json()

        assert favorites["total"] == 1
        assert len(favorites["items"]) == 1
        assert favorites["items"][0]["id"] == exercise_id
        assert favorites["items"][0]["image"].startswith("https://")

        missing_exercise_response = client.post(
            "/api/v1/favorites/does-not-exist",
            headers=headers,
        )

        assert missing_exercise_response.status_code == 404

        delete_response = client.delete(
            f"/api/v1/favorites/{exercise_id}",
            headers=headers,
        )

        assert delete_response.status_code == 204
        assert delete_response.content == b""

        final_response = client.get(
            "/api/v1/favorites",
            headers=headers,
        )

        assert final_response.status_code == 200
        assert final_response.json() == {
            "total": 0,
            "items": [],
        }

        second_delete_response = client.delete(
            f"/api/v1/favorites/{exercise_id}",
            headers=headers,
        )

        assert second_delete_response.status_code == 404

    finally:
        delete_test_user(email)