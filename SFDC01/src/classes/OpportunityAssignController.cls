/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  11.20.09   Shipra Misra           Intial assignment of user/'s on the Opportnity in User Assignment Record.               
 |  03.12.10   Prasad                 added isAtive condition on Account team query                                        
 |  15/03/2010 Arya                   Assigning the Account Team Member to the Standard Owner.            
 |  25-May-10  Prasad K               Added owner.isActive field on Opportunity query
 |  17-Sep-10  Shipra Misra           Cleaned code for Developer Script exception. WR:146082
 |  02-Feb-11  Srinivas               Worked on WR-151992, for IIG reorg.Adding new 4 Direct SST forecast groups
 |  02-Nov-11  Srinivas               Modified method "compareForecastGrp", bug: 'Assign' functionality adding 100% split to same forecast user while adding multiple users from same forecast group
 +===========================================================================*/

public class OpportunityAssignController 
{

  public List<SalesTeamWrapper> uaList {get; set;}
  public User_Assignment__c uAssign{get;set;}
  public Boolean showErrorMessage {get; set;}
  public Boolean showAssignedMessage {get; set;}
  public Boolean showForecastGroupError {get; set;}
  public Boolean ShowNullErrorMessage {get;set;}
  public Boolean ShowNoRecordMessage {get;set;}
  public Boolean ShowAssignButton {get;set;}
  public Boolean showNextPageButton {get;set;}
  public User_Assignment__c userAssignOpp{get;set;}
  public Boolean showOkButton {get; set;}//Boolean value to display OK button.//
  public Boolean showAssignOkButton {get; set;}
  public Boolean showAssignPageButton {get;set;}
  public Boolean showFinalOkButton {get;set;}
  List<OpportunityTeamMember> AddedTeamMember = new List<OpportunityTeamMember>();
  List <SalesTeamMember> stm= new List <SalesTeamMember>();
  String CurrentUserForecastGroup =null;
  Set<String> OppTeamMemforecastgrp=new Set<String>();
  set<String> AccUserFgrp=new set<String>();
  List<AccountTeamMember> selectedAccTeamMem=new List<AccountTeamMember>();
  List<OpportunityTeamMember> HouseAccInOppTeam=new List<OpportunityTeamMember>();
  List<OpportunityIntegration__c> houseAcct = OpportunityIntegration__c.getall().Values();
  List <SalesTeamMember> deletestm=new List <SalesTeamMember>();
  public OpportunityAssignListController AssignUtils= null;  
  
  //Added by Srinivas for new IIG Forecast Groups
  Map<String,Special_Forecast_Groups__c>  mapSpecial_Forecast_Groups = Special_Forecast_Groups__c.getAll();
  //////////////////////////////
   
    public OpportunityAssignController(ApexPages.StandardController Controller)
    { 
      
      showAssignPageButton = true;
      showAssignOkButton = false;
      showFinalOkButton = false;
           
      this.uAssign=(User_Assignment__c)controller.getRecord();
      //Code Updated on 17-10-10 Developer Script Excetion cleanup.Added Try Catch Block//  
      try
       {
          if(uAssign.Id!=null){
      //End of Code Updated on 17-10-10 Developer Script Excetion cleanup.//        
          userAssignOpp =[select  User__r.Name,Opportunity__r.Id, Opportunity__c,Id,
                                Account__r.Id, Account__c ,User__r.Forecast_Group__c, User__c,
                                Opportunity__r.House_Account_Name__c,Assignment_Group__c
                                From User_Assignment__c where id=:uAssign.id];
           
           AssignUtils= new OpportunityAssignListController(new String[]{userAssignOpp.Id});
           
            //Changes by Arya
            for(List<OpportunityTeamMember> Oppteammem:[Select User.Name,OpportunityId,UserId,User.IsActive, User.Forecast_Group__c from OpportunityTeamMember where OpportunityId=:userAssignOpp.Opportunity__r.Id]){
                for(OpportunityTeamMember opptm:Oppteammem){
                    if(opptm.User.Name=='House Account'){
                       HouseAccInOppTeam.add(opptm);
                    }    
                    OppTeamMemforecastgrp.add(opptm.User.Forecast_Group__c);
                    System.debug('OppTeamMemforecastgrp****'+OppTeamMemforecastgrp);
                }
            }
          }
       }
        catch(QueryException e)
       {
            System.debug('the exception is' +e);
       }
       
    }       
    // Method to display the account team member present against the account in User Assignment//
    public List<SalesTeamWrapper> getUser_Assignment(){
        Boolean InsufficientAccess = AssignUtils.restrictPermission();
        if(InsufficientAccess){         
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,Label.Insufficient_Privilege);
            ApexPages.addMessage(msg);

            showOkButton = false; 
            showAssignOkButton = True;
            showAssignPageButton = false;
            showFinalOkButton = True;
            showNextPageButton = false;
            return null;
        }   
        //showAssignPageButton = true;
        //showAssignOkButton = false;
        
