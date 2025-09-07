public class BusStatusBatch implements Database.Batchable<sObject>, Database.Stateful {

    private List<Id> busIds;

    // Constructor to accept Bus Ids
    public BusStatusBatch(List<Id> busIds) {
        this.busIds = busIds;
    }

    // Start method: fetch buses by Id
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id, Name, Number_of_Passengers__c 
            FROM Bus__c 
            WHERE Id IN :busIds
        ]);
    }

    // Execute method: process each batch of up to 200 records
    public void execute(Database.BatchableContext context, List<Bus__c> buses) {
        List<Bus__c> busesToUpdate = new List<Bus__c>();

        for (Bus__c bus : buses) {
            try {
                Integer passengerCount = (bus.Number_of_Passengers__c != null) 
                    ? Integer.valueOf(bus.Number_of_Passengers__c) 
                    : 0;

                if (passengerCount < 10) {
                    bus.Bus_Status__c = 'Available';
                } else if (passengerCount > 10 && passengerCount < 20) {
                    bus.Bus_Status__c = 'Limited Seats';
                } else if (passengerCount == 20) {
                    bus.Bus_Status__c = 'Full';
                } else if (passengerCount > 20) {
                    throw new BusCapacityExceededException('Bus ' + bus.Name + ' has more than 20 passengers!');
                }

                busesToUpdate.add(bus);

            } catch (BusCapacityExceededException ex) {
                // Log exception to custom object or debug – process continues
                System.debug(LoggingLevel.ERROR, ex.getMessage());
            }
        }

        if (!busesToUpdate.isEmpty()) {
            update busesToUpdate;
        }
    }

    // Finish method: log completion
    public void finish(Database.BatchableContext context) {
        System.debug('Bus Status update batch completed.');
    }
}
/*
to run for anonymouse consol
List<Id> busIds = new List<Id>();
for (Bus__c b : [SELECT Id FROM Bus__c LIMIT 200]) {
    busIds.add(b.Id);
}
String jobId = Database.executeBatch(new BusStatusBatch(busIds), 200);
System.debug('Queued batch job: ' + jobId);
*/