@isTest
public class BusCompanyControllerTest {

    @testSetup
    static void setupTestData() {
        // Create Bus Company
        Bus_Company__c company = new Bus_Company__c(Name='Test Company');
        insert company;

        // Create Buses
        List<Bus__c> buses = new List<Bus__c>();
        for (Integer i = 1; i <= 3; i++) {
            buses.add(new Bus__c(
                Bus_Company__c = company.Id,
                Bus_Status__c = i == 1 ? 'Available' : i == 2 ? 'Limited Seats' : 'Full'
            ));
        }
        insert buses;

        List<Passenger__c> passengers = new List<Passenger__c>();
        // Bus 1: 5 passengers
        for (Integer i = 0; i < 5; i++) {
            passengers.add(new Passenger__c(Bus__c = buses[0].Id));
        }
        // Bus 2: 12 passengers
        for (Integer i = 0; i < 12; i++) {
            passengers.add(new Passenger__c(Bus__c = buses[1].Id));
        }
        // Bus 3: 20 passengers
        for (Integer i = 0; i < 20; i++) {
            passengers.add(new Passenger__c(Bus__c = buses[2].Id));
        }
        insert passengers;
    }

    @isTest
    static void testGetBusesWithPassengers() {
        // Query Bus Company
        Bus_Company__c company = [SELECT Id FROM Bus_Company__c WHERE Name='Test Company' LIMIT 1];

        // Call Apex method
        Test.startTest();
        List<BusCompanyController.BusWrapper> wrappers = BusCompanyController.getBusesWithPassengers(company.Id);
        Test.stopTest();

        // Verify wrappers returned
        System.assertEquals(3, wrappers.size(), 'Should return 3 buses');

        for (BusCompanyController.BusWrapper b : wrappers) {
            System.assertNotEquals(null, b.busId, 'Bus Id should not be null');
            System.assertNotEquals(null, b.busName, 'Bus Name should not be null');
            System.assertNotEquals(null, b.busStatus, 'Bus Status should not be null');
            System.assertNotEquals(null, b.passengers, 'Passengers list should not be null');
            System.assertNotEquals(null, b.passengers[0].passengerName, 'Passenger name should not be null');
        }

        // Verify passenger counts
        System.assertEquals(5, wrappers[0].passengers.size(), 'Bus 1 should have 5 passengers');
        System.assertEquals(12, wrappers[1].passengers.size(), 'Bus 2 should have 12 passengers');
        System.assertEquals(20, wrappers[2].passengers.size(), 'Bus 3 should have 20 passengers');
    }
}