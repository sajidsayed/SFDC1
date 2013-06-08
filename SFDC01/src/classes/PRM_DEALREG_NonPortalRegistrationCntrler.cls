/*================================================================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR                        DESCRIPTION 
 |  ====          =========               ==                        =========== 
 |  11/05/2011    Anand Sharma           2237,2226,2225,2762        This class is used search product 
 |  24/05/2011    Anand Sharma                                      Moved page size into customsetting 
 |  26/05/2011    Ashwini Gowda          2917                       Set Submission Source Field value to 'Powerlink' if the
 |                                                                   DR was submitted using the Non-Portal DR Page.
 |  31/05/2011    Anand Sharma                                      Added check for active products
 |  01/06/2011    Suman B                                           Added selectOptions for Country input.
 |  06/06/2011    Suman B                                           Addded Account NameLocal and updated the search query                                                                       
 |  27/07/2011    Suman B               3160                        Added AccountSearch filter criteria for filteringout inactive Accounts.
 |  02/08/2011    Suman B                                           Modified the Country field selectOptions from CustomSettings CustomSettingCountryTheaterMapping__c 
 |                                                                   to Country__C field picklist values on the AccountSearch  
 |  03/08/2011   Prasad                                             Fix for Handoff and Theater on Create new account                                                                   
 |  05/08/2011   Suman B                                            Modified the search() to match the Account and Lead Country picklsit values. 
 |  26/08/2011   Shravanthi J            3714                       Updated the Record type as "Deal Registartion - Submitted" when leads are inserted.
 |  12/09/2011    Suman B                3808                       Added logic to set the Country field with Account Country CustomSetting for 
 |                                                                   Macedonia and South Georgia. 
 |  15/09/2011   Anand Sharma                                       Added fixed to display error message to user 
 |  04/11/2011   Suman B                IM7290735               Populating the CompanyLocal field with Related Account's NameLocal.
 |  10/11/2011   Suman B                IM7312572               To override the local address fields with new related Account Address on DR.
 |  11/11/2011   Suman B                WR#178765               Modified AccountSearch for searching based on Party Number.
 |  23/11/2011   Suman B                WR#178765               Modified AccountSearch for searching based on Synergy_Account_Number__c also.
    1 Dec 2011   Arif                   WR#178756               Added a condition to display error message if Approval criteria is not satisfied.
 | 31 Jan 2011   Prasad			IM7567769/187207 	 	Changed the email validation for SFDC auth parameter '.com' to '@'
 +===========================================================================================================================================================*/
public class PRM_DEALREG_NonPortalRegistrationCntrler { 
    
    //public vairables     
    public Lead leadRecord{get; set;}       
    public Id productId {get; set;}
    public String sortField {get; set;}
    public boolean sortAscending {get; set;}
    public String Query {get; Set;}
    public List<ProductsDataContainer> lstProductsDetails {get; set;}
    public List<ProductsDataContainer> lstFullProductsDetails {get; set;}
    public List<Partner_Tier_Mapping__c> lstRegistrationProduct {get; set;}
    public List<Partner_Tier_Mapping__c> lstExistingRegistrationProduct {get; set;}
    public String searchProduct {get; set;}
    public String searchProductCatalog {get;set;}
    public set<String> setProductNames{get; set;}  
    public set<Id> existingProducts{get; set;}   
    public String productName {get; set;}
    public boolean isExternalPortalSource {get; set;}   
    public boolean isPartnerPortalUser {get; set;} 
    public String items;
    public String lang { get; set; }
    
    //private vairable
    List<Registration_Product__c> regProductsList;
    List<Registration_Product__c> registrationProductsList = new List<Registration_Product__c>();
    List<ProductsDataContainer> selectProductList = new List<ProductsDataContainer>();    
    Account objRelatedAccount = new Account();
    public ID profileAccountId;
    // paging
    public PageManager objPageManager {get;set;}

    /** CUSTOM SEARCH LOOKUP CONTLR FIELDS**/      
    public List<Account> listAccount   {get;set;}
    public String inputvalue           {get;set;}
    public String inputAccountName     {get;set;}
    public String inputStreet          {get;set;}
    public String inputCity            {get;set;}
    public String inputState           {get;set;}
    public String inputZipCode         {get;set;}
    public String inputCountry         {get;set;}
    public String paramValue           {get;set;}
    public Boolean noResult            {get;set;}
    public String selectedrecord       {get;set;}
    public String hiddenAccId          {get;set;}
    public String inputPartyNumber     {get;set;}  // Added for WR#178765. 
    //CustomSearch hiddenFields.
    public String  hiddenStreet      {get;set;}
    public String  hiddenCity        {get;set;}
    public String  hiddenState       {get;set;}
    public String  hiddenZipCode     {get;set;}
    public String  hiddenCountry     {get;set;}

    //PopulateLeadAddress hiddenFields.
    public String  selectedStreet               {get;set;}
    public String  selectedCity                 {get;set;}
    public String  selectedState                {get;set;}
    public String  selectedZipCode              {get;set;}
    public String  selectedCountry              {get;set;}
    public String  selectedAccountName          {get;set;}
    public String  selectedAccountAddress       {get;set;}
    public String  selectedAccountAddressLocal  {get;set;}
  //    public Id objLeadId {get; set;}
    
    public List<Account> defaultlistAccount ; 
    Id leadid;
    string strQuery ;
    string inputAccountName1 ;
    String inputState1 ;
    String inputZipCode1;
    String inputCountry1 ;
    string inputCity1  ;
    String inputStreet1 ;
    String accountStatus = 'Active';
    String inputPartyNumber1 ;
    
    public Lead ldobj {get;set;}
    Account accselected ;
  
    //Sorting 
    public string sortField1 {get;set;}
    public Boolean sortAscending1 {get;set;}
  
    public boolean showDealRegForm{ get; set; }
    public String header { get; set; }
    public boolean showaddressmessage {get;set;}
    String accountTierValue;
    String DealRegAccesibleLinkDetails ='';
    
    // CustomSearch paging
    public PageManager objPageManagerAcc       {get;set;}
    public List<Account> lstAccountDetails     {get;set;}

    /** CUSTOM SEARCH LOOKUP CONTLR FIELDS --- END**/ 
 
