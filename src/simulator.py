import os
import random
from datetime import datetime, timedelta, timezone

import psycopg
from dotenv import load_dotenv

load_dotenv()

CONN = dict(
    host="localhost", port=5432, dbname="telemetry",
    user="telemetry", password=os.environ["POSTGRES_PASSWORD"],
    connect_timeout=5,
)


SENSORS = [
    ("battery", "battery", "%"),
    ("speed", "speed", "m/s"),
    ("motor_temp", "temperature", "°C"),
]


def main(steps=3600):
    with psycopg.connect(**CONN) as conn, conn.cursor() as cur:
        cur.execute(
            """INSERT INTO robots (name, model) VALUES (%s, %s)
               ON CONFLICT (name) DO UPDATE SET model = EXCLUDED.model
               RETURNING robot_id""",
            ("rover-1", "simulated"),
        )
        robot_id = cur.fetchone()[0]

        sensor_ids = {}
        for name, type_, unit in SENSORS:
            cur.execute(
                """INSERT INTO sensors (robot_id, name, type, unit)
                   VALUES (%s, %s, %s, %s)
                   ON CONFLICT (robot_id, name) DO UPDATE SET unit = EXCLUDED.unit
                   RETURNING sensor_id""",
                (robot_id, name, type_, unit),
            )
            sensor_ids[name] = cur.fetchone()[0]

        start = datetime.now(timezone.utc) - timedelta(seconds=steps)
        end = start + timedelta(seconds=steps)
        cur.execute(
            """INSERT INTO runs (robot_id, started_at, ended_at, notes)
               VALUES (%s, %s, %s, %s) RETURNING run_id""",
            (robot_id, start, end, "simulated run"),
        )
        run_id = cur.fetchone()[0]

        battery, speed, temp = 100.0, 0.0, 25.0
        rows = []
        for i in range(steps):
            t = start + timedelta(seconds=i)
            battery = max(0.0, battery - random.uniform(0.005, 0.02))
            speed = max(0.0, min(2.0, speed + random.uniform(-0.2, 0.2)))
            temp += (25 + speed * 15 - temp) * 0.02 + random.gauss(0, 0.1)
            rows.append((run_id, sensor_ids["battery"], t, battery))
            rows.append((run_id, sensor_ids["speed"], t, speed))
            rows.append((run_id, sensor_ids["motor_temp"], t, temp))

        cur.executemany(
            """INSERT INTO readings (run_id, sensor_id, recorded_at, value)
               VALUES (%s, %s, %s, %s)""",
            rows,
        )
    print(f"Inserted {len(rows)} readings for run {run_id}")


if __name__ == "__main__":
    main()