        if(uaList == null) {
          uaList = new List<SalesTeamWrapper>();
          for(AccountTeamMember uaAccountTeamMember : [Select User.Name,User.Forecast_Group__c, UserId,User.IsActive, User.LastName,User.FirstName,TeamMemberRole, Account.Name, AccountId,AccountAccessLevel From AccountTeamMember where accountId=:userAssignOpp.Account__r.Id and User.IsActive=true])
          {
                if(uaList.size()<=1000)
                {
                uaList.add(new SalesTeamWrapper(uaAccountTeamMember));  
                } 
          }
        }
        if(uaList.size()>0)
        {
           return uaList;  
        }else{
              ShowNullErrorMessage=true;
              return null;
        }
       
    }
    //Method to Assign the selected Team Member against the defined opportunity in UserAssignment based on validations on Forecast group.//
    public Boolean checkSelectedUserGroup(){
      for(SalesTeamWrapper UserToBeAssigned : getUser_Assignment()) {
             //if(UserToBeAssigned.IsChecked == true && (UserToBeAssigned.AccntTeamMem.User.Forecast_Group__c=='Direct'||UserToBeAssigned.AccntTeamMem.User.Forecast_Group__c=='Maintenance Renewals')){
             if(UserToBeAssigned.IsChecked == true && (mapSpecial_Forecast_Groups.containskey(UserToBeAssigned.AccntTeamMem.User.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(UserToBeAssigned.AccntTeamMem.User.Forecast_Group__c).Ownership_Allowed__c))
             {
                         selectedAccTeamMem.add(UserToBeAssigned.AccntTeamMem); 
                         System.debug('***UserToBeAssigned.AccntTeamMem.User.Name****'+UserToBeAssigned.AccntTeamMem.User.Name);
                         return true;
              }
      }
      return false;    
    }
    public PageReference AssignSalesTeamMember()
    {
       
       showAssignPageButton = true;
       showAssignOkButton = false;
       Set<String> HouseAccountGroup = new Set<String>();
        HouseAccountGroup.add('Direct'); //  this not Used anywhere in the code so not replacing
       
       PageReference NextPage= new PageReference('/'+userAssignOpp.Account__r.Id);
       if(getUser_Assignment()!=null)
       {
           Integer counter=0;
           for(SalesTeamWrapper UserToBeAssigned : getUser_Assignment())
           {
                   if(UserToBeAssigned.IsChecked == true )
                   {
                        counter=counter+1;
                        if( userAssignOpp.Assignment_Group__c=='House Account')
                        {   
                           //if(HouseAccountGroup.contains(UserToBeAssigned.AccntTeamMem.User.Forecast_Group__c)){
                            /*for(List<OpportunityTeamMember> Oppteammem:[Select OpportunityId,UserId,User.Forecast_Group__c from OpportunityTeamMember where OpportunityId=:userAssignOpp.Opportunity__r.Id and UserId=:houseAcct[1].House_Account_User__c]){
                                for(OpportunityTeamMember opptm:Oppteammem){
                                    HouseAccInOppTeam.add(opptm);
                                System.debug('HouseAccInOppTeam'+HouseAccInOppTeam);
                                }
                            }*/   
                               addTeamMember(UserToBeAssigned,compareForecastGrp(UserToBeAssigned)?0:100);
                               HouseAccountGroup.clear();
                           // }                        
                        }
                        else
                        {
                            if(UserToBeAssigned.AccntTeamMem.User.Forecast_Group__c==userAssignOpp.Assignment_Group__c )
                            {
                                addTeamMember(UserToBeAssigned,(counter==1)?100:0);
                                
                            }
                            else
                            {
                                ShowNoRecordMessage=false;
                                showErrorMessage = true;
                                return null;  
                            }
                        }
                   }
                   
               
            }
            if (counter==0)
            {
                showErrorMessage = false;
                ShowNoRecordMessage=true;
                return null;
            }
       }
       else
       {
          ShowNullErrorMessage=true;
          return null;
       }
       Savepoint sp = Database.setSavepoint();   
       try
       {
              Opportunity oppBypass;
              //insert AddedTeamMember;
              if(HouseAccInOppTeam.size()!=0){
                  Detail_Line__c detailln=new Detail_Line__c();
                  deletestm.add(new SalesTeamMember(false,HouseAccInOppTeam[0],detailln));            
              }
              OP_SSF_CommonUtils CommonUtils=new OP_SSF_CommonUtils();
              If(checkSelectedUserGroup()){
                  oppBypass=[Select owner.isactive,Name,Opportunity_Owner__c,OwnerId,bypass_validation__c from Opportunity where Id=:userAssignOpp.Opportunity__r.Id]; 
                  oppBypass.bypass_validation__c=true;
                  System.debug('welcome');
                  If(userAssignOpp.Assignment_Group__c=='House Account'){
                      if(houseAcct[1].House_Account_User__c==oppBypass.Opportunity_Owner__c){
                          for(AccountTeamMember uaAccountTeamMember : selectedAccTeamMem)
                          {
                              
                              oppBypass.Opportunity_Owner__c=uaAccountTeamMember.UserId;
                              //Changed by arya-Assigning the Account Team Member to the Standard Owner.
                              oppBypass.OwnerId=uaAccountTeamMember.UserId;
                              break;
                          }
                          System.debug('*****Calling remove****'+deletestm);
                          CommonUtils.removeSalesTeamMembers(deletestm);
                      }
                  }
                  update oppBypass;
              } 
             /* if(HouseAccInOppTeam.size()!=0){
                  Detail_Line__c detailln=new Detail_Line__c();
                  deletestm.add(new SalesTeamMember(false,HouseAccInOppTeam[0],detailln));            
              }
              OP_SSF_CommonUtils CommonUtils=new OP_SSF_CommonUtils();*/
              System.debug('Stm--->'+stm);  
              System.debug('Stm.size()--->'+stm.size());
              CommonUtils.addSalesTeamMembers(stm);              
              
              
              if(oppBypass!=null)
              {
                  oppBypass.bypass_validation__c=false;
                  update oppBypass; 
              }
              AddedTeamMember.clear();
              delete userAssignOpp;
       }
       catch(DMLException e)
       {
               System.debug('the exception is' +e);
           Database.rollback(sp);
                              
       }
    NextPage.setRedirect(true);
    return NextPage; 
            
   }
   
   
   // Method to add  checked in Account team member in a list and return the reult for insertion.//
   public List<OpportunityTeamMember> addTeamMember(SalesTeamWrapper UserToBeAssigned,integer percentage)
   {
               
               System.debug('Percentage******'+percentage);
               OpportunityTeamMember OpptyTeamMem = new OpportunityTeamMember();
               OpptyTeamMem.OpportunityId= userAssignOpp.Opportunity__r.Id ;
               OpptyTeamMem.TeamMemberRole=UserToBeAssigned.AccntTeamMem.TeamMemberRole;
               //OpptyTeamMem.OpportunityAccessLevel='Edit';    
               OpptyTeamMem.UserId=UserToBeAssigned.AccntTeamMem.UserId;
               //Changes for WR-151992
               OpptyTeamMem.User=UserToBeAssigned.AccntTeamMem.User; 
                
                Detail_Line__c detailln=new Detail_Line__c();
                    detailln.Opportunity_Access_Level__c='Edit';
                    detailln.Split__c=percentage;
                    detailln.OwnerId=UserInfo.getUserId();
                    detailln.Forecast_Group__c=UserToBeAssigned.AccntTeamMem.User.Forecast_Group__c;                 
          
                    stm.add(new SalesTeamMember(false,OpptyTeamMem,detailln));
                    
              //AddedTeamMember.add(OpptyTeamMem);
              return AddedTeamMember;
    }
    
    public PageReference NextAccountPage()
    {

       //String UserAssgnmentId = ApexPages.currentPage().getParameters().get('id');
       //PageReference NextPage= new PageReference('/'+UserAssgnmentId);
       PageReference NextPage= new PageReference('/'+userAssignOpp.Account__r.Id);
       NextPage.setRedirect(true);
       return NextPage;
    }
    
    public PageReference BackToUAPage()
    {

       String UserAssgnmentId = ApexPages.currentPage().getParameters().get('id');
       PageReference NextPage= new PageReference('/'+UserAssgnmentId);
       //PageReference NextPage= new PageReference('/'+userAssignOpp.Account__r.Id);
       NextPage.setRedirect(true);
       return NextPage;
    }
    
    public PageReference UserAssignmentPage()
    {
       //PageReference NextPage= new PageReference('/'+userAssignOpp.Id);
       String UserAssgnmentId = ApexPages.currentPage().getParameters().get('id');
       PageReference NextPage= new PageReference('/'+UserAssgnmentId);
       NextPage.setRedirect(true);
       showOkButton=true;
       return NextPage;
    }
    
    public PageReference UserAssignmentId()
    {   
       String UserAssgnmentId = ApexPages.currentPage().getParameters().get('id');
       PageReference NextPage= new PageReference('/'+UserAssgnmentId);
       NextPage.setRedirect(true);
       return NextPage;
    }

   
   public void  addSelfAssignedUser(){
    //Code Updated on 17-10-10 Developer Script Excetion cleanup.// 
    if(uAssign.id!=null){
          
        System.debug('AssignUtils***'+AssignUtils);
        AssignUtils.addSelfAssignedUser();   
    } 
    else{
        System.debug('The else clause entered'+uAssign.id);
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,Label.Oppty_Id_DoesNot_Exist);
        ApexPages.addMessage(msg);
        
    }
    //End of Code Updated on 17-10-10 Developer Script Excetion cleanup.//  
  }
    /*Added by Arya
   Method to Compare the Forecast group*/
   
   public boolean compareForecastGrp(SalesTeamWrapper Usertoassign){
   
       System.debug('***OppTeamMemforecastgrp****'+OppTeamMemforecastgrp);
       System.debug('Usertoassign.AccntTeamMem.User.Forecast_Group__c'+Usertoassign.AccntTeamMem.User.Forecast_Group__c);
       If(OppTeamMemforecastgrp.contains(Usertoassign.AccntTeamMem.User.Forecast_Group__c))
       {
           return true;
       }else if(AccUserFgrp.contains(Usertoassign.AccntTeamMem.User.Forecast_Group__c))
             {
                System.debug('****2*****');
                return true;
             }else{
                AccUserFgrp.add(Usertoassign.AccntTeamMem.User.Forecast_Group__c); 
                System.debug('****3*****');
                return false;
             }
   }//End of compareForecastGrp()
   
    
    public PageReference Ok()
    {
        return new PageReference('/a0N/o');

    }
        public PageReference assignSelfOk()
    {
        PageReference nextpage= new PageReference('/a0N/o');
        nextPage.setRedirect(true);
        return nextPage;
    }
    
    public class SalesTeamWrapper
    {
        public AccountTeamMember AccntTeamMem {get; set;}
        public Boolean IsChecked {get; set;}
        public SalesTeamWrapper(AccountTeamMember uaAccountTeamMember)
        {
            AccntTeamMem = uaAccountTeamMember;
            IsChecked = false;
        }
    }
    
}