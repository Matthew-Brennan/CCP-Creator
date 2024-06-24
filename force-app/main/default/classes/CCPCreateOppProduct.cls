public with sharing class CCPCreateOppProduct {

    @AuraEnabled(cacheable=true)
    public static String CCPCreateOppProduct(String oppId, Decimal clientUnitPrice) {
        try {
            // Fetch the Opportunity
            Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :oppId LIMIT 1];

            // Fetch the Product2 record for "CCP"
            Product2 product = [SELECT Id FROM Product2 WHERE Name = 'CCP Contract' LIMIT 1];

            system.debug('@@@Opp ' +opp);
            system.debug('@@@Product ' +product.Id);

            // Fetch the PricebookEntry record for the product in the standard price book
            PricebookEntry pbe = [
                SELECT Id
                FROM PricebookEntry
                WHERE Product2Id = :product.Id AND Pricebook2.Id = '01s300000000XpNAAU'
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
            oli.UnitPrice = clientUnitPrice;
            oli.Description = 'CCP';
            //oli.Vendor_Account__c = 'Eastbay I.T. Consulting'; // Assuming there is a custom field for vendor account
            oli.QuoteCategory__c = 'Hardware'; // Assuming there is a custom field for quote category

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
