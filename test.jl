using CSV
using DataFrames
using Clustering
using UnicodePlots
using Distances

data = CSV.read(joinpath("..", "data-exploration", "data_wide.csv"), DataFrame)
m = Matrix(data[:, 3:end])
m_dist = zeros(nrow(data), nrow(data))
for i in 1:nrow(data)
    for j in 1:nrow(data)
        m_dist[i, j] = hamming(m[i, :], m[j, :])
    end
end

clus = hclust(m_dist)

m_ordered = m_dist[clus.order, clus.order]


heatmap(m_ordered, width=38, height=38)

reduced = data[:, 1:2]

ordering = DataFrame(party_id=clus.order)

innerjoin(reduced, ordering, on=:party_id)
