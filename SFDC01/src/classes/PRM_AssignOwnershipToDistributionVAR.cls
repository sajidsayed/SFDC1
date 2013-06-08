/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 
 |  24/07/2012    Anirudh Singh            197913    This class is used as the custom controller for 
 |                                                   PRM_ChangeOwnershipToDistributionVAR Page.                                             
 +===========================================================================*/
public class PRM_AssignOwnershipToDistributionVAR{
    //Property Declaration
    public String userId {get; set;}    
    public List<User> lstDistributionVARUser {get;set;}
    public user selectedUser {get;set;}
    public Lead leadRecord {get;set;}
    public boolean isResultPanelRendered {get;set;}
    string strQuery ;
    public list<Id> lstAsscoaitedDistributionVAR; 
    
    //Sorting 
    public string sortField {get;set;}
    public Boolean sortAscending {get;set;}
    public string defaultsortQuery  {get;set;}
    
    // CustomSearch paging
    public PageManager objPageManager {get;set;}   
    public List<User> lstUserDetails{get;set;}
/* @Method <This is the constructor of the class.>   
   @return <void> -- <Returns nothing>
   @throws exception - <No Exception>
*/
    public PRM_AssignOwnershipToDistributionVAR(){       
       //fetch custom setting values
       Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();       
       string DistributorUserProfiles = DataValueMap.get('Reassigning Distributor Users').DataValue__c;
       string ReassignDisVarUserExcludeValues = DataValueMap.get('ReassignDisVarUserExcludeValues').DataValue__c;
       
       User CurrentUser;
       Integer pageSize = 25; 
       isResultPanelRendered = true;
       userId = '';
       //paging variables 
       objPageManager = new PageManager(pageSize);               
       objPageManager.page = 0;
       objPageManager.numberOfRows =0;
       lstUserDetails = new List<User>();
       Map<Id,APPR_MTV__RecordAssociation__c> mapAssociation;
       lstAsscoaitedDistributionVAR = new List<Id>();
       leadRecord  = [Select Id,OwnerId from Lead where id =: ApexPages.CurrentPage().getParameters().get('id')];       
        if(userInfo.getUserType()=='PowerPartner'){
           CurrentUser = [Select Id,AccountId,ContactId,Contact.AccountId,contact.Account.Partner_Type__c from User where Id=: userinfo.getUserId() and AccountId !=null];
        }   
        if(CurrentUser !=null && CurrentUser.Contact.AccountId !=null){
            mapAssociation = new Map<Id,APPR_MTV__RecordAssociation__c> ([Select Id,APPR_MTV__Account__c,APPR_MTV__Associated_Account__c,
                                                                                                            APPR_MTV__Account_Role__c from APPR_MTV__RecordAssociation__c 
                                                                                                            where APPR_MTV__Account__c=:CurrentUser.Contact.AccountId and
                                                                                                            APPR_MTV__Account_Role__c ='Distribution VAR']);
        }
        if(mapAssociation != null && mapAssociation.size()>0){
           for(APPR_MTV__RecordAssociation__c assObj : mapAssociation.values()){
               lstAsscoaitedDistributionVAR.add(assObj.APPR_MTV__Associated_Account__c);
           }
           system.debug('lstAsscoaitedDistributionVAR '+lstAsscoaitedDistributionVAR);
        }
        if(lstAsscoaitedDistributionVAR.size()>0){
            strQuery ='Select Id,FirstName,LastName,Phone,Name,Email,Contact.Account.Name from User where UserType=';
            strQuery =strQuery + '\'PowerPartner\' and isActive=True ';
            strQuery=strQuery+ 'and Contact.AccountId in :lstAsscoaitedDistributionVAR';
            strQuery=strQuery+ ' and Contact.Account.Partner_Type__c excludes ' + ReassignDisVarUserExcludeValues;
            
            system.debug('QUERY##### '+strQuery);
            lstDistributionVARUser = Database.query(strQuery);
            system.debug('lstDistributionVARUser '+lstDistributionVARUser);
        }
        if(lstDistributionVARUser !=null && lstDistributionVARUser.size()>0){
            objPageManager.numberOfRows = lstDistributionVARUser.size();
        }
        if(!DistributorUserProfiles.contains(userInfo.getProfileId())){
           ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Non_Distributor_User);
           ApexPages.addMessage(errorMessage);
           isResultPanelRendered = false;
           return; 
        }
        if(CurrentUser.contact.Account.Partner_Type__c.contains('Distributor') &&(lstAsscoaitedDistributionVAR ==null || mapAssociation.isempty())){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, System.Label.No_Distribution_VAR_Associated);
            ApexPages.addMessage(errorMessage);
            isResultPanelRendered = false;
            return;
        } 
    }   
   /* @Method <method is used to used to assign the Ownerhsip of Lead
              to Distribution Var User>
   @param <no Param>                
   @return <pagereference> -- <Returns to Lead Detail Page>
   @throws exception - <No Exception>
   */
   public pagereference reassignOwner(){
       System.Debug('userId --->' +userId);       
       pagereference pageref;      
       if(userId==''){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.No_Distribution_VAR_Selected);
            ApexPages.addMessage(errorMessage);
            pageref = null;
        }
        else{
             leadRecord.OwnerId= userId;
             try{           
                update leadRecord;         
             }
         catch(Exception ex){             
                String strErrorMessage = 'Error : '+ ex.getMessage();                           
                if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                    strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);                     
                }      
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, strErrorMessage );
                ApexPages.addMessage(errorMessage);                
                return null;
             }
                 
             
             pageref = new pagereference('/'+leadRecord.Id);       
       }
       return pageref;
   } 
   /* @Method <method is used Redirect Page to Lead Record on click of Cancel Button>
   @param <no Param>                
   @return <pagereference> -- <Returns to Lead Detail Page>
   @throws exception - <No Exception>
   */    
    public PageReference Cancel(){        
        return new pagereference('/'+leadRecord.Id);
    }
    /* @Method <getUserDetails(): This property will be used for pagination in the UI> 
       @param - <void>
       @return <List<User>> 
       @throws exception - <No Exception>
  */
    public List<User> getUserDetails(){
        
        lstUserDetails.clear();
        for(integer i=objPageManager.startIndex;i<objPageManager.endIndex&&i<lstDistributionVARUser.size();i++){
            lstUserDetails.add(lstDistributionVARUser.get(i));
         }
        
        return lstUserDetails; 
    }
    // SORTING 
    /* @Method <method is used sort User Record>
    @param <no Param>                
    @return <void>
    @throws exception - <No Exception>
    */
    public void runSortAction(){
        sortListUsers(sortField,sortAscending );
    }
  
   /* @Method <sortListAccounts(): This method is used  for displaying accounts in sorted order.  
           @param - <String,String>
           @return <void>
           @throws exception - <No Exception>
   */
  public void sortListUsers(String strSortKey, boolean isASC){
     String sortQuery ;
     if(strquery != Null && strquery !=''){
        sortQuery =  strquery.substring(0,strQuery.length() );
        if(isASC){
           sortQuery += '   ORDER BY ' + strSortKey + ' ASC ';
        }else{
           sortQuery += '   ORDER BY ' + strSortKey + ' DESC ';
        }   
         system.debug(sortQuery);    
        lstDistributionVARUser  = Database.query(sortQuery);
     }
   } // End - sortListUsers.  
}