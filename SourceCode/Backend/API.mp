import uuid
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from database import Base, engine, SessionLocal
import models, schemas
from auth import get_current_user

Base.metadata.create_all(bind=engine)

app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ================= AUTH =================
@app.post("/register")
def register(data: schemas.UserCreate, db: Session = Depends(get_db)):
    existing = db.query(models.User).filter_by(email=data.email).first()
    if existing:
        raise HTTPException(400, "Email exists")

    api_key = str(uuid.uuid4())

    user = models.User(
        email=data.email,
        name=data.name,
        api_key=api_key
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return {"user": user, "api_key": api_key}


@app.post("/login")
def login(data: schemas.LoginRequest, db: Session = Depends(get_db)):
    user = db.query(models.User).filter_by(email=data.email).first()
    if not user:
        raise HTTPException(404, "User not found")

    return {"api_key": user.api_key}


# ================= PRESCRIPTIONS =================
@app.get("/prescriptions")
def get_prescriptions(user=Depends(get_current_user), db: Session = Depends(get_db)):
    return db.query(models.Prescription).filter_by(user_id=user.id).all()


@app.post("/prescriptions")
def create_prescription(data: schemas.PrescriptionCreate,
                        user=Depends(get_current_user),
                        db: Session = Depends(get_db)):

    pres = models.Prescription(
        user_id=user.id,
        title=data.title,
        start_date=data.start_date,
        end_date=data.end_date,
        history={}
    )
    db.add(pres)
    db.commit()
    db.refresh(pres)

    for med in data.medicines:
        db.add(models.Medicine(
            prescription_id=pres.id,
            **med.dict()
        ))

    db.commit()
    return {"id": pres.id, "title": pres.title}


@app.get("/prescriptions/{id}")
def get_prescription(id: str, user=Depends(get_current_user), db: Session = Depends(get_db)):
    pres = db.query(models.Prescription).filter_by(id=id, user_id=user.id).first()
    if not pres:
        raise HTTPException(404, "Not found")
    return pres


@app.delete("/prescriptions/{id}")
def delete_prescription(id: str, user=Depends(get_current_user), db: Session = Depends(get_db)):
    pres = db.query(models.Prescription).filter_by(id=id, user_id=user.id).first()
    if not pres:
        raise HTTPException(404, "Not found")

    db.delete(pres)
    db.commit()
    return {"message": "Deleted"}


# ================= MEDICINES =================
@app.get("/prescriptions/{id}/medicines")
def get_medicines(id: str, user=Depends(get_current_user), db: Session = Depends(get_db)):
    return db.query(models.Medicine).filter_by(prescription_id=id).all()


@app.post("/prescriptions/{id}/medicines")
def add_medicine(id: str, data: schemas.MedicineCreate,
                 user=Depends(get_current_user), db: Session = Depends(get_db)):

    med = models.Medicine(
        prescription_id=id,
        **data.dict()
    )
    db.add(med)
    db.commit()
    db.refresh(med)

    return {"id": med.id, "name": med.name}


# ================= HISTORY =================
@app.post("/prescriptions/{id}/history")
def update_history(id: str, data: schemas.HistoryUpdate,
                   user=Depends(get_current_user),
                   db: Session = Depends(get_db)):

    pres = db.query(models.Prescription).filter_by(id=id).first()
    if not pres:
        raise HTTPException(404, "Not found")

    history = pres.history or {}
    history[str(data.date)] = data.actions

    pres.history = history
    db.commit()

    return {"history": history}
