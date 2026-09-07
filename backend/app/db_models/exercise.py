from datetime import datetime

from sqlalchemy import DateTime, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class ExerciseModel(Base):
    __tablename__ = "exercises"

    id: Mapped[str] = mapped_column(
        String(20),
        primary_key=True,
    )

    name: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
        index=True,
    )

    category: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    body_part: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
        index=True,
    )

    equipment: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
        index=True,
    )

    instructions: Mapped[dict] = mapped_column(
        JSONB,
        nullable=False,
        default=dict,
    )

    instruction_steps: Mapped[dict] = mapped_column(
        JSONB,
        nullable=False,
        default=dict,
    )

    muscle_group: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    secondary_muscles: Mapped[list] = mapped_column(
        JSONB,
        nullable=False,
        default=list,
    )

    target: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
        index=True,
    )

    media_id: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    image: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    gif_url: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    attribution: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
    )