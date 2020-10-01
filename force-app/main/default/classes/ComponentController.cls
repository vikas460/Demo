public class ComponentController {

    public List<sObject> idList{get;set;}
    Public List<String> SobjFieldList{get;set;}
      
      Public ApexPages.StandardSetController setRecords{
        get{
         if(setRecords == null){
            setRecords = new ApexPages.StandardSetController(getIdListRecrds());
            setRecords.setPageSize(4);
         }  
          return setRecords;
        }set;
       }
        
       Public List<sObject> getSObjectRecs(){
            List<sObject> sObjList = New List<sObject>();
            for(sObject SObj :(List<sObject>)setRecords.getRecords())
                sObjList.add(SObj); 
            return  sObjList ;   
       }
       
       Public List<String> FieldList{
           get{
           List<String> FieldList = New List<string>();
           FieldList = getSobjtFieldList();
           return FieldList;
           }set;
       }
       
        public List<sObject> getIdListRecrds() {
           List<sObject> IdListRecrds =idList;
           return IdListRecrds;
        }
        
        public List<string> getSobjtFieldList() {
           List<String> FieldList = SobjFieldList;
           return FieldList ;
        }
    
    }