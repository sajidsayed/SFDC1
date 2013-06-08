/*================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR        DESCRIPTION                               

|  ====          =========                ==        =========== 

| 12/09/2011     Anil Sure              #3656       This class is used to provide 
                                                    the ability to Search Deal Registration Records for
                                                    users based on the given search criteria.
| 21/12/2012	 Anil Sure							no viable alternative at character '%'  Issue
======================================================================================================*/
public with sharing class PRM_DealLeadSearchController {
public Lead leads{get;set;}
 public String Country{get;set;}
 public String Status{get;set;}
 public String OppNumber{get;set;}
 public String DealRegNumber{get;set;}
 public DateTime expdate;
 public DateTime Subdate;
 public DateTime appdate;
 public DateTime Accdate;
 public String ExpFromDate;
 public String ExpToDate;
 public String SubFromDate;
 public String SubToDate;
 public Boolean isAll;
 public String searchCriteria;
 public String DiReseller;
 public String DistVAR;
 public String RAccount;
 public String Downer;
 //Used to store the picklist values.
 List<SelectOption> CountryList;
 List<SelectOption> StatusList;
 String SubQuery; 
//Sorting 
public string sortField1 {get;set;}
public Boolean sortAscending1 {get;set;}
public string defaultsortQuery  {get;set;} 
public List<Lead> LeadList = new List<Lead>();
Contact contacts=new Contact();
//paging
public PageManager objPageManager {get;set;}   
public Integer pageSize;
public List<Lead> lstLeadDetails{get;set;}
public List<Lead> lstLead1Details{get;set;}

    public PRM_DealLeadSearchController(ApexPages.StandardController controller) {                
        this.leads=new Lead();
        searchcriteria='';
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c pageDetails = DataValueMap.get('PageSize');
         pageSize = 25;        
        try
        {            
            pageSize  = Integer.valueOf(pageDetails.DataValue__c);
        }
        catch(Exception e)
        {
            pageSize = 25;
        }
        searchCriteria = ApexPages.currentPage().getParameters().get('sbstr');
              
        System.Debug('SearchCriteria--->' +searchCriteria);
        }   
 /*@Method <This method openLink is used to link the related DealReg Account with related LeadID>
   @param <This method not taking any arguements>
   @return <Page Reference> - <returning new page reference>
   @throws exception - <No Exception>
*/ 
    public  PageReference openLink() {
        
        Id LeadId = ApexPages.currentPage().getParameters().get('LId');
        
        PageReference objPage;
        objPage = new PageReference('/'+ LeadId+ '?');
        String returnURL = '/apex/PRM_DealLeadDetailPage';
        objPage.getParameters().put('retURL', EncodingUtil.urlEncode(returnURL,'UTF-8'));
        
        System.debug('LeadId'+LeadId);       
        //return new PageReference ('/'+LeadId+'?retURL= /apex/PRM_DealLeadDetailPage');
        objPage.setRedirect(true);
        return objPage;
    }
    
 public  PageReference BackPage() {
  
        return Page.PRM_DealLeadSearch;
    }
      
 /* @Method <This method IsSearch is used to check 
     wether the user has entered all the search Fields>
   @param <This method not taking any arguements>
   @return <Page Reference> - <returning new Boolean Variable>
   @throws exception - <No Exception>
*/    
    public boolean isSearch() {
        system.debug(OppNumber);
            if(OppNumber=='' && DealRegNumber=='' && leads.DealReg_Expiration_Date__c==null && leads.DealReg_Expected_Close_Date__c==null && leads.Contract_End_Date__c==null && leads.DealReg_Partner_Expected_Close_Date__c==null && leads.Tier_2_Partner__c==null && leads.DealReg_Related_Account_lookup__c==null && leads.DealReg_Deal_Submitter_Contact__c==null && leads.Partner__c==null && Country=='--None--' && Status=='--None--')
            {      
                isAll = true;
                System.debug('isAll===========>>>'+isAll);               
            }
            else
            {
                isAll=false;
            }
             return isAll;
          }
 
  
 /* @Method <This method SearchResults is used to send the Search Params 
    to VF Page and to Query the results based on the Search Criteria>
   @param <This method not taking any arguements>
   @return <Page Reference> - <returning new page reference>
   @throws exception - <No Exception>
 */
    public  PageReference SearchResults() {
        
        ExpFromDate='';
        ExpToDate='';
        SubFromDate='';
        SubToDate='';
        Downer=leads.DealReg_Deal_Submitter_Contact__c;
        RAccount=leads.DealReg_Related_Account_lookup__c;
        DiReseller=leads.Partner__c;
        DistVAR=leads.Tier_2_Partner__c;
        sortAscending1 = TRUE;
        //paging variables 
         objPageManager = new PageManager(pageSize);               
         objPageManager.page = 0;
         objPageManager.numberOfRows =0;
         lstLead1Details = new List<Lead>();
         
         searchCriteria ='';
         
        SubQuery = 'Select FirstName, LastName, Title,Name,Owner.alias,' 
                                +'Phone,Company,Status,Lead_Number__c,' 
                                +'DealReg_Deal_Registration__c,DealReg_Deal_Registration_Status__c,'
                                +'Campaign_Event_Name__c ' 
                                +'from Lead where DealReg_Deal_Registration__c=True AND'; 
         
            if(Downer!=null)            
            {                                                      
            String SubQuery2= 'select Id,Name from contact where Id =: Downer ';
            contacts = Database.query(SubQuery2); 
            }   
            if (isSearch())
            {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Info, System.Label.Lead_Search_Error);
                ApexPages.addMessage(errorMessage);
                return null;                
            }
            else
            {                 
            if(OppNumber!='' && DealRegNumber!=''){
                SubQuery=SubQuery+' (Synergy_Opportunity_Number_1__c=:OppNumber OR DealReg_Deal_Registration_Number__c=:DealRegNumber) AND';
             }       
            if(OppNumber!='' && DealRegNumber==''){
                SubQuery=SubQuery+' Synergy_Opportunity_Number_1__c=:OppNumber AND';            
            }
            if(OppNumber=='' && DealRegNumber!=''){
                SubQuery=SubQuery+' DealReg_Deal_Registration_Number__c=:DealRegNumber AND';            
            }
            if(leads.DealReg_Expiration_Date__c!=null)
            {
                DateTime expdate=leads.DealReg_Expiration_Date__c;
                ExpFromDate = String.valueOfGmt(expdate);
                ExpFromDate = ExpFromDate.substring(0,ExpFromDate.length()-8);            
                System.debug(ExpFromDate);
                SubQuery=SubQuery+' DealReg_Expiration_Date__c>='+ExpFromDate+' AND';               
            }    
            if(leads.DealReg_Expected_Close_Date__c!=null)
            {
                DateTime Subdate=leads.DealReg_Expected_Close_Date__c;
                ExpToDate = String.valueOfGmt(Subdate);
                //Convert DateTime to Date                 
                ExpToDate = ExpToDate.substring(0,ExpToDate.length()-8);            
                System.debug(ExpToDate);
                SubQuery=SubQuery+' DealReg_Expiration_Date__c<='+ExpToDate+' AND';
             }
            if(leads.Contract_End_Date__c!=null)
            {
                //Convert Date Format to DateTime Format
                DateTime appdate=leads.Contract_End_Date__c;
                SubFromDate = String.valueOfGmt(appdate);                 
                SubFromDate = SubFromDate.replace(' ', 'T');
                SubFromDate = SubFromDate +'.000Z';                            
                System.debug(SubFromDate);
                SubQuery=SubQuery+' DealReg_Submission_Date__c>='+SubFromDate+' AND';                
            }    
            if(leads.DealReg_Partner_Expected_Close_Date__c!=null)
            {
               //Convert Date Format to DateTime Format
                DateTime Accdate=leads.DealReg_Partner_Expected_Close_Date__c;
                SubToDate = String.valueOfGmt(Accdate);                 
                SubToDate = SubToDate.replace(' ', 'T');
                SubToDate = SubToDate +'.000Z';                            
                System.debug(SubToDate);
                SubQuery=SubQuery+' DealReg_Submission_Date__c<='+SubToDate+' AND';
             }           
            if(DistVAR!=null)
            {                
                SubQuery=SubQuery+' Tier_2_Partner__c=:DistVAR AND';
            }            
            if(RAccount!=null)
            {                
                SubQuery=SubQuery+' (Company like \'%'+String.escapeSingleQuotes(RAccount)+'%\'OR CompanyLocal like \'%'+String.escapeSingleQuotes(RAccount)+'%\') AND';
            }           
            if(Downer!=null)
            {
                            
                SubQuery=SubQuery+' (DealReg_Deal_Submitter_Contact__c=\''+contacts.Id+'\' OR DealReg_Deal_Submitter_Name__c like \'%'+String.escapeSingleQuotes(contacts.Name)+'%\' OR CreatedBy.Name like \'%'+String.escapeSingleQuotes(contacts.Name)+'%\') AND';
            }           
            if(DiReseller!=null)
            {
                SubQuery=SubQuery+' Partner__c=:DiReseller AND';
            }           
            if(Country!='--None--')
            {
             SubQuery=SubQuery+' Country__c=:Country AND';
            }
            if(Status!='--None--')
            {
             SubQuery=SubQuery+' DealReg_Deal_Registration_Status__c=:Status AND';
            }
            //Trimming AND from the Query
            SubQuery = SubQuery.substring(0,SubQuery.length()-4 );
            //Appending Result size as LIMIT 1500
            SubQuery += ' LIMIT 1500' ;
            system.debug('QUERY##### '+SubQuery);        
  
            LeadList = Database.query(SubQuery);
            
            if(LeadList.size()<=0)
            {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.No_Results);
                ApexPages.addMessage(errorMessage);
            }
            objPageManager.numberOfRows = LeadList.size();
            
            PageReference objDetailPage;
            objDetailPage = new PageReference('/apex/PRM_DealLeadDetailPage'); 
            String returnURL = '/apex/PRM_DealLeadSearch';
            objDetailPage.getParameters().put('retURL', EncodingUtil.urlEncode(returnURL,'UTF-8'));
        
            //objDetailPage.setRedirect(true);
            return objDetailPage;         
            //return Page.PRM_DealLeadDetailPage;
           }
           
    }

