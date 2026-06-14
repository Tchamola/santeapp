from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from database import SessionLocal, engine, Base, PatientModel
from pydantic import BaseModel

# 1. On demande à SQLAlchemy de créer la table dans Postgres si elle n'existe pas
Base.metadata.create_all(bind=engine)

app = FastAPI()

# 2. Le Shémas Pydantic
class PatientCreate(BaseModel):
    age: int
    poids: float
    taille: float
    survecu: bool
    zone : str

# 3. La fonction outil (DÉFINIR AVANT LES ROUTES)
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# On crée une routte pour AJOUTER un patient
@app.post("/patients")
def ajouter_patient(patient_recu : PatientCreate, db : Session = Depends(get_db)):

    # Calcul automatique de l'IMC avant l'enregistrement dans la base de données
    imc_calcule = 0
    if patient_recu.taille > 0:
        imc_calcule = round(patient_recu.poids/(patient_recu.taille ** 2), 2)

    # On transforme les données reçues en un objet compatible avec notre base PostgreSQL
    nouveau_patient = PatientModel(
        age = patient_recu.age,
        poids = patient_recu.poids,
        taille = patient_recu.taille,
        imc = imc_calcule,
        survecu = patient_recu.survecu,
        zone = patient_recu.zone,
    )
    # On l'ajoute, on valide la transaction dans la base de données et on met à jour
    db.add(nouveau_patient)
    db.commit()
    db.refresh(nouveau_patient) # On récupère son ID généré automatiquement

    return {"message": "Patient ajouté avec succès !", "patient_id": nouveau_patient.id, "imc_enregistre" : imc_calcule}

# 3. On crée notre "Endpoint" (le point d'accès sur le web)
@app.get("/stats")
def obtenir_statistiques(db : Session = Depends(get_db)):

    # --- ANCIENNE LISTE EN DUR SUPPRIMEE ---
    # À la place, on récupère TOUS les patients directement depuis PostgreSQL !
    patients = db.query(PatientModel).all()

    # Si la base (PatientModel) est vide pour l'instant, on évite une division par zéro
    if not patients :
        return {
            "message" : "Aucun patient dans la base de données pour le moment",
            "statistiques_globales" : {},
            "prevalence_par_zone" : {}
        }
    # Variables globales pour les stats générales :
    total_age = 0
    total_imc = 0
    nombre_total = len(patients)
    deces = 0
    # Dictionnaire pour compter les cas par zone (Prévalence) :
    cas_par_zone = {}

    # On parcourt les pateints de notre dictionnaire :
    for patient in patients :
        # On calcul l'âge et les décès (avec SQLAlchemy on utilise 'patient.age')
        # et non des crochets 'patient["age"]
        total_age += patient.age 
        total_imc += patient.imc                 # au lieu de (total_age += patient["age"])
        if not patient.survecu:                   # if not patient["survecu"] :
            deces += 1
        # --- Logique de prévalence --- :
        zone_du_patient = patient.zone        #zone_du_patient = patient["zone"]
    
        # Si la zone n'est pas encore dans notre dictionnaire, on l'initialise à 0
        if zone_du_patient not in cas_par_zone:
            cas_par_zone[zone_du_patient] = 0

        # On ajoute 1 cas à cette à cette zone
        cas_par_zone[zone_du_patient] += 1

    # Calculs des statistiques globales
    age_moyen = round(total_age / nombre_total, 2)
    imc_moyen = round(total_imc/nombre_total, 2)
    taux_letalite = round((deces / nombre_total) * 100, 2)

    # 4. On retourne les résultats sous forme de dictionnaire (JSON)
    return {
        "Statistiques_globales": {
            "nombre_total_cas": nombre_total,
            "age_moyen_ans": age_moyen,
            "imc_moyen_global": imc_moyen,
            "taux_letalite_pourcentage": taux_letalite
        },
        "prevalence_par_zone": cas_par_zone,
    }





