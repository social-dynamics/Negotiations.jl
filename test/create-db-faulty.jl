using SQLite

db = SQLite.DB("test-faulty.sqlite")

SQLite.execute(
    db,
    """
    CREATE TABLE party
    (
        party_id INTEGER NOT NULL PRIMARY KEY,
        party_shorthand TEXT
    );
    """
)

SQLite.execute(
    db,
    """
    CREATE TABLE statement
    (
        statement_id INTEGER NOT NULL PRIMARY KEY,
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
        (1, \"TP_1\"),
        (2, \"TP_2\"),
        (3, \"TP_3\");
    """
)

SQLite.execute(
    db,
    """
    INSERT INTO statement
    VALUES
        (1, \"This is the first test statement.\"),
        (2, \"This is the second test statement.\"),
        (3, \"This is the third test statement.\");
    """
)

SQLite.execute(
    db,
    """
    INSERT INTO opinion
    VALUES
        (1, 1, 1),
        (1, 2, -1),
        (1, 3, 0),
        (2, 1, -1),
        (2, 2, 0),
        (2, 3, -1),
        (3, 1, 1),
        (3, 2, 1),
        (3, 3, 0);
    """
)

