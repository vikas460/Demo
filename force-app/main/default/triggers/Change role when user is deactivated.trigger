trigger TriggerUser on User (before update, after update,before insert) 
{
    
    List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
    Profile p = [select id from profile where profile.Name ='Inactive' limit 1];
    UserRole r = [Select Id from UserRole where UserRole.Name ='Inactive' limit 1];
    
    List<GroupMember> GMlist = new List<GroupMember>();
    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
 
        for(User u : Trigger.New)
         {
        
            if(u.IsActive == false)
            {       
               u.ProfileId = p.Id;
               u.UserRoleId = r.Id;           
            }
                
        }
           
    }

    if(Trigger.isAfter && Trigger.isUpdate)
    {
        for(User u : Trigger.New)
        {
        
            if(u.IsActive == false)
            { 
               psa = [Select Id from PermissionSetAssignment where assigneeId =: u.Id ];
  			   System.debug('PSA : ' + psa);
                
               // Public Group/Queue
               GMlist = [select id from GroupMember where UserOrGroupId =: u.Id];   
            }
         }
         try
         {
             if(!psa.isEmpty())
             {
                 Database.Delete(psa, false);
             }
             if(!GMlist.isEmpty())
             {
                 Database.Delete(GMlist, false);
             }
        
         }
        catch(Exception e)
        {
            System.debug('Error ' + e);
        }
    }
    
    /* Populate Manager field in USER record after created */
    if(Trigger.isBefore && Trigger.isinsert){
        
        for(user u : trigger.new){
            
        }
    }
    
}