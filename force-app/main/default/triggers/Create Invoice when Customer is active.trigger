// Modified Trigger Code
trigger Customer_After_Insert on APEX_Customer__c (after update) {
   List<apex_invoice__c> InvoiceList = new List<apex_invoice__c>();
   
   for (APEX_Customer__c objCustomer: Trigger.new) {
      
      // condition to check the old value and new value
      if (objCustomer.APEX_Customer_Status__c == 'Active' &&
      
      trigger.oldMap.get(objCustomer.id).APEX_Customer_Status__c == 'Inactive') {
         APEX_Invoice__c objInvoice = new APEX_Invoice__c();
         objInvoice.APEX_Status__c = 'Pending';
         InvoiceList.add(objInvoice);
      }
   }
   
   // DML to insert the Invoice List in SFDC
   insert InvoiceList;
}