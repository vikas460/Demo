public with sharing class AvailablePotentialSites {
	public static void availableSites(List<Opportunity> oppList) {
		// Stores the IDs of the opportunities with StageName = 'Closed Lost'
		List<String> oppIdCL = new List<String>();

		// Loop thorugh the list of opps and add the IDs of the ones that have
		// the StageName marked 'Closed Lost' to the oppIdCL list so that the list
		// can be used to update all of the related Potential_Site__c objects.
		for(Opportunity opp : oppList){
			if(opp.StageName == 'Closed Lost'){
				oppIdCL.add(opp.Id);
			}
		}

		// Get all of the potential sites that are related to the opportunity.
		List<Potential_Site__c> psList = [SELECT Id, Stage__c FROM Potential_Site__c WHERE Opportunity__c IN :oppIdCL];

		// Loop through the potential sites list and update the Stage__c to 'Available'.
		for(Potential_Site__c ps : psList){
			ps.Stage__c = 'Available';
		}

		update psList;
	}
}