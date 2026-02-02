--liquibase formatted sql

--changeset maksim:1
--comment: Создание таблицы пользователей
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--changeset maksim:2
--comment: Добавление тестового пользователя
INSERT INTO users (username, email) VALUES ('jenkins_bot', 'bot@jenkins.local');