/*  @Method <This method getCountryList used to get the picklist values
          from the Lead via metadata for the field Country>
    @param <This method does not take any parameters>
    @return <SelectOption> - <selected picklist values from Country>
    @throws exception - <No Exception>
*/
    public List<SelectOption> getCountryList(){
        if(CountryList == null){
            CountryList = new List<SelectOption>();
            CountryList.add(new SelectOption('--None--','--None--'));
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.lead.fields.Country__c;
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    CountryList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return CountryList;
    }
/*  @Method <This method getStatusList used to get the picklist values
            from the Lead via metadata for the field Deal Reg Status>
    @param <This method does not take any parameters>
    @return <SelectOption> - <selected picklist values from Status>
    @throws exception - <No Exception>
*/
    public List<SelectOption> getStatusList(){
        if(StatusList == null){            
            StatusList = new List<SelectOption>();
            StatusList.add(new SelectOption('--None--','--None--'));
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.lead.fields.DealReg_Deal_Registration_Status__c;
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    StatusList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return StatusList;
    }
/* @Method <This method setLeadList is setter method used to set the list of the Leads.>
   @param <This method is taking List<Lead> which contains list of Lead>
   @return <void> - <not returning anything>
   @throws exception - <No Exception>
*/
    
    public void setLeadList(List<Lead> LeadList){
        System.debug('LeadList===>'+LeadList);
        this.LeadList = LeadList;
    }
    
 /*@Method <This method getLeadList is a getter method to get the list of recrods from the Leads>
   @param <This method is not taking any arguments>
   @return <List<Lead>> - <Contains list of objective records>
   @throws exception - <No Exception>
*/

    public List<Lead> getLeadList(){
        System.debug('LeadList===>'+LeadList);
        return LeadList;
    }
    
   /* SORTING */  
  public void runSortAction1(){
   sortListLeads(sortField1,sortAscending1 );
  }
  
   /* @Method <sortListLeads(): This method is used  for displaying accounts in sorted order.  
      @param - <String,String>
      @return <void>
      @throws exception - <No Exception>
   */
  public void sortListLeads(String strSortKey, boolean isASC){
     String sortQuery ;
     System.debug('SubQuery'+SubQuery);
     if(SubQuery != Null && SubQuery !=''){
        sortQuery =  SubQuery.substring(0,SubQuery.length()-10 );
        sortQuery = SortQuery;
        System.debug('sortQuery'+sortQuery);
        if(isASC){
           sortQuery += '   ORDER BY ' + strSortKey + ' ASC ' + ' LIMIT 100  ';
           System.debug('ASCsortQuery'+sortQuery);
        }else{
           sortQuery += '   ORDER BY ' + strSortKey + ' DESC ' + ' LIMIT 100 ';
           System.debug('DESCsortQuery'+sortQuery);
        }   
         system.debug(sortQuery);    
       LeadList = Database.query(sortQuery);
     }
   } // End - sortListLeads.
   
  /*   @Method <ComponentSearch(): This method is used to search the lead details from Custom component.> 
       @param - <void>
       @return null 
       @throws exception - <No Exception>
  */
 public  PageReference ComponentSearch() {
    lstLead1Details = new List<Lead>();
    objPageManager = new PageManager(pageSize);               
    objPageManager.page = 0;
    objPageManager.numberOfRows =0;    
    System.Debug('ValueofSearchCriteria-->' +searchCriteria);       
    if(searchCriteria!=''){
    SubQuery = 'Select FirstName, LastName, Title,Name,Owner.alias,' 
                                +'Phone,Company,Status,Lead_Number__c,' 
                                +'DealReg_Deal_Registration__c,DealReg_Deal_Registration_Status__c,'
                                +'Campaign_Event_Name__c ' 
                                +'from Lead where DealReg_Deal_Registration__c=True AND';
    SubQuery=SubQuery+' (Name like \'%'+searchCriteria+'%\'OR DealReg_Deal_Registration_Number__c like \'%'+ searchCriteria + '%\') AND';
             
      //Trimming AND from the Query
            SubQuery = SubQuery.substring(0,SubQuery.length()-4 );
            //Appending Result size as LIMIT 1500
            SubQuery += ' LIMIT 1500' ;
            system.debug('QUERY2##### '+SubQuery);        

            LeadList = Database.query(SubQuery);
            
            if(LeadList.size()<=0)
            {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.No_Results);
                ApexPages.addMessage(errorMessage);
            }
            objPageManager.numberOfRows = LeadList.size(); 
        }     
        else{
            pagereference pageref= searchresults();
        }    
            return null;
   }  
   
       /* @Method <getProductsDetails(): This property is used to add product available for selection in the UI.> 
       @param - <void>
       @return <List<SelectOption>> 
       @throws exception - <No Exception>
  */
    public List<Lead> getLeadDetails(){
        
        lstLead1Details.clear();
        for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<LeadList.size();i++){
            lstLead1Details.add(LeadList.get(i));
         }
        
        return lstLead1Details; 
    }  


}