    //default constructor
    public PRM_DEALREG_NonPortalRegistrationCntrler(ApexPages.StandardController controller){
        // CHECK FROM WHERE THE PAGE IS GETTING ACCESS                       
        showDealRegForm=true;
        accountTierValue ='';
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c pageDetails = DataValueMap.get('PageSize');
        Integer pageSize = 25;        
        try
        {            
            pageSize  = Integer.valueOf(pageDetails.DataValue__c);
        }
        catch(Exception e)
        {
            pageSize = 25;
        }  
         
        //initialize variables
        searchProduct = '';
        searchProductCatalog ='';
        lstProductsDetails = new List<ProductsDataContainer>();
        lstFullProductsDetails = new List<ProductsDataContainer>();
        lstRegistrationProduct = new List<Partner_Tier_Mapping__c>();
        lstExistingRegistrationProduct = new List<Partner_Tier_Mapping__c>();
        setProductNames = new Set<String>();
        existingProducts = new Set<Id>();
        productName = '';               
        objPageManager = new PageManager(pageSize); 
        sortAscending = true;
        sortField = 'Partner_Product_Catalogue__r.Product__r.Name'; 
        selectedAccountAddress ='';
        selectedAccountAddressLocal ='';
        this.leadRecord = new Lead();
        isExternalPortalSource = true;
        isPartnerPortalUser = false;
                
        //check that product page called from related list or external page
        String leadViewId = ApexPages.currentPage().getParameters().get('retURL');
        System.debug('With URL leadViewId -->'+ leadViewId);        
        System.debug('isExternalPortalSource -->'+ isExternalPortalSource);
        
        if(leadViewId != null){
            isExternalPortalSource = false;            
            System.debug('leadViewId Before -->'+ leadViewId);
            leadViewId =  leadViewId.substring(1,leadViewId.length());
            System.debug('leadViewId -->'+ leadViewId); 
             
            // fetch lead record
            this.leadRecord =  fetchLead(leadViewId); 
          //  objLeadId = this.leadRecord.Id;
            //call add product method to fetch product records      
            addProducts();
        }
                
        //get language details
        PageReference pageRef = ApexPages.currentPage();
        lang=pageRef.getParameters().get('lang');  
        if(lang==''|| lang==null){
            lang='en_US';
        } 
        System.debug(' Final isExternalPortalSource -->'+ isExternalPortalSource);
        /* CHANGES START FOR CUSTOM SEARCH*/
        //leadid = ApexPages.currentPage().getParameters().get('id');

        listAccount = new List<Account>();
       /*   listAccount = [Select id,name,BillingState,BillingPostalCode,
                            Party_Number__c,Preferred_Install_Flag__c,
                            Child_Record_Count_Contact__c,Address__c,Address_Local__c 
                        FROM Account ORDER BY name ASC limit 10 ];
         */               
        defaultlistAccount = listAccount ;
       
        sortAscending1 = TRUE;
     // sortField1 = 'Name';  
        objPageManagerAcc = new PageManager(pageSize);
        lstAccountDetails = new List<Account>();  
        /*String header = ApexPages.currentPage().getHeaders().get('Referer');
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall();       
        CustomSettingDataValueMap__c DealRegAccesibleLink = (mapCustomSettingDataValueMap.get('Dealreg Accessible Link'));                
        DealRegAccesibleLinkDetails = DealRegAccesibleLink.DataValue__c;
        if(header!=null){
            System.debug('header.indexOf(DealRegAccesibleLinkDetails)=='+header.indexOf(DealRegAccesibleLinkDetails));
            if(header.indexOf(DealRegAccesibleLinkDetails)!=0 ){
                showDealRegForm=false;
         }
            return ;
        }*/
        
        String SFDC_AUTH = ApexPages.currentPage().getParameters().get('SFDC_AUTH');
        System.debug('SFDC_AUTH '+SFDC_AUTH);
        if(SFDC_AUTH !='' && SFDC_AUTH != null  && SFDC_AUTH.indexof('@')!=-1 ){
            showDealRegForm=true;
        }else{
            showDealRegForm=false;
        }
        
         /**/   
        
        /* CHANGES END FOR CUSTOM SEARCH*/          
    }
        
    /* @Method <fetchLead(): This method would fetch lead record details.>
       @param - <Lead id as String> 
       @return <void> - <Lead object>
       @throws exception - <No Exception>
    */
    private Lead fetchLead(String leadIds){  
        Lead objLead;
        if(leadIds != null || leadIds !=''){
            if(leadIds.length() >15) {
                leadIds = leadIds.substring(0, 15);
            }
            objLead = [Select Id, Name, Related_Account__c,Related_Account__r.Address__c,Related_Account__r.Address_Local__c,companyLocal,
                        DealReg_Address_Local__c , City_Local__c, State_Province_Local__c, Country_Local__c, Zip_Postal_Code_Local__c, 
                        Street_Local__c 
                        FROM Lead 
                        Where id =: leadIds];
        }        
        return objLead;                            
    }
    
    /* @Method <fetchAccount(): This method would fetch Account record details.>
       @param - <Account id as String> 
       @return <void> - <Account object>
       @throws exception - <No Exception>
    */
    private Account fetchAccount(String accountId){
        Account accRecord ;
        if(accountId != null || accountId !=''){
            accRecord = [Select Id, Name, Partner_Type__c, Velocity_Services_Implement__c, Solution_Center_Implemented__c,
                                Velocity_Solution_Provider_Tier__c, Theater1__c,  Velocity_Compliance_Status__c
                         FROM Account 
                         Where id =: accountId];
        }
        return accRecord;                            
    }
   
