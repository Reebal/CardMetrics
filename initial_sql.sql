create database banking;
use banking;
drop table transactions_data;
CREATE TABLE users_data (
    id INT PRIMARY KEY,
    current_age INT NOT NULL,
    retirement_age INT NOT NULL,
    birth_year INT NOT NULL,
    birth_month INT NOT NULL,
    gender VARCHAR(10) NOT NULL,
    address VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 6) NOT NULL,
    longitude DECIMAL(10, 6) NOT NULL,
    per_capita_income DECIMAL(10, 2) NOT NULL,
    yearly_income DECIMAL(10, 2) NOT NULL,
    total_debt DECIMAL(10, 2) NOT NULL,
    credit_score INT NOT NULL,
    num_credit_cards INT NOT NULL
);

CREATE TABLE cards_data (
    id INT PRIMARY KEY,
    client_id INT,
    card_brand VARCHAR(50),
    card_type VARCHAR(50),
    card_number VARCHAR(20),
    expires DATE,
    cvv VARCHAR(4),
    has_chip ENUM('YES', 'NO'),
    num_cards_issued INT,
    credit_limit DECIMAL(10, 2),
    acct_open_date DATE,
    year_pin_last_changed YEAR,
    FOREIGN KEY (client_id) REFERENCES users_data(id) ON DELETE CASCADE
);


CREATE TABLE transactions_data (
    id INT PRIMARY KEY,
    date DATE NOT NULL,
    client_id INT NOT NULL,
    card_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    use_chip VARCHAR(50) NOT NULL,
    merchant_id INT NOT NULL,
    merchant_city VARCHAR(100) NOT NULL,
    merchant_state VARCHAR(100) NOT NULL,
    zip CHAR(5) NOT NULL,
    mcc INT NOT NULL,
    errors VARCHAR(100),
    FOREIGN KEY (client_id) REFERENCES users_data (id) ON DELETE CASCADE,
    FOREIGN KEY (card_id) REFERENCES cards_data (id) ON DELETE CASCADE
);
