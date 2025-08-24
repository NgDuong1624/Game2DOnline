-- Create ENUM types
CREATE TYPE class_name_type AS ENUM ('Swordman', 'Gunner', 'Fighter', 'Mage');
CREATE TYPE item_type AS ENUM ('Weapon', 'Armor', 'Consumable', 'Devil_Fruit', 'Material', 'Other');
CREATE TYPE item_rarity AS ENUM ('Common', 'Rare', 'Epic', 'Legendary');
CREATE TYPE equip_slot_type AS ENUM ('Helmet', 'Armor', 'Pants', 'Weapon', 'Costume', 'None');
CREATE TYPE equip_target_type AS ENUM ('Player', 'Spirit', 'Both');
CREATE TYPE status_effect_type AS ENUM ('Buff', 'Debuff', 'Control', 'Special');
CREATE TYPE immunity_type AS ENUM ('None', 'Damage', 'Control', 'Both');
CREATE TYPE skill_target_type AS ENUM ('Self', 'SingleEnemy', 'MultiEnemy', 'AllAllies', 'AllEnemies');
CREATE TYPE quest_status_type AS ENUM ('Not Started', 'In Progress', 'Completed');
CREATE TYPE guild_role_type AS ENUM ('Leader', 'Officer', 'Member');
CREATE TYPE friend_status_type AS ENUM ('Pending', 'Accepted');
CREATE TYPE battle_type AS ENUM ('PvP', 'PvE');
CREATE TYPE rare_stat_type AS ENUM ('ExpPercent', 'HpPercent', 'AtkPercent', 'DefPercent', 'SpeedPercent', 'MpPercent', 'CritChance', 'CritDamage');
CREATE TYPE transaction_type AS ENUM ('Craft', 'Trade', 'Drop', 'Purchase', 'Reward', 'Consume', 'Upgrade');

-- Table for users
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,

    CONSTRAINT check_username_length CHECK (LENGTH(username) >= 3),
    CONSTRAINT check_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Table for game settings/configuration
