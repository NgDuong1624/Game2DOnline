-- Dành cho PostgresSql
CREATE DATABASE astral_shinobi_db;
USE astral_shinobi_db;

-- Bảng Users
CREATE TABLE Users (
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

-- Bảng Maps (đặt trước Characters vì Characters có FK tham chiếu)
CREATE TABLE Maps (
    map_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status TEXT CHECK (status IN ('Normal', 'Corrupted', 'Expanded')) DEFAULT 'Normal',
    cycle_end TIMESTAMP,
    description TEXT
);

-- Bảng Characters
CREATE TABLE Characters (
    character_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    name VARCHAR(50) NOT NULL,
    class TEXT CHECK (class IN ('Kiếm', 'Quạt', 'Kunai', 'Đao', 'Cung', 'Tiêu')) NOT NULL,
    level INTEGER DEFAULT 1,
    exp BIGINT DEFAULT 0,
    strength INTEGER DEFAULT 0,
    dexterity INTEGER DEFAULT 0,
    vitality INTEGER DEFAULT 0,
    chakra INTEGER DEFAULT 0,
    fusion_points INTEGER DEFAULT 0,
    position_x FLOAT DEFAULT 0,
    position_y FLOAT DEFAULT 0,
    map_id INTEGER,
    appearance JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (map_id) REFERENCES Maps(map_id)
);

-- Bảng Skills
CREATE TABLE Skills (
    skill_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type TEXT CHECK (type IN ('Active', 'Passive')) NOT NULL,
    class_req TEXT CHECK (class_req IN ('Kiếm', 'Quạt', 'Kunai', 'Đao', 'Cung', 'Tiêu', 'All')),
    level_req INTEGER DEFAULT 1,
    description TEXT,
    fusion_req JSONB,
    cost JSONB
);

-- Bảng Character_Skills
CREATE TABLE Character_Skills (
    char_skill_id SERIAL PRIMARY KEY,
    character_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    level INTEGER DEFAULT 1,
    is_fused BOOLEAN DEFAULT FALSE,
    learned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (character_id) REFERENCES Characters(character_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id)
);

-- Bảng Items
CREATE TABLE Items (
    item_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type TEXT CHECK (type IN ('Weapon', 'Armor', 'Potion', 'Gem', 'Scroll', 'Astral Crystal', 'AR Item')) NOT NULL,
    rarity TEXT CHECK (rarity IN ('Common', 'Rare', 'Epic', 'Legendary')) NOT NULL,
    description TEXT,
    stats JSONB,
    enchant_max INTEGER DEFAULT 0,
    sockets INTEGER DEFAULT 0,
    price INTEGER DEFAULT 0
);

-- Bảng Inventory
CREATE TABLE Inventory (
    inventory_id SERIAL PRIMARY KEY,
    character_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    quantity INTEGER DEFAULT 1,
    enchant_level INTEGER DEFAULT 0,
    gems JSONB,
    equipped BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (character_id) REFERENCES Characters(character_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Items(item_id)
);

-- Bảng Pets
CREATE TABLE Pets (
    pet_id SERIAL PRIMARY KEY,
    character_id INTEGER NOT NULL,
    name VARCHAR(50) NOT NULL,
    type TEXT CHECK (type IN ('Attack', 'Defense', 'Support', 'Hybrid')) NOT NULL,
    level INTEGER DEFAULT 1,
    ai_level INTEGER DEFAULT 1,
    evolution_stage INTEGER DEFAULT 1,
    stats JSONB,
    active BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (character_id) REFERENCES Characters(character_id) ON DELETE CASCADE
);

-- Bảng Quests
CREATE TABLE Quests (
    quest_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type TEXT CHECK (type IN ('Story', 'Side', 'Daily')) NOT NULL,
    description TEXT NOT NULL,
    level_req INTEGER DEFAULT 1,
    branch_options JSONB,
    rewards JSONB
);

-- Bảng Quest_Progress
CREATE TABLE Quest_Progress (
    progress_id SERIAL PRIMARY KEY,
    character_id INTEGER NOT NULL,
    quest_id INTEGER NOT NULL,
    status TEXT CHECK (status IN ('Not Started', 'In Progress', 'Completed')) DEFAULT 'Not Started',
    progress_data JSONB,
    branch_choice VARCHAR(50),
    completed_at TIMESTAMP,
    reset_at TIMESTAMP,
    FOREIGN KEY (character_id) REFERENCES Characters(character_id) ON DELETE CASCADE,
    FOREIGN KEY (quest_id) REFERENCES Quests(quest_id)
);

-- Bảng Clans
CREATE TABLE Clans (
    clan_id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    leader_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    level INTEGER DEFAULT 1,
    war_points INTEGER DEFAULT 0,
    village_level INTEGER DEFAULT 0,
    resources JSONB,
    FOREIGN KEY (leader_id) REFERENCES Characters(character_id)
);

-- Bảng Clan_Members
CREATE TABLE Clan_Members (
    member_id SERIAL PRIMARY KEY,
    clan_id INTEGER NOT NULL,
    character_id INTEGER NOT NULL,
    role TEXT CHECK (role IN ('Leader', 'Officer', 'Member')) DEFAULT 'Member',
    FOREIGN KEY (clan_id) REFERENCES Clans(clan_id) ON DELETE CASCADE,
    FOREIGN KEY (character_id) REFERENCES Characters(character_id) ON DELETE CASCADE
);

-- Bảng PvP_Records
CREATE TABLE PvP_Records (
    pvp_id SERIAL PRIMARY KEY,
    character_id INTEGER NOT NULL,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    rank INTEGER DEFAULT 0,
    last_fight TIMESTAMP,
    FOREIGN KEY (character_id) REFERENCES Characters(character_id) ON DELETE CASCADE
);

-- Bảng Economy
CREATE TABLE Economy (
    economy_id SERIAL PRIMARY KEY,
    character_id INTEGER NOT NULL,
    currency_type TEXT CHECK (currency_type IN ('Gold', 'Gems', 'Astral Crystals')) NOT NULL,
    amount BIGINT DEFAULT 0,
    FOREIGN KEY (character_id) REFERENCES Characters(character_id) ON DELETE CASCADE
);

-- Bảng Events
CREATE TABLE Events (
    event_id SERIAL PRIMARY KEY,
    type TEXT CHECK (type IN ('Cycle', 'War', 'AR', 'Boss Raid')) NOT NULL,
    start_at TIMESTAMP NOT NULL,
    end_at TIMESTAMP,
    server_impact JSONB,
    participants JSONB
);

-- Bảng Sessions
CREATE TABLE Sessions (
    session_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    token VARCHAR(255) NOT NULL,
    platform TEXT CHECK (platform IN ('PC', 'Mobile')) NOT NULL,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_at TIMESTAMP,
    is_online BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Bảng Logs
CREATE TABLE Logs (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    action_type VARCHAR(50) NOT NULL,
    details JSONB,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Indexes cho performance
CREATE INDEX idx_characters_user_id ON Characters(user_id);
CREATE INDEX idx_characters_map_id ON Characters(map_id);
CREATE INDEX idx_character_skills_character_id ON Character_Skills(character_id);
CREATE INDEX idx_inventory_character_id ON Inventory(character_id);
CREATE INDEX idx_pets_character_id ON Pets(character_id);
CREATE INDEX idx_quest_progress_character_id ON Quest_Progress(character_id);
CREATE INDEX idx_clan_members_clan_id ON Clan_Members(clan_id);
CREATE INDEX idx_pvp_records_character_id ON PvP_Records(character_id);
CREATE INDEX idx_economy_character_id ON Economy(character_id);
CREATE INDEX idx_sessions_user_id ON Sessions(user_id);
CREATE INDEX idx_logs_user_id ON Logs(user_id);
CREATE INDEX idx_logs_timestamp ON Logs(timestamp);