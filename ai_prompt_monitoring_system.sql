-- =====================================================
-- AI PROMPT MONITORING SYSTEM
-- Author: Yash Jain
-- =====================================================

-- =====================================================
-- DATABASE CREATION
-- =====================================================

DROP DATABASE IF EXISTS ai_prompt_monitoring;

CREATE DATABASE ai_prompt_monitoring;

USE ai_prompt_monitoring;

-- =====================================================
-- USERS TABLE
-- =====================================================

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    role VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- AI MODELS TABLE
-- =====================================================

CREATE TABLE ai_models (
    model_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(50),
    provider VARCHAR(50),
    version VARCHAR(20)
);

-- =====================================================
-- PROMPTS TABLE
-- =====================================================

CREATE TABLE prompts (
    prompt_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    model_id INT,
    prompt_text TEXT,
    risk_level VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (model_id) REFERENCES ai_models(model_id)
);

-- =====================================================
-- RESPONSES TABLE
-- =====================================================

CREATE TABLE responses (
    response_id INT AUTO_INCREMENT PRIMARY KEY,
    prompt_id INT,
    response_text TEXT,
    response_time FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (prompt_id) REFERENCES prompts(prompt_id)
);

-- =====================================================
-- SENSITIVE KEYWORDS TABLE
-- =====================================================

CREATE TABLE sensitive_keywords (
    keyword_id INT AUTO_INCREMENT PRIMARY KEY,
    keyword VARCHAR(50),
    risk_type VARCHAR(50)
);

-- =====================================================
-- AUDIT LOG TABLE
-- =====================================================

CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    prompt_id INT,
    action VARCHAR(100),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- SAMPLE DATA INSERTION
-- =====================================================

INSERT INTO users(username,email,role) VALUES
('Yash','yash@example.com','Researcher'),
('Admin','admin@example.com','Security'),
('Guest','guest@example.com','User');

INSERT INTO ai_models(model_name,provider,version) VALUES
('GPT','OpenAI','4'),
('Gemini','Google','1.5'),
('Copilot','Microsoft','2025');

INSERT INTO sensitive_keywords(keyword,risk_type) VALUES
('password','data_leak'),
('bank','financial'),
('credit card','financial'),
('api key','security'),
('private key','security');

-- =====================================================
-- TRIGGER FOR AUTOMATIC RISK DETECTION
-- =====================================================

DELIMITER $$

CREATE TRIGGER detect_prompt_risk
BEFORE INSERT ON prompts
FOR EACH ROW
BEGIN

IF NEW.prompt_text LIKE '%password%' 
   OR NEW.prompt_text LIKE '%credit card%'
   OR NEW.prompt_text LIKE '%api key%' 
   OR NEW.prompt_text LIKE '%private key%' THEN

   SET NEW.risk_level = 'High';

ELSEIF NEW.prompt_text LIKE '%bank%' THEN

   SET NEW.risk_level = 'Medium';

ELSE

   SET NEW.risk_level = 'Low';

END IF;

END$$

DELIMITER ;

-- =====================================================
-- SAMPLE PROMPTS
-- =====================================================

INSERT INTO prompts(user_id,model_id,prompt_text)
VALUES
(1,1,'Explain machine learning'),
(1,1,'Generate admin password list'),
(2,2,'How to secure API keys'),
(3,3,'Explain cloud computing');

-- =====================================================
-- SAMPLE RESPONSES
-- =====================================================

INSERT INTO responses(prompt_id,response_text,response_time)
VALUES
(1,'Machine learning is a branch of artificial intelligence',1.1),
(2,'Request denied due to security risk',0.8),
(3,'API keys should be stored securely',1.0),
(4,'Cloud computing provides scalable resources',1.2);

-- =====================================================
-- STORED PROCEDURE
-- =====================================================

DELIMITER $$

CREATE PROCEDURE get_high_risk_prompts()
BEGIN
SELECT 
    prompt_id,
    prompt_text,
    risk_level,
    created_at
FROM prompts
WHERE risk_level = 'High';
END$$

DELIMITER ;

-- =====================================================
-- VIEW FOR PROMPT ANALYTICS
-- =====================================================

CREATE VIEW prompt_user_view AS
SELECT 
    u.username,
    m.model_name,
    p.prompt_text,
    p.risk_level,
    p.created_at
FROM prompts p
JOIN users u
ON p.user_id = u.user_id
JOIN ai_models m
ON p.model_id = m.model_id;

-- =====================================================
-- ANALYTICS QUERIES
-- =====================================================

-- All prompts with users
SELECT * FROM prompt_user_view;

-- High risk prompts
SELECT * FROM prompts
WHERE risk_level='High';

-- Model usage statistics
SELECT 
    m.model_name,
    COUNT(p.prompt_id) AS total_prompts
FROM prompts p
JOIN ai_models m
ON p.model_id = m.model_id
GROUP BY m.model_name;

-- Average response time
SELECT 
    AVG(response_time) AS average_response_time
FROM responses;

-- Audit report placeholder
SELECT * FROM audit_logs;

-- =====================================================
-- END OF PROJECT
-- =====================================================
