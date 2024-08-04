import numpy as np
from scipy.linalg import svd
from scipy.optimize import least_squares


def surface_fit(points,px,py):
    # 提取点的坐标
    x = points[:, 0]
    y = points[:, 1]
    z = points[:, 2]

    def surface_function(params, x, y):
        a, b, c, d, e, f = params
        return a * x**2 + b * y**2 + c * x * y + d * x + e * y + f

    initial_params = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

    result = least_squares(lambda params: surface_function(params, x, y) - z, initial_params)

    a, b, c, d, e, f = result.x

    normal_vector =[2 * a * px + c * py + d, 2 * b * py + c * px + e, -1]

    return normal_vector


def compute_normals(data, k):
    normals = []
    for i in range(len(data)):
        dataset = data[i]

        for j in range(len(dataset)):
            point = dataset[j]
            px = point[0]
            py = point[1]
            k_nearest_points = []
            if i > 0:
                previous_dataset = data[i - 1]
                distances_prev = np.linalg.norm(previous_dataset - point, axis=1)
                indices_prev = np.argsort(distances_prev)
                k_nearest_points.extend(previous_dataset[indices_prev[:k]])

            distances = np.linalg.norm(dataset - point, axis=1)
            indices = np.argsort(distances)
            k_nearest_points.extend(dataset[indices[1:k + 1]])

            if i < len(data) - 1:
                next_dataset = data[i + 1]
                distances_next = np.linalg.norm(next_dataset - point, axis=1)
                indices_next = np.argsort(distances_next)
                k_nearest_points.extend(next_dataset[indices_next[:k]])

            k_nearest_points = np.array(k_nearest_points)
            normal_vector = surface_fit(k_nearest_points,px,py)
            normals.append(normal_vector)
    return normals

k = 26
data_list = []
for i in range(1, 21):
    filename = f"data{i}.txt"
    data = np.loadtxt(filename)
    data_list.append(data)
data = np.vstack(data_list)
normals = compute_normals(data_list, k)
normals = np.array(normals)
normals = normals / np.linalg.norm(normals, axis=1, keepdims=True)

output_data = np.hstack((data, normals))
np.savetxt('F:/output.txt', output_data, fmt='%.6f', delimiter=' ', newline='\n')