/*================================================================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR                        DESCRIPTION 
 |  ====          =========               ==                        =========== 
 |  23 Nov 2012   Hemavathi N M         Account Presentation        This Class is used to search all the account who are custom profiled account        
 |  19 Mar 2013   Avinash K            Account Presentation         Updated the query of results to search on Account Name field as well 
+===========================================================================================================================================================*/
public with sharing class AP_ProfiledAccountSearch { 

   //public vairables     
    public String accountDropDown { get; set; }
    public String searchData{get;set;}
    public String sortField {get; set;}
    public boolean sortAscending {get; set;}
    public String Query {get; Set;}
    public String items;
    public String inputAccountName     {get;set;}
    public String paramValue           {get;set;}
    public Boolean noResult            {get;set;}
    public Boolean minChar             {get;set;}
    public String selectedrecord       {get;set;}
    public String hiddenAccId          {get;set;}
       
    public Id recordTypeId;

   //List Variables
   public list<selectoption>item{get;set;}
   public List<Account> listAccount   {get;set;}
   public List<Account> defaultlistAccount ; // used for clear result
   public List<Account> listAllAccount;
   
   // CustomSearch paging
    public List<Account> lstAccountDetails {get;set;}
    public PageManager objPageManagerAcc {get;set;}

   string stringQuery ;
   string inputAccountName1 ;
   

    
    //Default constructor
    public AP_ProfiledAccountSearch(ApexPages.StandardController controller){
  
      Integer pageSize = 50;
      //SelectionOption of Search criteria  
      item=new list<selectoption>();
      item.add(new selectoption('Contains','Contains'));
      item.add(new selectoption('StartsWith','Starts With'));
      item.add(new selectoption('EndsWith','Ends With'));
    
      /* CHANGES START FOR CUSTOM SEARCH*/
      objPageManagerAcc = new PageManager(pageSize);
      objPageManagerAcc.page = 0;
      objPageManagerAcc.numberOfRows =0;
      listAccount = new List<Account>();
      defaultlistAccount = listAccount ;
        
      lstAccountDetails = new List<Account>(); 
      listAllAccount = new list<Account>();
      //get parameter from account search sidebar details
      searchData= Apexpages.currentPage().getParameters().get('Name');
      System.debug('Selected Name is ++++++'+searchData);
      
      List<String> searchFullData;
      try{
       searchFullData = searchData.split('[\\s]+');
      }
      catch(Exception qe){
           system.debug('Exception Search All Account'+qe);
           }
      System.debug('searchFullData  ----------> '+searchFullData );
               
       // System.debug('searchData ----------> '+searchData );
      if(searchData != null)
        { 
          inputAccountName = searchData;
          String searchData1='';
          if(searchData.length()<2){
           ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Info,System.Label.AP_Minimum_Character);
           ApexPages.addMessage(errorMessage);
           noResult = False ;
           minChar = true;
          }
          else{
          
          try{
            
            //Code added by Avinash begins...

            Map<String,Schema.RecordTypeInfo> AccountRecTypeDetails = Schema.SObjectType.Account.getRecordTypeInfosByName();
            
            if(AccountRecTypeDetails != null && AccountRecTypeDetails.size() > 0 &&
                AccountRecTypeDetails.get('Customer Profiled Account Record Type') != null && 
                AccountRecTypeDetails.get('Customer Profiled Account Record Type').getRecordTypeId() != null)
            {
                recordTypeId = AccountRecTypeDetails.get('Customer Profiled Account Record Type').getRecordTypeId();
            }
                
//Code added by Avinash ends above

           if(searchFullData.size() >= 2 &&(searchFullData[1]!='' || searchFullData[1] != null)) {
          //  if(searchFullData[1].length()<2){
          System.debug('searchData @@@@@@>'+searchData );
            searchData = searchData;
           // }
           // else{
          //  searchData = searchFullData[0];
           // searchData1 = searchFullData[1];}
//The following query has been modified by Avinash
           listAllAccount = [Select Id, Name,BillingCountry,IsPartner, BillingCity ,MAP_Account_Name__c ,Core_Quota_Rep__r.Name,Core_Quota_Rep__c ,City_Local__c,Country_Local__c,Customer_Profiled_Account__c,Account_District__c FROM Account Where RecordTypeId = :recordTypeId AND IsPartner=false AND (MAP_Account_Name__c Like : + '%' + searchData + '%' OR 
            Name Like : + '%' + searchData + '%') Limit 51];
           }
           else
           {
           if(!(searchFullData.size() >= 2 &&(searchFullData[1]!='' || searchFullData[1] != null)))
           searchData = searchFullData[0];

//The following query has been modified by Avinash
           listAllAccount = [Select Id, Name,BillingCountry,IsPartner, BillingCity ,MAP_Account_Name__c ,Core_Quota_Rep__r.Name,Core_Quota_Rep__c ,City_Local__c,Country_Local__c,Customer_Profiled_Account__c,Account_District__c FROM Account Where RecordTypeId = :recordTypeId AND IsPartner=false AND (MAP_Account_Name__c Like : + '%' + searchData + '%' OR 
            Name Like : + '%' + searchData + '%') Limit 51];

           }
          //  listAllAccount = [Select Id, Name,BillingCountry,IsPartner, BillingCity ,MAP_Account_Name__c ,Core_Quota_Rep__r.Name,Core_Quota_Rep__c ,City_Local__c,Country_Local__c,Customer_Profiled_Account__c,Account_District__c FROM Account Where Customer_Profiled_Account__c = true AND IsPartner=false AND ((MAP_Account_Name__c Like : + '%' + String.escapeSingleQuotes(searchData) + '%') OR (MAP_Account_Name__c Like : + '%' + String.escapeSingleQuotes(searchData1) + '%'))Limit 51]; 
            System.debug('@@@@@@listAllAccount----->'+listAllAccount.size());         
           }catch(QueryException qe){
           system.debug('Query Exception Search All Account' + qe);
           }
         
      
        //Result of Search All Account from sidebar
        if(listAllAccount == Null || listAllAccount.size()==0 ){
            noResult = TRUE ;
           }else{
            noResult = FALSE ;
            objPageManagerAcc.numberOfRows = listAllAccount.size() ;
            
      if(listAllAccount.size()>0 && searchData != null){
        listAccount = listAllAccount;
        System.debug('listAccount------->' + listAccount);
        
       if(listAccount.size()>=51 ){
           ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Info, System.Label.AP_SearchResultExceed);
           ApexPages.addMessage(errorMessage);
           }//END IF size>50
          }
         }
        }
      }//END IF  
     
    /* CHANGES END FOR CUSTOM SEARCH*/                          
    }//END Method - Controller
     
           
