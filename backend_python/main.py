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
@app.post("/submit-activity")
def submit_activity(data: dict):

    student = data.get("student", "Unknown")
    class_name = data.get("class", "Default")

    lesson = data.get("lesson", "Unknown lesson")
    activity = data.get("activity", "Unknown activity")
    answer = data.get("answer", "")
    responses = data.get("responses", {})

    result = {
    "student": student,
    "class": class_name,
    "lesson": lesson,
    "activity": activity,
    "answer": answer,
    "responses": responses,
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
def get_teacher_classes():

    classes = list(set(
        submission["class"] for submission in submissions
    ))

    return {"classes": classes}
classes = [
    "Y7",
    "Y8",
    "Y9",
    "Y10",
]
#classes
@app.get("/classes")
def get_all_classes():
    return {"classes": classes}

learners = {
    "Y7": ["Arthur", "Candy", "Gabriel", "Mugeon", "Jack", "Peter"],
    "Y8": ["Jiwon", "Jerry", "Coco", "Yulhui"],
    "Y9": ["Paul"],
    "Y10": ["Tine"]
}


@app.get("/learners/{class_name}")
def get_learners(class_name: str):
    return {
        "learners": learners.get(class_name, [])
    }

@app.get("/teacher/class/{class_name}")
def get_class_overview(class_name: str):

    class_submissions = [
        s for s in submissions
        if s["class"] == class_name
    ]

    students = {}

    for submission in class_submissions:
        student_name = submission["student"]
        answer = submission.get("answer", {})

        score = 0
        possible = 0

        if isinstance(answer, dict):
            # Normal lesson: 3 + 8 + 5 + 10 = 26
            if "inputScore" in answer:
                score = (
                    answer.get("inputScore", 0)
                    + answer.get("vocabularyScore", 0)
                    + answer.get("grammarScore", 0)
                    + answer.get("comprehensionScore", 0)
                )
                possible = 26

            # Unit review: vocabulary 10 + grammar 10 = 20
            elif "totalScore" in answer:
                score = answer.get("totalScore", 0)
                possible = 20

        if student_name not in students:
            students[student_name] = {
                "name": student_name,
                "lessons_completed": 0,
                "last_active": submission.get("timestamp", ""),
                "total_score": 0,
                "total_possible": 0,
            }

        students[student_name]["lessons_completed"] += 1
        students[student_name]["total_score"] += score
        students[student_name]["total_possible"] += possible

        if submission.get("timestamp", "") > students[student_name]["last_active"]:
            students[student_name]["last_active"] = submission.get("timestamp", "")

    for student in students.values():
        if student["total_possible"] > 0:
            student["average_percentage"] = round(
                (student["total_score"] / student["total_possible"]) * 100
            )
        else:
            student["average_percentage"] = 0

        # Keep old field name temporarily so Flutter does not break
        student["average_score"] = student["average_percentage"]

    ranked_students = sorted(
        students.values(),
        key=lambda x: x["average_percentage"],
        reverse=True
    )

    return {
        "class_name": class_name,
        "students": ranked_students
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