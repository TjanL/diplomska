from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session, select

from .model import Counter, create_database_and_tables, engine

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    create_database_and_tables()

    with Session(engine) as session:
        counter = session.exec(select(Counter).where(Counter.id == 1)).first()

        if counter is None:
            counter = Counter(count=0)
            session.add(counter)

        counter.count += 1
        session.commit()

    yield


@app.get("/api/count", response_model=Counter)
async def count():
    with Session(engine) as session:
        counter = session.exec(select(Counter).where(Counter.id == 1)).first()
        return counter
