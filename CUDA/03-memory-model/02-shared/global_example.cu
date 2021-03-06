#include <iostream>
#include <cmath>
#include <cassert>


#define BLOCKSIZE 256

__global__ void Difference(int n, int* input, int* result) {
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    int x_i = input[tid];
    if (tid > 0) {
        int x_i_minus = input[tid - 1];

        result[tid] = x_i - x_i_minus;
    } else {
        result[tid] = x_i;
    }
}


int main() {
    int N = 1 << 28;

    int* h_array = new int[N];
    int* h_diff = new int[N];
    for (int i = 0; i < N; ++i) {
        h_array[i] = i + 1;
    }
    
    int* d_array;
    int* d_diff;
    unsigned int size = N * sizeof(int);
    cudaMalloc(&d_array, size);
    cudaMalloc(&d_diff, size);

    cudaMemcpy(d_array, h_array, size, cudaMemcpyHostToDevice);
    
    int num_blocks = (N + BLOCKSIZE - 1) / BLOCKSIZE;

    cudaEvent_t start, stop;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    Difference<<<num_blocks, BLOCKSIZE>>>(N, d_array, d_diff);
    cudaEventRecord(stop);


    cudaMemcpy(h_diff, d_diff, size, cudaMemcpyDeviceToHost);

    float milliseconds;
    cudaEventSynchronize(stop);


    cudaEventElapsedTime(&milliseconds, start, stop);

    for (int i = 0; i < N; ++i) {
        assert(h_diff[i] == 1);
    }

    std::cout << milliseconds << " elapsed" << std::endl;

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_array);
    cudaFree(d_diff);
    delete[] h_array;
    delete[] h_diff;

}
