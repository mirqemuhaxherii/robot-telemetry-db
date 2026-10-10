CREATE TABLE robots (
    robot_id    SERIAL PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    model       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE runs (
    run_id      SERIAL PRIMARY KEY,
    robot_id    INT NOT NULL REFERENCES robots(robot_id),
    started_at  TIMESTAMPTZ NOT NULL,
    ended_at    TIMESTAMPTZ,
    notes       TEXT,
    CHECK (ended_at IS NULL OR ended_at >= started_at)
);

CREATE TABLE sensors (
    sensor_id   SERIAL PRIMARY KEY,
    robot_id    INT NOT NULL REFERENCES robots(robot_id),
    name        TEXT NOT NULL,
    type        TEXT NOT NULL,
    unit        TEXT NOT NULL,
    UNIQUE (robot_id, name)
);

CREATE TABLE readings (
    reading_id  BIGSERIAL PRIMARY KEY,
    run_id      INT NOT NULL REFERENCES runs(run_id),
    sensor_id   INT NOT NULL REFERENCES sensors(sensor_id),
    recorded_at TIMESTAMPTZ NOT NULL,
    value       DOUBLE PRECISION NOT NULL
);