from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_get_exercises_with_pagination():
    response = client.get(
        "/api/v1/exercises",
        params={
            "page": 1,
            "page_size": 5,
        },
    )

    data = response.json()

    assert response.status_code == 200
    assert data["page"] == 1
    assert data["page_size"] == 5
    assert data["total"] > 0
    assert data["pages"] > 0
    assert len(data["items"]) == 5


def test_filter_exercises_by_muscle():
    response = client.get(
        "/api/v1/exercises",
        params={
            "muscle": "biceps",
            "page": 1,
            "page_size": 10,
        },
    )

    data = response.json()

    assert response.status_code == 200
    assert data["muscle"] == "biceps"
    assert data["total"] > 0
    assert len(data["items"]) <= 10

    assert all(
        exercise["target"].casefold() == "biceps"
        for exercise in data["items"]
    )


def test_filter_is_case_insensitive():
    response = client.get(
        "/api/v1/exercises",
        params={
            "muscle": "BICEPS",
            "page_size": 5,
        },
    )

    data = response.json()

    assert response.status_code == 200
    assert data["total"] > 0

    assert all(
        exercise["target"].casefold() == "biceps"
        for exercise in data["items"]
    )


def test_get_exercise_by_id():
    response = client.get("/api/v1/exercises/0001")

    data = response.json()

    assert response.status_code == 200
    assert data["id"] == "0001"
    assert "name" in data
    assert "target" in data


def test_exercise_not_found():
    response = client.get(
        "/api/v1/exercises/id-that-does-not-exist"
    )

    assert response.status_code == 404
    assert response.json() == {
        "detail": "Ejercicio no encontrado"
    }


def test_invalid_page():
    response = client.get(
        "/api/v1/exercises",
        params={"page": 0},
    )

    assert response.status_code == 422


def test_page_size_greater_than_limit():
    response = client.get(
        "/api/v1/exercises",
        params={"page_size": 101},
    )

    assert response.status_code == 422


def test_get_muscles():
    response = client.get("/api/v1/muscles")

    data = response.json()

    assert response.status_code == 200
    assert data["total"] > 0
    assert len(data["items"]) == data["total"]
    assert data["items"] == sorted(data["items"])
    assert len(data["items"]) == len(set(data["items"]))

def test_get_equipment():
    response = client.get("/api/v1/equipment")
    data = response.json()

    assert response.status_code == 200
    assert data["total"] > 0
    assert len(data["items"]) == data["total"]
    assert data["items"] == sorted(data["items"])
    assert len(data["items"]) == len(set(data["items"]))


def test_get_body_parts():
    response = client.get("/api/v1/body-parts")
    data = response.json()

    assert response.status_code == 200
    assert data["total"] > 0
    assert len(data["items"]) == data["total"]
    assert data["items"] == sorted(data["items"])
    assert len(data["items"]) == len(set(data["items"]))

def test_cors_allows_frontend_origin():
    response = client.get(
        "/health",
        headers={
            "Origin": "http://localhost:5173",
        },
    )

    assert response.status_code == 200

    assert response.headers.get(
        "access-control-allow-origin"
    ) == "http://localhost:5173"

def test_cors_does_not_allow_unknown_origin():
    response = client.get(
        "/health",
        headers={
            "Origin": "http://example.com",
        },
    )

    assert response.status_code == 200

    assert (
        response.headers.get(
            "access-control-allow-origin"
        )
        is None
    )