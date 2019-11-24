defmodule BullsAndCows do
    def score_guess(str1, str2) do
        if str1 == str2 do "You win"
        else
            list1 = Enum.with_index(String.codepoints(str1))
            list2 = Enum.with_index(String.codepoints(str2))
            resultList = Enum.uniq(for tuple1 <- list1, tuple2 <- list2, do: checkTuple(tuple1,tuple2))
            bullsList = Enum.filter(resultList, fn{x,_} -> x == "Bulls" end)
            findExtraCows = Enum.map(bullsList, fn{_,index} -> Enum.filter(resultList, fn{x,y} -> x=="Cows" and y==index end) end)
            findExtraCows = List.flatten(findExtraCows)
            resultList = resultList--findExtraCows
            bullsNumber = length (Enum.filter(resultList, fn{x,_} -> x=="Bulls" end))
            cowsNumber = length (Enum.filter(resultList, fn{x,_} -> x=="Cows" end))
            Integer.to_string(bullsNumber)<>" Bulls, "<>Integer.to_string(cowsNumber)<>" Cows"
        end
    end

    def checkTuple(t1,t2) do
        if t1==t2 do {"Bulls",elem(t1,1)}
        else
            ind1 = elem(t1,1)
            ind2 = elem(t2,1)
            ind = Enum.min([ind1,ind2])
            if elem(t1,0) == elem(t2,0) do {"Cows",ind}
            else  {"",elem(t2,1)}
            end
        end 
    end

end