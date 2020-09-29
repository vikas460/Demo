public class MapClass {

    public PageReference removeFromQuote() {
        QuoteLineItem qli = [SELECT Id, Quote.Id FROM QuoteLineItem WHERE Id = :qliToRemove];
        Delete qli;
        return null;
    }


    public QuoteLineItem[] getExistingFaces() {
        QuoteLineItem[] qli = [SELECT Id, Product2.Name, Quote.Name, ListPrice, UnitPrice, Quantity, Start_Date_Text__c, End_Date_Text__c, SubTotal, Discount, TotalPrice FROM QuoteLineItem where Quote.Id = :ApexPages.CurrentPage().getParameters().get('qid')];
        return qli;
    }

    public string qliToRemove {get;set {qliToRemove = value;}}
    public Transient list<markWrap> MWlist {get;set;}                       //-- Added Transient by GSD 08/27/2018
    public list<SelectOption> regns {get;set;}
    public string regnPicked {get;set;}
    public Date_Input__c mc {get;set;}
    public Quote qut {get;set;}
    public boolean underConstruction {get;set;}
    public boolean alreadyBooked {get;set;}
    public Transient list<markWrap> underConstructionList {get;set;}        //-- Added Transient by GSD 08/27/2018
    public Transient list<markWrap> alreadyBookedList {get;set;}            //-- Added Transient by GSD 08/27/2018
    public Transient map<id,list<Asset>> ProdIdToAsset {get;set;}           //-- Added Transient by GSD 10/16/2018
    public Transient map<Id,List<Product2>> kioskId_to_Product {get;set;}   //-- Added Transient by GSD 08/27/2018
    public string startDateString {get;set;}
    public string endDateString {get;set;}
    public list<SelectOption> regions {get;set;}
    public Transient map<id,list<QuoteLineItem>> ProdIdToQuoteLineItem {get;set;}    //-- Added Transient by GSD 10/16/2018
    public boolean needsPriceBook {get;set;}
    public list<SelectOption> pbs {get;set;}

    public class markWrap{
        public decimal lat {get;set;}
        public decimal lon {get;set;}
        public string latLong {get;set;}
        public string mark {get;set;}
        public string el {get;set;}
        public string contentstrng {get;set;}
        public string infowndw {get;set;}
        public string link {get;set;}
        public string name {get;set;}
        public boolean include {get;set;}
        public list<faceWrap> faces {get;set;}
    }

    public class faceWrap{
        public Product2 prod {get;set;}
        public string prodName {get;set;}
        public boolean include {get;set;}
        public list<Asset> bookedTime {get;set;}
        public list<openTime> otlist {get;set;}
        public list<QuoteLineItem> quliitList {get;set;}
    }

    public class openTime{
        public string startDate {get;set;}
        public string endDate {get;set;}
    }

    public MapClass(){
        regns = new list<SelectOption>();
        sObject obj = new Kiosk__c();
        Schema.sObjectType objType = obj.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get('Network_Region__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values){
            regns.add(new SelectOption(a.getLabel(), a.getValue()));
        }
        mc = Date_Input__c.getInstance(userinfo.getProfileId());
        
        qut = [select name,Pricebook2Id, Start_Date_for_Map_Page__c, End_Date_for_Map_Page__c from Quote where id = :ApexPages.CurrentPage().getParameters().get('qid')];
        if(qut.Pricebook2Id == null){
            needsPriceBook = true;
            List<Pricebook2> pblist = [select name from Pricebook2 where isactive = true];
            pbs = new list<SelectOption>();
            for(Pricebook2 pb2 : pblist){
                pbs.add(new SelectOption(pb2.id, pb2.name));
            }
        }
        else{
            needsPriceBook = false;
        }
    }

    public void choosePriceBook(){
        update qut;
        qut = [select name,Pricebook2Id, Start_Date_for_Map_Page__c, End_Date_for_Map_Page__c from Quote where id = :ApexPages.CurrentPage().getParameters().get('qid')];
        if(qut.Pricebook2Id == null){
            needsPriceBook = true;
            List<Pricebook2> pblist = [select name from Pricebook2 where isactive = true];
            pbs = new list<SelectOption>();
            for(Pricebook2 pb2 : pblist){
                pbs.add(new SelectOption(pb2.id, pb2.name));
            }
        }
        else{
            needsPriceBook = false;
        }
    }

    public markWrap createMarkWrap(Kiosk__c k, integer i){
        markWrap mw = new markWrap();
            mw.lat = k.Latitude__c;
            mw.lon = k.Longitude__c;
            mw.latLong = 'mylat'+string.valueof(i);
            mw.mark = 'm'+string.valueof(i);
            mw.el = 'el'+string.valueof(i);
            mw.contentstrng = 'c'+string.valueof(i);
            mw.name = string.escapeSingleQuotes(k.name);
            mw.link = k.id;
            mw.infowndw = 'i'+string.valueof(i);
            if(kioskId_to_Product.get(k.id) != null){
                for(Product2 p : kioskId_to_Product.get(k.id)){
                    faceWrap fw = new faceWrap();
                        fw.prod = p;
                        
                        fw.prodName = string.escapeSingleQuotes(p.name);
                        system.debug(logginglevel.info, '*****ProdIdToAsset1212='+ProdIdToAsset);
                        if(ProdIdToAsset.get(p.id) != null){ Asset[] tempassetlist = ProdIdToAsset.get(p.id);    System.debug('tempassetlist : ' + tempassetlist);
                            fw.bookedTime = ProdIdToAsset.get(p.id);
                            System.debug('bookedTime : ' + fw.bookedTime);openTime[] optiList = new list<openTime>();
                            for(Asset a : tempassetlist){
                                openTime ot = new openTime();
                                openTime ot1 = new openTime();
                                if(a.InstallDate <= mc.Date_Field_1__c && a.UsageEndDate <= mc.Date_Field_2__c){
                                    ot.startDate = a.UsageEndDate.adddays(1).format();
                                    ot.endDate = mc.Date_Field_2__c.format();
                                }
                                else if(a.InstallDate > mc.Date_Field_1__c){
                                    ot.startDate = mc.Date_Field_1__c.format();
                                    ot.endDate = a.InstallDate.adddays(-1).format();
                                    if(a.UsageEndDate < mc.Date_Field_2__c){
                                        ot1.startDate = a.UsageEndDate.adddays(1).format();
                                        ot1.endDate = mc.Date_Field_2__c.format();
                                    }
                                }
                                else{
                                    ot.startDate = 'None';
                                    ot.endDate = 'None';
                                }
                                optiList.add(ot);
                                if(ot1.startDate != null && ot1.startDate != ''){
                                    optiList.add(ot1);
                                }
                            }
                            fw.otlist = optiList;
                        }
                         if(mw.faces == null){
                        mw.faces = new list<faceWrap>();
                    }
                        if(ProdIdToQuoteLineItem != null && ProdIdToQuoteLineItem.get(p.id) != null){
                            fw.quliitList = ProdIdToQuoteLineItem.get(p.id);
                        }
                  // else
                    mw.faces.add(fw);
                    System.debug(mw.faces);
                }
            }
            else{
                return null;
            }
        return mw;
    }


    public void updateSearch(){
        if(qut.Start_Date_for_Map_Page__c != null){
            startDateString = qut.Start_Date_for_Map_Page__c.format();
            // startDateString = mc.Date_Field_1__c.format();
        }
        if(qut.Start_Date_for_Map_Page__c != null){
            endDateString = qut.Start_Date_for_Map_Page__c.format();
            // endDateString = mc.Date_Field_2__c.format();
        }
        //Normal kiosks 
            MWlist = new list<markWrap>();
            
            
            // Already booked QLi for this time Rakshana from Cube84 did code this for overbooked issue.
            try{
             list<QuoteLineItem> alreadyBooked_QLI = new list<QuoteLineItem>();
           
            SET<ID> alreadyBooked_Products = new SET<ID>();
            alreadyBooked_QLI =[select id,product2.ID,product2.Family,Product2.description from QuoteLineItem where End_Date__c >= :qut.Start_Date_for_Map_Page__c];
            // Only for static faces
            for(QuoteLineItem Q : alreadyBooked_QLI){
               // if(Q.product2.description!=null){
               // if(Q.product2.description.contains('Static'))
                alreadyBooked_Products.add(Q.product2ID);
               // }else
                // if(Q.product2.family!=null){
                   // if(Q.product2.family.contains('Static'))
               // alreadyBooked_Products.add(Q.product2ID);
                  
                
            }
            system.debug('alreadyBooked_Products in other quotes '+alreadyBooked_Products);
           
            //set<id> acctIdSet = new set<id>();
            Map<String, Schema.SObjectType> SobjectSchemaMap = Schema.getGlobalDescribe();
            Schema.DescribeSObjectResult SobjectResult = SobjectSchemaMap.get('Kiosk__c').getDescribe();
            Map<String, Schema.SObjectField> SobjtField = SobjectResult.fields.getMap();
            string qry = '';
            for (Schema.SObjectField s : SobjtField.values()) {
                qry += s + ',';
            }
            system.debug(regnPicked);
            qry = qry.removeend(',');
            string sts = 'Under Construction';
            qry = 'select '+qry+' from '+ 'Kiosk__c where Network_Region__c = :regnPicked AND Longitude__c != null AND Latitude__c != null  AND Status__c != :sts';
            list<Kiosk__c> kList = database.query(qry);
            map<id,Kiosk__c> kioskMap = new map<id,Kiosk__c>();
            system.debug('kList '+kList);for(Kiosk__c k : kList){
                kioskMap.put(k.id,k);
                //acctIdSet.add(k.Account__c);
            }
              system.debug('kioskMap  '+kioskMap);
            ProdIdToAsset = new map<id,list<Asset>>();
            List<Asset> aList = [select Start_Date_Text__c,End_Date_Text__c,AccountId,Product2Id,UsageEndDate,InstallDate from Asset where Region__c = :regnPicked AND ((InstallDate >= :mc.Date_Field_1__c AND InstallDate <= :mc.Date_Field_2__c) OR (UsageEndDate >= :mc.Date_Field_1__c AND UsageEndDate <= :mc.Date_Field_2__c))];
          System.debug(aList);
            for(Asset a : aList){
                if(ProdIdToAsset.get(a.Product2Id) == null){
                    list<Asset> tempAlist = new list<Asset>();
                    tempAlist.add(a);
                    ProdIdToAsset.put(a.Product2Id,tempAlist);
                }
                else{
                    list<Asset> tempAlist = new list<Asset>();
                    tempAlist = ProdIdToAsset.get(a.Product2Id);
                    tempAlist.add(a);
                    ProdIdToAsset.put(a.Product2Id,tempAlist);
                }
            }
            system.debug(logginglevel.info, '*****ProdIdToQuoteLineItem='+ProdIdToQuoteLineItem);
            List<Product2> faceList = [select name,Kiosk__c from Product2 where Kiosk__c in :kioskMap.keyset()   AND id NOT IN (select Product2Id from Asset where Region__c = :regnPicked AND (InstallDate <= :mc.Date_Field_1__c AND UsageEndDate >= :mc.Date_Field_2__c)) and ID NOT  IN :alreadyBooked_Products];
            set<id> prodIdSet = new set<id>();
            kioskId_to_Product = new map<Id,List<Product2>>();
            for(Product2 p : faceList){ prodIdSet.add(p.id); if(kioskId_to_Product.get(p.Kiosk__c) == null){list<Product2> tempList = new list<Product2>();
                    tempList.add(p);
                    kioskId_to_Product.put(p.Kiosk__c,tempList);
                }
                else{
                    list<Product2> tempList = kioskId_to_Product.get(p.Kiosk__c);
                    tempList.add(p);
                    kioskId_to_Product.put(p.Kiosk__c,tempList);
                }
            }
            
            System.debug('prodIdSet : ' + prodIdSet);
            
            ProdIdToQuoteLineItem = new map<id,list<QuoteLineItem>>();
          
            List<QuoteLineItem> qliList = [select Start_Date_Text__c,End_Date_Text__c,Product2Id,Quote.Status,Quote.Id,Quote.Name,Quote.OpportunityId,Quote.Opportunity.Name,Quote.Opportunity.Owner.Name,End_Date__c,Start_Date__c from QuoteLineItem where Product2Id in :prodIdSet AND ((Start_Date__c >= :mc.Date_Field_1__c AND Start_Date__c <= :mc.Date_Field_2__c) OR (End_Date__c >= :mc.Date_Field_1__c AND End_Date__c <= :mc.Date_Field_2__c))];
           
            for(QuoteLineItem qli : qliList){if(ProdIdToQuoteLineItem.get(qli.Product2Id) != null){  list<QuoteLineItem> tempQliList = new list<QuoteLineItem>();
                    tempQliList = ProdIdToQuoteLineItem.get(qli.Product2Id);
                    tempQliList.add(qli);
                    ProdIdToQuoteLineItem.put(qli.Product2Id,tempQliList);
                }
                else{list<QuoteLineItem> tempQliList = new list<QuoteLineItem>(); tempQliList.add(qli); ProdIdToQuoteLineItem.put(qli.Product2Id,tempQliList);
                }
            }
            integer i = 0;
            system.debug(logginglevel.info, '*****ProdIdToAsset2121='+ProdIdToAsset);
            for(Kiosk__c k : kList){ system.debug(K.Name);  markWrap mw = createMarkWrap(k,i); if(mw != null){
                    MWlist.add(mw);
                }
                i++;
            }
            system.debug(logginglevel.info, '*****ProdIdToAsset='+ProdIdToAsset);
            system.debug(logginglevel.info, '*****MWlist='+MWlist);
            system.debug(logginglevel.info, '*****MWlist.size()='+MWlist.size());
        	//under construction items.
            if(underConstruction != null && underConstruction == true){
                underConstructionList = new list<markWrap>();
                //set<id> acctIdSet1 = new set<id>();
                qry = '';
                for (Schema.SObjectField s : SobjtField.values()) {
                    qry += s + ',';
                }
                qry = qry.removeend(',');
                sts = 'Under Construction';
                qry = 'select '+qry+' from '+ 'Kiosk__c' + ' where Network_Region__c = :regnPicked AND Longitude__c != null AND Latitude__c != null AND Status__c = :sts';
                kList = database.query(qry);
                kioskMap = new map<id,Kiosk__c>();
                for(Kiosk__c k : kList){
                    kioskMap.put(k.id,k);
                    //acctIdSet1.add(k.Account__c);
                }
                ProdIdToAsset = new map<id,list<Asset>>();
                aList = [select Start_Date_Text__c,End_Date_Text__c,AccountId,Product2Id,UsageEndDate,InstallDate from Asset where Region__c = :regnPicked AND ((InstallDate >= :mc.Date_Field_1__c AND InstallDate <= :mc.Date_Field_2__c) OR (UsageEndDate >= :mc.Date_Field_1__c AND UsageEndDate <= :mc.Date_Field_2__c))];
                for(Asset a : aList){
                    if(ProdIdToAsset.get(a.Product2Id) == null){
                        list<Asset> tempAlist = new list<Asset>();
                        tempAlist.add(a);
                        ProdIdToAsset.put(a.Product2Id,tempAlist);
                    }
                    else{
                        list<Asset> tempAlist = new list<Asset>();
                        tempAlist = ProdIdToAsset.get(a.Product2Id);
                        tempAlist.add(a);
                        ProdIdToAsset.put(a.Product2Id,tempAlist);
                    }
                }
                ProdIdToQuoteLineItem = new map<id,list<QuoteLineItem>>();
                faceList = [select name,Kiosk__c from Product2 where Kiosk__c in :kioskMap.keyset() AND id NOT IN (select Product2Id from Asset where Region__c = :regnPicked AND (InstallDate <= :mc.Date_Field_1__c AND UsageEndDate >= :mc.Date_Field_2__c))];
                kioskId_to_Product = new map<Id,List<Product2>>();
                prodIdSet = new set<id>();
                for(Product2 p : faceList){
                    prodIdSet.add(p.id);
                    if(kioskId_to_Product.get(p.Kiosk__c) == null){
                        list<Product2> tempList = new list<Product2>();
                        tempList.add(p);
                        kioskId_to_Product.put(p.Kiosk__c,tempList);
                    }
                    else{ list<Product2> tempList = kioskId_to_Product.get(p.Kiosk__c); tempList.add(p);  kioskId_to_Product.put(p.Kiosk__c,tempList);
                    }
                }
                
                
                qliList = [select Start_Date_Text__c,End_Date_Text__c,Product2Id,Quote.Status,End_Date__c,Start_Date__c,Quote.Name,Quote.OpportunityId,Quote.Opportunity.Name,Quote.Opportunity.Owner.Name 
                           from QuoteLineItem 
                           where Product2Id in :prodIdSet 
                           AND ((Start_Date__c >= :mc.Date_Field_1__c AND Start_Date__c <= :mc.Date_Field_2__c) OR (End_Date__c >= :mc.Date_Field_1__c AND End_Date__c <= :mc.Date_Field_2__c))];
                
                
                for(QuoteLineItem qli : qliList){
                    
                    if(ProdIdToQuoteLineItem.get(qli.Product2Id) != null){ list<QuoteLineItem> tempQliList = new list<QuoteLineItem>(); tempQliList = ProdIdToQuoteLineItem.get(qli.Product2Id);
                        tempQliList.add(qli);
                        ProdIdToQuoteLineItem.put(qli.Product2Id,tempQliList);
                    }
                    else{
                        list<QuoteLineItem> tempQliList = new list<QuoteLineItem>();
                        tempQliList.add(qli);
                        ProdIdToQuoteLineItem.put(qli.Product2Id,tempQliList); }}
              
                System.debug('333 klist : ' + klist);
                for(Kiosk__c k : kList){ markWrap mw = createMarkWrap(k,i);if(mw != null){ underConstructionList.add(mw);
                    }
                    i++;
                }
                system.debug(logginglevel.info, '*****underConstructionList='+underConstructionList);
                system.debug(logginglevel.info, '*****underConstructionList.size()='+underConstructionList.size());
            }
            else{
                underConstructionList = new list<markWrap>();
            }
        //already booked items.
            if(alreadyBooked != null && alreadyBooked == true){
                alreadyBookedList = new list<markWrap>();
                //set<id> acctIdSet1 = new set<id>();
                qry = '';
                for (Schema.SObjectField s : SobjtField.values()) {
                    qry += s + ',';}
                //}
                qry = qry.removeend(',');
                sts = 'Under Construction';
                qry = 'select '+qry+' from '+ 'Kiosk__c' + ' where Network_Region__c = :regnPicked AND Longitude__c != null AND Latitude__c != null';
                kList = database.query(qry);
                kioskMap = new map<id,Kiosk__c>();
                for(Kiosk__c k : kList){
                    kioskMap.put(k.id,k);
                    //acctIdSet1.add(k.Account__c);
                }
                
                ProdIdToAsset = new map<id,list<Asset>>();
                aList = [select Start_Date_Text__c,End_Date_Text__c,AccountId,Product2Id,UsageEndDate,InstallDate from Asset where Region__c = :regnPicked AND ((InstallDate >= :mc.Date_Field_1__c AND InstallDate <= :mc.Date_Field_2__c) OR (UsageEndDate >= :mc.Date_Field_1__c AND UsageEndDate <= :mc.Date_Field_2__c))];
                system.debug(logginglevel.info, '*****aList='+aList);
                for(Asset a : aList){
                    if(ProdIdToAsset.get(a.Product2Id) == null){
                        list<Asset> tempAlist = new list<Asset>();
                        tempAlist.add(a);
                        ProdIdToAsset.put(a.Product2Id,tempAlist);
                    }
                    else{
                        list<Asset> tempAlist = new list<Asset>();
                        tempAlist = ProdIdToAsset.get(a.Product2Id);
                        tempAlist.add(a);
                        ProdIdToAsset.put(a.Product2Id,tempAlist);
                    }
                }
                ProdIdToQuoteLineItem = new map<id,list<QuoteLineItem>>();
                faceList = [select name,Kiosk__c from Product2 where Kiosk__c in :kioskMap.keyset() AND id IN (select Product2Id from Asset where Region__c = :regnPicked AND (InstallDate <= :mc.Date_Field_1__c AND UsageEndDate >= :mc.Date_Field_2__c)) and ID NOT  IN :alreadyBooked_Products];
                
                kioskId_to_Product = new map<Id,List<Product2>>();
                prodIdSet = new set<id>();
                for(Product2 p : faceList){
                    prodIdSet.add(p.id);if(kioskId_to_Product.get(p.Kiosk__c) == null){ list<Product2> tempList = new list<Product2>();tempList.add(p);
                        kioskId_to_Product.put(p.Kiosk__c,tempList);} else{
                    
                   
                        list<Product2> tempList = kioskId_to_Product.get(p.Kiosk__c);
                        tempList.add(p);
                        kioskId_to_Product.put(p.Kiosk__c,tempList);}}
                qliList = [select Quote.OpportunityId,Quote.Opportunity.Name,Quote.Opportunity.Owner.Name,Quote.Name,Start_Date_Text__c,End_Date_Text__c,Product2Id,Quote.Status,End_Date__c,Start_Date__c from QuoteLineItem where Product2Id in :prodIdSet AND ((Start_Date__c >= :mc.Date_Field_1__c AND Start_Date__c <= :mc.Date_Field_2__c) OR (End_Date__c >= :mc.Date_Field_1__c AND End_Date__c <= :mc.Date_Field_2__c))];
                for(QuoteLineItem qli : qliList){
                    if(ProdIdToQuoteLineItem.get(qli.Product2Id) != null){  list<QuoteLineItem> tempQliList = new list<QuoteLineItem>();
                        tempQliList = ProdIdToQuoteLineItem.get(qli.Product2Id);tempQliList.add(qli); ProdIdToQuoteLineItem.put(qli.Product2Id,tempQliList);
                    }
                    else{
                        list<QuoteLineItem> tempQliList = new list<QuoteLineItem>();
                        tempQliList.add(qli);
                        ProdIdToQuoteLineItem.put(qli.Product2Id,tempQliList);}}
                  
                system.debug(logginglevel.info, '*****ProdIdToAsset333='+ProdIdToAsset);
                for(Kiosk__c k : kList){
                    markWrap mw = createMarkWrap(k,i);
                    if(mw != null){
                        alreadyBookedList.add(mw);
                    }
                    i++;
                }
                system.debug(logginglevel.info, '*****alreadyBookedList='+alreadyBookedList);
                system.debug(logginglevel.info, '*****alreadyBookedList.size()='+alreadyBookedList.size());
            }
            else{
                alreadyBookedList = new list<markWrap>();
            }
            }catch(exception e){System.debug('Error in Update search '+e);}
    }


    @remoteAction
    public static String addProducts(list<string> includedProdIds, string theQuoteId, string sd, string ed){
        system.debug(logginglevel.info, '*****includedProdIds='+includedProdIds);
        system.debug(logginglevel.info, '*****theQuoteId='+theQuoteId);
        system.debug(logginglevel.info, '*****sd='+sd);
        system.debug(logginglevel.info, '*****ed='+ed);
        set<Id> selectedIdSet = new set<Id>();
        for(string s : includedProdIds){
            selectedIdSet.add(s);
        }
        Quote tempQuote = [select name,Pricebook2Id from Quote where id = :theQuoteId];
        system.debug(logginglevel.info, '*****tempQuote='+tempQuote);
        List<QuoteLineItem> existingQlis = [select Product2Id from QuoteLineItem where QuoteId = :tempQuote.id];
        system.debug(logginglevel.info, '*****selectedIdSet='+selectedIdSet);
        system.debug(logginglevel.info, '*****existingQlis='+existingQlis);
        for(QuoteLineItem qli : existingQlis){
            if(selectedIdSet.contains(qli.Product2Id)){
                selectedIdSet.remove(qli.Product2Id);
            }
        }
        if(selectedIdSet.size() > 0){
            
            date stdate =ParseDateFromString(sd);
            date enDate = ParseDateFromString(ed);
            
            //date stdate = date.parse(sd);
            //date enDate = date.parse(ed);
            map<id,list<Asset>> ProdIdToAsset = new map<id,list<Asset>>();
            List<Asset> aList = [select Start_Date_Text__c,End_Date_Text__c,AccountId,Product2Id,UsageEndDate,InstallDate from Asset where Product2Id in :selectedIdSet AND ((InstallDate >= :stdate AND InstallDate <= :enDate) OR (UsageEndDate >= :stdate AND UsageEndDate <= :enDate))];
            System.debug('aList addProducts : ' + [select Start_Date_Text__c,End_Date_Text__c,AccountId,Product2Id,UsageEndDate,InstallDate from Asset]);
            for(Asset a : aList){
                if(ProdIdToAsset.get(a.Product2Id) == null){
                    list<Asset> tempAlist = new list<Asset>();
                    tempAlist.add(a);
                    ProdIdToAsset.put(a.Product2Id,tempAlist);
                }
                else{
                    list<Asset> tempAlist = new list<Asset>();
                    tempAlist = ProdIdToAsset.get(a.Product2Id);
                    tempAlist.add(a);
                    ProdIdToAsset.put(a.Product2Id,tempAlist);
                }
            }
            system.debug(logginglevel.info, '*****ProdIdToAsset='+ProdIdToAsset);
            system.debug(logginglevel.error, '*****tempQuote.Pricebook2Id='+tempQuote.Pricebook2Id);

            List<PricebookEntry> pbeList = [select UnitPrice,Product2Id,Pricebook2Id from PricebookEntry where Pricebook2Id = :tempQuote.Pricebook2Id AND Product2Id in :selectedIdSet];
            system.debug(logginglevel.info, '*****pbeList='+pbeList);
            if(pbeList.size() == 0){
                return 'Your Ad Faces are not listed in the PriceBook.';
            }
            list<QuoteLineItem> newQliList = new list<QuoteLineItem>();
            for(PricebookEntry pbe : pbeList){
                if(ProdIdToAsset.get(pbe.Product2Id) == null){
                    date startd = stdate;                       //-- Updated By GSD
                    //date startd =ParseDateFromString(sd);
                    //date startd = date.valueOf(sd);
                    //date endd = date.valueOf(ed);
                    date endd = enDate;
                    //date endd = ParseDateFromString(ed);
                    decimal dec1 = startd.daysbetween(endd);
                    system.debug(logginglevel.info, '*****dec1='+dec1);
                    decimal dec2 = dec1 / 30;
                    system.debug(logginglevel.info, '*****dec2='+dec2);
                    decimal dec3 = dec2.setScale(0, RoundingMode.DOWN);
                    system.debug(logginglevel.info, '*****dec3='+dec3);
                    decimal dec4 = dec2-dec3;
                    system.debug(logginglevel.info, '*****dec4='+dec4);
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.QuoteId = tempQuote.id;
                    qli.PriceBookEntryId = pbe.id;
                    if(dec4 > 0){
                        if(dec4 > .25){
                            if(dec4 > .50){
                                if(dec4 > .75){
                                    qli.Quantity = dec3 + 1;
                                }
                                else{
                                    qli.Quantity = dec3 + 0.75;
                                }
                            }
                            else{
                                qli.Quantity = dec3 + 0.5;
                            }
                        }
                        else{
                            qli.Quantity = dec3 + 0.25;
                        }
                    }
                    else{
                        qli.Quantity = dec3;
                    }
                    qli.UnitPrice = pbe.UnitPrice;
                    qli.Start_Date__c = startd;
                    qli.End_Date__c = endd;
                    newQliList.add(qli);
                }
                else{
                    date startd = stdate;   //-- Updated By GSD
                    date endd = enDate;     //-- Updated By GSD
                    //date startd = date.parse(sd);
                    //date endd = date.parse(ed);
                    Asset[] tempassetlist = ProdIdToAsset.get(pbe.Product2Id);
                    system.debug(logginglevel.info, '*****tempassetlist='+tempassetlist);
                    for(Asset a : tempassetlist){
                        System.debug('a.InstallDate : ' + a.InstallDate + ', startd : ' + startd);
                        System.debug('a.UsageEndDate : ' + a.UsageEndDate + ', endd : ' + endd);
                        if(a.InstallDate <= startd && a.UsageEndDate <= endd){
                            decimal d1 = a.UsageEndDate.daysbetween(endd);
                            decimal dec2 = d1 / 30;
                            decimal dec3 = dec2.setScale(0, RoundingMode.DOWN);
                            decimal dec4 = dec2-dec3;
                            QuoteLineItem qli = new QuoteLineItem();
                            qli.QuoteId = tempQuote.id;
                            qli.PriceBookEntryId = pbe.id;
                            if(dec4 > 0){
                                if(dec4 > .25){
                                    if(dec4 > .50){
                                        if(dec4 > .75){
                                            qli.Quantity = dec3 + 1;
                                        }
                                        else{
                                            qli.Quantity = dec3 + 0.75;
                                        }
                                    }
                                    else{
                                        qli.Quantity = dec3 + 0.5;
                                    }
                                }
                                else{
                                    qli.Quantity = dec3 + 0.25;
                                }
                            }
                            else{
                                qli.Quantity = dec3;
                            }
                            qli.UnitPrice = pbe.UnitPrice;
                            qli.Start_Date__c = a.UsageEndDate.adddays(1);
                            qli.End_Date__c = endd;
                            newQliList.add(qli);
                        }
                        else if(a.InstallDate > startd){
                            decimal d1 = startd.daysbetween( a.InstallDate.adddays(-1));
                            decimal dec2 = d1 / 30;
                            decimal dec3 = dec2.setScale(0, RoundingMode.DOWN);
                            decimal dec4 = dec2-dec3;
                            QuoteLineItem qli = new QuoteLineItem();
                            qli.QuoteId = tempQuote.id;
                            qli.PriceBookEntryId = pbe.id;
                            if(dec4 > 0){
                                if(dec4 > .25){
                                    if(dec4 > .50){
                                        if(dec4 > .75){
                                            qli.Quantity = dec3 + 1;
                                        }
                                        else{
                                            qli.Quantity = dec3 + 0.75;
                                        }
                                    }
                                    else{
                                        qli.Quantity = dec3 + 0.5;
                                    }
                                }
                                else{
                                    qli.Quantity = dec3 + 0.25;
                                }
                            }
                            else{
                                qli.Quantity = dec3;
                            }
                            qli.UnitPrice = pbe.UnitPrice;
                            qli.Start_Date__c = startd;
                            qli.End_Date__c =  a.InstallDate.adddays(-1);
                            newQliList.add(qli);
                            if(a.UsageEndDate < endd){
                                decimal d4 = startd.daysbetween( a.InstallDate.adddays(-1));
                                decimal dec5 = d4 / 30;
                                decimal dec6 = dec5.setScale(0, RoundingMode.DOWN);
                                decimal dec7 = dec5-dec3;
                                QuoteLineItem qli1 = new QuoteLineItem();
                                qli1.QuoteId = tempQuote.id;
                                qli1.PriceBookEntryId = pbe.id;
                                if(dec7 > 0){
                                    if(dec7 > .25){
                                        if(dec7 > .50){
                                            if(dec7 > .75){
                                                qli1.Quantity = dec6 + 1;
                                            }
                                            else{
                                                qli1.Quantity = dec6 + 0.75;
                                            }
                                        }
                                        else{
                                            qli1.Quantity = dec6 + 0.5;
                                        }
                                    }
                                    else{
                                        qli1.Quantity = dec6 + 0.25;
                                    }
                                }
                                else{
                                    qli1.Quantity = dec6;
                                }
                                qli1.UnitPrice = pbe.UnitPrice;
                                qli1.Start_Date__c = a.UsageEndDate.adddays(1);
                                qli1.End_Date__c =  endd;
                                newQliList.add(qli1);
                            }
                        }
                    }
                }

            }
            Try{
                system.debug(logginglevel.info, '*****newQliList='+newQliList);
                insert newQliList;
                return 'Your Ad Faces have been successfully added to the Quote.';
            }
            Catch(exception e){
                system.debug(logginglevel.info, '*****addProducts error = '+e);
                return e.getdmlMessage(0);
            }
        }
        return 'There were no faces selected.';
    }

    public static Date ParseDateFromString(String dateString){
        Integer month = FindMonthFromText(dateString.mid(4,3));
        system.debug(logginglevel.error, '*****month='+month);
        Integer day = Integer.valueOf(dateString.mid(8,2));
        system.debug(logginglevel.error, '*****day='+day);
        Integer year = Integer.valueOf(dateString.right(4));
        system.debug(logginglevel.error, '*****year='+year);
        return date.newinstance(year, month, day);

    }

    public static Integer FindMonthFromText(String monthString){
        if(monthString == 'Jan'){
            return 1;
        } else if(monthString == 'Feb'){
            return 2;
        } else if(monthString == 'Mar'){
            return 3;
        } else if(monthString == 'Apr'){
            return 4;
        } else if(monthString == 'May'){
            return 5;
        } else if(monthString == 'Jun'){
            return 6;
        } else if(monthString == 'Jul'){
            return 7;
        } else if(monthString == 'Aug'){
            return 8;
        } else if(monthString == 'Sep'){
            return 9;
        } else if(monthString == 'Oct'){
            return 10;
        } else if(monthString == 'Nov'){
            return 11;
        } else {
            return 12;
        }
    }

    public PageReference returnToQuote(){
        Pagereference MyPage = new Pagereference('/'+qut.id);
        MyPage.setRedirect(true);
        return MyPage;
    }



}