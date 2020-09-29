public with sharing class Adv_CampaignItemTrigger /*extends TriggerController*/
{

    public void sample(){
        system.debug('testing');
    }    
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /**
     * Constructor.
     * @see TriggerController   The base class of trigger controller.
     */
    
    /*
    public Adv_CampaignItemTrigger(Boolean isAfter, Boolean isBefore,
            Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
            List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }
   
    public static String serviceProductName  = 'P&I Costs';
*/
    
    /**
     * Override method to perform action after an insert operation was fired.
     * @see TriggerController#runAfterInsert
     */
    /*
    protected override void runAfterInsert() {
        if (!(system.isBatch() || system.isFuture())) {
            addInstallationItem((Map<Id, ADvendio__Campaign_Item__c>) mapNewItems);
        }
    }

    private void addInstallationItem(Map<Id, ADvendio__Campaign_Item__c> campaignItemMap) {
        startInstallationCostCreation(campaignItemMap.keySet());
    }

    @future
    private static void startInstallationCostCreation (Set<Id> campaignItemIds) {
        List<ADvendio__Campaign_Item__c> campaignItemsEnhanced = getEnhancedCampaignItemData(campaignItemIds);
        List<ADvendio__Campaign_Item__c> campaignItemsToInsert  = new List<ADvendio__Campaign_Item__c>();
        Map<Id, Id> adSpecsByCampaignItemId    = new Map<Id, Id>();
        for (ADvendio__Campaign_Item__c campaignItem : campaignItemsEnhanced) {
            if (isStaticProduct(campaignItem)) {
                adSpecsByCampaignItemId.put(campaignItem.Id, campaignItem.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__c);
            }
        }

        Map<Id, ADvendio__Ad_Price__c> piAdPricesByAdspecId    = getInstallationAdPrice(adSpecsByCampaignItemId.values());

        for (ADvendio__Campaign_Item__c campaignItem : campaignItemsEnhanced) {
            if (isStaticProduct(campaignItem)) {
                if (piAdPricesByAdspecId.containsKey(campaignItem.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__c)) {
                    campaignItemsToInsert.add(createInstallationItem(campaignItem, piAdPricesByAdspecId.get(campaignItem.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__c)));
                }
                else {
                    campaignItemsToInsert.add(createInstallationItem(campaignItem, piAdPricesByAdspecId.get('a0X000000000000XXX')));
                }
            }
        }

        insert campaignItemsToInsert;
    }

    private static List<ADvendio__Campaign_Item__c> getEnhancedCampaignItemData(Set<Id> campaignItemIds) {
        return new List<ADvendio__Campaign_Item__c>([SELECT Id, ADvendio__from_Date__c, ADvendio__Media_Campaign__c, Name, ADvendio__Ad_Price__r.ADvendio__Ad_Spec__c, ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.Is_digital__c
                                                        FROM ADvendio__Campaign_Item__c
                                                        WHERE Id IN :campaignItemIds]);
    }

    private static Map<Id, ADvendio__Ad_Price__c> getInstallationAdPrice(List<Id> adSpecsIds) {
        Map<Id, ADvendio__Ad_Price__c> adPricesByAdspecId  = new Map<Id, ADvendio__Ad_Price__c>();
        for (ADvendio__Ad_Price__c adPrice : [SELECT Id, ADvendio__Ad_Spec__c, ADvendio__Ad_Spec__r.Name, ADvendio__Billing_Category__c, CurrencyIsoCode, ADvendio__List_Price__c, ADvendio__Pricelist__c
                                                FROM ADvendio__Ad_Price__c WHERE (ADvendio__Ad_Spec__r.Name= :serviceProductName OR (ADvendio__Ad_Spec__c IN :adSpecsIds AND ADvendio__Billing_Category__c = 'Fixed Price')) AND ADvendio__Pricelist__r.Name = 'Volta Media Standard']) {
            if (adPrice.ADvendio__Ad_Spec__r.Name == serviceProductName) { // handle P+I fallback price
                adPricesByAdspecId.put('a0X000000000000XXX', adPrice);
            }
            else {
                adPricesByAdspecId.put(adPrice.ADvendio__Ad_Spec__c, adPrice);
            }
        }

        return adPricesByAdspecId;
    }


    private static Boolean isStaticProduct(ADvendio__Campaign_Item__c campaignItem) {
        Boolean isStaticProduct = false;
        try {
            isStaticProduct = 'No'.equals(campaignItem.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.Is_digital__c);

        }
        catch (Exception e) {
            isStaticProduct = false;
        }
        return isStaticProduct;
    }

    private static ADvendio__Campaign_Item__c createInstallationItem(ADvendio__Campaign_Item__c campaignItem, ADvendio__Ad_Price__c installationAdPrice) {
        ADvendio__Campaign_Item__c installationCampaignItem = new ADvendio__Campaign_Item__c();
        installationCampaignItem.ADvendio__Media_Campaign__c    = campaignItem.ADvendio__Media_Campaign__c;
        installationCampaignItem.ADvendio__Ad_Price__c          = installationAdPrice.Id;
        installationCampaignItem.ADvendio__Quantity__c          = 1;
        installationCampaignItem.ADvendio__Sales_Price__c       = installationAdPrice.ADvendio__List_Price__c;
        installationCampaignItem.ADvendio__from_Date__c         = campaignItem.ADvendio__from_Date__c;
        installationCampaignItem.ADvendio__until_Date__c        = campaignItem.ADvendio__from_Date__c;
        installationCampaignItem.ADvendio__Billing_Category__c  = installationAdPrice.ADvendio__Billing_Category__c;
        installationCampaignItem.CurrencyIsoCode                = installationAdPrice.CurrencyIsoCode;
        installationCampaignItem.Name                           = campaignItem.Name.subString(0, Math.min(campaignItem.Name.length(), 68)) + ' - ' + serviceProductName;

        return installationCampaignItem;
    }
*/
}