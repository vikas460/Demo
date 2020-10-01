@isTest
private class CreateAssetTest {
    
    @testSetup static void setupMethod()
    {
        account acct = new account(name='test');
        insert acct;
        
        zip__c zip = new zip__c(name='89108',county__c='Clark');
        insert zip;

        contact con = new contact(firstName='TestFN',lastName='TestLN',AccountId=acct.id,phone='5555555555');
        insert con;
        
        opportunity opp = new opportunity(
            name='test',stagename='Terms Agreed', Contract_Term__c=12,Probability=100,closedate=date.today()
            ,AccountId=acct.id,Electrical_Reimbursement__c=25.00,Rent__c=250.00
            ,Property_Listing_Link__c='https://www.testlink.co.jp/createAsset',Zip__c=zip.id
            ,Termimation_Date__c=date.today());
        insert opp;

        Product2 prdct = new Product2(name='test');
        insert prdct;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id=pricebookId,Product2Id=prdct.Id,UnitPrice = 10000,IsActive=true);
        insert standardPrice;

        Quote qt=new Quote(Name='Lightwilde',OpportunityId=opp.id, Pricebook2Id=pricebookId);
        insert qt;

        opp.SyncedQuoteId=qt.id;
        update opp;

        QuoteLineItem qli = new QuoteLineItem(PricebookEntryId=standardPrice.id,Quantity=1,QuoteId=qt.id,UnitPrice=10000);
        insert qli;

        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId=opp.Id,ContactId=con.id,Role='Decision Maker',IsPrimary=true);
        insert ocr;

        opp.Primary_Contact_Assigned__c=true;
        opp.stageName = 'Closed Won';
        update opp;
        
        system.debug('Show me the test ids:'+qt.id+','+qli.id);
        system.debug('Opp stageName:'+opp.stageName+' | Opp Primary Contact:'+opp.Primary_Contact_Assigned__c);
    }

    @isTest static void test_CheckIfNeeded() {
        Map<id, opportunity> MapNewMap=new Map<id, opportunity>([Select AccountId, isWon from Opportunity Limit 10]);
        CreateAsset ca = new CreateAsset();
        ca.NewOppMap = MapNewMap;
        ca.CheckIfNeeded();
    }
    
    @isTest static void test_findQuote() {
        // Implement test code
        Map<id, opportunity> MapNewMap=new Map<id, opportunity>([Select AccountId, isWon from Opportunity Limit 10]);
        Map<id, quote> NewQuoteMap=new Map<id, quote>();
        CreateAsset ca = new CreateAsset();
        ca.NewOppMap = MapNewMap;
        ca.CheckIfNeeded();
        ca.findQuote();

        // System.assertEquals(true,false);
    }/*
    
    @isTest static void test_findProducts() {
        // Implement test code
        System.assertEquals(true,false);
    }

    @isTest static void test_createTheAssets() {
        // Implement test code
        System.assertEquals(true,false);
    }*/
}