CREATE TABLE game_settings (
    setting_key VARCHAR(50) PRIMARY KEY,
    setting_value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table for classes with base stats
CREATE TABLE classes (
    class_id SERIAL PRIMARY KEY,
    class_name class_name_type NOT NULL,
    description TEXT,
    base_hp INT DEFAULT 100,
    base_mp INT DEFAULT 50,
    base_atk INT DEFAULT 10,
    base_def INT DEFAULT 5,
    base_speed INT DEFAULT 10,

    CONSTRAINT check_positive_base_stats CHECK (
        base_hp > 0 AND base_mp > 0 AND base_atk > 0 AND
        base_def >= 0 AND base_speed > 0
    )
);

-- Table for cultivation stages
CREATE TABLE cultivation_stages (
    stage_id SERIAL PRIMARY KEY,
    stage_name VARCHAR(50) NOT NULL,
    required_exp BIGINT NOT NULL,
    hp_bonus INT DEFAULT 0,
    mp_bonus INT DEFAULT 0,
    atk_bonus INT DEFAULT 0,
    def_bonus INT DEFAULT 0,
    speed_bonus INT DEFAULT 0,
    description TEXT,

    CONSTRAINT check_positive_required_exp CHECK (required_exp >= 0),
    CONSTRAINT check_non_negative_bonuses CHECK (
        hp_bonus >= 0 AND mp_bonus >= 0 AND atk_bonus >= 0 AND
        def_bonus >= 0 AND speed_bonus >= 0
    )
);

-- Table for status effects
CREATE TABLE status_effects (
    effect_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    type status_effect_type NOT NULL,
    duration_seconds INT DEFAULT 0,
    is_stackable BOOLEAN DEFAULT FALSE,
    immunity_type immunity_type DEFAULT 'None',
    hp_modifier INT DEFAULT 0,
    atk_modifier NUMERIC DEFAULT 1.0,
    def_modifier NUMERIC DEFAULT 1.0,
    speed_modifier NUMERIC DEFAULT 1.0,
    mp_modifier INT DEFAULT 0,

    CONSTRAINT check_positive_duration CHECK (duration_seconds >= 0),
    CONSTRAINT check_positive_modifiers CHECK (
        atk_modifier >= 0 AND def_modifier >= 0 AND speed_modifier >= 0
    )
);

-- Table for items
CREATE TABLE items (
    item_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type item_type NOT NULL,
    description TEXT,
    rarity item_rarity DEFAULT 'Common',
    equip_slot equip_slot_type DEFAULT 'None',
    atk_bonus INT DEFAULT 0,
    def_bonus INT DEFAULT 0,
    hp_bonus INT DEFAULT 0,
    mp_bonus INT DEFAULT 0,
    speed_bonus INT DEFAULT 0,
    price BIGINT DEFAULT 0,
    is_stackable BOOLEAN DEFAULT TRUE,
    equip_target equip_target_type DEFAULT 'Player',
    cultivation_required INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_positive_price CHECK (price >= 0),
    CONSTRAINT check_non_negative_bonuses CHECK (
        atk_bonus >= 0 AND def_bonus >= 0 AND hp_bonus >= 0 AND
        mp_bonus >= 0 AND speed_bonus >= 0
        ),
    FOREIGN KEY (cultivation_required) REFERENCES cultivation_stages(stage_id)
);

-- Table for maps
CREATE TABLE maps (
    map_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    level_required INT DEFAULT 1,
    description TEXT,

    CONSTRAINT check_positive_level_required CHECK (level_required > 0)
);

-- Table for characters with stat points and equipped items
CREATE TABLE characters (
    character_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    class_id INT NOT NULL,
    level INT DEFAULT 1,
    experience BIGINT DEFAULT 0,
    hp_points INT DEFAULT 0,
    mp_points INT DEFAULT 0,
    atk_points INT DEFAULT 0,
    def_points INT DEFAULT 0,
    speed_points INT DEFAULT 0,
    gold BIGINT DEFAULT 0,
    cultivation_stage INT DEFAULT 1,
    current_map_id INT,
    helmet_id INT,
    armor_id INT,
    pants_id INT,
    weapon_id INT,
    costume_id INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_active TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_positive_level CHECK (level > 0),
    CONSTRAINT check_non_negative_exp_gold CHECK (experience >= 0 AND gold >= 0),
    CONSTRAINT check_non_negative_stat_points CHECK (
        hp_points >= 0 AND mp_points >= 0 AND atk_points >= 0 AND
        def_points >= 0 AND speed_points >= 0
        ),

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (cultivation_stage) REFERENCES cultivation_stages(stage_id),
    FOREIGN KEY (current_map_id) REFERENCES maps(map_id),
    FOREIGN KEY (helmet_id) REFERENCES items(item_id),
    FOREIGN KEY (armor_id) REFERENCES items(item_id),
    FOREIGN KEY (pants_id) REFERENCES items(item_id),
    FOREIGN KEY (weapon_id) REFERENCES items(item_id),
    FOREIGN KEY (costume_id) REFERENCES items(item_id)
);

-- Table for skills
CREATE TABLE skills (
    skill_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    class_id INT,
    level_required INT DEFAULT 1,
    mp_cost INT DEFAULT 0,
    damage_multiplier NUMERIC DEFAULT 1.0,
    cooldown_seconds INT DEFAULT 0,
    is_passive BOOLEAN DEFAULT FALSE,
    effect_duration_seconds INT DEFAULT 0,
    target_type skill_target_type DEFAULT 'SingleEnemy',
    is_aoe BOOLEAN DEFAULT FALSE,
    is_passive_immune BOOLEAN DEFAULT FALSE,
    immune_effect_id INT,

    CONSTRAINT check_positive_requirements CHECK (
        level_required > 0 AND mp_cost >= 0 AND damage_multiplier >= 0 AND
        cooldown_seconds >= 0 AND effect_duration_seconds >= 0
        ),

    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (immune_effect_id) REFERENCES status_effects(effect_id)
);

-- Table for skill cooldowns
CREATE TABLE skill_cooldowns (
    character_id INT NOT NULL,
    skill_id INT NOT NULL,
    cooldown_end TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (character_id, skill_id),

    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
);

-- Table for shadow spirits
CREATE TABLE shadow_spirits (
    spirit_id SERIAL PRIMARY KEY,
    character_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    level INT DEFAULT 1,
    experience BIGINT DEFAULT 0,
    hp INT NOT NULL,
    atk INT NOT NULL,
    def INT NOT NULL,
    summon_cost_mp INT DEFAULT 20,
    active_skill_id INT,
    is_summoned BOOLEAN DEFAULT FALSE,
    acquired_from_boss_id INT,
    rarity item_rarity DEFAULT 'Common',
    class_id INT,
    is_from_unique_boss BOOLEAN DEFAULT FALSE,

    CONSTRAINT check_positive_spirit_stats CHECK (
        level > 0 AND experience >= 0 AND hp > 0 AND atk > 0 AND
        def >= 0 AND summon_cost_mp >= 0
        ),

    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE,
    FOREIGN KEY (active_skill_id) REFERENCES skills(skill_id),
    FOREIGN KEY (class_id) REFERENCES classes(class_id)
);

-- Table for monsters
CREATE TABLE monsters (
    monster_id SERIAL PRIMARY KEY,
    map_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    level INT NOT NULL,
    hp INT NOT NULL,
    atk INT NOT NULL,
    def INT NOT NULL,
    exp_reward BIGINT DEFAULT 0,
    gold_reward BIGINT DEFAULT 0,
    drop_item_id INT,
    is_boss BOOLEAN DEFAULT FALSE,
    spirit_drop_id INT,
    drop_chance NUMERIC DEFAULT 0.0,
    is_unique_boss BOOLEAN DEFAULT FALSE,

    CONSTRAINT check_positive_monster_stats CHECK (
        level > 0 AND hp > 0 AND atk > 0 AND def >= 0 AND
        exp_reward >= 0 AND gold_reward >= 0
        ),
    CONSTRAINT check_valid_drop_chance CHECK (drop_chance >= 0.0 AND drop_chance <= 1.0),

    FOREIGN KEY (map_id) REFERENCES maps(map_id),
    FOREIGN KEY (drop_item_id) REFERENCES items(item_id),
    FOREIGN KEY (spirit_drop_id) REFERENCES shadow_spirits(spirit_id)
);

-- Junction table for character skills
CREATE TABLE character_skills (
    character_id INT NOT NULL,
    skill_id INT NOT NULL,
    skill_level INT DEFAULT 1,
    PRIMARY KEY (character_id, skill_id),

    CONSTRAINT check_positive_skill_level CHECK (skill_level > 0),

    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
);

-- Table for Devil Fruits
CREATE TABLE devil_fruits (
    devil_fruit_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    granted_skill_id INT NOT NULL,
    curse_description TEXT,
    passive_effect_id INT,

    FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE CASCADE,
    FOREIGN KEY (granted_skill_id) REFERENCES skills(skill_id),
    FOREIGN KEY (passive_effect_id) REFERENCES status_effects(effect_id)
);

-- Table for inventory (stores equipment and other items)
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    character_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT DEFAULT 1,
    acquired_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_positive_quantity CHECK (quantity > 0),

    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE CASCADE
);

