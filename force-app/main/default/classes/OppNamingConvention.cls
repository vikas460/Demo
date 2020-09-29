public class OppNamingConvention 
{
 	/*
  		* This is a handler class for OpportunityTrigger (Opportunity) Trigger
  		* Used for Site & Media Opp Naming Convention
  		* 
	*/

    Public static void NamingConvention(List<Opportunity> lstopp)
	{
        Naming_Convention_Setting__c oppNameSetting = Naming_Convention_Setting__c.getInstance();
        System.debug(oppNameSetting);
        /*
        Boolean siteopp = oppNameSetting.Site_Opportunity_Trigger__c;
        Boolean mediaopp = oppNameSetting.Media_Opportunity_Trigger__c;
        system.debug('Media Opp checkbox ' +mediaopp);
        system.debug('Site Opp checkbox ' +siteopp);
        */

        try 
        {
		for(Opportunity opp : lstopp)
        {
           
            // Site Opp
            if(oppNameSetting.Site_Opportunity_Trigger__c && opp.Record_Type_Name__c=='Site')
            {
                system.debug(opp.Is_Named_Development__c);
                if(opp.Is_Named_Development__c==false)
                opp.Name = opp.Site_Account_Name__c+' Phase'+' '+opp.Phase__c;
                else
                    opp.Name = Opp.Account_Name__c+' '+opp.Site_Account_Name__c+' Phase'+' '+opp.Phase__c;  
            }
            else
            {
               // System.debug('No need of media opp naming convention');
            }
            
            //Media Opp
            if(oppNameSetting.Media_Opportunity_Trigger__c && opp.Record_Type_Name__c=='Media')
            {
                Integer admonth = opp.Ad_Install_Date__c.month();
                Integer adyear = opp.Ad_Install_Date__c.year();
                Integer count =0;
                if(admonth!=0 || admonth!=null)
                {
                if(admonth<=3 && admonth>=1 )
                {
                    count = 1;
                }
                else if(admonth<=6 && admonth>=4)
                {
                    count=2;
                }
                else if(admonth<=9 && admonth>=7)
                {
                    count=3;
                }
                else if(admonth<=12 && admonth>=10)
                {
                    count=4;
                }
                }
                
            opp.Name = opp.Account_Name__c+' '+ opp.Campaign_Name__c +' ' +count+'Q'+' '+adyear;
               // if(opp.stageName=='Ad/Sales - Negotiation/Review')
            //opp.External_Opportunity_Name__c = opp.External_Account_Name__c+' '+ opp.Campaign_Name__c+' '+count+'Q'+' '+adyear;
            
            }
            else
            {
                System.debug('No need of media opp naming convention');
            }
        }
        }catch(Exception e){system.debug('Error in OppNamingConvention '+e.getMessage()+':'+e.getLineNumber());}
	}
    
}