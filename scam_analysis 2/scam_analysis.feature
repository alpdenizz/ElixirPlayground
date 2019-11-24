Feature: Identification of driver scams
  As an operator of STRS's customer service
  Such that I can investigate possible scam driver
  I want to get access to the taxi ride statistics based on a customer report

  Scenario: Identifying taxi based on report and highlighing overpriced trips
    Given STRS's ride history includes the following trips
        | date       | pickup_time | dropoff_time | est_pickup_time | est_duration | pickup_address | dropoff_address | taxi_id |
        | 2017-10-16 | 10:28:30    | 10:44:16     | 10:30:00        | 00:11:00     | Raatuse 22     | Kreutzwaldi 1   | 3       |
        | 2017-10-16 | 10:42:17    | 10:51:40     | 10:42:00        | 00:09:00     | Liivi 2        | Turu 2          | 2       |
        | 2017-10-16 | 11:31:42    | 11:45:00     | 11:32:00        | 00:13:00     | Puusepa 8      | Võru 51         | 1       |
        | 2017-10-16 | 12:11:20    | 12:21:10     | 12:11:00        | 00:10:00     | Puusepa 8      | Kastani 1       | 4       |
        | 2017-10-16 | 15:10:10    | 15:30:20     | 15:12:00        | 00:12:00     | Aleksandri 7   | Puusepa 8       | 3       |
        | 2017-10-16 | 16:16:10    | 16:34:22     | 16:20:00        | 00:12:00     | Riia 14        | Narva mnt 89    | 3       |
        | 2017-10-16 | 18:30:44    | 18:44:00     | 18:30:00        | 00:15:00     | Puusepa 8      | Jaama 42        | 1       |
    And "John Smith" lodges a customer service request for abusive behavior
    And the date of the trip is "2017-10-16"
    And the taxi ride was from "Aleksandri 7" to "Puusepa 8"
    When the operator enters the date, pickup and drop off addresses of the trip
    Then the operator should see 1 row associated with taxi 3
    When the operator clears the form
    And the operator enters the taxi identifier 3
    Then the operator should see 3 rows
    When the operator filters 25% (+) overpriced trips
    Then the operator should see 3 yellow rows
    When the operator filters 50% (+) overpriced trips
    Then the operator should see 1 yellow row
    Then the operator should see 2 red rows
