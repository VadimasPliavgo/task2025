public with sharing class BusCompanyController {
    @AuraEnabled(cacheable=true)
    public static List<BusWrapper> getBusesWithPassengers(Id busCompanyId) {
        List<Bus__c> buses = [
            SELECT Id, Name, Number_of_Passengers__c, Bus_Status__c,
                   (SELECT Id, Name FROM Passengers__r)
            FROM Bus__c
            WHERE Bus_Company__c = :busCompanyId
            ORDER BY Name
        ];

        List<BusWrapper> results = new List<BusWrapper>();
        for (Bus__c b : buses) {
            results.add(new BusWrapper(b));
        }
        return results;
    }

    // Wrapper class to send structured data to LWC
    public class BusWrapper {
        @AuraEnabled public Id busId { get; set; }
        @AuraEnabled public String busName { get; set; }
        @AuraEnabled public Decimal passengerCount { get; set; }
        @AuraEnabled public String busStatus { get; set; }
        @AuraEnabled public List<PassengerWrapper> passengers { get; set; }

        public BusWrapper(Bus__c b) {
            busId = b.Id;
            busName = b.Name;
            passengerCount = b.Number_of_Passengers__c;
            busStatus = b.Bus_Status__c;
            passengers = new List<PassengerWrapper>();
            for (Passenger__c p : b.Passengers__r) {
                passengers.add(new PassengerWrapper(p));
            }
        }
    }

    public class PassengerWrapper {
        @AuraEnabled public Id passengerId { get; set; }
        @AuraEnabled public String passengerName { get; set; }

        public PassengerWrapper(Passenger__c p) {
            passengerId = p.Id;
            passengerName = p.Name;
        }
    }
}