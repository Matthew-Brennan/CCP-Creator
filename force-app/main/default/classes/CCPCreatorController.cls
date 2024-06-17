public with sharing class CCPCreatorController {
    public CCPCreatorController() {

    }

    public static Account getAccount(string accId){
        Account acc = [SELECT Id, Standard_Hourly_Rate_Sr__c FROM Account WHERE Id = :accId ];
    }
}