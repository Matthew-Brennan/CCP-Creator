import { LightningElement, api, wire, track } from 'lwc';
import getFields from '@salesforce/apex/CCPCreatorController.getCCPFields';
import createProduct from '@salesforce/apex/CCPCreateOppProduct.CCPCreateOppProduct';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import CCP_FIELD from '@salesforce/schema/Opportunity.CCP_Level__c';
import { updateRecord} from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DisplayCCPFields extends LightningElement {
    @api recordId;
    @track record = {};
    @track error;
    @track ccpOptions = [];
    wiredRecordResult; // To store the result of wiredRecord

    @wire(getFields, { oppId: '$recordId' })
    wiredRecord(result) {
        this.wiredRecordResult = result;
        const { error, data } = result;
        if (data) {
            this.record = { ...data }; // Make a shallow copy of the data
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    opportunityMetadata;

    // Get the picklist values for the CCP Type
    @wire(getPicklistValues, { recordTypeId: '$opportunityMetadata.data.defaultRecordTypeId', fieldApiName: CCP_FIELD })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.ccpOptions = data.values;
        } else if (error) {
            this.error = error;
        }
    }

    handleChange(event) {
        const field = event.target.name;
        const value = event.target.value;
        // Convert Discount Rate to a percentage format
        if (field === 'CCPDiscountRate') {
            value = value.toFixed(2); // Limit to 2 decimal places
        }
        this.record = { ...this.record, [field]: value }; // Update the record object by creating a new object
    }

    handleSave() {
        const fields = {};
        fields['Id'] = this.recordId;
        fields['CCP_Level__c'] = this.record.CCP;
        
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record updated successfully',
                        variant: 'success'
                    })
                );
                return refreshApex(this.wiredRecordResult); // Refresh the data
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body ? error.body.message : 'An error occurred',
                        variant: 'error'
                    })
                );
            });
    }


    handleCreateProduct() {
        createProduct({ oppId: this.recordId, clientUnitPrice: this.record.CCPClientPriceWithDiscount })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: result,
                        variant: 'success'
                    })
                );
                console.log(result);
                return refreshApex(this.wiredRecordResult);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Opportunity Product',
                        message: error.body ? error.body.message : 'An error occurred',
                        variant: 'error'
                    })
                );
            });
    }




    refreshData(){
        return refreshApex(this.wiredRecordResult); // Refresh the data
    }
}
