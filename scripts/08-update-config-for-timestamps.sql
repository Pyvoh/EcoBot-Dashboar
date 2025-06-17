-- Update configuration for new timestamp handling
-- Run this if you already have the database set up

-- Update existing device config for timestamp handling
INSERT INTO device_config (device_id, config_key, config_value, data_type, description) VALUES
('ecobot_001', 'timestamp_format', 'iso', 'string', 'Timestamp format: iso or unix'),
('ecobot_001', 'timezone', 'Asia/Manila', 'string', 'Device timezone (UTC+8)'),
('ecobot_001', 'ntp_server', 'pool.ntp.org', 'string', 'NTP server for time synchronization'),
('ecobot_001', 'time_sync_interval', '3600', 'integer', 'Time sync interval in seconds (1 hour)')
ON CONFLICT (device_id, config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    description = EXCLUDED.description,
    updated_at = NOW();

-- Update the starting rewards if needed
UPDATE device_config 
SET config_value = '15' 
WHERE device_id = 'ecobot_001' AND config_key = 'starting_rewards';

-- Add a system log entry for the update
INSERT INTO system_logs (device_id, log_level, category, message) 
VALUES ('ecobot_001', 'info', 'general', 'Configuration updated for ISO timestamp support');
