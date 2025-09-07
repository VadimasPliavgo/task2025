@isTest
public class BusStatusBatchTest {
    
    @testSetup
    static void setupTestData() {
        List<Bus__c> buses = new List<Bus__c>();
        
        // Create 4 buses (status and passenger rollups will be set after children inserted)
        for (Integer i = 0; i < 5; i++) {
            buses.add(new Bus__c());
        }
        insert buses;
        
        // Create Passenger records to populate the rollup summary field
        List<Passenger__c> passengers = new List<Passenger__c>();
        
        // Map of Bus index → number of passengers
        Map<Integer, Integer> busPassengerCounts = new Map<Integer, Integer>{
            0 => 5,   // Bus 1: Available
                1 => 15,  // Bus 2: Limited Seats
                2 => 20,  // Bus 3: Full
                3 => 25   // Bus 4: Exception
                };
                    
                    for (Integer i = 0; i < buses.size(); i++) {
                        Integer passengerCount = busPassengerCounts.get(i);
                        for (Integer j = 0; j < passengerCount; j++) {
                            passengers.add(new Passenger__c(Bus__c = buses[i].Id));
                        }
                    }
        
        insert passengers;
    }
    
    @isTest
    static void testBusStatusBatch() {
        // Fetch all Bus Ids
        List<Id> busIds = new List<Id>();
        for (Bus__c bus : [SELECT Id FROM Bus__c]) {
            busIds.add(bus.Id);
        }
        
        // Run the batch
        Test.startTest();
        Database.executeBatch(new BusStatusBatch(busIds), 200);
        Test.stopTest();
        
        // Re-query to get updated values (rollup field + status)
        List<Bus__c> buses = [
            SELECT Id, Bus_Status__c, Number_of_Passengers__c
            FROM Bus__c
            ORDER BY CreatedDate ASC
        ];
        
        // Assertions
        System.assertEquals(5, buses[0].Number_of_Passengers__c, 'Bus 1 passenger count mismatch');
        System.assertEquals('Available', buses[0].Bus_Status__c, 'Bus 1 should be Available');
        
        System.assertEquals(15, buses[1].Number_of_Passengers__c, 'Bus 2 passenger count mismatch');
        System.assertEquals('Limited Seats', buses[1].Bus_Status__c, 'Bus 2 should be Limited Seats');
        
        System.assertEquals(20, buses[2].Number_of_Passengers__c, 'Bus 3 passenger count mismatch');
        System.assertEquals('Full', buses[2].Bus_Status__c, 'Bus 3 should be Full');
        
        System.assertEquals(25, buses[3].Number_of_Passengers__c, 'Bus 4 passenger count mismatch');
        System.assertEquals(null, buses[3].Bus_Status__c, 'Bus 4 should not be updated due to exception');
        
        System.assertEquals(0, buses[4].Number_of_Passengers__c, 'Bus 5 passenger count mismatch');
        System.assertEquals('Available', buses[4].Bus_Status__c, 'Bus 5 should be Available');
    }
}