-- Sample Data for EcoBot Database

-- Insert your EcoBot device
INSERT INTO devices (device_id, device_name, location, firmware_version) 
VALUES ('ecobot_001', 'Main EcoBot', 'Office Building - Floor 1', '1.0.0')
ON CONFLICT (device_id) DO UPDATE SET
    device_name = EXCLUDED.device_name,
    location = EXCLUDED.location,
    firmware_version = EXCLUDED.firmware_version,
    updated_at = NOW();

-- Insert some sample configuration
INSERT INTO device_config (device_id, config_key, config_value, data_type, description) VALUES
('ecobot_001', 'target_bottles', '3', 'integer', 'Number of bottles needed to complete a session'),
('ecobot_001', 'reward_per_bottle', '5', 'integer', 'Reward points per bottle collected'),
('ecobot_001', 'container_height_cm', '20', 'decimal', 'Total height of container in centimeters'),
('ecobot_001', 'full_threshold_cm', '10', 'decimal', 'Distance threshold to consider container full'),
('ecobot_001', 'wifi_ssid', 'BOSSING!!', 'string', 'WiFi network name'),
('ecobot_001', 'server_url', 'ecobot-idnm.onrender.com', 'string', 'Server URL for API calls'),
('ecobot_001', 'notification_cooldown_ms', '60000', 'integer', 'Cooldown between notifications in milliseconds')
ON CONFLICT (device_id, config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    updated_at = NOW();

-- Insert sample historical data (matching your current data)
INSERT INTO bottle_sessions (device_id, bottles_collected, status, reward_points, start_time, end_time) VALUES
('ecobot_001', 3, 'completed', 14, '2025-06-17 06:58:54+00', '2025-06-17 06:59:30+00'),
('ecobot_001', 3, 'completed', 13, '2025-06-17 07:07:22+00', '2025-06-17 07:08:15+00');

-- Insert corresponding rewards
INSERT INTO rewards (device_id, session_id, points_awarded, reason) 
SELECT 
    bs.device_id, 
    bs.id, 
    bs.reward_points, 
    'Bottle collection reward'
FROM bottle_sessions bs 
WHERE bs.device_id = 'ecobot_001' AND bs.reward_points > 0;

-- Insert current bin status
INSERT INTO bin_status (device_id, status, container_level_cm, container_level_percent, is_full, message)
VALUES ('ecobot_001', 'unknown', 15.5, 25, false, 'System initialized');

-- Insert some sample system logs
INSERT INTO system_logs (device_id, log_level, category, message) VALUES
('ecobot_001', 'info', 'wifi', 'WiFi connected successfully'),
('ecobot_001', 'info', 'sensor', 'Color sensor initialized'),
('ecobot_001', 'info', 'general', 'System startup completed'),
('ecobot_001', 'info', 'api', 'Connected to server successfully');
