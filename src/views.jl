"""
    opinions_view(db:SQLite.DB)

Get a database view on the party opinions in a suitable database.
"""
function opinions_view(db::SQLite.DB)
    return DBInterface.execute(
        db,
        """
        SELECT party_id, statement_id, position
        FROM opinion
        """
    ) |> DataFrame
end


"""
    party_opinions_view(db::SQLite.DB)

Return a dataframe with party, statement and held position on that statement.
"""
function party_opinions_view(db::SQLite.DB)
    return DBInterface.execute(
        db,
        """
        SELECT party_shorthand, statement_id, position
        FROM opinion JOIN party
        ON opinion.party_id = party.party_id
        """
    ) |> DataFrame
end