// @Method <search(): This method is used  for Searching Accounts in the UI based on filter.> 
  public void filterAccountSearch() {
  minChar= false;
    stringQuery = 'Select id,name,Account_District__c,Core_Quota_Rep__r.Name,Core_Quota_Rep__c , ' ;
    stringQuery =  stringQuery +' City_Local__c,MAP_Account_Name__c,BillingCountry, BillingCity,Country_Local__c,Customer_Profiled_Account__c ' ;
    stringQuery =  stringQuery + ' FROM Account WHERE IsPartner=false AND RecordTypeId = :recordTypeId  ' ; 
    
    if(inputAccountName.length()<2 ){
         ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Info,System.Label.AP_Minimum_Character);
         ApexPages.addMessage(errorMessage);
         noResult = False ;
         minChar = true;
         }
    else{
    if(inputAccountName != '' && inputAccountName != null){
       inputAccountName1 = inputAccountName  ;
      List<String> searchFullData;
      try{
       searchFullData = inputAccountName1.split('[\\s]+');
       System.debug('SearchFullData@@@@@@@@>'+searchFullData );
      }
      catch(Exception qe){
           system.debug('Query Exception Search All Account'+qe);
           }
        
       
       if(accountDropDown == System.Label.AP_Contains){
        String inputAccountName2='';
        if(searchFullData.size() >= 2 &&(searchFullData[1]!='' || searchFullData[1] != null)) {
            
            if(searchFullData[1].length()<2){
            inputAccountName1 = inputAccountName;}
            else{
            inputAccountName1 =inputAccountName1;}
           // inputAccountName1 = searchFullData[0];
           // inputAccountName2 = searchFullData[1];}
           
           // stringQuery =  stringQuery + ' (( MAP_Account_Name__c like  \'%'+String.escapeSingleQuotes(inputAccountName1)+'%\') OR ( MAP_Account_Name__c like  \'%'+String.escapeSingleQuotes(inputAccountName2)+'%\') )';
           stringQuery =  stringQuery + ' and (MAP_Account_Name__c like  \'%'+inputAccountName1+'%\' OR Name like  \'%'+inputAccountName1+'%\')';
          
           }
           else{
           inputAccountName1 = searchFullData[0];
                 
           stringQuery =  stringQuery + ' and (MAP_Account_Name__c like  \'%'+inputAccountName1+'%\' OR Name like  \'%'+inputAccountName1+'%\')';
           }
       }
       if(!(searchFullData.size() >= 2 &&(searchFullData[1]!='' || searchFullData[1] != null))) {
        inputAccountName1=searchFullData[0];
//        System.debug('inputAccountName1@@@@@@@@@@@>'+inputAccountName1);
        
       }
       if(accountDropDown == System.Label.AP_StartsWith){
       stringQuery =  stringQuery + ' and (MAP_Account_Name__c like \''+inputAccountName1+'%\' OR Name like  \''+inputAccountName1+'%\')';
                      //stringQuery + ' and MAP_Account_Name__c like\''+ inputAccountName1+'%\'';
       }
       if(accountDropDown == System.Label.AP_EndsWith){
       System.debug('@@@@@@inputAccountName1@@@@@@'+inputAccountName1);
         stringQuery =  stringQuery + ' and (MAP_Account_Name__c like  \'%'+inputAccountName1+'\' OR Name like  \'%'+inputAccountName1+'\')';
                        //stringQuery + 'and MAP_Account_Name__c like \'%'+inputAccountName1+'\'';
       }
     
      // stringQuery = stringQuery.substring(0,stringQuery.length()-4 );
      stringQuery += '  LIMIT 51' ;
      system.debug('QUERY##### '+stringQuery);
    try{  
        listAccount = Database.query(stringQuery);
        //    System.debug('listAccount after insert---->' + listAccount);
       }catch(QueryException qe){
        system.debug('Query Exception' + qe);
       }
    if(listAccount.size()>=51 ){
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Info, System.Label.AP_SearchResultExceed);
        ApexPages.addMessage(errorMessage);
       }
     
    }//END IF - inputAccountName
   
    objPageManagerAcc.page = 0;
    objPageManagerAcc.numberOfRows =0;
    System.debug('listAccount------->' + listAccount);
  if(listAccount == Null || listAccount.size()==0 ){
      noResult = TRUE ;
    }else{
       noResult = FALSE ;
       objPageManagerAcc.numberOfRows = listAccount.size() ;
     }
    }
   
  } //END  METHOD FilterAccountSearch 
   

