from sqlalchemy import*
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# 1. L'adresse de connexion à PostgreSQL
  # Format : "postgresql://utilisateur:mot_de_passe@localhost:5432/nom_de_la_database"
DATABASE_URL = "postgresql://postgres:Tchamola10@localhost:5432/santeapp"

# 2. On crée le moteur de connexion :
engine = create_engine(DATABASE_URL)

# 3. On crée une fabrique de sessions (pour faire nos requetes plus tard)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 4. La classe de base pour nos modèles
Base = declarative_base()

# 5. On définit notre table "patients" (Le Modèle)
class PatientModel(Base):
    __tablename__ = "patients"
    id = Column(Integer, primary_key=True, index=True)
    age = Column(Integer, nullable=False)
    poids = Column(Float, nullable=False)
    taille = Column(Float, nullable=False)
    imc = Column(Float, nullable=False)
    survecu = Column(Boolean, default=True, nullable=False)
    zone = Column(String, nullable=False)
    



