from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import ALLOWED_ORIGINS
from app.routes.exercises import router as exercises_router


app = FastAPI(
    title="Gym Exercises API",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=False,
    allow_methods=["GET"],
    allow_headers=["*"],
)

app.include_router(exercises_router)


@app.get("/health", tags=["Health"])
def health():
    return {"status": "ok"}