// @Method <clearresults(): This method is used  for clearing searchresults Accounts in the UI.> 
  public void clearresults(){
     listAccount = defaultlistAccount ;
    }

// @Method <populateselectedrecord(): This method is used  for setting Accountid on the hiddenAccid  
 public PageReference populateselectedrecord(){    
     system.debug('Inside populateselectedrecord -- paramValue ' + paramvalue); 
     if(paramvalue != Null){
        hiddenAccId = paramvalue ;
       }
         //    system.debug('selected hiddenAccId--' + hiddenAccId);
    //To Redirect to selected account      
     PageReference redirect = new PageReference('/' + hiddenAccId);
        // pass the selected asset ID to the new page
    // redirect.getParameters().put('id',hiddenAccId); 
    redirect.setRedirect(true); 
     
    return redirect;
  }//END Method - populateselectedrecord
 
// @Method <getAccountDetails(): This property is used to display available for selection in the UI.> 
       
    public List<Account> getProfileAccountDetails(){
        lstAccountDetails.clear();
        System.debug('listAccount---->' + listAccount);
        if(listAccount.size()>0){
            for(integer i=objPageManagerAcc.startIndex;i<objPageManagerAcc.endIndex&&i<listAccount.size();i++){
            lstAccountDetails.add(listAccount.get(i));
        }
        }
        return lstAccountDetails; 
    }//END Method - getprofileAccountDetails    
}//END Class