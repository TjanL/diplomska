from typing import Optional

from sqlmodel import Field, SQLModel, create_engine


class Counter(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    count: int


sqlite_file_name = "database.db"
sqlite_url = f"sqlite:///{sqlite_file_name}"

connect_args = {"check_same_thread": False}
engine = create_engine(sqlite_url, connect_args=connect_args)


def create_database_and_tables():
    SQLModel.metadata.create_all(engine)
