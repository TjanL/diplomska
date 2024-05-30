import os
from typing import Optional

from sqlmodel import Field, SQLModel, create_engine


class Counter(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    count: int

print(os.environ.get("DATABASE_HOST", "sqlite:///database.db"))
connect_args = {"check_same_thread": False}
engine = create_engine(
    os.environ.get("DATABASE_HOST", "sqlite:///database.db"), connect_args=connect_args
)


def create_database_and_tables():
    SQLModel.metadata.create_all(engine)
