public with sharing class ConvertPotentialSiteToConstruction {
	public static void convert(List<Opportunity> oppList) {

		system.debug(logginglevel.error, '*****Start ConvertPotentialSiteToConstruction');

		// Stores the IDs of the opportunities with StageName = 'Closed Lost'
		List<String> oppIdCL = new List<String>();

		// Loop thorugh the list of opps and add the IDs of the ones that have
		// a probability of 80% to the oppIdCL list so that the list
		// can be used to update all of the related Potential_Site__c objects.
		for(Opportunity opp : oppList){
			if(opp.Probability >= 80){
				oppIdCL.add(opp.Id);
			}
		}

		system.debug(logginglevel.error, '*****oppIdCL='+oppIdCL);

		// Get all of the potential sites that are related to the opportunity.
		List<Potential_Site__c> psList = [SELECT Id, Account__c, Anchor_Stores__c, Average_HH_Income__c, Avg_Age__c,
												City__c, Closest_Public_EVSE_by_type__c, Closest_Public_EVSE_in_Miles__c,
												County__c, Ease_of_Installation__c, EVs_by_State__c, Existing_Public_EVs_on_Site__c,
												Infrastructure_Obstructions__c, Location_Description_EVSE__c,
												Location_Typology__c, Name, Network_Region__c, Opportunity__c, OwnerId,
												Parking__c, Population__c, Property_Owner_Company__c, Site_Surface_Material__c, 
												Site_Visibility__c, Size_SF__c, Stage__c, State__c, Suggested_of_Installations__c,
												Suggested_Type_of_Installation__c, Vertical__c, Visitors_Month__c,
												SFM_Email__c, SFM_Phone__c, SFM_Site_Facilities_Manager__c,
												SEM_Email__c, SEM_Phone__c, SEM_Site_Electrical_Manager__c
										FROM Potential_Site__c WHERE Opportunity__c IN :oppIdCL];
		// List to store all of the new construction projects.
		List<Construction_Project__c> cpList = new List<Construction_Project__c>();

		// Loop through the potential sites list and update the Stage__c to 'Available'.
		for(Potential_Site__c ps : psList){
			ps.Stage__c = 'Converted To Construction Site';

			// Create a new construction project and map the fields
			// from the potential site to the construction project.
			Construction_Project__c cp = new Construction_Project__c();
			cp.Primary_Account__c = ps.Account__c;
			cp.Anchor_Stores__c = ps.Anchor_Stores__c;
			cp.Avg_HH_Income__c = ps.Average_HH_Income__c;
			cp.Avg_Age__c = ps.Avg_Age__c;
			cp.City__c = ps.City__c;
			cp.Closest_Public_EVSE_by_type__c = ps.Closest_Public_EVSE_by_type__c;
			cp.Closest_Public_EVSE_in_Miles__c = ps.Closest_Public_EVSE_in_Miles__c;
			cp.County__c = ps.County__c;
			cp.Ease_of_Installation__c = ps.Ease_of_Installation__c;
			cp.EVs_by_State__c = ps.EVs_by_State__c;
			cp.Existing_Public_EVs_on_Site__c = ps.Existing_Public_EVs_on_Site__c;
			cp.Infrastructure_Obstructions__c = ps.Infrastructure_Obstructions__c;
			cp.Location_Description_EVSE__c = ps.Location_Description_EVSE__c;
			cp.Location_Typology__c = ps.Location_Typology__c;
			cp.Name = ps.Name;
			cp.Network_Region__c = ps.Network_Region__c;
			cp.Biz_Dev_Opportunity__c = ps.Opportunity__c;
			//cp.OwnerId = ps.OwnerId;
			cp.Parking__c = ps.Parking__c;
			cp.Population__c = ps.Population__c;
			cp.Site_Surface_Material__c = ps.Site_Surface_Material__c;
			cp.Site_Visibility__c = ps.Site_Visibility__c;
			cp.Size_SF__c = ps.Size_SF__c;
			cp.State__c = ps.State__c;
			cp.Suggested_number_of_Installations__c = ps.Suggested_of_Installations__c;
			cp.Suggested_Type_of_Installation__c = ps.Suggested_Type_of_Installation__c;
			cp.Vertical__c = ps.Vertical__c;
			cp.Visitors_Month__c = ps.Visitors_Month__c;
			cp.SFM_Email__c = ps.SFM_Email__c;
			cp.SFM_Phone__c = ps.SFM_Phone__c;
			cp.SFM_Site_Facilities_Manager__c = ps.SFM_Site_Facilities_Manager__c;
			cp.SEM_Email__c = ps.SEM_Email__c;
			cp.SEM_Phone__c = ps.SEM_Phone__c;
			cp.SEM_Site_Electrical_Manager__c = ps.SEM_Site_Electrical_Manager__c;

			cpList.add(cp);
		}

		update psList;
		insert cpList;
	}
}