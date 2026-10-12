from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.database import init_db
from app.routers import api_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan event handler for startup and shutdown operations."""
    # Initialize DB schemas on startup
    await init_db()
    yield


app = FastAPI(
    title=settings.PROJECT_NAME,
    description=settings.PROJECT_DESCRIPTION,
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs" if settings.ENVIRONMENT.lower() != "production" and settings.DEBUG else None,
    redoc_url="/redoc" if settings.ENVIRONMENT.lower() != "production" and settings.DEBUG else None,
    openapi_url=f"{settings.API_V1_STR}/openapi.json" if settings.ENVIRONMENT.lower() != "production" and settings.DEBUG else None,
)

# Cyber security response headers
@app.middleware("http")
async def add_security_headers(request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    return response

# Set up CORS middleware for Next.js frontend client
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS if isinstance(settings.CORS_ORIGINS, list) else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API v1 routes
app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint for container orchestrators and monitoring."""
    return {
        "status": "ok",
        "service": settings.PROJECT_NAME,
        "environment": settings.ENVIRONMENT,
    }


@app.get("/", tags=["Health"])
async def root():
    """Root redirect / welcoming endpoint."""
    return {
        "message": "Welcome to PATHAI Backend Service API",
        "docs": "/docs",
        "api_v1": settings.API_V1_STR,
    }
