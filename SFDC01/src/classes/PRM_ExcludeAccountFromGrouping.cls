/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 | 19/7/2010       Karthik Shivprakash     141592   This class is used to exclude the selected accounts from the grouping.
 | 
 | 05/08/2010      Karthik Shivprakash     Defect#76 Called the populate result method and added on more condition in selectedAccounts().
 | 20/12/2011	   Suman B				   WR-181186 Implemented pagination for  IM7329210 -Unable to Un-Group Accounts from Grouping.
 | 										   			 Added getAccountDetails() method to display the Account records based on paging. 	
 | 22/12/2011  	   Suman B				   WR-181186  Added customsetting for Pagesize.	
 +=============================================================================================================*/


public with sharing class PRM_ExcludeAccountFromGrouping {

/* @Method <This is constructor for the class PRM_ExcludeAccountFromGrouping>
   @param <this method not taking any arguments>
   @return <void> - <returning nothing>
   @throws exception - <No Exception>
*/  
    //Here we are getting the grouping ID from which the exclude is called
    Public String GroupingID = System.currentPageReference().getParameters().get('groupingId'); 
    Account_Groupings__c GroupingRecord;

    // paging
    public PageManager objPageManager       {get;set;}
    List<Account> accountToFetch = new List<Account>(); 
    List<AccountWrapper> listAccountDetails = new List<AccountWrapper>();
    Map<Id,AccountWrapper> mapAccountWrapper = new Map<Id,AccountWrapper>();
    Map<String,CustomSettingDataValueMap__c> dataValueMap = CustomSettingDataValueMap__c.getAll();            

    public PRM_ExcludeAccountFromGrouping(){
    System.debug('GroupingID-->'+GroupingID);
        if(GroupingID!=null){   
            GroupingRecord = [select id,name,active__c,Profiled_Account_Site_Duns__c from account_groupings__c where Id__c=:GroupingID];
	        CustomSettingDataValueMap__c pageDetails = DataValueMap.get('Partner_Grouping_Exclude');
	        Integer pageSize = 250;        
	        try
	        {            
	            pageSize  = Integer.valueOf(pageDetails.DataValue__c);
	        }
	        catch(Exception e)
	        {
	          pageSize = 250;
	        }  
            objPageManager = new PageManager(pageSize);
            getFetchAccounts();
        
        }
        
    }
         
    //Here we are creating the instance of the class PRM_GroupingOfAssignment
    PRM_GroupingOfAssignment classObj = new PRM_GroupingOfAssignment();
    //This is a wrapper list 
    List<AccountWrapper> accountWrapper=new List<AccountWrapper>();
    List<AccountWrapper> accountWrapperlist=new List<AccountWrapper>();
    //List which contains the selected accounts for the exclude
    List<Account> selectedAccounts = new List<Account>();
    //Map used to display the accounts along with the result if not excluded
    Map<Id,String> resultOfSelectedAccounts = new Map<Id,String>();
    //List which contains profiled account which will be selected to exclude
    List<Account> selectedProfiledAccount = new List<Account>();
    public Integer countOfExclude=0;
    public Integer countOfNotProcessed=0;
    public Integer totalCountOfExclude=0;



/* @Method <This is wrapper class which is used to display the list of accounts along with checkbox>
   @param <this method not taking any arguments>
   @return <void> - <returning nothing>
   @throws exception - <No Exception>
*/  

    public class AccountWrapper{
    
        public boolean checked;
        public Account accountRec;
        public String result;
        public List<String>ColumnValues=new List<String>(); 
        public AccountWrapper(Account accountRecord,Boolean checked1){
            this.accountRec=accountRecord;
            this.checked=checked1;
        }
        
        public void setChecked(boolean c){
        this.checked=c;
        }
        public boolean getChecked(){
        return this.checked;
        }
        
        public Account getAccountRec(){
        return this.accountRec;
        }
        public void setAccountRec(Account acct){
        this.accountRec=acct;
        }

/* @Method <Getter method for the result>
   @param <This method is not taking any arguments>
   @return <String> - <result which contain error message to display>
   @throws exception - <No Exception>
*/        
        public String getResult(){
           return result;
        }
    
/* @Method <Setter method for the result>
   @param <This method is taking string which contains error message>
   @return <void> - <not returning anything>
   @throws exception - <No Exception>
*/
        public void setResult(String result){
            this.result=result;
        }
     }

/* @Method <This is a wrapper list which contains all the accounts processed and not processed>
   @param <not taking any arguements>
   @return <List<AccountWrapper>> - <wrapper list of accounts>
   @throws exception - <No Exception>
*/ 
    
     public List<AccountWrapper> getAccountWrapperlist(){
         return accountWrapperlist;
     }
     
     

    

/* @Method <This is a getter method used to fetch the accounts>
   @param <This method is not taking any arguments>
   @return <List<Account>> - <returning null>
   @throws exception - <No Exception>
*/    
   /*
    public List<Account> getFetchAccounts(){
        List<Account> accountToFetch = [select id,name,BillingCountry,BillingCity,BillingState,Profiled_Account__c,Partner_Type__c,Global_DUNS_Entity__c,Site_DUNS_Entity__c,PROFILED_ACCOUNT_FLAG__c,Master_Grouping__r.name,Grouping__r.name,Grouping__c,Master_Grouping__c from account where Grouping__c=:GroupingRecord.Id];
        for(Account acc: accountToFetch){
            accountWrapper.add(new AccountWrapper(acc,false));
        }
        return null;
    } */
    
    public List<Account> getFetchAccounts(){
        objPageManager.page = 0;
        objPageManager.numberOfRows =0;
        accountToFetch = [select id,name,BillingCountry,BillingCity,BillingState,Profiled_Account__c,Partner_Type__c,Global_DUNS_Entity__c,Site_DUNS_Entity__c,PROFILED_ACCOUNT_FLAG__c,Master_Grouping__r.name,Grouping__r.name,Grouping__c,Master_Grouping__c from account where Grouping__c=:GroupingRecord.Id];
        return Null ;
    }

/* @Method <This is a getter method used to get the list of accounts for selected paging>
   @param <This method is not taking any arguments>
   @return <List<AccountWrapper>> - <returning null>
   @throws exception - <No Exception>
*/
    public List<AccountWrapper> getAccountDetails(){ 
        if(accountToFetch != Null && accountToFetch.size()>0){
           objPageManager.numberOfRows =accountToFetch.size();
           if(listAccountDetails.size()>0){
             for(AccountWrapper accwrp :listAccountDetails){
                 mapAccountWrapper.put(accwrp.accountRec.id,accwrp);
              }
           }
           listAccountDetails.clear();
           for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<accountToFetch.size();i++){
  			   if(mapAccountWrapper.containskey(accountToFetch.get(i).id)){
	              listAccountDetails.add(mapAccountWrapper.get(accountToFetch.get(i).id));
	           }
	           else{
	              listAccountDetails.add(new AccountWrapper(accountToFetch.get(i),false));
	           }
           }
        } 
        System.debug('listAccount -->'+accountToFetch.size());
        System.debug('Final AccountSearch objPageManager.startIndex ------>'+ objPageManager.startIndex);
        System.debug('Final Accountsearch objPageManager.endIndex ------>'+ objPageManager.endIndex);
        System.debug('Final PageAccountDetails-->'+ listAccountDetails.size());  
        return listAccountDetails;
    }
     
