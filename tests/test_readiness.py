import importlib.util
from pathlib import Path
from unittest.mock import MagicMock

import pytest

spec = importlib.util.spec_from_file_location(
    "network_monitor", Path(__file__).parents[1] / "microservices/network-monitor/app.py"
)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


@pytest.fixture
def client(monkeypatch):
    for key, value in {"DB_HOST": "postgres", "DB_USER": "test", "DB_PASSWORD": "test"}.items():
        monkeypatch.setenv(key, value)
    return module.app.test_client()


def test_database_failure_removes_readiness_but_preserves_liveness(client, monkeypatch):
    def fail(**kwargs):
        raise module.psycopg2.OperationalError("unavailable")
    monkeypatch.setattr(module.psycopg2, "connect", fail)
    assert client.get("/health/ready").status_code == 503
    assert client.get("/health/live").status_code == 200


def test_database_recovery_restores_readiness(client, monkeypatch):
    connection = MagicMock()
    monkeypatch.setattr(module.psycopg2, "connect", lambda **kwargs: connection)
    assert client.get("/health/ready").status_code == 200
    connection.cursor.return_value.__enter__.return_value.execute.assert_called_once_with("SELECT 1")
    connection.close.assert_called_once()


def test_missing_database_configuration_is_not_ready(client, monkeypatch):
    monkeypatch.delenv("DB_HOST")
    assert client.get("/health/ready").status_code == 503
