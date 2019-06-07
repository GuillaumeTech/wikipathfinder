import cython
import numpy as np
cimport numpy as np
import time
from collections import deque

ctypedef np.int32_t cpl_t

def load_graph(path):
    dt = np.dtype('<i4')
    return np.fromfile(path, dtype=dt)

@cython.boundscheck(False) # compiler directive
def get_path(np.ndarray[cpl_t,ndim=1] graph, int start, int end):
    t1_start = time.perf_counter()
    cdef int int_start = start // 4
    cdef int int_end = end // 4

    queue = deque([[int_start]])
    graph[int_start] = 1

    cdef list path
    cdef int node
    cdef int neightbors_count
    cdef np.ndarray neightbors_bytes_offset
    cdef np.ndarray neightbors
    cdef list new_path
    while queue:
        path = queue.pop()
        node = path[-1]
        graph[node] = 1
        neightbors_count = graph[node + 1]
        neightbors_bytes_offset = graph[node + HEADER_SIZE : node + HEADER_SIZE + neightbors_count]
        neightbors = neightbors_bytes_offset  // 4

        for neightbor in neightbors:
            if ( not (graph[neightbor])):
                new_path = list(path)
                new_path.append(neightbor)
                queue.appendleft(new_path)
                if (neightbor == int_end):
                    t1_stop = time.perf_counter()
                    print(t1_stop-t1_start)
                    return new_path



graph = load_graph('indexbi.bin')
HEADER_SIZE = 3
#print(get_path(graph, 1177692, 1179772))
print(get_path(graph, 783308, 795320))
