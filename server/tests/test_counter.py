from fastapi.testclient import TestClient

from server.main import app


def test_get_count():
    with TestClient(app) as client:
        response = client.get("/api/count")
        assert response.status_code == 200
        json = response.json()

        assert "count" in json
        assert isinstance(json.get("count"), int)
