defmodule Exercise1Test do
  use ExUnit.Case

 # @tag :pending
  test "reverses a given 'charlist'" do
    assert Exercise1.reverse('abracadabra') == 'arbadacarba'
    assert Exercise1.reverse('Panama') == 'amanaP'
  end

 # @tag :pending
  test "replaces any lowercase character in a given 'charlist' by its corresponding uppercase" do
    assert Exercise1.upcase('abracadabra') == 'ABRACADABRA'
    assert Exercise1.upcase('Panama') == 'PANAMA'
  end
  
 # @tag :pending
  test "removes non alphabetical caracters from a given 'charlist'" do
    assert Exercise1.remove_non_alpha('w o r d') == 'word'
    assert Exercise1.remove_non_alpha('w1o2r3d') == 'word'    
  end

 # @tag :pending
  test "checks simple words" do
    assert Exercise1.palindrome('redivider') == true
    assert Exercise1.palindrome('abracadabra') == false
  end

 # @tag :pending
  test "checks words, case insensitively" do
    assert Exercise1.palindrome('ReDivider') == true
  end

 # @tag :pending
  test "ignores non alphabetic characters" do
    assert Exercise1.palindrome('A man, a plan, a canal -- Panama') == true
    assert Exercise1.palindrome('Madam, I\'m Adam!') == true
  end
end