-- Table for item transaction log
CREATE TABLE item_transaction_log (
    transaction_id SERIAL PRIMARY KEY,
    character_id INT,
    item_id INT,
    quantity INT,
    transaction_type transaction_type NOT NULL,
    gold_cost BIGINT DEFAULT 0,
    notes TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE SET NULL,
    FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE SET NULL
);

-- Table for item upgrades
CREATE TABLE item_upgrades (
    item_id INT PRIMARY KEY,
    upgrade_level INT DEFAULT 0,
    star_level INT DEFAULT 0,
    upgrade_cost BIGINT DEFAULT 0,
    star_cost BIGINT DEFAULT 0,
    atk_bonus INT DEFAULT 0,
    def_bonus INT DEFAULT 0,
    hp_bonus INT DEFAULT 0,
    mp_bonus INT DEFAULT 0,
    speed_bonus INT DEFAULT 0,

    CONSTRAINT check_non_negative_upgrade_levels CHECK (
        upgrade_level >= 0 AND star_level >= 0
        ),
    CONSTRAINT check_non_negative_upgrade_costs CHECK (
        upgrade_cost >= 0 AND star_cost >= 0
        ),
    CONSTRAINT check_non_negative_upgrade_bonuses CHECK (
        atk_bonus >= 0 AND def_bonus >= 0 AND hp_bonus >= 0 AND
        mp_bonus >= 0 AND speed_bonus >= 0
        ),

    FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE CASCADE
);

-- Table for item rare stats
CREATE TABLE item_rare_stats (
    item_id INT NOT NULL,
    stat_type rare_stat_type NOT NULL,
    stat_value NUMERIC NOT NULL,
    PRIMARY KEY (item_id, stat_type),

    CONSTRAINT check_positive_stat_value CHECK (stat_value > 0),

    FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE CASCADE
);

-- Junction table for skills and status effects
CREATE TABLE skill_effects (
    skill_id INT NOT NULL,
    effect_id INT NOT NULL,
    chance NUMERIC DEFAULT 1.0,
    PRIMARY KEY (skill_id, effect_id),

    CONSTRAINT check_valid_chance CHECK (chance >= 0.0 AND chance <= 1.0),

    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    FOREIGN KEY (effect_id) REFERENCES status_effects(effect_id) ON DELETE CASCADE
);

