-- EcoBot Database Schema for Supabase
-- Run these commands in your Supabase SQL Editor

-- Enable Row Level Security (RLS) extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Device Management Table
CREATE TABLE devices (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id TEXT UNIQUE NOT NULL,
    device_name TEXT NOT NULL DEFAULT 'EcoBot',
    location TEXT,
    is_active BOOLEAN DEFAULT true,
    last_seen TIMESTAMP WITH TIME ZONE,
    firmware_version TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Bottle Collection Sessions
CREATE TABLE bottle_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id TEXT NOT NULL REFERENCES devices(device_id) ON DELETE CASCADE,
    session_number SERIAL,
    bottles_collected INTEGER NOT NULL DEFAULT 0,
    target_bottles INTEGER DEFAULT 3,
    session_type TEXT DEFAULT 'Arduino Collection',
    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'failed', 'cancelled')),
    reward_points INTEGER DEFAULT 0,
    start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_time TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Individual Bottle Records (for detailed tracking)
CREATE TABLE bottles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    session_id UUID REFERENCES bottle_sessions(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL REFERENCES devices(device_id) ON DELETE CASCADE,
    bottle_number INTEGER NOT NULL, -- 1st, 2nd, 3rd bottle in session
    color_detected TEXT, -- 'green', 'blue', 'other', 'unknown'
    color_rgb JSONB, -- Store RGB values: {"red": 123, "green": 456, "blue": 789}
    action_taken TEXT CHECK (action_taken IN ('accepted', 'rejected')),
    rejection_reason TEXT,
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Bin/Container Status
CREATE TABLE bin_status (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id TEXT NOT NULL REFERENCES devices(device_id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('empty', 'low', 'medium', 'high', 'full', 'unknown', 'error')),
    container_level_cm DECIMAL(5,2), -- Distance in centimeters
    container_level_percent INTEGER CHECK (container_level_percent >= 0 AND container_level_percent <= 100),
    is_full BOOLEAN DEFAULT false,
    message TEXT,
    alert_sent BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Reward System
CREATE TABLE rewards (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id TEXT NOT NULL REFERENCES devices(device_id) ON DELETE CASCADE,
    session_id UUID REFERENCES bottle_sessions(id) ON DELETE SET NULL,
    reward_type TEXT DEFAULT 'bottle_collection' CHECK (reward_type IN ('bottle_collection', 'bonus', 'penalty', 'manual')),
    points_awarded INTEGER NOT NULL,
    reason TEXT,
    multiplier DECIMAL(3,2) DEFAULT 1.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. System Logs
CREATE TABLE system_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id TEXT NOT NULL REFERENCES devices(device_id) ON DELETE CASCADE,
    log_level TEXT DEFAULT 'info' CHECK (log_level IN ('debug', 'info', 'warning', 'error', 'critical')),
    category TEXT DEFAULT 'general', -- 'wifi', 'sensor', 'servo', 'general', 'api'
    message TEXT NOT NULL,
    error_code TEXT,
    additional_data JSONB, -- Store any extra data as JSON
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Configuration Settings
CREATE TABLE device_config (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id TEXT NOT NULL REFERENCES devices(device_id) ON DELETE CASCADE,
    config_key TEXT NOT NULL,
    config_value TEXT NOT NULL,
    data_type TEXT DEFAULT 'string' CHECK (data_type IN ('string', 'integer', 'boolean', 'decimal', 'json')),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(device_id, config_key)
);
