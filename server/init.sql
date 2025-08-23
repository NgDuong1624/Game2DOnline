CREATE TABLE IF NOT EXISTS Users (
     user_id SERIAL PRIMARY KEY,
     username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    platform TEXT CHECK (platform IN ('PC', 'Mobile', 'Both')) DEFAULT 'Both',
    is_premium BOOLEAN DEFAULT FALSE,
    ar_access BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE
);

INSERT INTO Users (user_id, username, password_hash, email, created_at, last_login, platform, is_premium, ar_access, is_active) VALUES
    (1, 'ninja1', 'hashedPass1', 'ninja1@example.com', '2025-08-22 10:00:00', '2025-08-22 10:30:00', 'PC', true, false, true),
    (2, 'samurai2', 'hashedPass2', 'samurai2@example.com', '2025-08-22 11:00:00', NULL, 'Mobile', false, true, true),
    (3, 'shinobi3', 'hashedPass3', 'shinobi3@example.com', '2025-08-22 12:00:00', '2025-08-22 12:30:00', 'PC', true, false, true),
    (4, 'kunoichi4', 'hashedPass4', 'kunoichi4@example.com', '2025-08-22 13:00:00', NULL, 'Both', false, false, false)
    ON CONFLICT (user_id) DO NOTHING;