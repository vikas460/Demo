trigger CountChildAccount on Account(before insert,before update,after insert, after update, after delete) {
    Set<Id> Ids= new Set<Id>();

    List<Account> acclist = new List<Account>();
 List<Account> acclistToUpdate = new List<Account>();
    if(Trigger.isBefore && (Trigger.isinsert || Trigger.isUpdate))
    {
       
        AccountNamingConvention.BeforeUpdate(Trigger.New);
    }
    
    try{
    
    if( Trigger.isAfter &&  ( Trigger.isInsert || Trigger.isUpdate)){
AccountNamingConvention.AfterTrigger(trigger.new);
        if(Trigger.isInsert){
          for(Account acc: [select id from account where id=:Trigger.new]) // Blank update for Naming convention since the territory picklsit works on after update.
         acclistToUpdate.add(acc);
        }
        for(Account acc: Trigger.new){

            if(acc.ParentId!=null)

                Ids.add(acc.ParentId);

            acclist.add(acc);
             

        }
        if(Trigger.isUpdate){
            List<Opportunity> Opps = new list<opportunity>();
            Opps =[select id,Record_Type_Name__c,Is_Named_Development__c,Phase__c,Site_Account_Name__c,Account_Name__c from opportunity where site_Account__c in :Trigger.new];
           system.debug(opps);
            OppNamingConvention.NamingConvention(Opps);
            if(opps.size()>0)
            update opps;
        }
  

    }
    if (!acclistToUpdate.isEmpty())
            update acclistToUpdate;   

     

    if(Trigger.isAfter && Trigger.isDelete){

       for(Account acc: Trigger.old){

            if(acc.ParentId!=null)
                Ids.add(acc.ParentId);

            acclist.add(acc);

        }
    }

 
    if (!Ids.isEmpty()) {
        List<Account> AccountToUpdate = new List<Account>();
        
        Map<Id, Integer> mapcount = new Map<Id, Integer>();
        
        for (AggregateResult ar : [SELECT COUNT(ID), ParentID FROM Account 
                                WHERE ParentID IN :Ids GROUP BY ParentID]) {
              Id accID = (ID)ar.get('ParentID');
            Integer count = (Integer)ar.get('expr0');
            Account acc1 = new Account(Id=accID);
            acc1.Count__c= count;
            AccountToUpdate.add(acc1);
        }
        
        

        if (!AccountToUpdate.isEmpty()) {
            update AccountToUpdate;
        }
        
    }
    }catch(Exception e){
        system.debug('Exception '+e.getMessage()+':'+e.getLineNumber());
    }
}