-- Table for character status effects
CREATE TABLE character_status (
    character_id INT NOT NULL,
    effect_id INT NOT NULL,
    remaining_duration_seconds INT NOT NULL,
    applied_by_skill_id INT,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (character_id, effect_id),

    CONSTRAINT check_positive_duration CHECK (remaining_duration_seconds >= 0),

    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE,
    FOREIGN KEY (effect_id) REFERENCES status_effects(effect_id) ON DELETE CASCADE,
    FOREIGN KEY (applied_by_skill_id) REFERENCES skills(skill_id)
);

-- Table for shadow spirit status effects
CREATE TABLE spirit_status (
    spirit_id INT NOT NULL,
    effect_id INT NOT NULL,
    remaining_duration_seconds INT NOT NULL,
    applied_by_skill_id INT,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (spirit_id, effect_id),

    CONSTRAINT check_positive_spirit_duration CHECK (remaining_duration_seconds >= 0),

    FOREIGN KEY (spirit_id) REFERENCES shadow_spirits(spirit_id) ON DELETE CASCADE,
    FOREIGN KEY (effect_id) REFERENCES status_effects(effect_id) ON DELETE CASCADE,
    FOREIGN KEY (applied_by_skill_id) REFERENCES skills(skill_id)
);

-- Junction table for passive skill immunities
CREATE TABLE passive_skill_immunities (
    skill_id INT NOT NULL,
    effect_id INT NOT NULL,
    PRIMARY KEY (skill_id, effect_id),

    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    FOREIGN KEY (effect_id) REFERENCES status_effects(effect_id) ON DELETE CASCADE
);

-- Table for item sets
CREATE TABLE item_sets (
    set_id SERIAL PRIMARY KEY,
    set_name VARCHAR(100) NOT NULL,
    description TEXT,
    required_items_count INT NOT NULL,
    bonus_hp_percent NUMERIC DEFAULT 0.0,
    bonus_atk_percent NUMERIC DEFAULT 0.0,
    bonus_def_percent NUMERIC DEFAULT 0.0,
    bonus_speed_percent NUMERIC DEFAULT 0.0,
    bonus_effect_id INT,

    CONSTRAINT check_positive_required_items CHECK (required_items_count > 0),
    CONSTRAINT check_non_negative_bonuses_percent CHECK (
        bonus_hp_percent >= 0.0 AND bonus_atk_percent >= 0.0 AND
        bonus_def_percent >= 0.0 AND bonus_speed_percent >= 0.0
        ),

    FOREIGN KEY (bonus_effect_id) REFERENCES status_effects(effect_id)
);

