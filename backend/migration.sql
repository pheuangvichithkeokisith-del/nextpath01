CREATE TABLE alembic_version (
    version_num VARCHAR(32) NOT NULL, 
    CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);

-- Running upgrade  -> 0001_initial

CREATE TABLE sessions (
    id VARCHAR(36) NOT NULL, 
    form_version VARCHAR(50) DEFAULT 'v0.9.1' NOT NULL, 
    status VARCHAR(50) DEFAULT 'created' NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    completed_at DATETIME, 
    PRIMARY KEY (id)
);

CREATE INDEX ix_sessions_status ON sessions (status);

CREATE TABLE answers (
    id INTEGER NOT NULL, 
    session_id VARCHAR(36) NOT NULL, 
    question_id VARCHAR(50) NOT NULL, 
    option_codes JSON NOT NULL, 
    other_text TEXT, 
    extra_text TEXT, 
    text_value TEXT, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    PRIMARY KEY (id), 
    CONSTRAINT uq_session_question UNIQUE (session_id, question_id), 
    FOREIGN KEY(session_id) REFERENCES sessions (id) ON DELETE CASCADE
);

CREATE INDEX ix_answers_session_id ON answers (session_id);

CREATE INDEX ix_answers_question_id ON answers (question_id);

CREATE TABLE reports (
    id INTEGER NOT NULL, 
    session_id VARCHAR(36) NOT NULL, 
    response_pattern JSON NOT NULL, 
    possible_paths JSON NOT NULL, 
    context_factors JSON NOT NULL, 
    unknowns JSON NOT NULL, 
    versions JSON NOT NULL, 
    summary_text TEXT NOT NULL, 
    template_id VARCHAR(100) NOT NULL, 
    ai_version VARCHAR(50) NOT NULL, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    PRIMARY KEY (id), 
    UNIQUE (session_id), 
    FOREIGN KEY(session_id) REFERENCES sessions (id) ON DELETE CASCADE
);

CREATE INDEX ix_reports_session_id ON reports (session_id);

CREATE TABLE feedbacks (
    id INTEGER NOT NULL, 
    session_id VARCHAR(36) NOT NULL, 
    agreement VARCHAR(50) NOT NULL, 
    incorrect_note TEXT, 
    next_interest TEXT, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(session_id) REFERENCES sessions (id) ON DELETE CASCADE
);

CREATE INDEX ix_feedbacks_session_id ON feedbacks (session_id);

INSERT INTO alembic_version (version_num) VALUES ('0001_initial') RETURNING version_num;

