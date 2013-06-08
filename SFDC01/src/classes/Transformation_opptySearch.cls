/*======================================================================================================================
 |  HISTORY 
 |  DATE            DEVELOPER         WR/Req      DESCRIPTION 
 |  2/11/2013       Medhavi D.                     This Page will allow to search oppty by number
 
 ========================================================================================================================*/
public with sharing class Transformation_opptySearch { 
    //public vairables     
    public Lead leadRecord{get; set;}       
    public Id productId {get; set;}
    public String sortField {get; set;}
    public boolean sortAscending {get; set;}
    public String Query {get; Set;}
    
    
    public String searchProduct {get; set;}
    public String searchProductCatalog {get;set;}
    public set<String> setProductNames{get; set;}  
    public set<Id> existingProducts{get; set;}   
    public String productName {get; set;}
    public boolean isExternalPortalSource {get; set;}   
    public boolean isPartnerPortalUser {get; set;} 
    public String items;
    public String lang { get; set; }
    public string frmId{get;set;}
    public string cntId{get;set;}
    public string lktp{get;set;}
    public string lksrch{get;set;}
public string strOpp {get;set;}
    Account objRelatedAccount = new Account();
    public ID profileAccountId;
    // paging
    public PageManager objPageManager {get;set;}

    /** CUSTOM SEARCH LOOKUP CONTLR FIELDS**/      
    public List<Opportunity> listOppty   {get;set;}
    public String inputvalue           {get;set;}
    public String inputOpptyName     {get;set;}
    public String inputOpptyNumber          {get;set;}
   
    public String paramValue           {get;set;}
    public Boolean noResult            {get;set;}
    public Boolean noCriteria            {get;set;}
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
    
    public List<Opportunity> defaultlistOppty ; 
    Id leadid;
    string strQuery ;
    string inputOpptyName1='';
    String inputOpptyNumber1='' ;
    
    String accountStatus = 'Active';


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
    public PageManager objPageManagerAcc {get;set;}
    public List<Opportunity> lstOpptyDetails     {get;set;}

    /** CUSTOM SEARCH LOOKUP CONTLR FIELDS --- END**/ 
 
    //default constructor
    public Transformation_opptySearch(ApexPages.StandardController controller){
      
       
       frmId=System.currentPageReference().getParameters().get('lkfm');
       cntId=System.currentPageReference().getParameters().get('lknm');
       lktp='006';
       lksrch=System.currentPageReference().getParameters().get('lksrch');
        strOpp = System.currentPageReference().getParameters().get('oid');
        system.debug('strOpp--->'+strOpp);
        Integer pageSize = 25;        
                
        //initialize variables
        searchProduct = '';
        searchProductCatalog ='';
        inputOpptyName ='';
        inputOpptyNumber='';    
        objPageManager = new PageManager(pageSize); 
        objPageManagerAcc = new PageManager(pageSize);
        lstOpptyDetails = new List<Opportunity>();  
        listOppty = new List<Opportunity>();
        System.debug('lksrch---->'+lksrch);
        if(lksrch != ''){
           inputOpptyName =lksrch;
           search();
       }
       else{
       try{
        listOppty=[Select Account.name,Id, StageName,Opportunity_Closed_Date__c , Opportunity_Number__c,Name, BRS_Total_Forecast_Amount__c,Quote_Amount__c FROM Opportunity WHERE StageName NOT IN('Eval','Submitted','Won','Booked','Closed') limit 50];
            System.debug('listOppty1-->'+listOppty.size());
   }catch(QueryException qe){
     system.debug('Query Exception' + qe);
   }
       
       }

   }
  
    /** CHANGES CUSTOM SEARCH -- START **/
       
    /* @Method <search(): This method is used  for Searching Accounts in the UI.> 
       @param - <void>
       @return <void>
       @throws exception - <No Exception>
    */
    
    public void search() {
    getFormTag();
    getControlTag();  
    system.debug('cntId--->'+cntId+'<--->'+frmId); 
    string stageStatus='Closed';
    string stageBooked='Booked';
    string stageEval='Eval';
    string stageSubmitted='Submitted';
    string stageWon='Won';
    
    strQuery = 'Select Account.name,Id, StageName, ' ;
    strQuery =  strQuery +' Opportunity_Closed_Date__c , Opportunity_Number__c, ' ;
    strQuery =  strQuery +'  Name, BRS_Total_Forecast_Amount__c,Quote_Amount__c ';
    //strQuery =  strQuery + ' FROM Opportunity WHERE (StageName !=: stageStatus or StageName !=: stageBooked or StageName !=: stageEval or StageName !=: stageSubmitted  or StageName !=: stageWon)' ; 
    strQuery =  strQuery + ' FROM Opportunity WHERE (StageName !=: stageStatus and StageName !=: stageBooked and StageName !=: stageEval and StageName !=: stageSubmitted and StageName !=: stageWon)' ; 
    noCriteria =false;
   
   if(inputOpptyName.length() == 0 && inputOpptyNumber.length()==0){
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.Label.Transformation_Search_Criteria));
     noCriteria = True;
     noResult = True;
   }
   if(!noCriteria){
  /*
     
    if(inputOpptyName != Null && inputOpptyName != ''){
    
     noResult =false;
    
       inputOpptyName1 = inputOpptyName  ;
     //  strQuery =  strQuery + ' AND Name like: inputOpptyName1';
     strQuery =  strQuery + ' AND Name Like \'%'+inputOpptyName1 +'%\''; 
     }
     if(inputOpptyNumber != Null && inputOpptyNumber != ''){
      noResult =false;
    
        inputOpptyNumber1 = inputOpptyNumber  ;
//        strQuery =  strQuery + ' AND Opportunity_Number__c like : inputOpptyNumber1 ' ;
strQuery =  strQuery + '  AND Opportunity_Number__c Like \'%'+inputOpptyNumber1 +'%\''; 
     } */
     noResult = false;
    // if(inputOpptyName.length() != 0 && inputOpptyNumber.length() != 0){
     if(inputOpptyName.length() != 0 && (inputOpptyNumber != '' && inputOpptyNumber != null)){
      System.debug('Both the value not equal to null');
     if(inputOpptyName.length()>2 && inputOpptyNumber.length() > 2){
        inputOpptyName1 = inputOpptyName  ;
        strQuery =  strQuery + ' AND Name Like \'%'+inputOpptyName1 +'%\''; 
        inputOpptyNumber1 = inputOpptyNumber  ;
        strQuery =  strQuery + '  AND Opportunity_Number__c Like \'%'+inputOpptyNumber1 +'%\''; 
      }
      else if(inputOpptyName.length()>2){
           inputOpptyName1 = inputOpptyName  ;
           strQuery =  strQuery + ' AND Name Like \'%'+inputOpptyName1 +'%\''; 
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,System.label.Transformation_Search_Result_Based_Name));
           }
     else if( inputOpptyNumber.length() >  2){
        inputOpptyNumber1 = inputOpptyNumber  ;
        strQuery =  strQuery + '  AND Opportunity_Number__c Like \'%'+inputOpptyNumber1 +'%\''; 
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,System.label.Transformation_Search_Result_Based_Number));}
      else{
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.Label.Transformation_Search_Result_Error));
      noCriteria = true;
         noResult = True;
      }
     }
     
     if(inputOpptyName != '' && inputOpptyNumber == ''){
     System.debug('Name value not equal to null');
     
     if(inputOpptyName.length()>2){
           inputOpptyName1 = inputOpptyName  ;
           strQuery =  strQuery + ' AND Name Like \'%'+inputOpptyName1 +'%\''; }
     else{
     System.debug('else name----');
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.Label.Transformation_Search_oppty_Name));
         noCriteria = true;
         noResult = True;
     }
     }
    if(inputOpptyName == '' && inputOpptyNumber != ''){
    System.debug('Number value not equal to null');
    if( inputOpptyNumber.length() > 2){
        inputOpptyNumber1 = inputOpptyNumber  ;
        strQuery =  strQuery + '  AND Opportunity_Number__c Like \'%'+inputOpptyNumber1 +'%\''; }
    else{
 
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.Label.Transformation_Search_oppty_Number));
     noCriteria = true;
     noResult = True;
    }
    }

 if(!noResult){
   strQuery += '  LIMIT 100' ;
   system.debug('QUERY##### '+strQuery);
      
   try{
        listOppty.Clear();   
       listOppty = Database.query(strQuery);
       System.debug('listOppty-->'+listOppty.size());
   }catch(QueryException qe){
     system.debug('Query Exception' + qe);
   }
 
       objPageManagerAcc.page = 0;
       objPageManagerAcc.numberOfRows =0;
 
 /*  if(listOppty == Null || listOppty.size()==0 ){
     strQuery = 'Select Account.name,Id, StageName, ' ;
    strQuery =  strQuery +' Opportunity_Closed_Date__c , Opportunity_Number__c, ' ;
    strQuery =  strQuery +' Name, BRS_Total_Forecast_Amount__c,Quote_Amount__c ';
//    strQuery =  strQuery + ' FROM Opportunity WHERE StageName !=: stageStatus or StageName !=: stageBooked or StageName !=: stageEval or StageName !=: stageSubmitted  or StageName !=: stageWon' ; 
strQuery =  strQuery + ' FROM Opportunity WHERE (StageName !=: stageStatus and StageName !=: stageBooked and StageName !=: stageEval and StageName !=: stageSubmitted and StageName !=: stageWon)' ; 
   
    if(inputOpptyName != Null && inputOpptyName != ''){
       inputOpptyName1 = inputOpptyName  ;
       strQuery =  strQuery + ' and NameLocal like : inputOpptyName1 ';
    //  strQuery =  strQuery + ' AND Name Like \'%'+inputOpptyName1 +'%\'';
     }
     if(inputOpptyNumber != Null && inputOpptyNumber != ''){
        inputOpptyNumber1 = inputOpptyNumber  ;
     //   strQuery =  strQuery + ' AND Opportunity_Number__c like : inputOpptyNumber1  ' ;
     strQuery =  strQuery + '  AND Opportunity_Number__c Like \'%'+inputOpptyNumber1 +'%\'';
     }
    

   strQuery += '  LIMIT 100' ;
   system.debug('QUERY##### '+strQuery);
      
       try{  
           listOppty = Database.query(strQuery);
       }catch(QueryException qe){
         system.debug('Query Exception' + qe);
        }
   } // END OF SEARCH - LOCAL FIELDS.
   */
   if(listOppty == Null || listOppty.size()==0 ){
      noResult = TRUE ;
      noCriteria = false;
    
   }else{
     noResult = FALSE ;
     objPageManagerAcc.numberOfRows = listOppty.size() ;
   }
   }//No Criteria
   }//No Result
  } //END OD METHOD - search()
   
    /* @Method <clearresults(): This method is used  for clearing searchresults Accounts in the UI.> 
       @param - <void>
       @return <void>
       @throws exception - <No Exception>
    */
    public void clearresults(){
       defaultlistOppty = lstOpptyDetails;
     listOppty = defaultlistOppty ;
     //return null ;
    }

 
/* @Method <getAccountDetails(): This property is used to display available for selection in the UI.> 
       @param - <void>
       @return <List<Account> 
       @throws exception - <No Exception>
    */
    public List<Opportunity> getOpptyDetails(){
        lstOpptyDetails.clear();
        objPageManagerAcc.page = 0;
        objPageManagerAcc.numberOfRows =listOppty.size();
        System.debug('listOppty@@@@@'+listOppty);
        if(listOppty.size() > 0){
        System.debug('size of list---->'+ listOppty.size());
        for(integer i=objPageManagerAcc.startIndex;i<objPageManagerAcc.endIndex&&i<listOppty.size();i++){
            lstOpptyDetails.add(listOppty.get(i));
      }  
     }
     system.debug('lstOpptyDetails---->'+lstOpptyDetails.size());
       return lstOpptyDetails; 
      }
   public string getFormTag() {
    return System.currentPageReference().getParameters().get('lkfm');
  }
   public string getControlTag() {
    return System.currentPageReference().getParameters().get('lknm');
  }
  public PageReference cancelLink() {
  if(strOpp != null){
        return new PageReference('/'+strOpp);
  }
  else{
  return new PageReference('/'+'a3P/e?retURL=%2Fa3P%2Fo');
}
}
}