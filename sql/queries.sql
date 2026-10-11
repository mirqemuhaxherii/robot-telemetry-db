SELECT date_trunc('minute', r.recorded_at) AS minute,
       round(avg(r.value)::numeric, 2) AS avg_speed
FROM readings r
JOIN sensors s ON s.sensor_id = r.sensor_id
WHERE s.name = 'speed'
GROUP BY minute
ORDER BY minute
LIMIT 10;

SELECT r.recorded_at, round(r.value::numeric, 2) AS battery
FROM readings r
JOIN sensors s ON s.sensor_id = r.sensor_id
WHERE s.name = 'battery' AND r.value < 60
ORDER BY r.recorded_at
LIMIT 1;

SELECT r.recorded_at, round(r.value::numeric, 2) AS temp_c
FROM readings r 
JOIN sensors s ON s.sensor_id = r.sensor_id
WHERE s.name =  'motor_temp'
ORDER BY r.value DESC
LIMIT 5;

WITH per_minute AS (
    SELECT date_trunc('minute', r.recorded_at) AS minute,
           min(r.value) AS battery_end
    FROM readings r
    JOIN sensors s ON s.sensor_id = r.sensor_id
    WHERE s.name = 'battery'
    GROUP BY minute
)
SELECT minute,
       round(battery_end::numeric, 2) AS battery,
       round((LAG(battery_end) OVER (ORDER BY minute) - battery_end)::numeric, 2) AS drain
FROM per_minute
ORDER BY minute
LIMIT 10;

WITH per_minute AS (
    SELECT date_trunc('minute', r.recorded_at) AS minute,
           avg(r.value) AS avg_speed
    FROM readings r
    JOIN sensors s ON s.sensor_id = r.sensor_id
    WHERE s.name = 'speed'
    GROUP BY minute
)
SELECT minute,
       round(avg_speed::numeric, 2) AS avg_speed,
       round(avg(avg_speed) OVER (
           ORDER BY minute ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
       )::numeric, 2) AS moving_avg_5min
FROM per_minute
ORDER BY minute
LIMIT 10;