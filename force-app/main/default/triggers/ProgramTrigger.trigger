trigger ProgramTrigger on Program__c (after insert)
{
    
    List<Opportunity> lstOpp = new List<Opportunity>();
    List<string> StateValues = new List<String>();
    list<string> Cities = new list<string>();
    set<String> Owner_Email_Addresses = new set<String>();
    Map<String,string> OppOwners = new Map<String,String>();
    Map<String,List<string>> OppOwnerswithName = new Map<String,List<string>>();
    Map<String,string> OppOwnersNamewithEmail = new Map<String,string>();
    List<ProgramDetail__c> ProgramDetailsList = new List<ProgramDetail__c>();
    list<sitetracker__Project__c> Projects = new list<sitetracker__Project__c>(); 
    Rebate_Program_Notification_Off__c SwitchNotification = Rebate_Program_Notification_Off__c.getInstance();
    system.debug('SwitchNotification '+SwitchNotification);
    if(Trigger.isAfter && Trigger.isInsert )
    {
        try{
            List<CitiesData> CitiesDataVal = new list<CitiesData>();
           
            // Collect cities and state values of the Program
            for(Program__c p : Trigger.New)
            {
               //if( p.State__c != null )
                    StateValues.add(p.state__c);
                     system.debug(p.Name);     
                if(p.Cities__c!=null)
                    if(p.Cities__c.contains(','))
                    Cities = p.Cities__c.split(',');
                else
                    Cities.add(p.Cities__c);
                CitiesDataVal.add(new CitiesData(P.State__c,P.Cities__c,P.Id,P.Name));
            }
       
           lstOpp = [select id, name, Site_Account__r.ShippingState,Owner_s_Email__c,Owner_fullName__c,Site_Account__r.ShippingCity  from Opportunity 
                      where recordtype.name ='Site' and Site_Account__r.ShippingState=:StateValues];
         Projects =[SELECT Id, Name, Site_Account__r.ShippingState,Site_Account__r.ShippingCity FROM sitetracker__Project__c limit :limits.getLimitQueryRows()];
            if(Cities.size()>0)
               lstOpp = [select id, name,Site_Account__r.ShippingCity, Site_Account__r.ShippingState,Owner_s_Email__c,Owner_fullName__c  from Opportunity 
                      where recordtype.name ='Site' and Site_Account__r.ShippingState=:StateValues and Site_Account__r.ShippingCity in :Cities];  
        
            // Collect Opp Owners Notify Opp Owners
            for(Opportunity Opp :lstOpp){
                
                OppOwners.put(Opp.Id,Opp.Owner_s_Email__c);
                OppOwnersNamewithEmail.put(Opp.Owner_s_Email__c,opp.Owner_fullName__c);
                //Related Program Details for mapping the opportunity
              
            }
              for(CitiesData c:   CitiesDataVal)
                {
                    for(Opportunity Opp :lstOpp){
                        if(Opp.Site_Account__r.ShippingCity!=null && C.cities!=Null)
                        if(Opp.Site_Account__r.ShippingState==c.State && C.cities.contains(Opp.Site_Account__r.ShippingCity) && Cities.size()>0 ){
                   ProgramDetail__c PD = new ProgramDetail__c(Program__c=c.ProgramId,Site_Opportunity__c=Opp.id,Name=c.ProgramName);
                        ProgramDetailsList.add(PD);
                        }
                         if(Opp.Site_Account__r.ShippingState==c.State && Cities.size()==0){
                             ProgramDetail__c PD1 = new ProgramDetail__c(Program__c=c.ProgramId,Site_Opportunity__c=Opp.id,Name=c.ProgramName);   
                     			 ProgramDetailsList.add(PD1);
                        }  }
                    //Add Projects to the Program
                    for(sitetracker__Project__c Pr: Projects){
                        if(Pr.Site_Account__r.ShippingCity!=Null && C.cities!=null)
                        if(Pr.Site_Account__r.ShippingState==C.state && C.cities.contains(Pr.Site_Account__r.ShippingCity) && Cities.size()>0 ){
                             ProgramDetail__c PD = new ProgramDetail__c(Program__c=c.ProgramId,Project__c=Pr.id,Name=c.ProgramName);
                       // ProgramDetailsList.add(PD);
                        }
                          if(Pr.Site_Account__r.ShippingState==c.State && Cities.size()==0){
                             ProgramDetail__c PD1 = new ProgramDetail__c(Program__c=c.ProgramId,Project__c=Pr.id,Name=c.ProgramName);   
                     			// ProgramDetailsList.add(PD1);
                        } 
                        }
                    
                      // ProgramDetails__c PD = new ProgramDetails__c(Program__c=)
                }
             
            system.debug('All Opps count '+lstopp.size());
            
            // Filer duplicate Owner emails
           
            Owner_Email_Addresses.addAll(OppOwners.values());
           // system.debug('All Opps count '+lstopp.size());
            system.debug('Owner_Email_Addresses'+Owner_Email_Addresses.size());
            List<string> OppNamesTemp = new List<String>();
            
            for(string s :Owner_Email_Addresses){
                OppNamesTemp.clear();
                
                for(Opportunity Opp :lstOpp){
                    if(opp.Owner_s_Email__c==s)
                        OppNamesTemp.add(Opp.Name);
                }
                OppOwnerswithName.put(s,OppNamesTemp);
            }
             system.debug('No. of Opps that have been matched: '+lstOpp.size());
            system.debug('No. of users will get notified: '+OppOwnerswithName.size());
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>(); 
            List<String> Opps_That_Owned = new list<string>();
            for(String S : Owner_Email_Addresses){
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                list<string> Receipents = new list<string>();
                Receipents.add(s);
                message.BccAddresses = Receipents;
                for(String Opps :OppOwnerswithName.get(s))
                    Opps_That_Owned.add(opps);
                
                if(Opps_That_Owned.size()>1){
                    message.subject ='Opportunities have matched with a Rebate Program' ;
                    message.setHtmlBody('Hi '+OppOwnersNamewithEmail.get(s)+',<br/><br/><b>'+Opps_That_Owned+'</b> have matched with Rebate Program: <b>'+Trigger.New[0].Name+'.</b>  Review Rebate Program details and requirements by following this link: '+Trigger.New[0].Website__c+'. If project is eligible, contact Eric Lustgarten to initiate application process.');
                }
                else if(Opps_That_Owned.size()==1)
                {
                    message.subject ='Opportunity has matched with a Rebate Program' ;
                    message.setHtmlBody('Hi '+OppOwnersNamewithEmail.get(s)+',<br/><br/><b>'+Opps_That_Owned+'</b> has matched with Rebate Program: <b>'+Trigger.New[0].Name+'.</b>  Review Rebate Program details and requirements by following this link: '+Trigger.New[0].Website__c+'. If project is eligible, contact Eric Lustgarten to initiate application process.');
                }
                emails.add(message);
            }
            if(SwitchNotification.Turn_On__c==TRUE){
            //system.debug('emails '+emails.size());
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
if (results[0].success) {
System.debug('The email was sent successfully.');
} else {
System.debug('The email failed to send: '
+ results[0].errors[0].message);
}
            }
system.debug('emails '+emails[0]);
            if(ProgramDetailsList.size()>0)
        insert ProgramDetailsList;    
      //  } // end custom setting check
        } catch(exception e){system.debug('Exception '+e.getMessage()+ 'Line No: '+e.getLineNumber());}
    } // end if
    
     public class CitiesData {
       
        public string State;
      
        public string Cities;
      	
        public Id ProgramID;
         public string ProgramName;
        public CitiesData(string State, string Cities, Id ProgramID,String ProgramName) {
            this.State = State;
            this.Cities = Cities;
            this.ProgramID = ProgramID;
             this.ProgramName = ProgramName;
        } }
}