/* @Method <getter method for the grouping sObject to display the grouping name in result page>
   @param <this method not taking any arguements>
   @return <Grouping> - <grouping details>
   @throws exception - <No Exception>
*/    

    public account_groupings__c getGroupingRecord(){
        return GroupingRecord;
    }

/* @Method <Getter method used to get the count of accounts to exclude from the group>
   @param <this method not taking any arguements>
   @return <Integer> - <returning count Of Exclude accounts>
   @throws exception - <No Exception>
*/    

    public Integer getCountOfExclude(){
        return countOfExclude;
    }

/* @Method <Getter method used to get the total count of the selected accounts to exclude>
   @param <this method not taking any arguements>
   @return <Integer> - <returning total count both excluded and not excluded>
   @throws exception - <No Exception>
*/     

    public Integer getTotalCountOfExclude(){
        return totalCountOfExclude;
    }
    
/* @Method <Setter method for the wrapper class>
   @param <List<AccountWrapper> accountWrap>
   <accountWrap -- contains the list of accounts to exclude>
   @return <void> - <wrapper list of accounts>
   @throws exception - <No Exception>
*/     

    public void setAccountWrapper(List<AccountWrapper> accountWrap){
            this.accountWrapper=accountWrap;
    }

/* @Method <Getter method for the wrapper class>
   @param <not taking any arguements>
   @return <List<AccountWrapper>> - <wrapper list of accounts>
   @throws exception - <No Exception>
*/ 

    public List<AccountWrapper> getAccountWrapper(){
            return accountWrapper;
    }
    
/* @Method <Setter method for the selected accounts>
   @param <List<Account> selectedProfiledAccount>
   <selectedProfiledAccount -- contains the list of accounts to exclude>
   @return <void> - <wrapper list of accounts>
   @throws exception - <No Exception>
*/ 
    
    public void setSelectedProfiledAccount(List<Account> selectedProfiledAccount){
            this.selectedProfiledAccount=selectedProfiledAccount;
    }
    
/* @Method <Getter method which contains the selected profiled account>
   @param <not taking any arguments>
   <selectedProfiledAccount -- contains the list of accounts to exclude>
   @return <List<Account>> - <list of accounts>
   @throws exception - <No Exception>
*/ 


    public List<Account> getSelectedProfiledAccount(){
            return selectedProfiledAccount;
    }
    
