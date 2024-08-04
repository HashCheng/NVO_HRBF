import numpy as np
from scipy.linalg import svd
from scipy.optimize import least_squares


def surface_fit(points,px,py):
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

def check_angle_threshold(v1, v2, v3, threshold):
    def angle_between_vectors(vec1, vec2):
        dot_product = np.dot(vec1, vec2)
        norm_v1 = np.linalg.norm(vec1)
        norm_v2 = np.linalg.norm(vec2)
        cosine_similarity = dot_product / (norm_v1 * norm_v2)
        cosine_similarity = np.clip(cosine_similarity, -1.0, 1.0)
        angle_rad = np.arccos(cosine_similarity)
        angle_deg = np.degrees(angle_rad)
        return angle_deg

    angle_v1_v2 = angle_between_vectors(v1, v2)
    angle_v2_v3 = angle_between_vectors(v2, v3)

    if angle_v1_v2 < threshold and angle_v2_v3 < threshold:
        return False
    else:
        return True

def compute_normals(data):
    normals = []
    for i in range(len(data)):
        dataset = data[i]

        for j in range(len(dataset)):
            point = dataset[j]
            px = point[0]
            py = point[1]
            k_nearest_points = np.empty((0, 3))
            k_nearest_points1 = np.empty((0, 3))
            k_nearest_points2 = np.empty((0, 3))
            k=2
            sign=True

            vector1=[]
            while sign:
                k=k+1

                if i > 0:
                    previous_dataset = data[i - 1]
                    distances_prev = np.linalg.norm(previous_dataset - point, axis=1)
                    indices_prev = np.argsort(distances_prev)
                    k_nearest_points = np.concatenate((k_nearest_points, previous_dataset[indices_prev[:k]]), axis=0)
                    k_nearest_points1 = np.concatenate((k_nearest_points1, previous_dataset[indices_prev[:k + 1]]), axis=0)
                    k_nearest_points2 = np.concatenate((k_nearest_points2, previous_dataset[indices_prev[:k + 2]]), axis=0)

                distances = np.linalg.norm(dataset - point, axis=1)
                indices = np.argsort(distances)
                k_nearest_points = np.concatenate((k_nearest_points, dataset[indices[1:k + 1]]), axis=0)
                k_nearest_points1 = np.concatenate((k_nearest_points1, dataset[indices[1:k + 2]]), axis=0)
                k_nearest_points2 = np.concatenate((k_nearest_points2, dataset[indices[1:k + 3]]), axis=0)

                if i < len(data) - 1:
                    next_dataset = data[i + 1]
                    distances_next = np.linalg.norm(next_dataset - point, axis=1)
                    indices_next = np.argsort(distances_next)
                    k_nearest_points = np.concatenate((k_nearest_points, next_dataset[indices_next[:k]]), axis=0)
                    k_nearest_points1 = np.concatenate((k_nearest_points1, next_dataset[indices_next[:k + 1]]),axis=0)
                    k_nearest_points2 = np.concatenate((k_nearest_points2, next_dataset[indices_next[:k + 2]]),axis=0)

                normal_vector = surface_fit(k_nearest_points,px,py)
                normal_vector1 = surface_fit(k_nearest_points1, px, py)
                normal_vector2 = surface_fit(k_nearest_points2, px, py)
                vector1=normal_vector
                sign=check_angle_threshold(normal_vector, normal_vector1, normal_vector2, 5)#设置阈值

            normals.append(vector1)

    return normals


data_list = []
for i in range(1, 21):
    filename = f"data{i}.txt"
    data = np.loadtxt(filename)
    data_list.append(data)
data = np.vstack(data_list)
normals = compute_normals(data_list)
normals = np.array(normals)
normals = normals / np.linalg.norm(normals, axis=1, keepdims=True)

output_data = np.hstack((data, normals))
np.savetxt('F:/output.txt', output_data, fmt='%.6f', delimiter=' ', newline='\n')