public class AccountNamingConvention 
{
 	/*
  		* This is a handler class for CountChildAccount (Account) Trigger
  		* Used for Site Account Naming Convention
  		* 
	*/
    public static boolean isExecuted =true;
    Public static void BeforeUpdate(List<Account> lstacc)
	{
        Map<String,String> ParentAccountName = new map<string,string>();
     
        Naming_Convention_Setting__c siteAccNameSetting = Naming_Convention_Setting__c.getInstance();
       // System.debug(siteAccNameSetting);
        if(siteAccNameSetting.Site_Account_Trigger__c)
        {
        try
        {
		for(Account acc : lstacc)
        {
           
            if(acc.Record_Type__c == 'Site')
            {
                if(acc.Named_Development__c == 'Yes')
                {  
                  
                    acc.Name = acc.Property_Name__c+', '+acc.ShippingCity+' '+acc.ShippingState;
                     acc.External_Site_Account_Name__c =  acc.Property_Name__c+', '+acc.ShippingCity+' '+acc.ShippingState;
     
                }
                else 
                {
                  if( acc.ParentId!=null)
                  {
                        acc.Name = acc.Parent_Account_Name__c+' '+acc.ShippingStreet;//+' '+acc.ShippingCity+' '+acc.ShippingState;
                      if(acc.Site_Partner_Internal_Identifier__c!=null && acc.Site_Partner_Internal_Identifier__c!='' )
                       acc.External_Site_Account_Name__c = acc.Parent_Account_Name__c+' '+acc.Site_Partner_Internal_Identifier__c+', '+acc.ShippingStreet;
                      else
                        acc.External_Site_Account_Name__c = acc.Parent_Account_Name__c+' '+acc.ShippingStreet;  
                  }
                
                }
            }
            
        }
        }
        catch(Exception e){system.debug('Error in AccountNamingConvention '+e.getMessage()+':'+e.getLineNumber());}
        }
        else { System.debug('No need of Site Account Naming Convention');}

    }
     Public static void AfterTrigger(List<Account> Accounts)
	{
        
        List<account> ToUpdate = new List<account>();
         if(AccountNamingConvention.isExecuted){
        for(Account acc : [select id,Record_Type__c,Site_Account__r.Name,Name,Cluster_Suffix__c from account where id in :Accounts])
        {
            system.debug(acc.record_type__c);
             if(acc.Record_Type__c == 'Cluster'){
                 if(acc.Cluster_Suffix__c!=null && acc.Cluster_Suffix__c!=''){
               
                     acc.Name = acc.Site_Account__r.Name+ ' '+acc.Cluster_Suffix__c;
                 ToUpdate.add(acc);
                 }
            }
        
    }
             AccountNamingConvention.isExecuted=false;
         }
       
        if(ToUpdate.size()>0)
         update ToUpdate;
        
    
}
}