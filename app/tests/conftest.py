import datetime
import pytest
from freezegun import freeze_time


FROZEN_TIME = "2024-01-15 12:00:00"


@pytest.fixture()
def frozen_now():
    """Freeze time so timestamp and uptime assertions are deterministic."""
    with freeze_time(FROZEN_TIME):
        yield datetime.datetime(2024, 1, 15, 12, 0, 0)
