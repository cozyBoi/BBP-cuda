mkdir build
nvcc -o build/mm_1 mm_1.cu
nvcc -o build/mm_2 mm_2.cu
nvcc -o build/mm_3 mm_3.cu
nvcc -o build/a reduction_a.cu
nvcc -o build/b reduction_b.cu
nvcc -o build/c reduction_c.cu
nvcc -o build/d reduction_d.cu