-- Enable Real-time subscriptions for Supabase

-- Enable real-time for main tables that need live updates
ALTER PUBLICATION supabase_realtime ADD TABLE bottle_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE bottles;
ALTER PUBLICATION supabase_realtime ADD TABLE bin_status;
ALTER PUBLICATION supabase_realtime ADD TABLE rewards;
ALTER PUBLICATION supabase_realtime ADD TABLE system_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE devices;

-- Note: Run this after creating your tables
-- This enables real-time subscriptions in your Next.js app
