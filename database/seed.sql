categories-- ============================================================
-- Localyze Seed Data
-- ============================================================

USE localyze;

-- ============================================================
-- 1. Categories
-- ============================================================
INSERT INTO categories (name, description, icon_url) VALUES
('Plumber', 'Plumbing repairs, installation, and maintenance services', NULL),
('Electrician', 'Electrical wiring, repairs, and installation services', NULL),
('Carpenter', 'Woodwork, furniture repair, and custom carpentry', NULL),
('RO Service', 'Water purifier installation, repair, and maintenance', NULL),
('Tiffin Service', 'Home-cooked meal delivery and tiffin subscription', NULL),
('House Help', 'Domestic cleaning, cooking, and household assistance', NULL),
('Laundry', 'Clothes washing, ironing, and dry cleaning services', NULL),
('Tailor', 'Stitching, alterations, and custom clothing', NULL),
('Ration Shop', 'Local grocery and daily essentials delivery', NULL),
('Painter', 'Interior and exterior painting services', NULL),
('AC Service', 'Air conditioner installation, repair, and servicing', NULL),
('Pest Control', 'Pest extermination and prevention services', NULL),
('Movers & Packers', 'Relocation, packing, and moving services', NULL),
('Tutor', 'Home tutoring and private coaching', NULL),
('Beauty & Salon', 'At-home beauty, grooming, and salon services', NULL);

-- ============================================================
-- 2. Admin User
-- Password: Admin@123 (BCrypt hashed)
-- ============================================================
INSERT INTO users (full_name, email, phone, password, role, is_verified, is_active) VALUES
('Admin', 'admin@localyze.com', '9999999999',
 '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
 'ADMIN', TRUE, TRUE);
