function initialize_db(db_name::String)
    db = SQLite.DB("./" * db_name * ".sqlite")
    create_party_table!(db)
    create_statement_table!(db)
    create_opinion_table!(db)
    create_results_table!(db)
    create_sequences_table!(db)
    return db
end


function create_party_table!(db::SQLite.DB)
    SQLite.execute(db, """
        CREATE TABLE IF NOT EXISTS party
        (
            party_id INTEGER NOT NULL PRIMARY KEY,
            party_shorthand TEXT,
            party_name TEXT,
        );
    """)
    return true
end


function create_statement_table!(db::SQLite.DB)
    SQLite.execute(db, """
        CREATE TABLE IF NOT EXISTS statement
        (
            statement_id INTEGER NOT NULL PRIMARY KEY,
            statement_title TEXT,
            statement TEXT,
        );
    """)
    return true
end


function create_opinion_table(db::SQLite.DB)
    SQLite.execute(db, """
        CREATE TABLE IF NOT EXISTS opinion
        (
            party_id INTEGER NOT NULL,
            statement_id INTEGER NOT NULL,
            position INTEGER,
            position_rationale TEXT,
            FOREIGN KEY(party_id) REFERENCES party(party_id),
            FOREIGN KEY(statement_id) REFERENCES statement(statement_id),
            PRIMARY KEY(party_id, statement_id)
        );
    """)
    return true
end


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
            seq INTEGER NOT NULL,
            batchname TEXT,
            PRIMARY KEY(agent_id, step, rep, statement_id, seq, batchname),
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
            batchname TEXT,
            FOREIGN KEY(seq_id, batchname) REFERENCES results(seq, batchname),
            PRIMARY KEY(seq_id, batchname, step),
        );
    """)
    return true
end
