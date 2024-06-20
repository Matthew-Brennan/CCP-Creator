@isTest
private class CCPCreatorControllerTest {

@isTest
    static void testGetCCPFields() {


        // Insert an opportunity with an account
        Account a = new Account(
            Name = 'Axiom LTD',
            Standard_Hourly_Rate_Sr__c = 160
            
        );
        insert a;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = a.Id,
            StageName = 'Closed Won',
            CCP_Level__c =  'Platinum', 
            CloseDate = System.today()
        );
        insert opp;


       // Opportunity opp = [SELECT Id, of_Hours__c, CCP_Level__c, CCP_Total__c, CCP_Discount_Rate__c, CCP_Discount_Amount__c, CCP_Total_Amount__c FROM Opportunity WHERE Name = 'Axiom needs a new server - Matt Dieter Testing 2' LIMIT 1];
       // Account acc = [SELECT Id FROM Account WHERE Name = 'Axiom LTD' LIMIT 1];

     //  System.debug('Opp: '+opp);
    //   System.debug('Acc: '+a);

        Test.startTest();
        Map<String, Object> record = CCPCreatorController.getCCPFields(opp.Id);
        Test.stopTest();

        System.assertEquals(opp.CreatedDate, record.get('CCP'), 'CCP should match');
       // System.assertEquals(a.Standard_Hourly_Rate_Sr__c, record.get('StandardHourlyRate'), 'StandardHourlyRate should match');
        System.assertEquals(opp.of_Hours__c, record.get('ofHours'), 'ofHours should match');
        System.assertEquals(opp.CCP_Total__c, record.get('CCPTotatlWithoutDiscount'), 'CCPTotatlWithoutDiscount should match');
        System.assertEquals(opp.CCP_Discount_Rate__c, record.get('CCPDiscountRate'), 'CCPDiscountRate should match');
        System.assertEquals(opp.CCP_Discount_Amount__c, record.get('CCPDiscountAmount'), 'CCPDiscountAmount should match');
        System.assertEquals(opp.CCP_Total_Amount__c, record.get('CCPClientPriceWithDiscount'), 'CCPClientPriceWithDiscount should match');
    }
}