/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  11.10.2012      Smitha         MOJO        Initial Creation.Create Opty from Asset List view.
+========================================================================================================================*/

public class SFA_MOJO_CreateOpptyController {
    
    public List<Asset__c> lstSelectedAssets = new List<Asset__c>();
    public List<Opportunity_Asset_Junction__c> lstJnObj = new List<Opportunity_Asset_Junction__c>();          
    public Set<Id> lstCreateOpty = new Set<Id>();    
    public Set<Id> setAssetIds = new Set<Id>();   
    public String accName,accId,accLkid, idListView,CustomUrl,Status ='Closed',ForecastCategoryName = 'Pipeline';    
    public datetime closeDate = datetime.now() + 120;      
    public Integer intActiveOpty {get;set;} {intActiveOpty = 0 ;}   
    public Integer intDiffAccount {get;set;} {intDiffAccount = 0;}
    public Integer intErrored {get;set;} {intErrored = 0;}
    public Integer intNoRec {get;set;} {intNoRec = 0;}    
    public String idRecordType,strCloseDate,encodedCloseDate,encodedAccName,strAssetIds,encodedAssetIds,encodedaccLkid,dataMapRetUrl,dataValueMap,encodeddataValueMap;    
 

    public SFA_MOJO_CreateOpptyController(ApexPages.StandardSetController controller) {
        Integer assetCount=0;
        lstSelectedAssets = controller.getSelected();               
      
        for (Asset__c selctdassets : lstSelectedAssets) 
        {
            setAssetIds.add(selctdassets.id);
        }
        
        lstSelectedAssets = [Select id,name,Product_Name_Vendor__c, Product_Family__c, Customer_Name__r.name,Customer_Name__r.Customer_Profiled_Account__c,Customer_Name__r.Customer_Profiled_Account_Lookup__r.Name,Customer_Name__r.Customer_Profiled_Account_Lookup__c, Customer_Name__c from Asset__c Where id in :setAssetIds limit 50000];
        
        if((lstSelectedAssets!=null)&&(lstSelectedAssets.size() > 0))
        {
            for(integer i=0; i<lstSelectedAssets.size(); i++)
            {
                accName = null;
                accId = null;
                accLkid = null;
                if(lstSelectedAssets[i].Customer_Name__c!=null)
                {
                  // if(lstSelectedAssets[i].Customer_Name__r.Customer_Profiled_Account_Lookup__c == null){
                  if(lstSelectedAssets[i].Customer_Name__r.Customer_Profiled_Account__c){
                    System.debug('True--------');
                    accName = lstSelectedAssets[i].Customer_Name__c;    
                    accId = lstSelectedAssets[i].Customer_Name__r.Name;
                    accLkid = lstSelectedAssets[i].Customer_Name__r.Id;  
                    break;       
                    }
                   // else if(lstSelectedAssets[i].Customer_Name__r.Customer_Profiled_Account_Lookup__c != null){
                   else if(lstSelectedAssets[i].Customer_Name__r.Customer_Profiled_Account__c ){
                    System.debug('false--------');
                  /*  accName = lstSelectedAssets[i].Customer_Name__r.Customer_Profiled_Account_Lookup__c ;    
                    accId = lstSelectedAssets[i].Customer_Name__r.Customer_Profiled_Account_Lookup__r.Name;
                    accLkid = lstSelectedAssets[i].Customer_Name__r.Customer_Profiled_Account_Lookup__c;         */
                    
                    accName = lstSelectedAssets[i].Customer_Name__c;    
                    accId = lstSelectedAssets[i].Customer_Name__r.Name;
                    accLkid = lstSelectedAssets[i].Customer_Name__r.Id; 
                    if(lstSelectedAssets[i].Customer_Name__r.Customer_Profiled_Account_Lookup__c == null){
                          assetCount =assetCount+1;
                    }
                    
                    }
                     if(assetCount >= 2){
                        System.debug('false--------');
                        accName = lstSelectedAssets[i].Customer_Name__r.Customer_Profiled_Account_Lookup__c ;    
                        accId = lstSelectedAssets[i].Customer_Name__r.Customer_Profiled_Account_Lookup__r.Name;
                        accLkid = lstSelectedAssets[i].Customer_Name__r.Customer_Profiled_Account_Lookup__c;       
                    
                    }
                 
                }
            }          
            for(integer j=0; j<lstSelectedAssets.size(); j++)
            {
                if(accName!=lstSelectedAssets[j].Customer_Name__c  && lstSelectedAssets[j].Customer_Name__r.Customer_Profiled_Account_Lookup__c == null)
                {                   
                    intDiffAccount++;
                }
                else
                {
                    lstCreateOpty.add(lstSelectedAssets[j].id);                 
                }
            }
            
        }
        else
        {
            intNoRec++;         
        }           
        if((setAssetIds!=null)&&(setAssetIds.size() > 0))
        {
            lstJnObj = [select id,Asset_Record_Type_ID__c,Opportunity_Forecast_Status__c,Opportunity_Close_Date__c,Related_Asset__c,Related_Asset__r.id,Related_Opportunity__c from Opportunity_Asset_Junction__c where Related_Asset__r.id in:setAssetIds limit 50000];            
            
            if((lstJnObj!=null)&&(lstJnObj.size()>0))
            {               
                for(Opportunity_Asset_Junction__c j: lstJnObj)
                {                   
                    if(j.Opportunity_Forecast_Status__c.contains(Status))
                    {
                        lstCreateOpty.add(j.Related_Asset__r.id);                        
                    }
                    else
                    {
                        intActiveOpty++;
                    }    
                }                                       
            }            
            else
            {               
                for(Asset__c noreltdopty: lstSelectedAssets)
                {
                    lstCreateOpty.add(noreltdopty.id);
                }
            }
                    
        }
        
        intErrored = intActiveOpty + intDiffAccount;                        
        
        strAssetIds = '';                      
        for(Id assetid: lstCreateOpty)
        {           
            strAssetIds += assetid + ',' ;
        }
        // remove last additional comma from string
        
        if((strAssetIds!= null) &&(strAssetIds!= ''))
        {
            strAssetIds = strAssetIds.subString(0,strAssetIds.length()-1);          
        }
        
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        dataValueMap  = data.get('Asset Ids field').DataValue__c ;
        dataMapRetUrl = data.get('Return URL in Asset').DataValue__c ;         

        
    }
    
