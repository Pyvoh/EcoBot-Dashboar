-- Triggers for EcoBot Database

-- Trigger to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_devices_updated_at 
    BEFORE UPDATE ON devices 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_device_config_updated_at 
    BEFORE UPDATE ON device_config 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger to automatically calculate session duration
CREATE OR REPLACE FUNCTION calculate_session_duration()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.end_time IS NOT NULL AND NEW.start_time IS NOT NULL THEN
        NEW.duration_seconds = EXTRACT(EPOCH FROM (NEW.end_time - NEW.start_time))::INTEGER;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calculate_bottle_session_duration
    BEFORE UPDATE ON bottle_sessions
    FOR EACH ROW EXECUTE FUNCTION calculate_session_duration();

-- Trigger to update device last_seen when data is received
CREATE OR REPLACE FUNCTION update_device_activity()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM update_device_last_seen(NEW.device_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply activity trigger to main data tables
CREATE TRIGGER update_activity_on_bottle_session
    AFTER INSERT ON bottle_sessions
    FOR EACH ROW EXECUTE FUNCTION update_device_activity();

CREATE TRIGGER update_activity_on_bin_status
    AFTER INSERT ON bin_status
    FOR EACH ROW EXECUTE FUNCTION update_device_activity();

CREATE TRIGGER update_activity_on_system_log
    AFTER INSERT ON system_logs
    FOR EACH ROW EXECUTE FUNCTION update_device_activity();
