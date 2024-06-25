public with sharing class CCPCreateOppProduct {

    @AuraEnabled
    public static String CCPCreateOppProduct(String oppId, Decimal clientUnitPrice) {
        try {
            // Fetch the Opportunity
            Opportunity opp = [SELECT Id, AccountId, Pricebook2Id, 	of_Hours__c FROM Opportunity WHERE Id = :oppId LIMIT 1];

            // Fetch the Product2 record for "CCP"
            Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'CCP Contract' LIMIT 1];

            system.debug('@@@Opp ' +opp);
            system.debug('@@@Product ' +product);

            // Fetch the PricebookEntry record for the product in the standard price book
            PricebookEntry pbe = [
                SELECT Id
                FROM PricebookEntry
                WHERE Product2.Name = :product.Name AND Pricebook2Id = :opp.Pricebook2Id
                LIMIT 1
            ];

            system.debug('@@@Opp ' +opp);
            system.debug('@@@Product ' +product);
            system.debug('@@@PB ' + pbe);

            // Create the OpportunityLineItem (Opportunity Product)
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opp.Id;
            oli.PricebookEntryId = pbe.Id;
            oli.Quantity = 1;
            oli.UnitPrice = 0;
            oli.Client_Unit_Price__c = clientUnitPrice;
            oli.Product_Details__c = opp.of_Hours__c + ' Hours CCP';
            oli.Vendor_Account__c = '00130000004rCgEAAU'; //set the vendor to Eastbay I.T. Consulting
            oli.QuoteCategory__c = 'Hardware'; 

            system.debug('@@@OLI ' + oli);
            insert oli;

            return 'Opportunity Product created successfully.';
        } catch (Exception e) {
            // Log the error and return the error message
            System.debug('Error creating Opportunity Product: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
}
