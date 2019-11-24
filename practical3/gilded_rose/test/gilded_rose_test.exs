defmodule GildedRoseTest do
  use ExUnit.Case
  

  test """
      At the end of each day our system lowers both 
      'quality' and 'sell_in' for every item"
      """ do
        items = [%Item{name: "+5 Dexterity Vest", sell_in: 10, quality: 20}]
        [%{sell_in: sell_in, quality: quality}] = GildedRose.update_quality(items)
         assert sell_in < 10
         assert quality < 20 
      end

   test """
    Once the sell by date has passed, Quality degrades twice as fast
    """
      do
        items = [%Item{name: "+5 Dexterity Vest", sell_in: 0, quality: 20}]
        [%{sell_in: sell_in, quality: quality}] = GildedRose.update_quality(items)
        assert sell_in == -1
        assert quality == 18
      end
    test """
      The Quality of an item is never negative
      """
        do
          items = [%Item{name: "+5 Dexterity Vest", sell_in: 0, quality: 0}]
          [%{sell_in: sell_in, quality: quality}] = GildedRose.update_quality(items)
          assert sell_in == -1
          assert quality == 0
        end
    test """
      “Aged Brie” actually increases in Quality the older it gets
        """
          do
            items = [%Item{name: "Aged Brie", sell_in: 2, quality: 0}]
            [%{sell_in: sell_in, quality: quality}] = GildedRose.update_quality(items)
            assert sell_in == 1
            assert quality == 1
          end
    test """
        The Quality of an item is never more than 50
        """
        do
        items = [%Item{name: "Aged Brie", sell_in: 10, quality: 50}]
        [%{sell_in: sell_in, quality: quality}] = GildedRose.update_quality(items)
        assert quality == 50
        end
end