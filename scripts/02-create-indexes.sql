-- Performance Indexes for EcoBot Database

-- Device indexes
CREATE INDEX idx_devices_device_id ON devices(device_id);
CREATE INDEX idx_devices_active ON devices(is_active);
CREATE INDEX idx_devices_last_seen ON devices(last_seen);

-- Bottle sessions indexes
CREATE INDEX idx_bottle_sessions_device_id ON bottle_sessions(device_id);
CREATE INDEX idx_bottle_sessions_status ON bottle_sessions(status);
CREATE INDEX idx_bottle_sessions_created_at ON bottle_sessions(created_at DESC);
CREATE INDEX idx_bottle_sessions_device_status ON bottle_sessions(device_id, status);

-- Individual bottles indexes
CREATE INDEX idx_bottles_session_id ON bottles(session_id);
CREATE INDEX idx_bottles_device_id ON bottles(device_id);
CREATE INDEX idx_bottles_color ON bottles(color_detected);
CREATE INDEX idx_bottles_action ON bottles(action_taken);
CREATE INDEX idx_bottles_detected_at ON bottles(detected_at DESC);

-- Bin status indexes
CREATE INDEX idx_bin_status_device_id ON bin_status(device_id);
CREATE INDEX idx_bin_status_created_at ON bin_status(created_at DESC);
CREATE INDEX idx_bin_status_device_latest ON bin_status(device_id, created_at DESC);
CREATE INDEX idx_bin_status_full ON bin_status(is_full);

-- Rewards indexes
CREATE INDEX idx_rewards_device_id ON rewards(device_id);
CREATE INDEX idx_rewards_session_id ON rewards(session_id);
CREATE INDEX idx_rewards_created_at ON rewards(created_at DESC);
CREATE INDEX idx_rewards_type ON rewards(reward_type);

-- System logs indexes
CREATE INDEX idx_system_logs_device_id ON system_logs(device_id);
CREATE INDEX idx_system_logs_level ON system_logs(log_level);
CREATE INDEX idx_system_logs_category ON system_logs(category);
CREATE INDEX idx_system_logs_created_at ON system_logs(created_at DESC);
CREATE INDEX idx_system_logs_device_level ON system_logs(device_id, log_level);

-- Config indexes
CREATE INDEX idx_device_config_device_id ON device_config(device_id);
CREATE INDEX idx_device_config_key ON device_config(config_key);
CREATE INDEX idx_device_config_active ON device_config(is_active);