-- Junction table for item sets
CREATE TABLE item_set_members (
    set_id INT NOT NULL,
    item_id INT NOT NULL,
    PRIMARY KEY (set_id, item_id),

    FOREIGN KEY (set_id) REFERENCES item_sets(set_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE CASCADE
);

-- Table for item special mechanics
CREATE TABLE item_specials (
    special_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    description TEXT,
    target_type equip_target_type DEFAULT 'Player',
    hp_bonus INT DEFAULT 0,
    atk_bonus INT DEFAULT 0,
    def_bonus INT DEFAULT 0,
    speed_bonus INT DEFAULT 0,
    effect_id INT,
    cultivation_required INT,

    CONSTRAINT check_non_negative_special_bonuses CHECK (
        hp_bonus >= 0 AND atk_bonus >= 0 AND def_bonus >= 0 AND speed_bonus >= 0
        ),

    FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE CASCADE,
    FOREIGN KEY (effect_id) REFERENCES status_effects(effect_id),
    FOREIGN KEY (cultivation_required) REFERENCES cultivation_stages(stage_id)
);

-- Table for shadow spirit skills
CREATE TABLE shadow_spirit_skills (
    spirit_id INT NOT NULL,
    skill_id INT NOT NULL,
    unlock_cultivation_stage INT NOT NULL,
    skill_order INT NOT NULL,
    PRIMARY KEY (spirit_id, skill_id),

    CONSTRAINT check_positive_skill_order CHECK (skill_order > 0),

    FOREIGN KEY (spirit_id) REFERENCES shadow_spirits(spirit_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    FOREIGN KEY (unlock_cultivation_stage) REFERENCES cultivation_stages(stage_id)
);

-- Table for quests
CREATE TABLE quests (
    quest_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    level_required INT DEFAULT 1,
    reward_exp BIGINT DEFAULT 0,
    reward_gold BIGINT DEFAULT 0,
    reward_item_id INT,
    is_repeatable BOOLEAN DEFAULT FALSE,

    CONSTRAINT check_positive_quest_requirements CHECK (
        level_required > 0 AND reward_exp >= 0 AND reward_gold >= 0
        ),

    FOREIGN KEY (reward_item_id) REFERENCES items(item_id)
);

-- Junction table for character quests
CREATE TABLE character_quests (
    character_id INT NOT NULL,
    quest_id INT NOT NULL,
    status quest_status_type DEFAULT 'Not Started',
    progress INT DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (character_id, quest_id),

    CONSTRAINT check_non_negative_progress CHECK (progress >= 0),

    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE,
    FOREIGN KEY (quest_id) REFERENCES quests(quest_id) ON DELETE CASCADE
);

-- Table for guilds
CREATE TABLE guilds (
    guild_id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    leader_character_id INT NOT NULL,
    description TEXT,
    max_members INT DEFAULT 50,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_positive_max_members CHECK (max_members > 0),
    CONSTRAINT check_guild_name_length CHECK (LENGTH(name) >= 3),

    FOREIGN KEY (leader_character_id) REFERENCES characters(character_id)
);

-- Junction table for guild members
CREATE TABLE guild_members (
    guild_id INT NOT NULL,
    character_id INT NOT NULL,
    role guild_role_type DEFAULT 'Member',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    contribution_points BIGINT DEFAULT 0,
    PRIMARY KEY (guild_id, character_id),

    CONSTRAINT check_non_negative_contribution CHECK (contribution_points >= 0),

    FOREIGN KEY (guild_id) REFERENCES guilds(guild_id) ON DELETE CASCADE,
    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE
);

-- Table for friends
CREATE TABLE friends (
    character_id1 INT NOT NULL,
    character_id2 INT NOT NULL,
    status friend_status_type DEFAULT 'Pending',
    friends_since TIMESTAMP WITH TIME ZONE,
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (character_id1, character_id2),

    CONSTRAINT check_different_characters CHECK (character_id1 != character_id2),

    FOREIGN KEY (character_id1) REFERENCES characters(character_id) ON DELETE CASCADE,
    FOREIGN KEY (character_id2) REFERENCES characters(character_id) ON DELETE CASCADE
);

-- Table for battle logs
CREATE TABLE battle_logs (
    battle_id SERIAL PRIMARY KEY,
    attacker_id INT NOT NULL,
    defender_id INT NOT NULL,
    battle_type battle_type NOT NULL,
    winner_id INT,
    battle_duration_seconds INT DEFAULT 0,
    exp_gained BIGINT DEFAULT 0,
    gold_gained BIGINT DEFAULT 0,
    log TEXT,
    status_effects_applied JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_non_negative_battle_results CHECK (
        battle_duration_seconds >= 0 AND exp_gained >= 0 AND gold_gained >= 0
        )
);

-- Enhanced function to calculate character stats including rare stats and cultivation bonuses
CREATE OR REPLACE FUNCTION calculate_character_stats(p_character_id INT)
    RETURNS TABLE (
                      total_hp INT,
                      total_mp INT,
                      total_atk INT,
                      total_def INT,
                      total_speed INT,
                      crit_chance NUMERIC,
                      crit_damage NUMERIC
                  ) AS $$
DECLARE
    char_record RECORD;
    class_record RECORD;
    cultivation_record RECORD;
    equipment_bonuses RECORD;
    rare_stats RECORD;
BEGIN
    -- Get character data
    SELECT * INTO char_record FROM characters WHERE character_id = p_character_id;

    -- Get class base stats
    SELECT * INTO class_record FROM classes WHERE class_id = char_record.class_id;

    -- Get cultivation bonuses
    SELECT * INTO cultivation_record FROM cultivation_stages WHERE stage_id = char_record.cultivation_stage;

    -- Calculate equipment bonuses (including upgrades and specials)
    SELECT
        COALESCE(SUM(i.hp_bonus + COALESCE(iu.hp_bonus, 0) + COALESCE(isp.hp_bonus, 0)), 0) as hp_bonus,
        COALESCE(SUM(i.mp_bonus + COALESCE(iu.mp_bonus, 0)), 0) as mp_bonus,
        COALESCE(SUM(i.atk_bonus + COALESCE(iu.atk_bonus, 0) + COALESCE(isp.atk_bonus, 0)), 0) as atk_bonus,
        COALESCE(SUM(i.def_bonus + COALESCE(iu.def_bonus, 0) + COALESCE(isp.def_bonus, 0)), 0) as def_bonus,
        COALESCE(SUM(i.speed_bonus + COALESCE(iu.speed_bonus, 0) + COALESCE(isp.speed_bonus, 0)), 0) as speed_bonus
    INTO equipment_bonuses
    FROM items i
             LEFT JOIN item_upgrades iu ON i.item_id = iu.item_id
             LEFT JOIN item_specials isp ON i.item_id = isp.item_id
    WHERE i.item_id IN (
                        char_record.helmet_id, char_record.armor_id, char_record.pants_id,
                        char_record.weapon_id, char_record.costume_id
        ) AND i.item_id IS NOT NULL;

    -- Get rare stats
    SELECT
        COALESCE(SUM(CASE WHEN irs.stat_type = 'CritChance' THEN irs.stat_value ELSE 0 END), 0) as crit_chance,
        COALESCE(SUM(CASE WHEN irs.stat_type = 'CritDamage' THEN irs.stat_value ELSE 0 END), 0) as crit_damage
    INTO rare_stats
    FROM items i
             JOIN item_rare_stats irs ON i.item_id = irs.item_id
    WHERE i.item_id IN (
                        char_record.helmet_id, char_record.armor_id, char_record.pants_id,
                        char_record.weapon_id, char_record.costume_id
        ) AND i.item_id IS NOT NULL;

    -- Calculate final stats
    RETURN QUERY
        SELECT
            (class_record.base_hp + (char_record.hp_points * 5) +
             COALESCE(cultivation_record.hp_bonus, 0) + COALESCE(equipment_bonuses.hp_bonus, 0))::INT,
            (class_record.base_mp + (char_record.mp_points * 3) +
             COALESCE(cultivation_record.mp_bonus, 0) + COALESCE(equipment_bonuses.mp_bonus, 0))::INT,
            (class_record.base_atk + (char_record.atk_points * 2) +
             COALESCE(cultivation_record.atk_bonus, 0) + COALESCE(equipment_bonuses.atk_bonus, 0))::INT,
            (class_record.base_def + (char_record.def_points * 2) +
             COALESCE(cultivation_record.def_bonus, 0) + COALESCE(equipment_bonuses.def_bonus, 0))::INT,
            (class_record.base_speed + (char_record.speed_points * 1) +
             COALESCE(cultivation_record.speed_bonus, 0) + COALESCE(equipment_bonuses.speed_bonus, 0))::INT,
            COALESCE(rare_stats.crit_chance, 0.0),
            COALESCE(rare_stats.crit_damage, 0.0);
END;
$$ LANGUAGE plpgsql;

-- Function to check if skill is on cooldown
CREATE OR REPLACE FUNCTION is_skill_on_cooldown(p_character_id INT, p_skill_id INT)
    RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM skill_cooldowns
        WHERE character_id = p_character_id
          AND skill_id = p_skill_id
          AND cooldown_end > CURRENT_TIMESTAMP
    );
END;
$$ LANGUAGE plpgsql;

-- Function to add skill cooldown
CREATE OR REPLACE FUNCTION add_skill_cooldown(p_character_id INT, p_skill_id INT)
    RETURNS VOID AS $$
DECLARE
    cooldown_seconds INT;
BEGIN
    SELECT s.cooldown_seconds INTO cooldown_seconds
    FROM skills s WHERE skill_id = p_skill_id;

    INSERT INTO skill_cooldowns (character_id, skill_id, cooldown_end)
    VALUES (p_character_id, p_skill_id, CURRENT_TIMESTAMP + INTERVAL '1 second' * cooldown_seconds)
    ON CONFLICT (character_id, skill_id)
        DO UPDATE SET cooldown_end = CURRENT_TIMESTAMP + INTERVAL '1 second' * cooldown_seconds;
END;
$$ LANGUAGE plpgsql;

-- Procedure to create shadow spirit from boss
CREATE OR REPLACE PROCEDURE create_shadow_spirit_from_boss(p_character_id INT, p_boss_id INT)
    LANGUAGE plpgsql AS $$
DECLARE
    random_class_id INT;
    new_spirit_id INT;
    punch_skill_id INT;
    random_skill_1 INT;
    random_skill_2 INT;
BEGIN
    SELECT class_id INTO random_class_id FROM classes ORDER BY RANDOM() LIMIT 1;
    SELECT skill_id INTO punch_skill_id FROM skills WHERE name = 'Spirit Punch' LIMIT 1;
    SELECT skill_id INTO random_skill_1 FROM skills WHERE skill_id != punch_skill_id ORDER BY RANDOM() LIMIT 1;
    SELECT skill_id INTO random_skill_2 FROM skills WHERE skill_id NOT IN (punch_skill_id, random_skill_1) ORDER BY RANDOM() LIMIT 1;

    INSERT INTO shadow_spirits (
        character_id, name, level, hp, atk, def, summon_cost_mp, is_summoned,
        acquired_from_boss_id, is_from_unique_boss, class_id, rarity
    )
    VALUES (
        p_character_id, 'Dark Spirit ' || FLOOR(RANDOM() * 1000)::TEXT, 1, 100, 20, 15, 20, FALSE,
        p_boss_id, TRUE, random_class_id, 'Epic'
    )
    RETURNING spirit_id INTO new_spirit_id;

    INSERT INTO shadow_spirit_skills (spirit_id, skill_id, unlock_cultivation_stage, skill_order)
    VALUES
        (new_spirit_id, punch_skill_id, (SELECT stage_id FROM cultivation_stages WHERE stage_name = 'Qi Condensation'), 1),
        (new_spirit_id, random_skill_1, (SELECT stage_id FROM cultivation_stages WHERE stage_name = 'Foundation Establishment'), 2),
        (new_spirit_id, random_skill_2, (SELECT stage_id FROM cultivation_stages WHERE stage_name = 'Core Formation'), 3);
END;
$$;

-- Procedure to add random rare stat
CREATE OR REPLACE PROCEDURE add_random_rare_stat(p_item_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    stat_types rare_stat_type[] := ARRAY['ExpPercent', 'HpPercent', 'AtkPercent', 'DefPercent', 'SpeedPercent', 'MpPercent', 'CritChance', 'CritDamage']::rare_stat_type[];
    random_stat rare_stat_type;
    random_value NUMERIC;
BEGIN
    random_stat := stat_types[FLOOR(RANDOM() * array_length(stat_types, 1) + 1)];
    random_value := ROUND((RANDOM() * 0.15 + 0.05)::NUMERIC, 3);

    INSERT INTO item_rare_stats (item_id, stat_type, stat_value)
    VALUES (p_item_id, random_stat, random_value)
    ON CONFLICT DO NOTHING;
END;
$$;

-- Procedure to log item transaction
CREATE OR REPLACE PROCEDURE log_item_transaction(
    p_character_id INT,
    p_item_id INT,
    p_quantity INT,
    p_transaction_type transaction_type,
    p_gold_cost BIGINT DEFAULT 0,
    p_notes TEXT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO item_transaction_log (character_id, item_id, quantity, transaction_type, gold_cost, notes)
    VALUES (p_character_id, p_item_id, p_quantity, p_transaction_type, p_gold_cost, p_notes);
END;
$$;

-- Function to clean expired cooldowns
CREATE OR REPLACE FUNCTION clean_expired_cooldowns()
RETURNS INT AS $$
DECLARE
    deleted_count INT;
BEGIN
    DELETE FROM skill_cooldowns WHERE cooldown_end <= CURRENT_TIMESTAMP;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to clean expired status effects
CREATE OR REPLACE FUNCTION clean_expired_status_effects()
RETURNS INT AS $$
DECLARE
    deleted_count INT;
BEGIN
    -- Clean character status effects
    DELETE FROM character_status WHERE remaining_duration_seconds <= 0;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;

    -- Clean spirit status effects
    DELETE FROM spirit_status WHERE remaining_duration_seconds <= 0;

    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to update last_active timestamp
CREATE OR REPLACE FUNCTION update_character_last_active()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_active = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update character last_active on any update
CREATE TRIGGER character_last_active_trigger
    BEFORE UPDATE ON characters
    FOR EACH ROW
    EXECUTE FUNCTION update_character_last_active();

-- Trigger function to log item transactions automatically
CREATE OR REPLACE FUNCTION auto_log_inventory_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO item_transaction_log (character_id, item_id, quantity, transaction_type, notes)
        VALUES (NEW.character_id, NEW.item_id, NEW.quantity, 'Drop', 'Item acquired');
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.quantity > OLD.quantity THEN
            INSERT INTO item_transaction_log (character_id, item_id, quantity, transaction_type, notes)
            VALUES (NEW.character_id, NEW.item_id, NEW.quantity - OLD.quantity, 'Drop', 'Item quantity increased');
        ELSIF NEW.quantity < OLD.quantity THEN
            INSERT INTO item_transaction_log (character_id, item_id, quantity, transaction_type, notes)
            VALUES (NEW.character_id, NEW.item_id, OLD.quantity - NEW.quantity, 'Consume', 'Item quantity decreased');
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO item_transaction_log (character_id, item_id, quantity, transaction_type, notes)
        VALUES (OLD.character_id, OLD.item_id, OLD.quantity, 'Consume', 'Item removed from inventory');
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger for automatic inventory logging
CREATE TRIGGER inventory_changes_log_trigger
    AFTER INSERT OR UPDATE OR DELETE ON inventory
    FOR EACH ROW
    EXECUTE FUNCTION auto_log_inventory_changes();

-- Performance Indexes
CREATE INDEX idx_character_user ON characters(user_id);
CREATE INDEX idx_character_level ON characters(level);
CREATE INDEX idx_character_last_active ON characters(last_active);
CREATE INDEX idx_inventory_character ON inventory(character_id);
CREATE INDEX idx_inventory_item ON inventory(item_id);
CREATE INDEX idx_shadow_spirit_character ON shadow_spirits(character_id);
CREATE INDEX idx_monster_map ON monsters(map_id);
CREATE INDEX idx_monster_boss ON monsters(is_boss) WHERE is_boss = true;
CREATE INDEX idx_item_upgrades_item ON item_upgrades(item_id);
CREATE INDEX idx_item_rare_stats_item ON item_rare_stats(item_id);
CREATE INDEX idx_skill_cooldowns_character ON skill_cooldowns(character_id);
CREATE INDEX idx_skill_cooldowns_end ON skill_cooldowns(cooldown_end);
CREATE INDEX idx_character_status_character ON character_status(character_id);
CREATE INDEX idx_spirit_status_spirit ON spirit_status(spirit_id);
CREATE INDEX idx_battle_logs_attacker ON battle_logs(attacker_id);
CREATE INDEX idx_battle_logs_defender ON battle_logs(defender_id);
CREATE INDEX idx_battle_logs_timestamp ON battle_logs(timestamp);
CREATE INDEX idx_transaction_log_character ON item_transaction_log(character_id);
CREATE INDEX idx_transaction_log_timestamp ON item_transaction_log(timestamp);
CREATE INDEX idx_guild_members_guild ON guild_members(guild_id);
CREATE INDEX idx_guild_members_character ON guild_members(character_id);

-- Initial game settings data
INSERT INTO game_settings (setting_key, setting_value, description) VALUES
('max_level', '1000', 'Maximum character level'),
('base_exp_multiplier', '1.0', 'Base experience gain multiplier'),
('base_gold_multiplier', '1.0', 'Base gold gain multiplier'),
('max_inventory_slots', '100', 'Maximum inventory slots per character'),
('guild_creation_cost', '10000', 'Cost in gold to create a guild'),
('friend_list_max', '50', 'Maximum friends per character'),
('daily_quest_reset_hour', '0', 'Hour of day when daily quests reset (0-23)'),
('pvp_level_requirement', '10', 'Minimum level required for PvP battles'),
('spirit_summon_duration', '300', 'Default spirit summon duration in seconds');

-- Sample cultivation stages
INSERT INTO cultivation_stages (stage_name, required_exp, hp_bonus, mp_bonus, atk_bonus, def_bonus, speed_bonus, description) VALUES
('Mortal Realm', 0, 0, 0, 0, 0, 0, 'The beginning stage for all cultivators'),
('Qi Condensation', 1000, 10, 5, 2, 1, 1, 'First step into cultivation'),
('Foundation Establishment', 5000, 25, 15, 5, 3, 2, 'Building a solid foundation'),
('Core Formation', 15000, 50, 30, 10, 6, 4, 'Forming the cultivation core'),
('Nascent Soul', 50000, 100, 60, 20, 12, 8, 'Birth of the nascent soul'),
('Soul Transformation', 150000, 200, 120, 40, 25, 15, 'Transforming the soul'),
('Void Refinement', 500000, 400, 240, 80, 50, 30, 'Refining the void within'),
('Body Integration', 1500000, 800, 480, 160, 100, 60, 'Integrating body and soul'),
('Mahayana', 5000000, 1600, 960, 320, 200, 120, 'Great vehicle cultivation'),
('True Immortal', 15000000, 3200, 1920, 640, 400, 240, 'Achieving true immortality');

-- Sample classes
INSERT INTO classes (class_name, description, base_hp, base_mp, base_atk, base_def, base_speed) VALUES
('Swordman', 'Master of blade combat with balanced offense and defense', 120, 40, 12, 8, 10),
('Gunner', 'Long-range specialist with high damage but low defense', 80, 60, 15, 4, 12),
('Fighter', 'Close combat expert with high health and defense', 150, 30, 10, 12, 8),
('Mage', 'Magic user with powerful spells and high mana', 70, 100, 8, 3, 6);