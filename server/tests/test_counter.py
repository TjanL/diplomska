from fastapi.testclient import TestClient

from server.main import app

client = TestClient(app)


def test_get_count():
    response = client.get("/api/count")
    assert response.status_code == 200
    json = response.json()

    assert "count" in json
    assert isinstance(json.get("count"), int)
