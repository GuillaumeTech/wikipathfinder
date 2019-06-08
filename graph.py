import numpy as np
import time
from collections import deque

def load_graph(path):
    dt = np.dtype('<i4')
    return np.fromfile(path, dtype=dt)

def get_path(graph, start, end):
    t1_start = time.perf_counter_ns()
    int_start = start // 4
    int_end = end // 4
    queue = deque([int_start])
    graph[int_start] = 1

    while queue:
        node = queue.pop()
        neighbours_count = graph[node + 1]
        neighbours_bytes_offset = graph[node + HEADER_SIZE : node + HEADER_SIZE + neighbours_count]
        neighbours = neighbours_bytes_offset // 4
        for neighbour in neighbours:
            if (graph[neighbour] == 0):
                queue.appendleft(neighbour)
                graph[neighbour] = node
                if (neighbour == int_end):
                    t1_stop = time.perf_counter_ns()
                    print(t1_stop - t1_start)
                    return workout_path(graph, int_start, int_end)

def workout_path(graph, start, end):
    queue = [end]
    node = graph[end]
    while node != start:
        queue.append(node)
        node = graph[node]
    queue.append(start)
    return queue.reverse()


graph = load_graph('indexbi.bin')
HEADER_SIZE = 3
#print(get_path(graph, 1177692, 1179772))
print(get_path(graph, 783308, 795320))
