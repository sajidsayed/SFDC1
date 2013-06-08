/*==================================================================================================================+

 |  HISTORY  |                                                                            

 |  DATE          DEVELOPER      WR        DESCRIPTION   strInputCode                            

 |  ====          =========      ==        =========== 

 |  08/01/2013    Hemavathi N M               To Mass Link the Asset with the opportunity.                      
 +==================================================================================================================**/

public  class Transformation_AssetMassLinkController {
    public Account accountObj {get;set;}
    public Account accObj {get;set;}
    public Boolean isSelected {get;set;}
    public List<Account> listAccount   {get;set;}
    public List<Asset__c> listAsset   {get;set;}
    public List<assWrapper> AssetList {get;set;}  
    public Asset__c objAsset   {get;set;}
    public Id customer_Profile_Account;
    public List<Asset__c> selectedAssets {get;set;} 
    public  Opportunity_Asset_Junction__c link {get;set;}
    public String opptyId ;
    public Id accountId ;
    String retURL='/a3S/o';
    public String newAssetUrl {get; set;}
    public Boolean isListEmpty {get;set;}
    public Boolean FlagResult {get; set;}
    public Boolean FlagButton {get; set;}
    public PageReference returnURL {get; set;}
      public PageManager objPageManager {get;set;}
    public Transformation_AssetMassLinkController(){
        System.debug('Constructor');
    }
    public Transformation_AssetMassLinkController(ApexPages.StandardController controller) {
         isListEmpty = false;
        selectedAssets = new List<Asset__c>();
        link= new  Opportunity_Asset_Junction__c(); 
        accObj = (Account) controller.getRecord();
          //Instance of Page Manager in Paginator.
        objPageManager = new PageManager(100); 
        
           opptyId = ApexPages.currentPage().getParameters().get('opportunityId');
           accountId=ApexPages.currentPage().getParameters().get('accId');
           listAsset = new List <Asset__c>();
           AssetList = new List<assWrapper>();
           
           if(accountId != null ){
                accountObj=[select Id,Name,Customer_Profiled_Account_Lookup__c,Party_Number__c from Account where id =: accountId];
            }
           if(accObj.Id != null ){
               system.debug('accobj-->'+ accObj) ;
               accountObj=[select id,Name,Customer_Profiled_Account_Lookup__c,Party_Number__c from Account where id=: accObj.Id ];
               }
            AccountData();
            for(Asset__c ast: listAsset)
            {
                AssetList.add(new assWrapper(ast));   
            }
            System.debug('AssetList1--->'+AssetList);
                    objPageManager.numberOfRows = AssetList.size();  
             Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
             
            if(accObj.Id != null){
            System.debug('Inside new Assert URl');
             newAssetUrl = data.get('New Asset URL').DataValue__c+accObj.Id+'&CF00N70000002sjfj='+accountObj.Name+data.get('New Asset URL2').DataValue__c+accObj.Id+data.get('New Asset URL3').DataValue__c; }
             returnURL = new PageReference('/apex/Transformation_Account_Asset_list')  ; 
             returnURL.getParameters().put('Id', accObj.Id);
             returnURL.setRedirect(true);
              
    } 
    
    Private void AccountData(){
    if(accountObj != null){
     List<Id> accId=new List<Id>();
   
 //For Account Pagelayout
 if(opptyId == null){
        if(accountObj.Customer_Profiled_Account_Lookup__c == null){
            List<Account> lstAcc=[select id,Name from Account where Customer_Profiled_Account_Lookup__c =: accountObj.Id];
          
           
            for(Account accObj : lstAcc){
                accId.add(accObj.Id);
            }
            accId.add(accountObj.Id);
        }
        else{
         accId.add(accountObj.Id);
        }
    listAsset =[Select Id ,Model__c,Install_Date__c,Customer_Name__r.Party_Number__c,Customer_Name__r.Customer_Profiled_Account_Lookup__c,Custom_Asset_Name__c,Serial_Number__c,Name,Disposition_Status__c ,Account_Record_Type__c ,RecordType.Name ,Product_Name_Vendor__c,Product_Family__c,Customer_Name__c,Contract_Number__c 
        from Asset__c where Customer_Name__c in : accId];
   
    }
  else if(opptyId != null){
  Opportunity opptyOb = new Opportunity() ;
  String opptyClosed = System.Label.Transformation_Closed;
  opptyOb = [Select Id, StageName from opportunity where Id =:opptyId];
 
  
    if(accountObj.Customer_Profiled_Account_Lookup__c != null){
            List<Account> lstAcc=[select id,Name from Account where Customer_Profiled_Account_Lookup__c =: accountObj.Customer_Profiled_Account_Lookup__c];
         
            for(Account accObj : lstAcc){
           
                accId.add(accObj.Id);
            }
            accId.add(accountObj.Customer_Profiled_Account_Lookup__c);
        }
        else{
        List<Account> lstAcc=[select id,Name from Account where id=:accountObj.Id OR Customer_Profiled_Account_Lookup__r.Id =: accountObj.Id ];
      
        for(Account accOb1 : lstAcc){
              accId.add(accOb1.Id);
            }
       //  accId.add(accountObj.Id);
        }
       
        if(opptyOb.StageName != opptyClosed){
        listAsset =[Select Id ,Model__c,Install_Date__c,Customer_Name__r.Party_Number__c,Customer_Name__r.Customer_Profiled_Account_Lookup__c,Custom_Asset_Name__c,Serial_Number__c,Name,Disposition_Status__c ,Account_Record_Type__c ,RecordType.Name ,Product_Name_Vendor__c,Product_Family__c,Customer_Name__c,Contract_Number__c 
        from Asset__c where Customer_Name__c in : accId  and Disposition_Status__c =: System.Label.Transformation_Installed and RecordType.Name !=: System.Label.Transformation_EMC_Installed];
        }
      
        
  }
     
        if(listAsset.size() > 0){
        FlagButton = true;
        }
        else{
            isListEmpty = true;
            ApexPages.Message myMsg;
            myMsg = new ApexPages.Message(ApexPages.Severity.INFO,System.Label.Transformation_NoRecordsOnLink);
            ApexPages.addMessage(myMsg);
        
        }
        
        
       // System.debug('listAsset1---->' + listAsset.size());
     
       }
    }
    
