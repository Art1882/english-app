from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"status": "backend working"}

@app.post("/check")
def check_sentence(data: dict):
    sentence = data.get("sentence", "")
    return {
        "feedback": f"You wrote: {sentence}"
    }