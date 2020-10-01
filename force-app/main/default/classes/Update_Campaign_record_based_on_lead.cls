@isTest
private class ConvertPotentialSiteToConstructionTest {
    
    @testSetup static void setupMethod()
    {
        account a = new account(name='test');
        insert a;
        opportunity o = new opportunity(name='test',stagename='Test Opp',Probability=100,closedate=date.today(),AccountId=a.id);
        insert o;

        Potential_Site__c site=new Potential_Site__c(Name='Shadowacre',Opportunity__c=o.id, Account__c=a.id, Property_Owner_Company__c='Shadowacre Enterprises' );
        insert site;
    }

    @isTest static void test_Convert_Site() {
        List<opportunity> opp=[Select Id, Probability from opportunity limit 1];
        System.assertNotEquals(0, opp.size(),'No opportunities were selected.');

        ConvertPotentialSiteToConstruction.convert(opp);

        List<Construction_Project__c> projects=[Select id from Construction_Project__c limit 1];
        System.assertNotEquals(0,projects.size(),'No construction projects were found.');
    }
}