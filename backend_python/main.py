import json
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 🔥 in-memory storage
SUBMISSIONS_FILE = "submissions.json"


def load_submissions():
    if os.path.exists(SUBMISSIONS_FILE):
        with open(SUBMISSIONS_FILE, "r") as file:
            return json.load(file)
    return []


def save_submissions():
    with open(SUBMISSIONS_FILE, "w") as file:
        json.dump(submissions, file, indent=4)


submissions = load_submissions()


#check
@app.post("/check")
def check_sentence(data: dict):

    student = data.get("student", "Unknown")
    class_name = data.get("class", "Default")

    lesson = data.get("lesson", "Unknown lesson")
    activity = data.get("activity", "Unknown activity")
    answer = data.get("answer", "").strip()

    result = {
    "student": student,
    "class": class_name,
    "lesson": lesson,
    "activity": activity,
    "answer": answer,
    "feedback": "Saved for teacher review.",
    "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M")
}

    submissions.append(result)
    save_submissions()

    return result


# view all submissions
@app.get("/submissions")
def get_submissions():
    return {"submissions": submissions}


# 🔥 teacher classes
@app.get("/teacher/classes")
def get_classes():

    classes = list(set(
        submission["class"] for submission in submissions
    ))

    return {"classes": classes}


# 🔥 teacher class overview
@app.get("/teacher/class/{class_name}")
def get_class_overview(class_name: str):

    class_submissions = [
        s for s in submissions
        if s["class"] == class_name
    ]

    students = {}

    for submission in class_submissions:

        student_name = submission["student"]

        if student_name not in students:
            students[student_name] = {
                "name": student_name,
                "lessons_completed": 0
            }

        students[student_name]["lessons_completed"] += 1

    return {
        "class_name": class_name,
        "students": list(students.values())
    }


# 🔥 teacher individual student
@app.get("/teacher/student/{student_name}")
def get_student_work(student_name: str):

    student_submissions = [
        s for s in submissions
        if s["student"] == student_name
    ]

    student_submissions.sort(
        key=lambda x: x.get("timestamp", ""),
        reverse=True
    )

    return {
        "student": student_name,
        "submissions": student_submissions
    }