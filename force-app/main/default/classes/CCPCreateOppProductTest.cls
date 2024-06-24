@isTest
private class CCPCreateOppProductTest {
    
        @testSetup
        static void setupTestData() {
            // Create a test Account
            Account testAccount = new Account(
                Name = 'Test Account',
                Standard_Hourly_Rate_Sr__c = 100
            );
            insert testAccount;
    
            // Create a test Opportunity
            Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'PO Received',
                CloseDate = Date.today().addDays(30),
                AccountId = testAccount.Id,
                CCP_Level__c = 'Bronze'
            );
            insert testOpportunity;
    
            // Create a test Product2 (CCP)
            Product2 testProduct = new Product2(
                Name = 'CCP Contract',
                Family = 'Hardware',
                isActive = true
            );
            insert testProduct;

            Id pbId = Test.getStandardPricebookId();
    
            // Create a Pricebook2 (Standard Price Book)
            Pricebook2 standardPriceBook = new Pricebook2(
                id = pbId,
                Name = 'Standard Price Book', 
                Description = 'Price Book Products', 
                IsActive = true 
            );
            update standardPriceBook;

            Pricebook2 spb = [SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1];

            System.debug('@@@SPB ' + spb);

            PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = spb.Id, Product2Id = testProduct.Id, UnitPrice = 1000, IsActive = true);
            insert standardPBE;

            System.debug('@@@SPE ' + standardPBE);
    
            // Create a PricebookEntry for the product
            PricebookEntry testPricebookEntry = new PricebookEntry(
                Pricebook2Id = standardPriceBook.Id,
                Product2Id = testProduct.Id,
                UnitPrice = 100,
                IsActive = true,
                UseStandardPrice = false
            );
          //  insert testPricebookEntry;
        }
    
        @isTest
        static void testCreateOpportunityProduct() {
            // Retrieve test data
            Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
            Decimal clientUnitPrice = 900.00;
    
            // Call the method to test
            Test.startTest();
            String result = CCPCreateOppProduct.CCPCreateOppProduct(testOpportunity.Id, clientUnitPrice);
            String badResult = CCPCreateOppProduct.CCPCreateOppProduct('000000000000000', clientUnitPrice);
            Test.stopTest();
    
            // Verify the result
            System.assertEquals('Opportunity Product created successfully.', result);
            System.assertEquals('Error: List has no rows for assignment to SObject', badResult);
    
            // Verify that the OpportunityLineItem was created correctly
            OpportunityLineItem[] oliList = [
                SELECT OpportunityId, PricebookEntryId, Quantity, UnitPrice, TotalPrice, Description, Vendor_Account__c, QuoteCategory__c
                FROM OpportunityLineItem
                WHERE OpportunityId = :testOpportunity.Id
            ];
            
            System.assertEquals(1, oliList.size(), 'Exactly one OpportunityLineItem should be created.');
    
            OpportunityLineItem oli = oliList[0];
            System.assertEquals(1, oli.Quantity);
            System.assertEquals(900.00, oli.UnitPrice);
            System.assertEquals(clientUnitPrice, oli.TotalPrice);
            System.assertEquals('CCP', oli.Description);
            //System.assertEquals('Eastbay I.T. Consulting', oli.Vendor_Account__c);
            System.assertEquals('Hardware', oli.QuoteCategory__c);
        }
    }