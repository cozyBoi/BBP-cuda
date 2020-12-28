mkdir build
nvcc -o build/mm mm.cu
nvcc -o build/a reduction_a.cu
nvcc -o build/b reduction_b.cu
nvcc -o build/c reduction_c.cu
nvcc -o build/d reduction_d.cu