    public PageReference EditRecord(){
        String ObjectiveEditId = ApexPages.currentPage().getParameters().get('ObjectiveEditId');
        System.debug('ObjectiveEditId-->'+ObjectiveEditId);
        return new PageReference('/'+ObjectiveEditId+'/e?retURL=%2F'+ObjectiveEditId);
    }

   public PageReference linkAssest(){
   System.debug('**************INSIDE LINK ASSET****************');
         String strOpp = ApexPages.currentPage().getParameters().get('retURL');
           String OpportunityId ='';
           Boolean noSelectedItem = true;    
           String asseId ='';
          
           for(assWrapper aAss: AssetList)
            {
            if(aAss.selected == true)
            {
                selectedAssets.add(aAss.ass);   
             }            
             }
        
        if((selectedAssets!=null)&&(selectedAssets.size()>0))
        {   
            noSelectedItem = false;
           
                List<Transformation_AssetList__c> lstAssetId = new List<Transformation_AssetList__c>();
                List<Transformation_AssetList__c> deleteId =[Select Name from Transformation_AssetList__c];
                           
                
                for(Asset__c assObj : selectedAssets){
                    Transformation_AssetList__c objAssetId = new Transformation_AssetList__c();
                    objAssetId.Name = assObj.id;
                    lstAssetId.add(objAssetId);
                }
                try{
                    if(deleteId.size()>0)
                    delete deleteId;
                    if(lstAssetId.size()>0)
                    insert lstAssetId;
                }
                catch(Exception e){
                    System.debug('Query Exception---->' + e);
                }
                
          
        }  
     
        Id oId= ApexPages.currentPage().getParameters().get('opportunityId');
       if (oId != null){
               // integer index =strOpp.indexof('opportunityId');
               //  System.debug('index '+index);
              //   OpportunityId=strOpp.substring(index +14);
                  link.Related_Opportunity__c=oId;
                //  retURL='/'+OpportunityId; 
                  retURL='/apex/Transformation_Link_Assets?retURL=/?opportunityId='+oId;
                  System.debug('retURL--->' + retURL); 
          }
          
        if(!noSelectedItem)
        return new PageReference(retURL);
        else{
            ApexPages.Message myMsg;
            myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No Assets selected');
            ApexPages.addMessage(myMsg);
            return null;
       
        }
    }
    
        public void DeleteRecord(){
        String ObjectiveDeleteId = ApexPages.currentPage().getParameters().get('ObjectiveDeleteId');
        System.debug('ObjectiveDeleteId-->'+ObjectiveDeleteId);
        Asset__c deleteRecords = new Asset__c();
        if(ObjectiveDeleteId != null){
        deleteRecords = [select id,name from Asset__c where Id=:ObjectiveDeleteId];}
      
        //Check if User has delete access on record.
        boolean hasDeleteAccess = Schema.sObjectType.Asset__c.isDeletable();
      
      //  PageReference returnPage=null;
        try{
           if(deleteRecords != null){
            if(hasDeleteAccess){            
                delete deleteRecords;
       
                //returnPage = new PageReference('/apex/Transformation_AssertMassLink?retURL=/?opportunityId='+opptyId);
            //  returnPage = new PageReference('/apex/Transformation_AssertMassLink?opportunityId='+opptyId+'&accId'+accountId);
      
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Transformation_NoPrivilageToAsset);
                ApexPages.addMessage(myMsg);
                System.debug('myMsg'+myMsg);
            }
           }
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
        //returnPage.setRedirect(false);
      //  return returnPage;
    }
    public List<Asset__c> SelectedRecord(){
    for(assWrapper aAss: AssetList)
        {
            if(aAss.selected == true)
            {
                selectedAssets.add(aAss.ass);   
            }            
        }
        if((selectedAssets!=null)&&(selectedAssets.size()>0))
        {
           
            return selectedAssets;                   
        }
        else
        return null;
    }
    public List<assWrapper> getAssetsDetails()
    {
        //getAssets();
         system.debug('AssetList---->'+AssetList);
         List<assWrapper > data = new List<assWrapper >();
        for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<AssetList.size();i++){
            data.add(AssetList.get(i));
           
        }
         System.debug('***data***'+data);
        return data;
    } 
    // Wrapper Class
    public class assWrapper { 
        public Asset__c ass {get;set;}
        public Boolean selected {get;set;}
       // public string patyNumber {get;set;}
        public assWrapper(Asset__c a)
        {
            ass = a;
            selected = false;
        }
    }   
    
    public List<Asset__c> getselectedAssets()
    {
        return selectedAssets;
    }
    
    public PageReference cancelLink() {
        return new PageReference('/'+opptyId);
}

 public PageReference processSelected()
    {
       // for(aAsset aAss: getAssets())
      for(assWrapper aAss: AssetList){
             if(aAss.selected == true)
            {
                selectedAssets.add(aAss.ass);   
            }            
        }
        if((selectedAssets!=null)&&(selectedAssets.size()>0))
        {
            system.debug('selectedAssets in Process--->'+selectedAssets);           
                            
        }
        
          
        FlagResult = true;
        return null;
    } 
}//End of Class