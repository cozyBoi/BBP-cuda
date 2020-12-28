mkdir build
nvcc -o build/mm mm.cu
gcc -o build/a reduction_a.c
nvcc -o build/b reduction_b.c
nvcc -o build/c reduction_c.c
nvcc -o build/d reduction_d.c

