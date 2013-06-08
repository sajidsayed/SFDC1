/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 19/7/2010       Karthik Shivprakash     141592     This is the extension class for visual force page to include the accounts into grouping.
     
 | 27/7/2010       Karthik Shivprakash     Defect#17  Modified to display the next and previous button to display when records is > 200.
 
 | 8/8/2010        Prasad Kothawade        Defect#74  Created new Method goToPage()
  
 | 10/08/2010      Karthik Shivprakash        --      Added on condition to populate error message when profiled account with active grouping is selected.
 
 | 10/08/2010      Karthik Shivprakash     Defect#95  Updating profiled account check box to flase while including the proflied accounts.
 +===========================================================================*/



public with sharing class PRM_IncludeAccountGrouping {

    //List used to hold the accounts which are not included into the grouping
    List<Account> accountsNotProcessed = new List<Account>();
    //Creating the class instance
    PRM_GroupingOfAssignment classObj = new PRM_GroupingOfAssignment();
    //Map used to display the accounts along with the success message
    Map<Id,String> resultNotProcessed = new Map<Id,String>();
    //To hold the message
    public String result;
    //Used to hold the count of how many accounts got included successfully
    public Integer countOfInclude=0;
    //Use to hold the total count of accounts selected
    public Integer totalCount=0;
    //Use to hold the count of accounts which are not included
    public Integer countOfNotProcessed=0;
    //Creating the standard controller variable
    Public ApexPages.StandardSetController stdController ;
    //List used to create the sorting
    List<Account>SortedAccounts = new List<Account>();
    //Used to controll the rendering of the select all and deselect all link on page
    Boolean selectRender = true;
    Public String GroupingID =null;
    Public account_groupings__c grouping=null;
    public boolean renderList=false;
    public boolean hasNext;
    Integer count=0;
    public boolean isPaging{get;set;}
    integer pageNo=0;
    //This is getter method to render the list of accounts
    public boolean getRenderList(){
        return renderList;
    }  
    
/* @Method <This method is used to create the edit view of the accounts>
   @param <this method not taking any arguments>
   @return <PageReference> - <Returning Page create view page>
   @throws exception - <No Exception>
*/    
    

    public PageReference editView(){
      String editUrl ='/ui/list/FilterEditPage?id='+stdController.getFilterId()+'&retURL=/apex/PRM_IncludeAccountListView?groupingId='+GroupingID+'&cancelURL=/apex/PRM_IncludeAccountListView?groupingId='+GroupingID;
      return new PageReference(editUrl);
    }

/* @Method <This method is used to create the new view for the accounts>
   @param <this method not taking any arguments>
   @return <PageReference> - <Returning Page edit view page>
   @throws exception - <No Exception>
*/

    public PageReference createView(){
        String createUrl = '/ui/list/FilterEditPage?ftype=a&retURL=/apex/PRM_IncludeAccountListView?groupingId='+GroupingID+'&cancelURL=/apex/PRM_IncludeAccountListView?groupingId='+GroupingID;
        return new PageReference(createUrl);
    }

/* @Method <This method is used to get the records from the standard controller>
   @param <ApexPages.StandardSetController controller>
   <controller -- Creating the standard controller variable>
   @return <void> - <Not returning anything>
   @throws exception - <No Exception>
*/    
    public PRM_IncludeAccountGrouping(){} 

    public PRM_IncludeAccountGrouping(ApexPages.StandardSetController controller) {
        stdController=controller;
        System.debug('Records Count'+stdController.getrecords().size());
        stdController.setPageSize(200);
        GroupingID = System.currentPageReference().getParameters().get('groupingId');
        string page = System.currentPageReference().getParameters().get('pageNo');
        if(page!=null){
            pageNo=Integer.valueOf(page);
        }
                
        grouping = [select id,name from account_groupings__c where id__c=:GroupingID];
    }
    
/* @Method <This method is used to sort the account based on siteDUNS/Entity>
   @param <List<Account> accounts1>
   <accounts1 -- Passing the accounts list>
   @return List<Account> - <List of sorted Accounts>
   @throws exception - <No Exception>
*/ 

    private List<Account> sortAccounts(List<Account> accounts1){
        Map<Integer,List<Account>>AccountMap = new Map<Integer,List<Account>>();
        List<Account>SortedAccounts1= new List<Account>();
        for(Account acc :accounts1){
            String siteduns='0';
            if(acc.Site_Duns_Entity__c!=null){
                siteduns=acc.Site_Duns_Entity__c;
            }
            List<Account> accs=AccountMap.get(Integer.valueOf(siteduns));
            if(accs==null){
                accs = new List<Account>();
            }
            accs.add(acc);
            AccountMap.put(Integer.valueOf(siteduns),accs);
        }
        List<Integer> ListSorted =new List<Integer>();
        ListSorted.addAll(AccountMap.keyset());
        ListSorted.sort();
        for(Integer siteduns : ListSorted){
              System.debug(siteduns);
              System.debug(AccountMap.get(siteduns));
              SortedAccounts1.addAll(AccountMap.get(siteduns)); 
        }
        return SortedAccounts1;
    }

/* @Method <This method is used to get the sorted accounts and display on the page, its a getter method>
   @param <this method not taking any arguements>
   @return <Page Reference> - <Null reference>
   @throws exception - <No Exception>
*/    

    public PageReference getAccount(){
        //stdController.getCompleteResult();
        List<Account>accounts1=(Account[]) stdController.getRecords();
        System.debug('In go button'+accounts1.size());
        SortedAccounts=sortAccounts(accounts1); //accounts1;//
        System.debug('SortedAccounts.size() '+SortedAccounts.size());
        //System.debug('Total Size '+ stdController.count()  );
        //stdController=new ApexPages.StandardSetController(SortedAccounts);
        renderList=true;
        return null;
    }

/* @Method <Saving the selected accounts after clicking the next link and displaying the accounts in sorted>
   @param <this method not taking any arguements>
   @return <Page Reference> - <returning null reference>
   @throws exception - <No Exception>
*/    

    public PageReference nextPage(){
         //System.debug('Value of hasNext'+hasNext);
         //System.debug('Inside next method'+hasNext);
         try{
             count=count+1;
             selectRender=false;
              System.debug('SortedAccounts '+SortedAccounts);
            // clearSelection();
             
             stdController.next();
             List<Account>accounts1=(Account[]) stdController.getRecords();
             System.debug(accounts1);
             SortedAccounts=sortAccounts(accounts1);
         }catch(Exception e){
             PageReference page= new PageReference('/apex/PRM_IncludeAccountListView?groupingId='+GroupingID+'&pageNo='+count).setRedirect(true);
             page.setRedirect(true);
             return page;
         }
         return null;
    }

 
/* @Method <go to the page>
   @param <this method takes integer page #>
   @return null - <returning null reference>
   @throws exception - <No Exception>
*/    

    public void goToPage(){
         //System.debug('Value of hasNext'+hasNext);
         //System.debug('Inside next method'+hasNext);
         if(pageNo==0){
             return;
         }
         try{
             for(integer i=0;i<pageNo;i++){          
                 count=count+1;
                  System.debug('SortedAccounts '+SortedAccounts);
                // clearSelection();
             
                 stdController.next();
             }
             selectRender=false;
             List<Account>accounts1=(Account[]) stdController.getRecords();
             System.debug(accounts1);
             SortedAccounts=sortAccounts(accounts1);
         }catch(Exception e){
             PageReference page= new PageReference('/apex/PRM_IncludeAccountListView?groupingId='+GroupingID+'&pageNo='+count).setRedirect(true);
             page.setRedirect(true);
             //return page;
         }
        // return null;
    }

 
   private void clearSelection(){
           System.debug('SortedAccounts '+SortedAccounts);
       for(Account acc:(Account[]) stdController.getRecords()){
           System.debug('acc.selected__c '+acc.selected__c);
           acc.selected__c=false;
       }
   } 
/* @Method <Getting the records from the controller and sorting it display on the page>
   @param <this method not taking any arguements>
   @return <Page Reference> - <returning null reference>
   @throws exception - <No Exception>
*/    

     public PageReference previousPage(){
         System.debug('Inside previous method'+count);
         count=count-1;
         if(count==0){
             selectRender=true;
         }
         try{
             stdController.previous();
             List<Account>accounts1=(Account[]) stdController.getRecords();
             System.debug(accounts1);
             SortedAccounts=sortAccounts(accounts1);
         }catch(Exception e){
             PageReference page= new PageReference('/apex/PRM_IncludeAccountListView?groupingId='+GroupingID+'&pageNo='+count).setRedirect(true);
             page.setRedirect(true);
             return page;
         }
         return null;
    }

/* @Method <This method is getter method to sort the accounts>
   @param <this method not taking any arguements>
   @return <List<Account>> - <returning sorted accounts>
   @throws exception - <No Exception>
*/
    
    public List<Account> getSortedAccounts(){
        renderList=true;
        return SortedAccounts ;
    }

/* @Method <This method is used to get the selected accounts list to group those accounts based on profiled account>
   @param <this method not taking any arguements>
   @return <Page Reference> - <returning null>
   @throws exception - <No Exception>
*/
    
    public pageReference include(){
        List<Account> selectedAccounts = new List<Account>();
        List<Account> selectProfiledAccount = new List<Account>();
        //stdController.getRecords()
        List<Account>accounts=(Account[]) stdController.getRecords();
        for(Account acc:accounts){
            if( acc.selected__c && (acc.Grouping__c!=grouping.Id && acc.PROFILED_ACCOUNT_FLAG__c!=true)){  
                selectedAccounts.add(acc);
                String msg = System.Label.Success_Of_Include;
                resultNotProcessed.put(acc.id,msg);
                accountWrapList.add(new accountWrapper(acc,false));
                countOfinclude=selectedAccounts.size();
                System.debug('Selected Account List'+selectedAccounts);
                acc.selected__c=false;
                populateResult(resultNotProcessed);
            }
            else if(acc.selected__c==true && (acc.Grouping__c==grouping.Id && acc.PROFILED_ACCOUNT_FLAG__c!=true)){
                System.debug('Inside else if, accountsNotProcessed'+accountsNotProcessed);
                accountsNotProcessed.add(acc);
                accountWrapList.add(new accountWrapper(acc,false));
                countOfNotProcessed=accountsNotProcessed.size();
                System.debug('Not Processed if group is same'+accountsNotProcessed);
                String msg1 = System.Label.Accounts_already_in_a_group;
                resultNotProcessed.put(acc.Id,msg1);
                populateResult(resultNotProcessed);
            }
            else if(acc.selected__c==true && (acc.PROFILED_ACCOUNT_FLAG__c==true && acc.Grouping__c==grouping.Id)){
                accountsNotProcessed.add(acc);
                accountWrapList.add(new accountWrapper(acc,false));
                countOfNotProcessed=accountsNotProcessed.size();
                System.debug('Not Processed if profiled account'+accountsNotProcessed);
                System.debug('Grouping name in exclude result'+acc.Grouping__r.name);
                String msg2 = acc.name + System.Label.Profiled_Account_Include_Error_I + grouping.Name + System.Label.Profiled_Account_Include_Error_II;
                resultNotProcessed.put(acc.Id,msg2);
                populateResult(resultNotProcessed);
            }
            else if(acc.selected__c && (acc.PROFILED_ACCOUNT_FLAG__c==true && acc.Grouping__c==null)){
                System.debug('Inside group inactive');
                //Defect#95 updating profiled account check box to flase while including the proflied accounts.
                acc.Profiled_Account_Flag__c=false;
                selectedAccounts.add(acc);
                String msg3 = System.Label.Success_Of_Include;
                resultNotProcessed.put(acc.id,msg3);
                accountWrapList.add(new accountWrapper(acc,false));
                populateResult(resultNotProcessed);
                countOfinclude=selectedAccounts.size();
                acc.selected__c=false;
            }
            //Added one condition to check if profiled account with active grouping is selected to throw error.
            else if(acc.selected__c && (acc.PROFILED_ACCOUNT_FLAG__c==true && acc.Grouping__c!=null)){
                selectProfiledAccount.add(acc);
                System.debug('Size of selected Profiled Account'+selectProfiledAccount.size());
                String msg4 = System.Label.Include_Error1;
                resultNotProcessed.put(acc.id,msg4);
                accountWrapList.add(new accountWrapper(acc,false));
                populateResult(resultNotProcessed);
                acc.selected__c=false;
            }
        }

        if(selectedAccounts.size()>0){
            system.debug('selectedAccounts '+selectedAccounts);
            system.debug('selectedAccounts '+selectedAccounts.size());
            classObj.includeInGrouping(selectedAccounts,GroupingID);
            totalCount=(countOfInclude+countOfNotProcessed);
            System.debug('Total Count'+totalCount);
            return Page.PRM_ResultOfInclude;
        }
        else if(accountsNotProcessed.size()>0){
            return Page.PRM_ResultOfInclude;
        }
        else if(accountsNotProcessed.size()==0 && selectedAccounts.size()==0 && selectProfiledAccount.size()==0){
            ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Please_select_atleast_one_account_to_include_into_the_group);
            ApexPages.addMessage(msg1);
        }
        //Added one condition to check if profiled account with active grouping is selected to throw error.
        else if(selectProfiledAccount.size()>0){
            return Page.PRM_ResultOfInclude;
        }
        return null;
    }

