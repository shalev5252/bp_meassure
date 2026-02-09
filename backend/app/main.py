from fastapi import FastAPI

app = FastAPI(
    title="BP Monitor API",
    version="1.0.0",
)


@app.get("/health")
async def health() -> dict:
    return {"status": "ok", "version": "1.0.0"}
