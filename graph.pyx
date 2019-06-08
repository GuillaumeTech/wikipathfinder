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

    queue = deque([int_start])
    graph[int_start] = 1


    cdef int node
    cdef int neighbours_count
    cdef np.ndarray neighbors_bytes_offset
    cdef np.ndarray neighbours

    while queue:
        node = queue.pop()
        neighbours_count = graph[node + 1]
        neighbours_bytes_offset = graph[node + HEADER_SIZE : node + HEADER_SIZE + neighbours_count]
        neighbours = neighbours_bytes_offset // 4
        for neighbour in neighbours:
            if ((graph[neighbour]) == 0):
                queue.appendleft(neighbour)
                graph[neighbour] = node
                if (neighbour == int_end):
                    t1_stop = time.perf_counter()
                    print(t1_stop-t1_start)
                    return workout_path(graph, int_start, int_end)


def workout_path(graph, start, end):
    queue = deque([end])
    node = graph[end]
    while node != start:
        queue.appendleft(node)
        node = graph[node]
    queue.appendleft(start)
    return queue



graph = load_graph('indexbi.bin')
HEADER_SIZE = 3
#print(get_path(graph, 1177692, 1179772))
print(get_path(graph, 783308, 795320))
