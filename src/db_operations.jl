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

# # TODO:
# function create_sequences_table(db)
#     SQLite.execute(db, """
#         CREATE TABLE IF NOT EXISTS results
#         (
            
#         );
#     """)
#     return true
# end
