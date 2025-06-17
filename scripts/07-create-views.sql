-- Useful Views for EcoBot Dashboard

-- Dashboard summary view
CREATE OR REPLACE VIEW dashboard_summary AS
SELECT 
    d.device_id,
    d.device_name,
    d.location,
    d.is_active,
    d.last_seen,
    -- Latest bin status
    bs.status as bin_status,
    bs.container_level_percent,
    bs.is_full,
    bs.message as bin_message,
    -- Statistics
    COALESCE(stats.total_bottles, 0) as total_bottles,
    COALESCE(stats.total_sessions, 0) as total_sessions,
    COALESCE(stats.total_rewards, 0) as total_rewards,
    COALESCE(stats.success_rate, 0) as success_rate,
    stats.last_session
FROM devices d
LEFT JOIN LATERAL (
    SELECT * FROM get_device_stats(d.device_id)
) stats ON true
LEFT JOIN LATERAL (
    SELECT * FROM get_latest_bin_status(d.device_id)
) bs ON true;

-- Recent sessions view (for history table)
CREATE OR REPLACE VIEW recent_sessions AS
SELECT 
    bs.id,
    bs.device_id,
    bs.session_number,
    bs.bottles_collected,
    bs.target_bottles,
    bs.session_type,
    bs.status,
    bs.reward_points,
    bs.start_time,
    bs.end_time,
    bs.duration_seconds,
    -- Count of bottles by action
    bottle_stats.accepted_bottles,
    bottle_stats.rejected_bottles,
    -- Reward info
    r.points_awarded as actual_reward_points
FROM bottle_sessions bs
LEFT JOIN LATERAL (
    SELECT 
        COUNT(CASE WHEN action_taken = 'accepted' THEN 1 END) as accepted_bottles,
        COUNT(CASE WHEN action_taken = 'rejected' THEN 1 END) as rejected_bottles
    FROM bottles b 
    WHERE b.session_id = bs.id
) bottle_stats ON true
LEFT JOIN rewards r ON r.session_id = bs.id AND r.reward_type = 'bottle_collection'
ORDER BY bs.created_at DESC;

-- System health view
CREATE OR REPLACE VIEW system_health AS
SELECT 
    d.device_id,
    d.device_name,
    d.is_active,
    d.last_seen,
    CASE 
        WHEN d.last_seen > NOW() - INTERVAL '5 minutes' THEN 'online'
        WHEN d.last_seen > NOW() - INTERVAL '1 hour' THEN 'idle'
        ELSE 'offline'
    END as connection_status,
    -- Recent error count
    error_stats.error_count_24h,
    error_stats.warning_count_24h,
    -- Latest bin status
    bs.is_full,
    bs.status as bin_status
FROM devices d
LEFT JOIN LATERAL (
    SELECT 
        COUNT(CASE WHEN log_level = 'error' THEN 1 END) as error_count_24h,
        COUNT(CASE WHEN log_level = 'warning' THEN 1 END) as warning_count_24h
    FROM system_logs sl 
    WHERE sl.device_id = d.device_id 
    AND sl.created_at > NOW() - INTERVAL '24 hours'
) error_stats ON true
LEFT JOIN LATERAL (
    SELECT * FROM get_latest_bin_status(d.device_id)
) bs ON true;
