-- Check if your database is already set up
-- Run this first to see what you have

-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('devices', 'bottle_sessions', 'bottles', 'bin_status', 'rewards', 'system_logs', 'device_config');

-- Check if you have any data
SELECT 'devices' as table_name, COUNT(*) as record_count FROM devices
UNION ALL
SELECT 'bottle_sessions', COUNT(*) FROM bottle_sessions
UNION ALL
SELECT 'bin_status', COUNT(*) FROM bin_status
UNION ALL
SELECT 'device_config', COUNT(*) FROM device_config;

-- Check current device config
SELECT config_key, config_value 
FROM device_config 
WHERE device_id = 'ecobot_001';