    /* @Method <addProducts(): This method is used to fetch products.>
       @param - <void>
       @return <void> - <>
       @throws exception - <No Exception>
    */ 
    public boolean addProducts(){
        boolean isAccountValid = true;
        System.debug('Add Product leadRecord -->'+ this.leadRecord);
     
        //leadRecord.Related_Account__c ='0017000000Pw7UB';
        
        if(userinfo.getUserType() == 'PowerPartner'){     
            // get profiled account Id from partner user contact                    
            User currentUser = [Select u.ContactId, u.Contact.AccountId,contact.Account.PROFILED_ACCOUNT_FLAG__c,
                                    contact.Account.Profiled_Account__c,u.Velocity_Access__c, u.Co_Op_Access__c 
                                from User u 
                                where id=:userinfo.getUserId()];
                            
            isPartnerPortalUser = true;                                    
                                          
            System.debug('currentUser Account Id-->'+currentUser.Contact.AccountId);           
           //if account is profiled account then get that account id else take its profiled account Id
            if(currentUser.contact.Account.PROFILED_ACCOUNT_FLAG__c==true){  
                this.profileAccountId = currentUser.Contact.AccountId ;
            }                   
            else{ 
                this.profileAccountId = currentUser.Contact.Account.Profiled_Account__c;
            }            
            objRelatedAccount = fetchAccount(this.profileAccountId);            
        }else{
            if(leadRecord.Related_Account__c != null){
                objRelatedAccount = fetchAccount(leadRecord.Related_Account__c);
            }
        }
        
        System.debug('objRelatedAccount -->'+ objRelatedAccount);
        
        accountTierValue = objRelatedAccount.Velocity_Solution_Provider_Tier__c;
        if(accountTierValue == null || accountTierValue == ''){
            Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
            CustomSettingDataValueMap__c accountTier = DataValueMap.get('ProductAccountDefaultTier');
            accountTierValue = accountTier.DataValue__c;
        }
                
        //check that account had tier and theater value
        /*
        if(objRelatedAccount != null && ((objRelatedAccount.Velocity_Solution_Provider_Tier__c == null || objRelatedAccount.Velocity_Solution_Provider_Tier__c =='')
                || (objRelatedAccount.Theater1__c == null || objRelatedAccount.Theater1__c =='') )){        
                isAccountValid = false;         
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, System.Label.PRM_DEALREG_InValidAccount);
            ApexPages.addMessage(errorMessage);                        
        }
        */
        //fetch existing product on deal
        doSearchExistingProduct();
        //fetch all product accept which is already on deal
        doSearchClearFilters(); 
        return isAccountValid;   
    } 
    
    /* @Method <addProductsOnLead(): This method is used to redirect on respective page.>
       @param - <void>
       @return <PageReference> - <Navigates to other VF Page for associating products to deal reg>
       @throws exception - <No Exception>
    */  
    public PageReference addProductsOnLead(){       
        if(addProducts()){
            System.debug('lang=++++' + lang);
            return new PageReference ('/apex/PRM_DEALREG_selectProducts?lang='+lang);
        }else{
            return null;
        }
    }
    
    /* @Method <sortList(): This method is used to sort the products on the basis of field and asc/desc order.>
       @param - <stri>ng, string
       @return <void> -
       @throws exception - <No Exception>
    */     
    public void sortList(String strSortKey, boolean isASC){
        List<Partner_Tier_Mapping__c> lstProduct =new  List<Partner_Tier_Mapping__c>();   
        String strQuery =  query;               
        String strProductIds = ' Partner_Product_Catalogue__c NOT IN (';
        
        if(lstRegistrationProduct.size()>0 ){                        
            for(Partner_Tier_Mapping__c objProd: lstRegistrationProduct){
                strProductIds += '\'' + objProd.Partner_Product_Catalogue__c + '\' ,';
            }
            if(strProductIds.endsWith(',')){                                
                    strProductIds = strProductIds.substring(0,strProductIds.length() -1);                           
            }                       
            query += strProductIds + ')';
        }
        if(query.endsWith('where')){                                
                query = query.substring(0,query.length() -5);                           
        }
        if(query.endsWith('AND')){                                
                query = query.substring(0,query.length() -3);                           
        }
        if(isASC){
            query += ' ORDER BY ' + strSortKey + ' asc';
        }else{
            query += ' ORDER BY ' + strSortKey + ' desc';
        }       
        System.Debug('Sort Query --->' + query);   
        lstProduct = Database.query(query);
        
        lstFullProductsDetails.clear();
        if(lstProduct.size() > 0){
            Set<String> setProductNames= new Set<String>();
            for(Partner_Tier_Mapping__c prod:lstProduct)
            {
                if(!setProductNames.contains(prod.Partner_Product_Catalogue__c)){
                    setProductNames.add(prod.Partner_Product_Catalogue__c);
                    lstFullProductsDetails.add(new ProductsDataContainer(prod));
                }                
            }
        }
        
        objPageManager.page = 0;
        objPageManager.numberOfRows =0;                   
        objPageManager.numberOfRows = lstFullProductsDetails.size();
        
        query =strQuery; 
    }    
    
    /* @Method <runSortAction(): This method is called from VF page on click on column. 
            This will call sort function and and display sorted data on VF page>
       @param - <void>
       @return <void> - <Not Returning anything> 
       @throws exception - <No Exception>
    */
    public void runSortAction(){
        List<Partner_Tier_Mapping__c> lstTempProduct = new List<Partner_Tier_Mapping__c>();
        List<Partner_Tier_Mapping__c> lstTempProductSorted = new List<Partner_Tier_Mapping__c>();
        for(ProductsDataContainer prdContainer: lstProductsDetails){
                lstTempProduct.add(prdContainer.selProduct);                    
        }       
        if(lstTempProduct.size()> 0){
                sortList(sortField, sortAscending);
        }
    }
        
    /* @Method <updateProduct(): This method is used to remove selected Products in UI from selection 
                         and make it available for selection.> 
       @param - <void>
       @return <void> - <Not Returning anything> 
       @throws exception - <No Exception>
    */
    public void updateProduct(){
        List<Partner_Tier_Mapping__c> unSelectedProductList = new List<Partner_Tier_Mapping__c>();
        for(Integer i=0; i < lstRegistrationProduct.size() ; i++){    
            if(lstRegistrationProduct[i].Id == productId){
                lstProductsDetails.add(new ProductsDataContainer(lstRegistrationProduct[i]));                
                lstFullProductsDetails.add(new ProductsDataContainer(lstRegistrationProduct[i]));
            }else{
                unSelectedProductList.add(lstRegistrationProduct[i]);
            }
        }          
        lstRegistrationProduct = unSelectedProductList;        
        sortList(sortField, sortAscending);
        System.debug('updateProduct lstProductsDetails-->'+lstProductsDetails.size());
        System.debug('updateProduct registrationProductsList-->'+lstRegistrationProduct.size());                      
    }
    
    /* @Method <selectedProducts(): This method is used to add products selected from UI.>
       @param - <void>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */  
    public void selectedProducts(){
        List<ProductsDataContainer> unSelectedProductList = new List<ProductsDataContainer>();
        for(ProductsDataContainer selectedRegProd: lstProductsDetails){                 
            if(selectedRegProd.selected){
                lstRegistrationProduct.add(selectedRegProd.selProduct);                 
            }else{
                unSelectedProductList.add(selectedRegProd);                
            }
        }
        lstProductsDetails.clear();        
        lstProductsDetails = unSelectedProductList;
        sortList(sortField, sortAscending);
        System.debug('lstProductsDetails-->'+lstProductsDetails.size());
        System.debug('registrationProductsList-->'+lstRegistrationProduct.size());           
    }
    
