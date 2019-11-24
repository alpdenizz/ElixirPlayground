defmodule Exercise1 do
    def reverse(l) do
        MList.foldl(l, [], fn(x,acc) -> [x|acc] end)
    end 
    def upcase(list) do
        MList.map(list, fn (c) when c in ?a..?z -> c - ?a + ?A 
                                                    (c) -> c end)
    end
    def remove_non_alpha(list) do 
        MList.filter(list, fn (c) -> c in ?a..?z or c in ?A..?Z end)
    end
    def palindrome(list) do
        remove_non_alpha(upcase(list)) == reverse(remove_non_alpha(upcase(list)))    
    end
end
