public with sharing class CreateAsset {
	
	public map<id,Opportunity> NewOppMap {get;set;}
	public map<id,Opportunity> OldOppMap {get;set;}
	map<id,Opportunity> OppMap1 {get;set;}
	map<id,Opportunity> OppMap2 {get;set;}
	list<Quote> QList {get;set;}
	map<id,Quote> QuoteMap {get;set;}
	list<QuoteLineItem> QliList {get;set;}
	list<Asset> NewAssetList {get;set;}
	map<id,Product2> ProdMap {get;set;}


	public CreateAsset() {}

	public PageReference CheckIfNeeded(){
		OppMap1 = new map<id,Opportunity>();
		if(NewOppMap == null || NewOppMap.size() == 0){
			return null; 
		}
		for(id i : NewOppMap.keyset()){
			if(OldOppMap == null || OldOppMap.get(i) == null){
				if(NewOppMap.get(i).isWon != true){
					continue;
				}
			}
			else{
				if(NewOppMap.get(i).isWon != true){
					continue; 
				}
				else if(NewOppMap.get(i).isWon == true && OldOppMap.get(i).isWon == true){
					continue;
				}
			}
			OppMap1.put(i,NewOppMap.get(i));
		}
		if(OppMap1.size() == 0){
			return null; 
		}
		findQuote();
		return null;
	}

	public PageReference findQuote(){
		Map<String, Schema.SObjectType> SobjectSchemaMap = Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult SobjectResult = SobjectSchemaMap.get('Quote').getDescribe();
		Map<String, Schema.SObjectField> SobjtField = SobjectResult.fields.getMap();
		string qry = '';
		for (Schema.SObjectField s : SobjtField.values()) {
		    qry += s + ',';
		}
		Set<Id> keys = OppMap1.keyset();
		qry = qry.removeend(',');
		qry = 'SELECT '+qry+' FROM Quote WHERE OpportunityId in ';
		qry += ':keys AND IsSyncing = true';
		system.debug('Query: '+qry);
		QList = database.query(qry);
		if(QList.size() == 0){
			return null; 
		}
		QuoteMap=new map<id,Quote>();
		for(Quote q : QList){
			QuoteMap.put(q.id,q);
		}
		findQuoteLineItems();
		return null;
	}

	public PageReference findQuoteLineItems(){
		Map<String, Schema.SObjectType> SobjectSchemaMap = Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult SobjectResult = SobjectSchemaMap.get('QuoteLineItem').getDescribe();
		Map<String, Schema.SObjectField> SobjtField = SobjectResult.fields.getMap();
		string qry = '';
		for (Schema.SObjectField s : SobjtField.values()) {
		    qry += s + ',';
		}
		Set<Id> keys = QuoteMap.keyset();
		qry = qry.removeend(',');
		qry = 'SELECT '+qry+' FROM QuoteLineItem WHERE QuoteId in ';
		qry += ':keys';
		system.debug('Query find QLI'+qry);
		QliList = database.query(qry);
		if(QliList.size() == 0){
			return null; 
		}
		findProducts();
		return null;
	}

	public PageReference findProducts(){
		set<id> tempIdSet = new set<id>();
		for(QuoteLineItem qli : QliList){
			tempIdSet.add(qli.Product2Id);
		}
		ProdMap = new map<id,Product2>();
		ProdMap.putall([select name,Description,family, Kiosk__c from Product2 where id in :tempIdSet]);
		if(ProdMap.size() == 0){
			return null; 
		}
		createTheAssets();
		return null;
	}

	public PageReference createTheAssets(){
		NewAssetList = new list<Asset>();
		for(QuoteLineItem qli : QliList){
			Asset a = new Asset();
				a.AccountId = OppMap1.get(QuoteMap.get(qli.QuoteId).OpportunityId).AccountId;
				a.Name = ProdMap.get(qli.Product2Id).name;
				if(QuoteMap.get(qli.QuoteId).ContactId != null){
					a.ContactId = QuoteMap.get(qli.QuoteId).ContactId; 
				}
				a.Kiosk__c=ProdMap.get(qli.Product2Id).Kiosk__c;
				a.Description = qli.Description;
				a.InstallDate = qli.Start_Date__c;
				a.Price = qli.UnitPrice;
				a.Product2Id = qli.Product2Id;
				//a.PurchaseDate = qli.;
				a.Quantity = qli.Quantity;
				//a.SerialNumber = qli.;
				a.Status = 'Purchased';
				a.UsageEndDate = qli.End_Date__c;
			NewAssetList.add(a);
		}
		Try{
			insert NewAssetList;
		}
		Catch(exception e){
			system.debug(logginglevel.info, '*****'+e);
		}
		return null;
	}



}