/* @Method <Here we are getting the selected accounts and adding into list to exclude the accounts>
   @param <this method not taking any arguements>
   @return <List<Account>> - <returning selected accounts>
   @throws exception - <No Exception>
*/    
    
    public List<Account> selectedAccounts(){
    	getAccountDetails();
    	accountWrapper = mapAccountWrapper.values() ;
        for(AccountWrapper acctObj:accountWrapper){
            //Here we are checking if the account is selected and its should not be profiled account then we will exclude the accounts from grouping
            //Defect#76 Added one condition to check for exclude the account it the grouping is active.
            if(acctObj.checked==true && acctObj.accountRec.profiled_account_flag__c!=true && GroupingRecord.Profiled_Account_Site_Duns__c!=acctObj.accountRec.Site_DUNS_Entity__c){
                selectedAccounts.add(acctObj.accountRec);
                String msg1 = System.Label.Success_Of_Exclude;
                accountWrapperlist.add(new accountWrapper(acctObj.accountRec,false));
                resultOfSelectedAccounts.put(acctObj.accountRec.Id,msg1);
                populateResult(resultOfSelectedAccounts);
                System.debug('Result Map'+resultOfSelectedAccounts);
                countOfExclude=selectedAccounts.size();
                System.debug('In If list'+selectedAccounts);
            }
            //Defect#76 added to display the non profiled account with result when grouping is active and clicked on exclude.
            else if(acctObj.checked==true && acctObj.accountRec.profiled_account_flag__c!=true && GroupingRecord.Profiled_Account_Site_Duns__c==acctObj.accountRec.Site_DUNS_Entity__c){
                String errorMessage1 = System.Label.Exclude_Error1;
                selectedProfiledAccount.add(acctObj.accountRec);
                accountWrapperlist.add(new accountWrapper(acctObj.accountRec,false));
                resultOfSelectedAccounts.put(acctObj.accountRec.Id,errorMessage1);
                populateResult(resultOfSelectedAccounts);
            }
            //Here we are checking if the account is selected and it is a profield account, then we will not exclude that account from grouping
            else if(acctObj.checked && acctObj.accountRec.profiled_account_flag__c==true){
                String errorMessage = System.Label.Account_Cannot_Be_Removed;
                selectedProfiledAccount.add(acctObj.accountRec);
                accountWrapperlist.add(new accountWrapper(acctObj.accountRec,false));
                countOfNotProcessed=selectedProfiledAccount.size();
                System.debug('Else list'+selectedProfiledAccount);
                resultOfSelectedAccounts.put(acctObj.accountRec.Id,errorMessage);
                populateResult(resultOfSelectedAccounts);
            }      
        }
        //Here we are taking the total count of the selected accounts for exclude
        totalCountOfExclude=(countOfExclude+countOfNotProcessed);
        return selectedAccounts;
    }

/* @Method <This method is used to diplay the accounts with the result>
   @param <Map<Id,String> accountResult>
   <accountResult -- which contains accounts with error message>
   @return <List<Account>> - <returning selected accounts>
   @throws exception - <No Exception>
*/
    
    //
    public void populateResult(Map<Id,String> accountResult){
        for(AccountWrapper acct : accountWrapperlist){
                String errorMessage = accountResult.get(acct.accountRec.Id);
                acct.result = errorMessage;
                
        }
    }
    
/* @Method <Here the selected accounts will be excluded by calling the exclude method>
   @param <not taking any arguments>
   @return <Page Reference> - <returning null>
   @throws exception - <No Exception>
*/

    public PageReference exclude() {
        selectedAccounts();
        System.debug('After func call');
        if(selectedAccounts.size()>0){
            classObj.excludeFromGrouping(selectedAccounts,GroupingID);
            return Page.PRM_ResultOfExclude;
        }
        //Here we are checking if the account is selected or not,if not then it will throw the error message
        else if(selectedAccounts.size()==0 && selectedProfiledAccount.size()==0){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Please_select_atleast_on_account_to_exclude_from_the_grouping);
            ApexPages.addMessage(errorMessage);
            return null;
        }
        //Here we are checking the count of selected accounts which is not excluded then it will call the populate method to display the result
        else if(selectedProfiledAccount.size()>0){
            System.debug('Calling result page for profiled accounts');
            //populateResult(resultOfSelectedAccounts);
            return Page.PRM_ResultOfExclude;
        }
        return null;
    }

/* @Method <This method will take the user back again to the grouping page>
   @param <this method not taking any arguements>
   @return <Page Reference> - <returning back to grouping page>
   @throws exception - <No Exception>
*/     
    public PageReference back() {
        return new PageReference('/'+GroupingRecord.Id);
    }
    
/* @Method <This method is used to take back the user to the grouping page>
   @param <This method is not taking any arguments>
   @return <Page Reference> - <Returning back to grouping page>
   @throws exception - <No Exception>
*/

    public PageReference cancel() {
        return new PageReference('/'+GroupingRecord.Id);
    }

/* @Method <Method used to de-selecte all the accounts>
   @param <not taking any arguements>
   @return <page reference> - <returning null>
   @throws exception - <No Exception>
*/ 
    
    public PageReference deSelectAll(){
        for(AccountWrapper acctObj:accountWrapper){
            acctObj.checked=false;
        }
        return null;
    }

/* @Method <Method used to select all the accounts to include>
   @param <not taking any arguements>
   @return <page reference> - <returning null>
   @throws exception - <No Exception>
*/

    public PageReference selectAll(){
        for(AccountWrapper acctObj:accountWrapper){
            acctObj.checked=true;
        }
        return null;
    }

}