package main

import (
	"bufio"
	"encoding/binary"
	"fmt"
	"gopkg.in/karalabe/cookiejar.v1/collections/deque"
	"os"
	"time"
)

const  HEADER_SIZE uint32 = 3
func main() {
	test, _ := loadGraphRaw("main/indexbi.bin")
	graph := intGraph(test)
	fmt.Println(getPath(graph, 783308, 795320))
}



func loadGraphRaw(filename string) ([]byte,error){
	file, err := os.Open(filename)

	if err != nil {
		return nil, err
	}


	stats, statsErr := file.Stat()
	if statsErr != nil {
		return nil, statsErr
	}

	var size int64 = stats.Size()
	bytes := make([]byte, size)
	bufr := bufio.NewReader(file)
	_,err = bufr.Read(bytes)
	file.Close()

	return bytes, err
}

func intGraph(rawGraph []byte) ([]uint32){
	var properGraph []uint32
	for i:=0; i < len(rawGraph)-4; i=i+4 {
		a := []byte{rawGraph[i], rawGraph[i+1], rawGraph[i+2], rawGraph[i+3]}
		properGraph = append(properGraph, binary.LittleEndian.Uint32(a))
	}
	return properGraph
}


func getPath(graph []uint32, start uint32, end uint32) []uint32 {
	startT := time.Now()
	var intStart uint32 = uint32(start/4)
	var intEnd uint32 = uint32(end/4)

	queue := deque.New()
	queue.PushRight(intStart)
	graph[intStart] = 1

	for queue != nil {
		var node = queue.PopRight().(uint32)
		var neightboursCount = graph[node + 1]
		neightbours_bytes := graph[node + HEADER_SIZE : node + HEADER_SIZE + neightboursCount]
		var neightbours = make([]uint32, neightboursCount+1)
		for i:=0; i < len(neightbours_bytes); i++ {
			neightbours[i] = neightbours_bytes[i]/4
		}
		for i:=0; i < len(neightbours); i++ {
			if graph[neightbours[i]] == 0 {
				queue.PushLeft(neightbours[i])
				graph[neightbours[i]] = node
				if neightbours[i] == intEnd {
					t := time.Now()
					elapsed := t.Sub(startT)
					fmt.Println(elapsed.Nanoseconds())
					return workoutPath(graph, intStart, intEnd)
				}
			}
		}

	}
	return nil
}

func workoutPath(graph []uint32, start uint32, end uint32) []uint32{
	path := []uint32{end}
	var node uint32 = graph[end]
	for node != start {

		path = append(path, node)
		node = graph[node]
	}
	path = append(path, start)
	return reverse(path)
}


func reverse(s []uint32) []uint32{
	for i, j := 0, len(s)-1; i < j; i, j = i+1, j-1 {
		s[i], s[j] = s[j], s[i]
	}
	return s
}
