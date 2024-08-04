import numpy as np
from scipy.spatial import cKDTree
from sklearn.decomposition import PCA

data = np.loadtxt('data.txt')

k_neighbors = 30
kdtree = cKDTree(data)

normals = []
for i in range(len(data)):
    _, indices = kdtree.query(data[i], k=k_neighbors + 1)

    neighbors = data[indices[1:]]
    pca = PCA(n_components=3)
    pca.fit(neighbors)
    normal = pca.components_[-1]
    normals.append(normal)
normals = np.array(normals)

print("Point Cloud Normals:")
print(normals)
output_data = np.hstack((data, normals))
np.savetxt('F:/output.txt', output_data, fmt='%.6f', delimiter=' ', newline='\n')
