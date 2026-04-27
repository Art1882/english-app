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

# 🔥 NEW: in-memory storage
submissions = []

@app.post("/check")
def check_sentence(data: dict):
    student = data.get("student", "Unknown")
    sentence = data.get("sentence", "").strip()

    feedback = []

    if not sentence:
        feedback.append("Write a sentence.")
    else:
        if not sentence[0].isupper():
            feedback.append("Start with a capital letter.")
        if not sentence.endswith("."):
            feedback.append("End with a full stop.")
        if len(sentence.split()) < 3:
            feedback.append("Write a longer sentence.")

    if not feedback:
        feedback.append("Good sentence.")

    result = {
        "student": student,
        "sentence": sentence,
        "feedback": " ".join(feedback)
    }

    submissions.append(result)

    return result

# 🔥 NEW: endpoint to view all submissions
@app.get("/submissions")
def get_submissions():
    return {"submissions": submissions}