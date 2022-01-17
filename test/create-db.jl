using SQLite

db = SQLite.DB("test.sqlite")

SQLite.execute(
    db,
    """
    CREATE TABLE party
    (
        party_id INTEGER NOT NULL PRIMARY KEY,
        party_shorthand TEXT,
        party_name TEXT
    );
    """
)

SQLite.execute(
    db,
    """
    CREATE TABLE statement
    (
        statement_id INTEGER NOT NULL PRIMARY KEY,
        statement_title TEXT,
        statement TEXT
    );
    """
)

SQLite.execute(
    db,
    """
    CREATE TABLE opinion
    (
        party_id INTEGER NOT NULL,
        statement_id INTEGER NOT NULL,
        position INTEGER,
        position_rationale TEXT,
        FOREIGN KEY(party_id) REFERENCES party(party_id),
        FOREIGN KEY(statement_id) REFERENCES statement(statement_id),
        PRIMARY KEY(party_id, statement_id)
    );
    """
)

SQLite.execute(
    db,
    """
    INSERT INTO party
    VALUES
        (1, \"TP_1\", \"TESTPARTY_1\"),
        (2, \"TP_2\", \"TESTPARTY_2\"),
        (3, \"TP_3\", \"TESTPARTY_3\");
    """
)

SQLite.execute(
    db,
    """
    INSERT INTO statement
    VALUES
        (1, \"Test statement 1\", \"This is the first test statement.\"),
        (2, \"Test statement 2\", \"This is the second test statement.\"),
        (3, \"Test statement 3\", \"This is the third test statement.\");
    """
)

SQLite.execute(
    db,
    """
    INSERT INTO opinion
    VALUES
        (1, 1, 1, \"We hold this position because of A.\"),
        (1, 2, -1, \"We hold this position because of B.\"),
        (1, 3, 0, \"We hold this position because of C.\"),
        (2, 1, -1, \"We hold this position because of D.\"),
        (2, 2, 0, \"We hold this position because of E.\"),
        (2, 3, -1, \"We hold this position because of F.\"),
        (3, 1, 1, \"We hold this position because of G.\"),
        (3, 2, 1, \"We hold this position because of H.\"),
        (3, 3, 0, \"We hold this position because of I.\");
    """
)

