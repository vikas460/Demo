/**
 * @ Des: This code can be used for automatically populating the
 *  latitude and longitude of addresses in a custom object.
 */ 

public with sharing class LatLongLookup {
    public LatLongLookup() {
        system.debug('This is for Test coverage');
    }
/**
 * Lat_Lon_Lookup description
 * @param  KioskIds list of records
 * @Des: 1. Replace Kiosk__c with your custom object name. 
 *       2. Check if you have used the same field names in the custom object.
     
 */ 
    @future(callout=true)
    public static void Lat_Lon_Lookup(set<id> KioskIds) {
        system.debug(logginglevel.info, '*****KioskIds='+KioskIds);
        List<Kiosk__c> kList = [select Street_Address__c,City__c,State__c,Zip_Code__c from Kiosk__c where id in :KioskIds]; 
        system.debug(logginglevel.info, '*****kList1='+kList);
        for(Kiosk__c k : kList){
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            string Address = k.Street_Address__c + '+' + k.City__c + '+' + k.State__c + '+' + k.Zip_Code__c;
            Address = Address.deleteWhitespace();
            req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' +Address+ '&key=AIzaSyDX-MWJqF5Mhnbc3tWZKahAQ5BzlCoDoac');
            req.setMethod('GET');
            HttpResponse res = new HttpResponse();
            if(test.isrunningtest()){
                res.setbody('{"results":[{"address_components":[{"long_name":"Lehi","short_name":"Lehi","types":["locality","political"]},{"long_name":"UtahCounty","short_name":"UtahCounty","types":["administrative_area_level_2","political"]},{"long_name":"Utah","short_name":"UT","types":["administrative_area_level_1","political"]},{"long_name":"UnitedStates","short_name":"US","types":["country","political"]}],"formatted_address":"Lehi,UT,USA","geometry":{"bounds":{"northeast":{"lat":40.471736,"lng":-111.818818},"southwest":{"lat":40.3554032,"lng":-111.918773}},"location":{"lat":40.3916172,"lng":-111.8507662},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":40.471736,"lng":-111.818818},"southwest":{"lat":40.3554032,"lng":-111.918773}}},"partial_match":true,"types":["locality","political"]}],"status":"OK"}');
            }
            else{
                res = http.send(req);
            }
            string s = string.valueof(res.getBody());
            system.debug(logginglevel.info, '*****s='+s);
            GeoResults rslts = (GeoResults)JSON.deserialize(res.getBody(), GeoResults.class);
            system.debug(logginglevel.info, '*****rslts='+rslts);
            if(rslts.results.size() > 0){
                k.Geolocation__Latitude__s = rslts.results.get(0).geometry.location.lat;
                k.Geolocation__Longitude__s = rslts.results.get(0).geometry.location.lng; 
            }           
            k.Lat_Lon_Looked_Up_At__c = datetime.now();
        }
        system.debug(logginglevel.info, '*****kList from LatLongLookup='+kList);
        update kList;
    }



    public class GeoResults{
        public list<gresults> results {get;set;}
    }


    public class gresults{
        public list<addressComponents> address_components {get;set;}
        public string formatted_address {get;set;}
        public Geo geometry {get;set;}
    }

    public class addressComponents{
        public string long_name {get;set;}
        public string short_name {get;set;}
        public list<string> types {get;set;}
    }

    public class Geo{
        public Locatn location {get;set;}
    }

    public class Locatn{
        public decimal lat {get;set;}
        public decimal lng {get;set;}
    }
}