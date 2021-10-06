using CSV
using DataFrames
using Clustering
using UnicodePlots

data = CSV.read(joinpath("..", "data-exploration", "data_wide.csv"), DataFrame)
m = Matrix(data[:, 3:end])
clus = hclust(m)
m_ordered = m[clus.order, :]

m_dist = zeros(nrow(data), nrow(data))

for i in 1:nrow(data)
    for j in 1:nrow(data)
        m_dist[i, j] = hamming(m[i, :], m[j, :])
    end
end

