import numpy as np
import open3d as o3d

points = np.loadtxt('data.txt')

pcd = o3d.geometry.PointCloud()
pcd.points = o3d.utility.Vector3dVector(points)

# o3d.geometry.estimate_normals(pcd, search_param=o3d.geometry.KDTreeSearchParamHybrid(radius=0.1, max_nn=30))
o3d.geometry.estimate_normals(pcd, search_param=o3d.geometry.KDTreeSearchParamHybrid(radius=60, max_nn=12))

normals = np.asarray(pcd.normals)

output_data = np.hstack((points, normals))
np.savetxt('F:/output.txt', output_data, fmt='%.6f', delimiter=' ', newline='\n')
