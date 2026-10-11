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