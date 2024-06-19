import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

// Specify the fields to fetch
const FIELDS = [
    {label: 'CCP Type', fieldName: 'CCP'},
    {label: 'Client Hourly Rate', fieldName: 'StandardHourlyRate'},
    {label: '# of Hours', fieldName: 'ofHours'},
    {label: 'Total Without Discount', fieldName: 'CCPTotatlWithoutDiscount'},
    {label: 'Discount Rate', fieldName: 'CCPDiscountRate' },
    {label: 'Discount Amount', fieldName: 'CCPDiscountAmount'},
    {label: 'Client Price with Discount', fieldName: 'CCPClientPriceWithDiscount'}
];

export default class DisplayCCPFields extends LightningElement {
    @api recordId;

    @wire(getRecord, { oppID: '$recordId', fields: FIELDS })

}