import numpy as np
import time
from collections import deque

def load_graph(path):
    dt = np.dtype('<i4')
    return np.fromfile(path, dtype=dt)

def get_path(graph, start, end):
    t1_start = time.perf_counter()

    int_start = start // 4
    int_end = end // 4
    queue = deque([[int_start]])
    graph[int_start] = 1

    while queue:
        path = queue.pop()
        node = path[-1]
        neighbours_count = graph[node + 1]
        neighbours_bytes_offset = graph[node + HEADER_SIZE : node + HEADER_SIZE + neighbours_count]
        neighbours = neighbours_bytes_offset // 4
        for neighbour in neighbours:
            if (graph[neighbour] == 0):
                new_path = list(path)
                new_path.append(neighbour)
                queue.appendleft(new_path)
                graph[node] = 1
                if (neighbour == int_end):
                    t1_stop = time.perf_counter()
                    print(t1_stop - t1_start)
                    return new_path



graph = load_graph('indexbi.bin')
HEADER_SIZE = 3
#print(get_path(graph, 1177692, 1179772))
print(get_path(graph, 783308, 795320))
