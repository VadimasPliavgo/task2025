import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBusesWithPassengers from '@salesforce/apex/BusCompanyController.getBusesWithPassengers';

export default class BusCompanyBuses extends LightningElement {
    @api recordId; // Bus Company Id
    buses;

    @wire(getBusesWithPassengers, { busCompanyId: '$recordId' })
    wiredBuses({ error, data }) {
        if (data) {
            this.buses = data.map(bus => {
                const status = bus.busStatus ? bus.busStatus : 'Status: Unknown';
                const count = bus.passengerCount != null ? `Passengers: ${bus.passengerCount}` : 'Passengers: 0';
                return {
                    ...bus,
                    label: `${bus.busName} • ${status} • ${count}`,
                    busUrl: '/' + bus.busId,
                    passengers: bus.passengers
                        ? bus.passengers.map(p => ({
                              ...p,
                              passengerUrl: '/' + p.passengerId
                          }))
                        : []
                };
            });
        } else if (error) {
            this.buses = undefined;
            this.showErrorToast(error);
        }
    }

    get hasBuses() {
        return this.buses && this.buses.length > 0;
    }

    showErrorToast(error) {
        let message = 'Unknown error';
        if (error && error.body && error.body.message) {
            message = error.body.message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading buses',
                message: message,
                variant: 'error'
            })
        );
    }
    openBusRecord(event) {
    const busId = event.target.dataset.id;
    if (busId) {
        window.open('/' + busId, '_blank');
    }
}

}