     public void ValidateOpty(){
        
        if(intNoRec!= 0)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.No_Record_Selected_for_Create_Opportunity);
            ApexPages.addMessage(msg);
        }
        
        if(intActiveOpty!=0)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Active_Opportunity_on_Asset_Error);
            ApexPages.addMessage(msg);
        }
   
        if(intDiffAccount!=0)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Different_Account_on_Asset_Error);
            ApexPages.addMessage(msg);
        }
        
    }
    
    public PageReference CreateOpty(){
        
        ValidateOpty(); 
        if((intErrored<=0)&&(intNoRec<=0))
        {                              
            if(lstCreateOpty!=null)
            {               
                idListView = Apexpages.currentPage().getParameters().get('fcf');
                idRecordType = [select id from recordtype where Name = 'New Manually Created Record Type' and SobjectType = 'Opportunity' limit 1].Id;
                if((accId!=null)&&(accLkid!=null))
                {
                    encodedAccName = EncodingUtil.urlEncode(accId, 'UTF-8');
                    encodedaccLkid = EncodingUtil.urlEncode(accLkid, 'UTF-8');
                }
                if(strAssetIds!=null)
                {
                    encodedAssetIds =  EncodingUtil.urlEncode(strAssetIds, 'UTF-8');
                }
                if(dataValueMap!=null)
                {
                    encodeddataValueMap = EncodingUtil.urlEncode(dataValueMap, 'UTF-8');
                }
                strCloseDate = closeDate.format('MM/dd/yyyy') ;                         
                encodedCloseDate = EncodingUtil.urlEncode(strCloseDate, 'UTF-8');   
                 
                if((idListView!=null)&&(idRecordType!=null)&&(encodedAccName!=null)&&(encodedaccLkid!=null)&&(ForecastCategoryName!=null)&&(encodedCloseDate!=null)&&(encodedAssetIds!=null)&&(encodeddataValueMap!=null))
                {                   
                    CustomUrl= '/006/e?retURL='+dataMapRetUrl+idListView+'&RecordType='+idRecordType+'&ent=Opportunity&opp4='+encodedAccName+'&opp4_lkid='+encodedaccLkid+'&opp11='+ForecastCategoryName+'&opp9='+encodedCloseDate+'&'+encodeddataValueMap+'='+encodedAssetIds;               
                    return new PageReference(CustomUrl);
                }
                
            }
        }
        return null;
    }

}