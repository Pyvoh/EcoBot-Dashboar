-- Utility Functions for EcoBot Database

-- Function to get latest bin status for a device
CREATE OR REPLACE FUNCTION get_latest_bin_status(p_device_id TEXT)
RETURNS TABLE (
    status TEXT,
    container_level_cm DECIMAL,
    container_level_percent INTEGER,
    is_full BOOLEAN,
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bs.status,
        bs.container_level_cm,
        bs.container_level_percent,
        bs.is_full,
        bs.message,
        bs.created_at
    FROM bin_status bs
    WHERE bs.device_id = p_device_id
    ORDER BY bs.created_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate total bottles for a device
CREATE OR REPLACE FUNCTION get_device_stats(p_device_id TEXT)
RETURNS TABLE (
    total_bottles INTEGER,
    total_sessions INTEGER,
    total_rewards INTEGER,
    success_rate DECIMAL,
    last_session TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(SUM(bs.bottles_collected), 0)::INTEGER as total_bottles,
        COUNT(bs.id)::INTEGER as total_sessions,
        COALESCE(SUM(r.points_awarded), 0)::INTEGER as total_rewards,
        CASE 
            WHEN COUNT(bs.id) > 0 THEN 
                ROUND((COUNT(CASE WHEN bs.status = 'completed' THEN 1 END)::DECIMAL / COUNT(bs.id)::DECIMAL) * 100, 2)
            ELSE 0
        END as success_rate,
        MAX(bs.created_at) as last_session
    FROM bottle_sessions bs
    LEFT JOIN rewards r ON r.session_id = bs.id
    WHERE bs.device_id = p_device_id;
END;
$$ LANGUAGE plpgsql;

-- Function to update device last_seen timestamp
CREATE OR REPLACE FUNCTION update_device_last_seen(p_device_id TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE devices 
    SET 
        last_seen = NOW(),
        updated_at = NOW()
    WHERE device_id = p_device_id;
    
    -- Insert device if it doesn't exist
    INSERT INTO devices (device_id, device_name, last_seen)
    VALUES (p_device_id, 'EcoBot_' || p_device_id, NOW())
    ON CONFLICT (device_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- Function to complete a bottle session
CREATE OR REPLACE FUNCTION complete_bottle_session(
    p_session_id UUID,
    p_reward_points INTEGER DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_start_time TIMESTAMP WITH TIME ZONE;
    v_device_id TEXT;
BEGIN
    -- Get session details
    SELECT start_time, device_id INTO v_start_time, v_device_id
    FROM bottle_sessions 
    WHERE id = p_session_id;
    
    -- Update session
    UPDATE bottle_sessions 
    SET 
        status = 'completed',
        end_time = NOW(),
        duration_seconds = EXTRACT(EPOCH FROM (NOW() - v_start_time))::INTEGER,
        reward_points = COALESCE(p_reward_points, reward_points)
    WHERE id = p_session_id;
    
    -- Add reward if specified
    IF p_reward_points IS NOT NULL AND p_reward_points > 0 THEN
        INSERT INTO rewards (device_id, session_id, points_awarded, reason)
        VALUES (v_device_id, p_session_id, p_reward_points, 'Session completion reward');
    END IF;
END;
$$ LANGUAGE plpgsql;
