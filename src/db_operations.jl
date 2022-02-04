function create_results_table!(db)
    SQLite.execute(db, """
        CREATE TABLE IF NOT EXISTS results
        (
            agent_id INTEGER NOT NULL,
            party TEXT,
            step INTEGER NOT NULL,
            rep INTEGER NOT NULL,
            statement_id INTEGER NOT NULL,
            position REAL,
            seq INTEGER NOT null,
            PRIMARY KEY(agent_id, step, rep, statement_id, seq)
        );
    """)
    return true
end


function create_sequences_table!(db)
    SQLite.execute(db, """
        CREATE TABLE IF NOT EXISTS sequences
        (
            seq_id INTEGER NOT NULL,
            step INTEGER,
            party_1 TEXT,
            party_2 TEXT,
            FOREIGN KEY(seq_id) REFERENCES results(seq),
            PRIMARY KEY(seq_id, step)
        );
    """)
    return true
end
