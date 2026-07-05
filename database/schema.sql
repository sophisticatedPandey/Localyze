-- ============================================================
-- Localyze Database Schema
-- MySQL 8.x
-- ============================================================

CREATE DATABASE IF NOT EXISTS localyze;
USE localyze;

-- ============================================================
-- 1. USERS
-- ============================================================
CREATE TABLE users (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100)    NOT NULL,
    email           VARCHAR(255)    NOT NULL,
    phone           VARCHAR(15)     NOT NULL,
    password        VARCHAR(255)    NOT NULL,
    role            ENUM('USER', 'SELLER', 'ADMIN') NOT NULL DEFAULT 'USER',
    profile_image_url VARCHAR(500)  NULL,
    address         VARCHAR(500)    NULL,
    latitude        DECIMAL(10, 8)  NULL,
    longitude       DECIMAL(11, 8)  NULL,
    is_verified     BOOLEAN         NOT NULL DEFAULT FALSE,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    verification_token VARCHAR(255) NULL,
    reset_token     VARCHAR(255)    NULL,
    reset_token_expiry TIMESTAMP    NULL,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uk_users_email UNIQUE (email),
    CONSTRAINT uk_users_phone UNIQUE (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);

-- ============================================================
-- 2. CATEGORIES
-- ============================================================
CREATE TABLE categories (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL,
    description     VARCHAR(500)    NULL,
    icon_url        VARCHAR(500)    NULL,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_categories_name UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. SERVICES
-- ============================================================
CREATE TABLE services (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    seller_id       BIGINT          NOT NULL,
    category_id     BIGINT          NOT NULL,
    title           VARCHAR(200)    NOT NULL,
    description     TEXT            NOT NULL,
    price           DECIMAL(10, 2)  NOT NULL,
    price_unit      VARCHAR(20)     NOT NULL DEFAULT 'fixed',
    address         VARCHAR(500)    NOT NULL,
    latitude        DECIMAL(10, 8)  NOT NULL,
    longitude       DECIMAL(11, 8)  NOT NULL,
    availability    VARCHAR(200)    NULL,
    status          ENUM('ACTIVE', 'INACTIVE', 'PENDING', 'REJECTED') NOT NULL DEFAULT 'ACTIVE',
    avg_rating      DECIMAL(2, 1)   NOT NULL DEFAULT 0.0,
    total_reviews   INT             NOT NULL DEFAULT 0,
    is_deleted      BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_services_seller   FOREIGN KEY (seller_id)   REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_services_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    CONSTRAINT chk_services_price   CHECK (price > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_services_seller ON services(seller_id);
CREATE INDEX idx_services_category ON services(category_id);
CREATE INDEX idx_services_status ON services(status);
CREATE INDEX idx_services_location ON services(latitude, longitude);
CREATE INDEX idx_services_price ON services(price);
CREATE INDEX idx_services_avg_rating ON services(avg_rating);

-- ============================================================
-- 4. SERVICE IMAGES
-- ============================================================
CREATE TABLE service_images (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    service_id      BIGINT          NOT NULL,
    image_url       VARCHAR(500)    NOT NULL,
    public_id       VARCHAR(255)    NULL,
    display_order   INT             NOT NULL DEFAULT 0,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_service_images_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_service_images_service ON service_images(service_id);

-- ============================================================
-- 5. BOOKINGS
-- ============================================================
CREATE TABLE bookings (
    id                  BIGINT      AUTO_INCREMENT PRIMARY KEY,
    user_id             BIGINT      NOT NULL,
    service_id          BIGINT      NOT NULL,
    seller_id           BIGINT      NOT NULL,
    status              ENUM('PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    booking_date        DATE        NOT NULL,
    time_slot           VARCHAR(50) NULL,
    notes               TEXT        NULL,
    cancellation_reason TEXT        NULL,
    created_at          TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_bookings_user    FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_bookings_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    CONSTRAINT fk_bookings_seller  FOREIGN KEY (seller_id)  REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_seller ON bookings(seller_id);
CREATE INDEX idx_bookings_service ON bookings(service_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_date ON bookings(booking_date);

-- ============================================================
-- 6. PAYMENTS (Razorpay)
-- ============================================================
CREATE TABLE payments (
    id                      BIGINT          AUTO_INCREMENT PRIMARY KEY,
    booking_id              BIGINT          NOT NULL,
    user_id                 BIGINT          NOT NULL,
    razorpay_order_id       VARCHAR(255)    NOT NULL,
    razorpay_payment_id     VARCHAR(255)    NULL,
    razorpay_signature      VARCHAR(255)    NULL,
    amount                  DECIMAL(10, 2)  NOT NULL,
    currency                VARCHAR(10)     NOT NULL DEFAULT 'INR',
    status                  ENUM('CREATED', 'PAID', 'FAILED', 'REFUNDED') NOT NULL DEFAULT 'CREATED',
    created_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    CONSTRAINT fk_payments_user    FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT uk_payments_razorpay_order UNIQUE (razorpay_order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_payments_booking ON payments(booking_id);
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);

-- ============================================================
-- 7. REVIEWS
-- ============================================================
CREATE TABLE reviews (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT          NOT NULL,
    service_id      BIGINT          NOT NULL,
    booking_id      BIGINT          NOT NULL,
    rating          INT             NOT NULL,
    comment         TEXT            NULL,
    is_deleted      BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_reviews_user    FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    CONSTRAINT uk_reviews_booking UNIQUE (booking_id),
    CONSTRAINT chk_reviews_rating CHECK (rating >= 1 AND rating <= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_reviews_service ON reviews(service_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);

-- ============================================================
-- 8. MESSAGES
-- ============================================================
CREATE TABLE messages (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    booking_id      BIGINT          NOT NULL,
    sender_id       BIGINT          NOT NULL,
    receiver_id     BIGINT          NOT NULL,
    content         TEXT            NOT NULL,
    is_read         BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_messages_booking  FOREIGN KEY (booking_id)  REFERENCES bookings(id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_sender   FOREIGN KEY (sender_id)   REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_messages_booking ON messages(booking_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_receiver ON messages(receiver_id);
CREATE INDEX idx_messages_is_read ON messages(is_read);
