from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes.favorites import router as favorites_router
from app.config import ALLOWED_ORIGINS
from app.routes.auth import router as auth_router
from app.routes.exercises import router as exercises_router


app = FastAPI(
    title="EjerciciosApp API",
    version="1.3.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=False,
    allow_methods=["GET", "POST", "DELETE"],
    allow_headers=["*"],
)

app.include_router(exercises_router)
app.include_router(auth_router)
app.include_router(favorites_router)


@app.get("/health", tags=["Health"])
def health():
    return {"status": "ok"}