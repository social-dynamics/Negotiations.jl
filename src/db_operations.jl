function create_results_table!(db)
    SQLite.execute(db, """
        CREATE TABLE IF NOT EXISTS results
        (
            result_id INTEGER NOT NULL PRIMARY KEY,
            agent_id INTEGER,
            party TEXT,
            step INTEGER,
            rep INTEGER,
            statement_id INTEGER NOT NULL,
            position REAL,
            seq INTEGER
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
