public with sharing class CCPCreatorController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCCPFields(string oppId){
        
        Opportunity opp = [SELECT Id, of_Hours__c, CCP_Level__c, CCP_Total__c, CCP_Discount_Rate__c, CCP_Discount_Amount__c, CCP_Total_Amount__c, Account.Id
                            FROM Opportunity WHERE Id = :oppId ];

        Account acc = [SELECT Id, Standard_Hourly_Rate_Sr__c FROM Account WHERE Id = :opp.Account.Id ];

        Map<String, Object> flattenedRecord = new Map<String, Object>{
            'CCP' => opp.CCP_Level__c,
            'StandardHourlyRate' => acc.Standard_Hourly_Rate_Sr__c,
            'ofHours' => opp.of_Hours__c,
            'CCPTotatlWithoutDiscount' => opp.CCP_Total__c,
            'CCPDiscountRate' => opp.CCP_Discount_Rate__c,
            'CCPDiscountAmount' => opp.CCP_Discount_Amount__c,
            'CCPClientPriceWithDiscount' => opp.CCP_Total_Amount__c
            };

            return flattenedRecord;

    }
}