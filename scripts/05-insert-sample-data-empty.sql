-- Empty Sample Data for EcoBot Database (No initial sessions)

-- Insert your EcoBot device only
INSERT INTO devices (device_id, device_name, location, firmware_version) 
VALUES ('ecobot_001', 'Main EcoBot', 'Office Building - Floor 1', '1.0.0')
ON CONFLICT (device_id) DO UPDATE SET
    device_name = EXCLUDED.device_name,
    location = EXCLUDED.location,
    firmware_version = EXCLUDED.firmware_version,
    updated_at = NOW();

-- Insert configuration only
INSERT INTO device_config (device_id, config_key, config_value, data_type, description) VALUES
('ecobot_001', 'target_bottles', '3', 'integer', 'Number of bottles needed to complete a session'),
('ecobot_001', 'reward_per_session', '1', 'integer', 'Reward points used per completed session'),
('ecobot_001', 'starting_rewards', '15', 'integer', 'Initial reward points when system starts'),
('ecobot_001', 'container_height_cm', '20', 'decimal', 'Total height of container in centimeters'),
('ecobot_001', 'full_threshold_cm', '10', 'decimal', 'Distance threshold to consider container full'),
('ecobot_001', 'wifi_ssid', 'BOSSING!!', 'string', 'WiFi network name'),
('ecobot_001', 'server_url', 'ecobot-idnm.onrender.com', 'string', 'Server URL for API calls'),
('ecobot_001', 'notification_cooldown_ms', '60000', 'integer', 'Cooldown between notifications in milliseconds')
ON CONFLICT (device_id, config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    updated_at = NOW();

-- Insert initial bin status only
INSERT INTO bin_status (device_id, status, container_level_cm, container_level_percent, is_full, message)
VALUES ('ecobot_001', 'unknown', 15.5, 25, false, 'System initialized - ready for first session');

-- Insert initial system log only
INSERT INTO system_logs (device_id, log_level, category, message) VALUES
('ecobot_001', 'info', 'general', 'System initialized with 15 reward points');

-- NO SAMPLE SESSIONS OR REWARDS - START COMPLETELY EMPTY
