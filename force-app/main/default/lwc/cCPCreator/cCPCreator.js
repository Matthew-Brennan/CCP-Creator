import { LightningElement, api, wire, track } from 'lwc';
import getFields from '@salesforce/apex/CCPCreatorController.getCCPFields';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import CCP_FIELD from '@salesforce/schema/Opportunity.CCP_Level__c';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DisplayCCPFields extends LightningElement {
    @api recordId;
    @track record = {};
    @track error;
    @track ccpOptions = [];

    @wire(getFields, { oppId: '$recordId' })
    wiredRecord({ error, data }) {
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

    //get the picklist values for the CCP Type
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
            value = parseFloat(value); // Ensure value is a float number
            if (!isNaN(value)) {
                value = value.toFixed(2); // Limit to 2 decimal places
            }
        }

        this.record = { ...this.record, [field]: value }; // Update the record object by creating a new object
    }

    handleSave() {
        const fields = {};
        fields['Id'] = this.recordId;
        fields['of_Hours__c'] = this.record.ofHours;
        fields['CCP_Level__c'] = this.record.CCP;
        fields['CCP_Total__c'] = this.record.CCPTotatlWithoutDiscount;
        fields['CCP_Discount_Rate__c'] = this.record.CCPDiscountRate;
        fields['CCP_Discount_Amount__c'] = this.record.CCPDiscountAmount;
        fields['CCP_Total_Amount__c'] = this.record.CCPClientPriceWithDiscount;

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
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}
