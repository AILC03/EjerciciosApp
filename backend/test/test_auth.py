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


def test_complete_authentication_flow():
    email = f"test-{uuid4()}@example.com"
    password = "MiClaveSegura123"

    try:
        register_response = client.post(
            "/api/v1/auth/register",
            json={
                "email": email,
                "password": password,
            },
        )

        assert register_response.status_code == 201

        registered_user = register_response.json()

        assert registered_user["email"] == email
        assert registered_user["is_active"] is True
        assert "password" not in registered_user
        assert "password_hash" not in registered_user

        duplicate_response = client.post(
            "/api/v1/auth/register",
            json={
                "email": email,
                "password": password,
            },
        )

        assert duplicate_response.status_code == 409

        login_response = client.post(
            "/api/v1/auth/login",
            json={
                "email": email,
                "password": password,
            },
        )

        assert login_response.status_code == 200

        token_data = login_response.json()

        assert token_data["token_type"] == "bearer"
        assert token_data["access_token"]

        me_response = client.get(
            "/api/v1/auth/me",
            headers={
                "Authorization": (
                    f"Bearer {token_data['access_token']}"
                )
            },
        )

        assert me_response.status_code == 200
        assert me_response.json()["email"] == email

        invalid_login_response = client.post(
            "/api/v1/auth/login",
            json={
                "email": email,
                "password": "ContraseñaIncorrecta123",
            },
        )

        assert invalid_login_response.status_code == 401

    finally:
        delete_test_user(email)


def test_me_requires_token():
    response = client.get("/api/v1/auth/me")

    assert response.status_code == 401