    /* @Method <saveLeadAndProducts(): This method is used to save Deal Reg and associate products to deal reg(Lead).>
       @param - <void>
       @return <PageReference> 
       @throws exception - <No Exception>
    */  
    public PageReference saveLeadAndProducts(){
        List<Registration_Product__c>  lstPrsProd = new List<Registration_Product__c>();   
        if(lstRegistrationProduct.size() >0){
            try{                
                if(leadRecord.Id == null){
                    Map<String,Schema.RecordTypeInfo> recordTypes = Lead.sObjectType.getDescribe().getRecordTypeInfosByName(); 
                    /*Updated the RecordType to Deal Registration - Submitted when a Deal Reg is inserted through PowerLink as per Requirement: 3714 */
                    Id dealRegRecordtypeId = recordTypes.get('Deal Registration - Submitted').getRecordTypeId();
                    //Id dealRegRecordtypeId = recordTypes.get('Deal Registration').getRecordTypeId();
                    leadRecord.RecordTypeId = dealRegRecordtypeId;
                    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
                    CustomSettingDataValueMap__c siteUserId = DataValueMap.get('SiteUserId');
                    Id DealOwnerId = siteUserId.DataValue__c;
                    leadRecord.OwnerId = DealOwnerId;
                    leadRecord.DealReg_Submission_Source__c = 'Powerlink';
                    insert leadRecord;                
                    System.debug('leadRecord--->'+leadRecord.DealReg_Submission_Source__c);
                    System.debug('leadRecord--->'+leadRecord.id);         
                }               
                Id dealRegId = this.leadRecord.Id; 
                for(Partner_Tier_Mapping__c product: lstRegistrationProduct){
                    if(!existingProducts.contains(product.Partner_Product_Catalogue__c)){
                        Registration_Product__c obj = new Registration_Product__c(Deal_Registration__c =dealRegId, Partner_Product_Catalog__c = product.Partner_Product_Catalogue__c);
                        lstPrsProd.add(obj);
                    }
                }            
                
                insert lstPrsProd ;
                deleteProducts();
                
            }catch(DMLException ex){
                String strErrorMessage = 'Error : '+ ex.getMessage();               
                if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                    strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                }              
                if(strErrorMessage.endsWith(': []')){
                    strErrorMessage = strErrorMessage.substring(0, strErrorMessage.length() -4);
                }
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, strErrorMessage);
                ApexPages.addMessage(errorMessage);
                return null;
            }
                    
        }        
        
        if(isExternalPortalSource){
            try{
                // Create an approval request for the newly created Deal Reg
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(leadRecord.id);
                // Submit the approval request for the newly created Deal Reg
                Approval.ProcessResult result = Approval.process(req1);
                return new PageReference('/apex/PRM_DEALREG_Submission_Screen?lang='+lang); 
            }catch(Exception e){
                // WR#178756 
                ApexPages.addMessages(e);
               return null;  
            }
                        
        }else{
            return new PageReference('/' + leadRecord.Id);
        }
    }
    
    /* @Method <saveProducts(): This method is used to associate products to deal reg(Lead) and navigate back to deal reg page.>
       @param - <void>
       @return <PageReference> 
       @throws exception - <No Exception>
    */  
    public PageReference saveProducts(){
        return new PageReference('/apex/PRM_DEALREG_nonportalRegistrationForm?lang='+lang); 
    }
    
    /* @Method <deleteProducts(): This method is used to delete products to deal reg(Lead).>
       @param - <void>
       @return <PageReference> 
       @throws exception - <No Exception>
    */  
    public void deleteProducts(){
        Set<Id> setProducts = new Set<Id>();
        System.debug(lstExistingRegistrationProduct.size() + ' lstExistingRegistrationProduct --> ' + lstExistingRegistrationProduct);
        System.debug(lstRegistrationProduct.size() + ' lstRegistrationProduct --> ' + lstRegistrationProduct);
        Map<Id, Partner_Tier_Mapping__c> existingProduct = new Map<Id, Partner_Tier_Mapping__c>();
        Map<Id, Partner_Tier_Mapping__c> currentProduct = new Map<Id, Partner_Tier_Mapping__c>();
        for(Partner_Tier_Mapping__c productExist: lstExistingRegistrationProduct){
            existingProduct.put(productExist.Partner_Product_Catalogue__c, productExist);
        }
        for(Partner_Tier_Mapping__c product: lstRegistrationProduct){
            currentProduct.put(product.Partner_Product_Catalogue__c, product);          
        }
        for(Partner_Tier_Mapping__c productExist: lstExistingRegistrationProduct){
            if(!currentProduct.containsKey(productExist.Partner_Product_Catalogue__c) ){
                System.debug(' setProducts --> ' + setProducts );
                setProducts.add(productExist.Partner_Product_Catalogue__c);
            }
        }
        if(setProducts.size() >0){
            System.debug(' setProducts --> ' + setProducts);            
            List<Registration_Product__c> lstRegistrationProduct = [Select id from Registration_Product__c 
                                                                    where Deal_Registration__c =:leadRecord.id 
                                                                    and Partner_Product_Catalog__c in: setProducts];
            if(lstRegistrationProduct.size() > 0){
                delete lstRegistrationProduct;
            }           
        }
    }
    
    /* @Method <cancel(): This method is used to redirect to deal page page.>
       @param - <void>
       @return <PageReference> 
       @throws exception - <No Exception>
    */  
    public PageReference cancelDeal(){          
        if(isExternalPortalSource){
            System.debug(' Page --> ');
            return new PageReference('/apex/PRM_DEALREG_nonportalRegistrationForm?lang='+lang);              
        }else{
            System.debug(' Lead --> ');
            return new PageReference('/' + leadRecord.Id);
        }
    }
    
    /* @Method <doSearchClearFilters(): This method is used to clear sub product and product and call doSearchWithoutFilters.>
       @param - <void>
       @return <void> 
       @throws exception - <No Exception>
    */      
    public void doSearchClearFilters(){
        SearchProductCatalog ='';
        searchProduct ='';
        doSearchWithoutFilters();
    }
    
    /* @Method <doSearchWithoutFilters(): This method is used to call doQuery and doSearchQuery method.>
       @param - <void>
       @return <void> 
       @throws exception - <No Exception>
    */    
    public void doSearchWithoutFilters(){       
        doQuery();
        doSearchQuery();        
    }
    
    /* @Method <doQuery(): This method is used to create query which only filter using theater and tier.>
       @param - <void>
       @return <void> 
       @throws exception - <No Exception>
    */   
    private void doQuery(){
        Query = 'Select Partner_Product_Catalogue__c, Partner_Product_Catalogue__r.Product__r.Name, Partner_Product_Catalogue__r.Product__r.Product_Type_Sales__c, ' + 
                 ' Partner_Product_Catalogue__r.Product__c, Partner_Product_Catalogue__r.Name, Theater__c, Tier__c from Partner_Tier_Mapping__c  where Partner_Product_Catalogue__r.Product__r.IsActive = true AND';           
        if( isPartnerPortalUser){                        
            Query += '  Tier__c =\''+ accountTierValue + '\' AND Theater__c =\''+ objRelatedAccount.Theater1__c + '\' AND';         
        }
    }
        
    /* @Method <doSearchQuery(): This method is used to create query  which only filter using theater, tier and selected product
                                                    and fetch product using query. Reset pagemanager .>
       @param - <void>
       @return <void> 
       @throws exception - <No Exception>
    */      
    public void doSearchQuery() {
        List<Partner_Tier_Mapping__c> lstProduct = new List<Partner_Tier_Mapping__c>();
        regProductsList=null;        
        String StrQuery = Query;
        String strProductIds = ' Partner_Product_Catalogue__c NOT IN (';
               
        if(lstRegistrationProduct.size()>0 ){                        
            for(Partner_Tier_Mapping__c objProd: lstRegistrationProduct){
                strProductIds += '\'' + objProd.Partner_Product_Catalogue__c + '\' ,';
            }
            if(strProductIds.endsWith(',')){                                
                strProductIds = strProductIds.substring(0,strProductIds.length() -1);                           
            }
            query += strProductIds + ')';
        }
        System.debug('Query -->'+ Query);
        if(Query.endsWith('where')){                                
                Query = Query.substring(0,Query.length() -5);                           
        }
        if(Query.endsWith('AND')){                                
                Query = Query.substring(0,Query.length() -3);                           
        }
        if(sortAscending){
            query += ' ORDER BY ' + sortField + ' asc';
        }else{
            query += ' ORDER BY ' + sortField + ' desc';
        }
        System.debug('Query Check-->'+ Query);               
        try{            
            lstProduct = Database.query(Query);             
        }catch(QueryException e){
            String errMsg = e.getMessage();            
            ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.Error,'Please check the filter criteria :- '+ errMsg);
            ApexPages.addMessage(msg2);            
        }        
        lstProductsDetails.clear();
        lstFullProductsDetails.clear();
        objPageManager.page = 0;
        objPageManager.numberOfRows =0;
        
        if(lstProduct.size() >0){
            Set<String> setProductNames= new Set<String>();
            for(Partner_Tier_Mapping__c prod:lstProduct){
                if(!setProductNames.contains(prod.Partner_Product_Catalogue__c)){
                    setProductNames.add(prod.Partner_Product_Catalogue__c);
                    lstFullProductsDetails.add(new ProductsDataContainer(prod));
                }                
            }               
            objPageManager.numberOfRows = lstFullProductsDetails.size();
        }        
        Query = StrQuery;               
    }
        
    /* @Method <doSearchProduct(): This method is used to fetch product on the basis of product name .>
       @param - <void>
       @return <void> 
       @throws exception - <No Exception>
    */  
    public void doSearchProduct() {
        regProductsList=null;        
        doQuery();
        if(SearchProduct.length() >0 ){      
            //SearchProduct = SearchProduct.replace('\'','\\\'');               
            //Query +=       ' AND ( Partner_Product_Catalogue__r.Product__r.Name like \'%' + searchProduct + '%\')';                       
            Query += ' ( Partner_Product_Catalogue__r.Product__r.Name like :searchProduct ) AND';
            
            doSearchQuery();
        }else{
            lstFullProductsDetails.clear();
        }               
    }
        
    /* @Method <doSearchSubCatalog(): This method is used to fetch product on the basis of sub catalog name .>
       @param - <void>
       @return <void> 
       @throws exception - <No Exception>
    */   
    public void doSearchSubCatalog() {        
        regProductsList=null;
        doQuery();
        if(SearchProductCatalog.length() >0 ){       
            //SearchProductCatalog = SearchProductCatalog.replace('\'','\\\'');                 
            Query +=    ' ( Partner_Product_Catalogue__r.Name like :SearchProductCatalog ) AND';
            doSearchQuery();
        }else{
            lstFullProductsDetails.clear();
        }       
    } 
        
    /* @Method <doSearchExistingProduct(): This method is used to search for Registration Products exist for deal record.>
       @param - <void>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */  
    public void doSearchExistingProduct() {
        if(this.leadRecord != null ){   
            set<Id> productCatalogId = new Set<Id>();
            List<Registration_Product__c> lstProduct = new List<Registration_Product__c>();
            if(this.leadRecord.Id != null){
                lstProduct =[Select Id, Deal_Registration__c , Partner_Product_Catalog__c 
                                                        from Registration_Product__c
                                                        where Deal_Registration__c =:this.leadRecord.Id ];
            }
            
            if(lstProduct!= null && lstProduct.size() >0){
                for(Registration_Product__c objregProdu: lstProduct){
                    productCatalogId.add(objregProdu.Partner_Product_Catalog__c);
                }
            }                                                                               
            Map<Id,Partner_Tier_Mapping__c> mapExistingmapping = new Map<Id,Partner_Tier_Mapping__c>();
            if(isPartnerPortalUser){
                 
                mapExistingmapping = new Map<Id,Partner_Tier_Mapping__c>([Select Partner_Product_Catalogue__c, Partner_Product_Catalogue__r.Product__r.Name,
                                            Partner_Product_Catalogue__r.Product__c, Partner_Product_Catalogue__r.Name, 
                                            Theater__c, Tier__c 
                                        from Partner_Tier_Mapping__c 
                                        where Partner_Product_Catalogue__c in:productCatalogId 
                                            and Tier__c =: accountTierValue
                                            and Theater__c=: objRelatedAccount.Theater1__c and Partner_Product_Catalogue__r.Product__r.isActive = true]);
            }else{
                mapExistingmapping = new Map<Id,Partner_Tier_Mapping__c>([Select Partner_Product_Catalogue__c, Partner_Product_Catalogue__r.Product__r.Name,
                                            Partner_Product_Catalogue__r.Product__c, Partner_Product_Catalogue__r.Name, 
                                            Theater__c, Tier__c 
                                        from Partner_Tier_Mapping__c 
                                        where Partner_Product_Catalogue__c in:productCatalogId and Partner_Product_Catalogue__r.Product__r.isActive = true]);
            }
            
            if( mapExistingmapping.size() >0){
                //existingProducts = mapExistingmapping.keySet();
                List<Partner_Tier_Mapping__c> lstTempExistingmapping = new List<Partner_Tier_Mapping__c>();
                for(Partner_Tier_Mapping__c objPTM: mapExistingmapping.values()){
                    if(!existingProducts.contains(objPTM.Partner_Product_Catalogue__c)){
                        lstTempExistingmapping.add(objPTM);
                        existingProducts.add(objPTM.Partner_Product_Catalogue__c);
                    }                   
                }
                lstRegistrationProduct = lstTempExistingmapping;
                lstExistingRegistrationProduct =  lstTempExistingmapping;                                  
            }                                                                                                                                                       
        }                           
    }
    
    /* @Method <changeLang(): This method is used to change the Language from UI.> 
       @param - <void>
       @return <PageReference> 
       @throws exception - <No Exception>
    */
    public PageReference changeLang() {
        return new PageReference('/apex/PRM_DEALREG_NonPortalRegistrationForm?lang='+lang);
    } 
    
    /* @Method <getItems(): This method is used to add languages available for selection in the UI.> 
       @param - <void>
       @return <List<SelectOption>> 
       @throws exception - <No Exception>
    */   
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        Map<String, DealRegistration_CustomSetting__c> languageValuesMap = DealRegistration_CustomSetting__c.getAll(); 
        for(DealRegistration_CustomSetting__c language: languageValuesMap.values()){
            if(language!=null && language.LanguageCode__c != null){
                options.add(new SelectOption(language.LanguageCode__c,language.Language__c)); 
            }         
        }
        return options;
    }  
    
    /* @Method <getProductsDetails(): This property is used to add product available for selection in the UI.> 
       @param - <void>
       @return <List<SelectOption>> 
       @throws exception - <No Exception>
    */
    public List<ProductsDataContainer> getProductsDetails(){
        List<ProductsDataContainer> data = new List<ProductsDataContainer>();
        lstProductsDetails.clear();
        for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<lstFullProductsDetails.size();i++){
            lstProductsDetails.add(lstFullProductsDetails.get(i));
        }
        System.debug('Final ProductsDetailslstProductsDetails ------>'+ lstProductsDetails);
        System.debug('Final registrationProductsList-->'+lstRegistrationProduct.size());
        System.debug('Final objPageManager.startIndex ------>'+ objPageManager.startIndex);
        System.debug('Final objPageManager.endIndex ------>'+ objPageManager.endIndex);
        System.debug('Final lstFullProductsDetails-->'+lstFullProductsDetails.size());  
        return lstProductsDetails; 
    }
        
        /** This is our wrapper/container class.This wrapper clas contains both the object 
        Registration_Product__c and a Boolean value  */        
    public class ProductsDataContainer{
        public Partner_Tier_Mapping__c selProduct {get; set;}  
        public Boolean selected {get; set;}
        public ProductsDataContainer(Partner_Tier_Mapping__c regProd){  
            selProduct = regProd;  
            selected = false;  
        } 
    }

    /* @Method <changeLang(): This method is used to change the Language from UI.> 
       @param - <void>
       @return <PageReference> 
       @throws exception - <No Exception>
    */
    public PageReference redirectToPowerlink() {
        PageReference redirectTopowelink = null;
        if(!showDealRegForm && isExternalPortalSource){
            //redirectTopowelink = new PageReference(DealRegAccesibleLinkDetails);
            //redirectTopowelink = new PageReference('http://smeroom01.corp.emc.com');
            redirectTopowelink = new PageReference('/apex/PRM_DealReg_ReRoutePowerLink');
        }
        return redirectTopowelink;
    }
    
    /** CHANGES CUSTOM SEARCH -- START **/
       
    /* @Method <search(): This method is used  for Searching Accounts in the UI.> 
       @param - <void>
       @return <void>
       @throws exception - <No Exception>
    */
    
    public void search() {
    strQuery = 'Select id,name,type,BillingState,BillingPostalCode,NameLocal,Account_Status__c, ' ;
    strQuery =  strQuery +' Party_Number__c,Preferred_Install_Flag__c, Synergy_Account_Number__c, ' ;
    strQuery =  strQuery +' Child_Record_Count_Contact__c,Address__c,Address_Local__c ';
    strQuery =  strQuery + ' FROM Account WHERE IsPartner = FALSE  AND' ; 
    strQuery =  strQuery + ' Account_Status__c =:accountStatus  AND'  ;

    // Added for - WR#178765
    if(inputPartyNumber != Null && inputPartyNumber != ''){
       inputPartyNumber1 = inputPartyNumber  ;
       strQuery =  strQuery + ' (Party_Number__c like : inputPartyNumber1  OR Synergy_Account_Number__c like : inputPartyNumber1  ) AND ';
     }
    if(inputAccountName != Null && inputAccountName != ''){
       inputAccountName1 = inputAccountName  ;
       strQuery =  strQuery + ' name like : inputAccountName1  AND';
     }
     if(inputState != Null && inputState != ''){
        inputState1 = inputState  ;
        strQuery =  strQuery + ' BillingState like :inputState1 AND ' ;
     }
     if(inputZipCode != Null && inputZipCode !=''){
        inputZipCode1 = inputZipCode ;
        strQuery =  strQuery + ' BillingPostalCode like : inputZipCode1 AND ';
     }

     if(inputCountry != Null && inputCountry != ''){
        inputCountry1 = inputCountry  ;
        Map<String,CountryMapping__c> countryValueMap = CountryMapping__c.getAll();
        for(CountryMapping__c countryAccLead : countryValueMap.values()){
           if(inputCountry == countryAccLead.LeadCountry__c){
              inputCountry1 = countryAccLead.AccountCountry__c ; 
             }
           }//End of for loop.           
          system.debug('inputCountry1 ######### '+ inputCountry1);
          strQuery =  strQuery + '  BillingCountry  like : inputCountry1 AND ';
     }     
     /* if(leadRecord.Country__c != Null && leadRecord.Country__c != ''){
        inputCountry1 = leadRecord.Country__c  ;
        strQuery =  strQuery + '  BillingCountry  like : inputCountry1 AND ';
     } */
     
     if(inputCity != Null && inputCity !=''){
       inputCity1  =  inputCity  ;
       strQuery =  strQuery + ' BillingCity like :inputCity1 AND ';
     }
     if(inputStreet != Null && inputStreet != ''){
       inputStreet1 = inputStreet   ;
       strQuery =  strQuery + ' BillingStreet like :inputStreet1 AND ' ;
     }

   strQuery = strQuery.substring(0,strQuery.length()-4 );
   strQuery += '  LIMIT 100' ;
   system.debug('QUERY##### '+strQuery);
      
   try{  
       listAccount = Database.query(strQuery);
   }catch(QueryException qe){
     system.debug('Query Exception' + qe);
   }
 //  strQuery = '';

       objPageManagerAcc.page = 0;
       objPageManagerAcc.numberOfRows =0;
 
   if(listAccount == Null || listAccount.size()==0 ){
    strQuery = 'Select id,name,type,BillingState,BillingPostalCode,NameLocal,Account_Status__c,' ;
    strQuery =  strQuery +' Party_Number__c,Preferred_Install_Flag__c, Synergy_Account_Number__c, ' ;
    strQuery =  strQuery +' Child_Record_Count_Contact__c,Address__c,Address_Local__c ';
    strQuery =  strQuery + ' FROM Account WHERE IsPartner = FALSE  AND' ; 
    strQuery =  strQuery + ' Account_Status__c =:accountStatus  AND'  ;

    // Added for - WR#178765
    if(inputPartyNumber != Null && inputPartyNumber != ''){
           inputPartyNumber1 = inputPartyNumber  ;
           strQuery =  strQuery + ' (Party_Number__c like : inputPartyNumber1  OR Synergy_Account_Number__c like : inputPartyNumber1  ) AND ';
    }
    if(inputAccountName != Null && inputAccountName != ''){
       inputAccountName1 = inputAccountName  ;
       strQuery =  strQuery + ' NameLocal like : inputAccountName1  AND';
     }
     if(inputState != Null && inputState != ''){
        inputState1 = inputState  ;
        strQuery =  strQuery + ' State_Province_Local__c like :inputState1 AND ' ;
     }
     if(inputZipCode != Null && inputZipCode !=''){
        inputZipCode1 = inputZipCode ;
        strQuery =  strQuery + ' Zip_Postal_Code_Local__c like : inputZipCode1 AND ';
     }
     if(inputCountry != Null && inputCountry != ''){
        inputCountry1 = inputCountry  ;
        Map<String,CountryMapping__c> countryValueMap = CountryMapping__c.getAll();
        for(CountryMapping__c countryAccLead : countryValueMap.values()){
           if(inputCountry == countryAccLead.LeadCountry__c){
              inputCountry1 = countryAccLead.AccountCountry__c ; 
              }
             }//End of for loop.             
          system.debug('Local inputCountry1 ######### '+ inputCountry1);
         strQuery =  strQuery + '  Country_Local__c  like : inputCountry1 AND ';
     }     

     if(inputCity != Null && inputCity !=''){
       inputCity1  =  inputCity  ;
       strQuery =  strQuery + ' City_Local__c like :inputCity1 AND ';
     }
     if(inputStreet != Null && inputStreet != ''){
       inputStreet1 = inputStreet   ;
       strQuery =  strQuery + ' Street_Local__c like :inputStreet1 AND ' ;
     }
     
   strQuery = strQuery.substring(0,strQuery.length()-4 );
   strQuery += '  LIMIT 100' ;
   system.debug('QUERY##### '+strQuery);
      
       try{  
           listAccount = Database.query(strQuery);
       }catch(QueryException qe){
         system.debug('Query Exception' + qe);
        }
   } // END OF SEARCH - LOCAL FIELDS.
   
   if(listAccount == Null || listAccount.size()==0 ){
      noResult = TRUE ;
   }else{
     noResult = FALSE ;
     objPageManagerAcc.numberOfRows = listAccount.size() ;
   }
  } //END OD METHOD - search()
   
    /* @Method <clearresults(): This method is used  for clearing searchresults Accounts in the UI.> 
       @param - <void>
       @return <void>
       @throws exception - <No Exception>
    */
    public void clearresults(){
     listAccount = defaultlistAccount ;
     //return null ;
    }

  /* @Method <populateValues(): This method is used  for populating Account details on lead fields.> 
    @param - <void>
    @return <PageReference>
    @throws exception - <No Exception>
    */
   public PageReference populateValues(){
    PageReference pref;
  /*  Id accountId = '001900000041Goi' ;
    pref = new PageReference('/00390000002eceF/e?con4_lkid='+accountId+'-&nooverride=1&con4='+'testAccount'+'&cancelURL='+accountId );
   */
    if( selectedrecord != null && selectedrecord != '' ){
      paramvalue = selectedrecord ;
      system.debug('selectedrecord --'+ selectedrecord);
      accselected = [select id,name,type,BillingState,BillingPostalCode,BillingCity , NameLocal,
                               BillingStreet,BillingCountry,Party_Number__c,City_Local__c,Country_Local__c,
                               State_Province_Local__c,Zip_Postal_Code_Local__c,Street_Local__c,
                               Child_Record_Count_Contact__c,Address__c,Address_Local__c
                            FROM ACCOUNT WHERE id =: paramValue ] ;
      

      leadRecord.City       = accselected.BillingCity ;
      leadRecord.Country    = accselected.BillingCountry ;
      leadRecord.Street     = accselected.BillingStreet;
      leadRecord.State      = accselected.BillingState  ;    
      
      // Added for checking setting the local Address fields --IM7312572.               
        leadRecord.City_Local__c            = accselected.City_Local__c ;
        leadRecord.State_Province_Local__c  = accselected.State_Province_Local__c;
        leadRecord.Country_Local__c         = accselected.Country_Local__c ;
        leadRecord.Zip_Postal_Code_Local__c = accselected.Zip_Postal_Code_Local__c ;
        leadRecord.Street_Local__c          = accselected.Street_Local__c;
      
      leadRecord.DealReg_Related_Account_lookup__c = accselected.Name;
      leadRecord.Related_Account__c = accselected.id;
      leadrecord.Company = accselected.Name;
      leadrecord.Company_Local__c = accselected.NameLocal;
      selectedAccountAddress = accselected.Address__c;
      selectedAccountAddressLocal = accselected.Address_Local__c;
      leadrecord.companyLocal = accselected.NameLocal;
      
   // inputStreet='ANAND';
        
      system.debug('Lead populated values --- ' +leadRecord);
      system.debug('Account details'+ accselected);
     }
     return null;
   }

        /* @Method <populateAccountInfo(): This method is used  for populating Account address details 
                                                                                on lead fields.> 
           @param - <void>
           @return <void>
           @throws exception - <No Exception>
        */
    public pagereference populateAccountInfo() {
      system.debug('Inside PopualteAccountInfo');
      if(selectedStreet == '' || selectedStreet == Null ||selectedCity== '' || selectedCity== Null ||
         selectedCountry== '' || selectedCountry== Null ||selectedAccountName == '' || selectedAccountName ==Null ){
          showaddressmessage = TRUE ;
          system.debug('Inside address error message');
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.Populate_Address);
         ApexPages.AddMessage(msg);
         return null;
      }
      else{

        /** Setting the Custom Setting Value for Country on Lead **/ 
        Map<String,CountryMapping__c> countryValueMap = CountryMapping__c.getAll();
        for(CountryMapping__c countryAccLead : countryValueMap.values()){
           if(selectedCountry == countryAccLead.LeadCountry__c){
              selectedCountry = countryAccLead.AccountCountry__c ; 
           }
        }//End of for loop.              
                 
       leadRecord.Street  = selectedStreet;
       leadRecord.City    = selectedCity ;
       leadRecord.Country = selectedCountry   ;
       leadRecord.Country__c = selectedCountry;
       leadRecord.Company = selectedAccountName ;
       if(lang !='en_US'){
        leadRecord.Street_Local__c  = selectedStreet;
        leadRecord.City_Local__c    = selectedCity ;
        leadRecord.Country_Local__c = selectedCountry   ;
        leadRecord.Company_Local__c = selectedAccountName ;
       }
      }  
     
      if(selectedState != Null && selectedState !='') { 
         leadRecord.State = selectedState ;
         if(lang !='en_US'){
            leadRecord.State_Province_Local__c = selectedState ;
         }
      }
      if(selectedZipCode != Null && selectedZipCode !='' ) { 
         leadRecord.PostalCode = selectedZipCode   ;
         if(lang !='en_US'){
            leadRecord.Zip_Postal_Code_Local__c = selectedZipCode   ;           
         }
      } 
      leadRecord.DealReg_Related_Account_lookup__c ='';
      selectedAccountAddress = selectedStreet + ' <br/> ' + selectedCity ;
      if(selectedStreet !='' && selectedCity != ''){
        selectedAccountAddress = selectedAccountAddress + ' , ';
      } 
      selectedAccountAddress =  selectedAccountAddress  + selectedState + ' '  + selectedZipCode + ' <br/> ' + selectedCountry;
      selectedAccountAddressLocal = '';
      leadrecord.Company_Local__c = '';
      if(lang !='en_US'){
           selectedAccountAddressLocal = selectedAccountAddress   ; 
           leadrecord.Company_Local__c = selectedAccountName;           
      }
      
     
      system.debug('Lead details### ' + leadRecord);
      return null;
    }

   /* @Method <populateselectedrecord(): This method is used  for setting Accountid on the hiddenAccid  
           @param - <void>
           @return <void>
           @throws exception - <No Exception>
        */
   public void populateselectedrecord(){    
     system.debug('Inside populateselectedrecord -- paramValue ' + paramvalue); 
     if(paramvalue != Null){
        hiddenAccId = paramvalue ;
     }
     system.debug('selected hiddenAccId--' + hiddenAccId);
   }
    /* SORTING */  
  public void runSortAction1(){
   sortListAccounts(sortField1,sortAscending1 );
  }
  
   /* @Method <sortListAccounts(): This method is used  for displaying accounts in sorted order.  
           @param - <String,String>
           @return <void>
           @throws exception - <No Exception>
        */
  public void sortListAccounts(String strSortKey, boolean isASC){
     String sortQuery ;
     if(strquery != Null && strquery !=''){
        sortQuery =  strquery.substring(0,strQuery.length()-9 );
       if(isASC){
          sortQuery += '   ORDER BY ' + strSortKey + ' ASC ' + ' LIMIT 100  ';
       }else{
          sortQuery += '   ORDER BY ' + strSortKey + ' DESC ' + ' LIMIT 100 ';
       }   
       system.debug(sortQuery);    
       listAccount = Database.query(sortQuery);
     }   
   } // End - sortListAccounts.
   
    public List<SelectOption> getSearchCriteriaList() {     
         List<SelectOption> options2 = new List<SelectOption>();  
         options2.add(new SelectOption('','--None--'));       
      /* Map<String,CustomSettingCountryTheaterMapping__c> mapCountry = CustomSettingCountryTheaterMapping__c.getall();
         List<String> CountryList =new List<String>(mapCountry.keySet());
         CountryList.sort(); */
         Schema.DescribeFieldResult fieldResult = Lead.Country__c.getDescribe();
         List<Schema.PicklistEntry> CountryList = fieldResult.getPicklistValues();
         
         for(Schema.PicklistEntry f : CountryList){
            options2.add(new SelectOption(f.getValue(),f.getValue()));
           }    
         return options2;  
       }
       
    /* @Method <getAccountDetails(): This property is used to display available for selection in the UI.> 
       @param - <void>
       @return <List<Account> 
       @throws exception - <No Exception>
    */
    public List<Account> getAccountDetails(){
        lstAccountDetails.clear();
        for(integer i=objPageManagerAcc.startIndex;i<objPageManagerAcc.endIndex&&i<listAccount.size();i++){
            lstAccountDetails.add(listAccount.get(i));
        }
        System.debug('listAccount -->'+listAccount.size());
        System.debug('Final AccountSearch objPageManager.startIndex ------>'+ objPageManagerAcc.startIndex);
        System.debug('Final Accountsearch objPageManager.endIndex ------>'+ objPageManagerAcc.endIndex);
        System.debug('Final PageAccountDetails-->'+ lstAccountDetails.size());  
        return lstAccountDetails; 
    }    
}