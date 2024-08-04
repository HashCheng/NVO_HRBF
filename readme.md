# Data description
The data should have the following characteristics:
1. The boundary data of different ore bodies are stored and numbered separately
2. For the ore body boundary data of a single file, the ore body boundary points need to be stored in order

# Data processing
This part of the code is mainly used for data processing in the early stage

## Homogenization
Through B-spline interpolation, the homogenization of the closed ore body boundary is realized, and the specific idea is referred to: Homogenization

## Calculation of the normal direction
1. Nearest neighbor search + principal component analysis
2. Nearest neighbor search + least squares
3. Local search + least squares
4. Adaptive iteration + local search + least squares

# Normal visualization
Realize the visualization of sample point data method

# 3D modelling of the ore body
Reference: hfrbf_Function It is used to realize the 3D reconstruction of the geological model, and the 3D reconstruction is realized from the 3D spatial coordinates of the sample point and its normal direction

# Version information
python 3.6+


