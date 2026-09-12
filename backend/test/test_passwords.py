from app.security.passwords import (
    hash_password,
    verify_password,
)


def test_hash_password_does_not_return_plain_text():
    password = "MiClave123"

    hashed_password = hash_password(password)

    assert hashed_password != password
    assert hashed_password.startswith("$argon2")


def test_verify_password_accepts_correct_password():
    password = "MiClave123"
    hashed_password = hash_password(password)

    assert verify_password(password, hashed_password) is True


def test_verify_password_rejects_incorrect_password():
    hashed_password = hash_password("MiClave123")

    assert verify_password(
        "ContraseñaIncorrecta",
        hashed_password,
    ) is False