/* @Method <This is getter method for the count of accounts included successfully>
   @param <this method not taking any arguements>
   @return <Integer> - <returning countOfincluded accounts>
   @throws exception - <No Exception>
*/

    public Integer getCountOfInclude(){
        return countOfInclude;
    }
    
/* @Method <Getter method for the total count of the accounts selected>
   @param <this method not taking any arguements>
   @return <Integer> - <returning total count both processed and unprocessed>
   @throws exception - <No Exception>
*/   
    
    public Integer getTotalCount(){
        return totalCount;
    }
    
/* @Method <getter method for the grouping sObject to display the grouping name in result page>
   @param <this method not taking any arguements>
   @return <Grouping> - <grouping details>
   @throws exception - <No Exception>
*/

    public account_groupings__c getGrouping(){
        return grouping;
    }

/* @Method <This method is used to display the message on the result sheet if accounts is not processed>
   @param <Map<Id,String> resultNotProcessed>
   <resultNotProcessed -- which contains account id with error message>
   @return <void> - <not returning anything>
   @throws exception - <No Exception>
*/
    
    public void populateResult(Map<Id,String> resultNotProcessed){
        for(AccountWrapper accObj: accountWrapList){
                String errorMessage = resultNotProcessed.get(accObj.acc.Id);
                accObj.result = errorMessage;
                System.debug('Result'+result);
        }
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

/* @Method <This method is used to take back the user to the grouping page from where he has navigated to include accounts>
   @param <This method is not taking any arguments>
   @return <Page Reference> - <Returning back to grouping page>
   @throws exception - <No Exception>
*/
    
    public pageReference back(){
        return new PageReference('/'+grouping.Id);
    }

/* @Method <This method is used to take back the user to the grouping page>
   @param <This method is not taking any arguments>
   @return <Page Reference> - <Returning back to grouping page>
   @throws exception - <No Exception>
*/
    
    public pageReference cancel(){
        return new PageReference('/'+grouping.Id);
    }

/* @Method <Getter method of map for the accounts which are not processed in include>
   @param <This method is not taking any arguments>
   @return <Map<Id,String>> - <returning map which contains account id along with error message>
   @throws exception - <No Exception>
*/    

    public Map<Id,String> getResultNotProcessed(){
        return resultNotProcessed;
    }

/* @Method <Getter method of list for the accounts which are not processed in include>
   @param <This method is not taking any arguments>
   @return <List<Account>> - <returning list which contains account not processed>
   @throws exception - <No Exception>
*/    

    public List<Account> getAccountsNotProcessed(){
        return accountsNotProcessed;
    }

/* @Method <Setter method for the accounts not processed in include>
   @param <List<Account> accountsNotProcessed>
   <accountsNotProcessed -- this contains accounts which is not going to include in the grouping>
   @return <List<Account>> - <returning list which contains account not processed>
   @throws exception - <No Exception>
*/
    
    public void setAccountsNotProcessed(List<Account> accountsNotProcessed){
        this.accountsNotProcessed=accountsNotProcessed;
    }

/* @Method <Method used to select all the accounts to include>
   @param <not taking any arguements>
   @return <page reference> - <returning null>
   @throws exception - <No Exception>
*/    

    public pageReference selectAll(){
        List<Account> selectedAccounts = new List<Account>();
        //stdController.getRecords()
        List<Account>accounts=(Account[]) stdController.getRecords();
        for(Account acc:accounts){
            acc.selected__c=true;
        }
        return null;
    }

/* @Method <Method used to de-selecte all the accounts>
   @param <not taking any arguements>
   @return <page reference> - <returning null>
   @throws exception - <No Exception>
*/    

    public pageReference deSelectAll(){
        List<Account> selectedAccounts = new List<Account>();
        //stdController.getRecords()
        List<Account>accounts=(Account[]) stdController.getRecords();
        for(Account acc:accounts){
            acc.selected__c=false;
        }
        return null;
    }

/* @Method <Method used to de-selecte all the accounts>
   @param <not taking any arguements>
   @return <boolean> - <true or false>
   @throws exception - <No Exception>
*/    
    
    public boolean getSelectRender(){
        return selectRender;
    }

/* @Method <This is a wrapper class to wrap the error message with the account>
   @param <not taking any arguements>
   @return <void> - <not returning anything>
   @throws exception - <No Exception>
*/

List<AccountWrapper> accountWrapList = new List<AccountWrapper>();

    public class accountWrapper{
    
        public boolean checked;
        public Account acc;
        public String result;
        public accountWrapper(account acc1,Boolean checked1){
            this.acc=acc1;
            this.checked=checked1;
        }
        public String getResult(){
            return result;
        }
        
        public void setResult(String result){
            this.result=result;
        }
        
        public void setChecked(boolean c){
        this.checked=c;
        }
        public boolean getChecked(){
        return this.checked;
        }
        
        public account getAcc(){
        return this.acc;
        }
        public void setAcc(Account acc){
        this.acc=acc;
        }
     }

/* @Method <This is a wrapper list which contains all the accounts processed and not processed>
   @param <not taking any arguements>
   @return <List<AccountWrapper>> - <wrapper list of accounts>
   @throws exception - <No Exception>
*/     
     public List<AccountWrapper> getAccountWrapList(){
         return accountWrapList;
     }
    
    
}