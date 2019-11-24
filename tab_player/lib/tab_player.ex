defmodule TabPlayer do
    def parse(tab) do
        list = String.split(tab,"\n")
        list = List.delete(list,"")
        listOfList = Enum.map(list, fn(x) -> String.codepoints(x) end)
        listOfIndex = Enum.map(listOfList, fn(x) -> Enum.with_index(x) end)
        headListOfIndex = hd listOfIndex
        getStopLocs = Enum.filter(headListOfIndex, fn{x,y} -> (x=="|") end)
        getStopLocs = Enum.map(getStopLocs, fn{x,y} -> y end)
        getStopLocs = tl getStopLocs
        listFiltered = Enum.map(listOfIndex, fn(x) -> Enum.filter(x, fn(y) -> elem(y,0) =~ ~r/\w/ end) end)
        flatten = List.flatten(Enum.map(listFiltered, fn(x) -> Enum.map(x, fn(y) -> {(elem((hd x),0))<>(elem(y,0)),(elem(y,1))} end)end))
        filteredFlatten = Enum.filter(flatten, fn(x) -> elem(x,1) != 0 end)
        printIndexes = Enum.map(filteredFlatten, fn(x) -> elem(x,1) end)
        sortedIndex = Enum.sort(printIndexes)
        uniqueSorted = Enum.uniq(sortedIndex)
        replicas = sortedIndex--uniqueSorted
        replicas = Enum.uniq(replicas)
        getToBeMerged = Enum.map(replicas, fn(x) -> Enum.filter(filteredFlatten, fn{a,b} -> x==b end) end)
        mergedList = Enum.map(getToBeMerged, fn(list) -> {deleteLastChar(mergeNote(list)), elem((hd list),1)} end)
        filtered = Enum.filter(filteredFlatten, fn{_,x} -> !(x in replicas) end)
        filtered = filtered++mergedList
        pauseLoc = getDiffPoint(Enum.sort(uniqueSorted++getStopLocs))
        pauseLoc = Enum.map(pauseLoc, fn(x) -> x+1 end)
        pauses = Enum.map(pauseLoc, fn(x) -> {"_",x} end)
        filtered = filtered++pauses
        uniqueSorted = Enum.sort(uniqueSorted++pauseLoc) -- getStopLocs
        flatten2 = List.flatten(Enum.map(uniqueSorted, fn(x) -> Enum.filter(filtered, fn(y) -> elem(y,1) == x end) end))
        final = Enum.map(flatten2, fn(x) -> elem(x,0) end)
        Enum.join(final, " ") 
      end

    def mergeNote([]) do
        ""
    end
    def mergeNote([ {x,_} | tail]) do
       list = x<>"/"<>mergeNote(tail)
    end

    def deleteLastChar(str) do
        list = String.codepoints(str)
        list = List.delete_at(list,-1)
        List.to_string(list)
    end

    def getDiffPoint(list) when length(list) < 2 do
        []
    end 
    def getDiffPoint([h|t]) when length(t) >= 1 do
        if (hd t) - h >= 4 do
            [h] ++ getDiffPoint(t)
        else
            getDiffPoint(t)
        end
    end

end

