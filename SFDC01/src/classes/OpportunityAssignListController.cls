/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER            DESCRIPTION                               
 |  ====       =========            =========== 
 | 
    28-Apr-10  Karthik              Updated addSalesTeamMember() Method - Defect#669,670
    
    29-Apr-10  Arif                 Updated addSalesTeamMember() Method - Defect#666,668,667
    
    06-May-10  Karthik              Added House account sales account team member deletion feature.
    
    27 May 10  Karthik              DEFECT 691 Updated addsalesteammember function.         
    
    28-May-10  Karthik              Defect 693 update the query for userAssignOpp.
    
    04-Jun-10  Arif                 Added a Query in WebService function
    
    27-Jul-10  Anand Sharma         Fix for WR-141528 - On Self User Assignment: JavaScript Duplicate Id issue
    
    10-Nov-10  Pratibh Prakash      WR-147033: Fix to update User management process so that User Assignment for any status of the record.
                                    Changes- Line 83 : removed Assignment_Status__c='Not Assigned' from where condition in Query
                                             Line 356: removed Assignment_Status__c='In Progress' from where condition in Query
                                             Line 549: removed Assignment_Status__c='Not Assigned' from where condition in Query
    02-Feb-11  Srinivas             Worked on WR-151992, for IIG reorg. Adding new 4 Direct SST forecast groups    
    27-Jun-11  Srinivas             Worked on WR-170057, for removing UserAssignment records with In-Progress status.                                         
 +===========================================================================*/

global class OpportunityAssignListController{      
   //prasad
  // VF page compoments controllers
    public Boolean ShowNullErrorMessage {get;set;}
    public Boolean ShowNoRecordMessage {get;set;}
    public Boolean ShowAssignButton {get;set;}
    public Boolean showErrorMessage {get; set;}
    public Boolean showresultsection {get; set;} 
    public Boolean showAssignedMessage {get; set;}
    public Boolean showForecastGroupError {get; set;}
    public Boolean showOkButton {get; set;}
    public String successOpps{get; set;}
    public String failOpps{get; set;}
    public Boolean showRepExist{get; set;}
     
    public List<User_Assignment__c> userAssignOpp{get;set;}
    public Map<String,String> OpportunityAccountId=new Map<String,String>();
    public Map<String,AccountTeamMember> ATMMap=new Map<String,AccountTeamMember>();
    public Map<String,List<User_Assignment__c>> UAMap=new Map<String,List<User_Assignment__c>>();     
    Public List<OpportunityIntegration__c> houseAcct_CustomSettings = OpportunityIntegration__c.getall().Values(); // custom Settings
    Public Map<String,List<SalesTeamMember>> salesteam=new Map<String,List<SalesTeamMember>>();
    OP_SSF_CommonUtils CommonUtils=null;
    
    //Added by Srinivas for new IIG Forecast Groups
    Map<String,Special_Forecast_Groups__c>  mapSpecial_Forecast_Groups = Special_Forecast_Groups__c.getAll();
    //////////////////////////////
   
    public List<User_Assignment__c> Del_UserAssgnment_List=new List<User_Assignment__c>();
    Map<String,Set<String>> OppteammemForecast=new Map<String,Set<String>>();
    Set<String> teamForecastGroup;
    List <SalesTeamMember> deletestm=new List <SalesTeamMember>();
    Map<String,OpportunityTeamMember> HouseAccInOppTeam=new Map<String,OpportunityTeamMember>();
    Public User user;
    String[] IdstoInsert;
    //Constructor
    public OpportunityAssignListController(String[] IdstoInsert){
                   this.IdstoInsert=IdstoInsert;
                   System.debug('IdstoInsert   ---->'+IdstoInsert);
                   init(IdstoInsert);
                   
    }
    
    public OpportunityAssignListController(ApexPages.StandardController Controller){ 
      String ListIds=ApexPages.currentPage().getParameters().get('toInsert');
      System.debug('Ids List is   ---->'+ListIds);
      System.debug('I AM THE FIRST ONE TO GET INVOKED   ---->');
      if(ListIds!=null){
          IdstoInsert = ListIds.split(',');
      }
      if(IdstoInsert!=null && IdstoInsert.size()>0 ){
          init(IdstoInsert);  
      }else{
           init(new List<string>()); 
      }
      
  }
  
  public void init(String[] IdstoInsert){
  
    
      //Get user FG
      System.debug('IdstoInsert   ---->'+IdstoInsert);
      System.debug('I AM THE SECOND TO GET INVOKED   ---->');
      user=[Select Forecast_Group__c from User where id=:Userinfo.getuserid()];
      // Get Assignments records
      userAssignOpp =[select Opportunity__r.Id, Opportunity__c,Id,
                            Account__r.Id, Account__c ,Assignment_Status__c ,User__r.Forecast_Group__c, User__c,
                            Opportunity__r.House_Account_Name__c,Assignment_Group__c,Name
                            From User_Assignment__c where id in :IdstoInsert];
            
      // Prepare Map Users assinments with Account
      List<User_Assignment__c> UAToInsert;                 
      for(User_Assignment__c UA:userAssignOpp){
          OpportunityAccountId.put(UA.Opportunity__r.Id,UA.Account__r.Id);
          UAToInsert=UAMap.get(UA.Account__r.Id);
          if(UAToInsert==null){
              UAToInsert=new List<User_Assignment__c>();
          }   
          UAToInsert.add(UA);
          UAMap.put(UA.Account__r.Id,UAToInsert);
      }
      System.debug('**UAMap**'+UAMap);
      
      System.debug('**OpportunityAccountId**'+OpportunityAccountId);
      for(List<OpportunityTeamMember> OppTeamMember:[Select User.Name,OpportunityId,User.Forecast_Group__c from OpportunityTeamMember where OpportunityId in :OpportunityAccountId.keyset()]){
          for(OpportunityTeamMember OTM:OppTeamMember){
              // prepare opp Id and Sales team FG set
              teamForecastGroup=OppteammemForecast.get(OTM.OpportunityId);
              if(teamForecastGroup==null){
                 teamForecastGroup=new Set<String>();   
              }
               teamForecastGroup.add(OTM.User.Forecast_Group__c);
               System.debug('**teamForecastGroup2**'+teamForecastGroup);
               OppteammemForecast.put(OTM.OpportunityId,teamForecastGroup);
                   
              
              // Prepare House Account reps to delete in next steps WR 125695
              if(OTM.User.Name=='House Account'){
                     HouseAccInOppTeam.put(OTM.OpportunityId,OTM);
                     System.debug('HouseAccInOppTeam***'+HouseAccInOppTeam.size());
              }       
          System.debug('**OppteammemForecast**'+OppteammemForecast);
       }
      }
  }

    // restrict a user with Channel Profile and Channel FG. 
    // returns true if doesnot have access
    public Boolean restrictPermission(){
        Boolean InsufficientAccess=false;
        System.debug('Current Profile: ' + UserInfo.getProfileId());
        List<EMCChannel__c> emcProfile = EMCChannel__c.getall().Values();     
        if(((String)UserInfo.getProfileId()).Contains(emcProfile[0].Channel_Profile_Id__c) || user.Forecast_Group__c=='Channel'){
           InsufficientAccess= true;                   
        }
        return InsufficientAccess;
    }

 public void  addSelfAssignedUser(){
    System.debug('IdstoInsert***'+IdstoInsert);
     if(IdstoInsert.size()>7){
             
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,Label.Number_Of_User_Assignment_Selected);
            ApexPages.addMessage(msg);
            showOkButton = True;
            return;
        }
     Savepoint sp =null;    
      try{
                // Check user permissions
                Boolean Access = restrictPermission();
                if(Access){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,Label.Insufficient_Privilege);
                    ApexPages.addMessage(msg);
                    showOkButton = True;  
                    showresultsection = false;     
                    return;
                }
                showOkButton=false;
              
              //Set Save point
              sp = Database.setSavepoint();
              
              // Prepare Account team Map              
              for(AccountTeamMember[] uaAccountTeamMember : [Select User.Forecast_Group__c,id, UserId,TeamMemberRole, Account.Name, AccountId,AccountAccessLevel From AccountTeamMember where UserId=:UserInfo.getUserId() and accountid in:UAMap.keyset()]){
                for(AccountTeamMember ATM1:uaAccountTeamMember){
                    ATMMap.put(ATM1.AccountId,ATM1);
                }
                System.debug('**ATMMap**'+ATMMap);
              }  
              System.debug('OpportunityAccountId***'+OpportunityAccountId);
              
              for(Id AccountId:UAMap.keyset()){
                System.debug('AccountId---->'+AccountId);
                //ID AccountId=OpportunityAccountId.get(OppID);
                AccountTeamMember AccTeamMem=ATMMap.get(AccountId);
                 for(User_Assignment__c UA:UAMap.get(AccountId)){
                    
                      if(UA.Assignment_Group__c=='House Account' || User.Forecast_Group__c==UA.Assignment_Group__c){
                            Del_UserAssgnment_List.add(UA);
                            if(AccTeamMem != null){
                                createSalesTeam(AccTeamMem.TeamMemberRole,UA);
                            }else{
                                createSalesTeam('Other',UA);
                            }
                            System.debug('Record size2'+Del_UserAssgnment_List.size());
                      }else{
                          //showForecastGroupError= true;
                           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,UA.Name+':  '+Label.Assign_Self_Forecast_Group_Not_Same);
                           ApexPages.addMessage(msg);
                           showOkButton = True; 
                           Database.rollback(sp);
                           return; 
                      } 
                                
                    }//End of For Loop of UserAssignment
                System.debug('AccountId in for loop'+AccountId);
            }
            
            updateOppsalesTeam();
            System.debug('Del_UserAssgnment_List**'+Del_UserAssgnment_List);
            if(Del_UserAssgnment_List.size()>0){
                    System.debug('delUserAssgnmentList  '+Del_UserAssgnment_List);
                    delete Del_UserAssgnment_List;
                    //delUserAssgnmentList.clear();
            }
            // Added by Abhishek WR 556  
            //if(HouseAccInOppTeam.size()>0 && (user.Forecast_Group__c=='Direct'||user.Forecast_Group__c=='Maintenance Renewals')){
            if(HouseAccInOppTeam.size()>0 && ( mapSpecial_Forecast_Groups.containskey(user.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(user.Forecast_Group__c).Ownership_Allowed__c))
            {
              delete HouseAccInOppTeam.values();
            }
       ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info,Label.Assigned_Self_On_UserAssignment );
       ApexPages.addMessage(msg);
       showOkButton = True;
            
    }catch(Exception e){
            showOkButton = True;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,e.getMessage() );
            System.debug('Exception '+e);
            ApexPages.addMessage(msg);
            Database.rollback(sp);                
            System.debug('the exception is' +e);
        }
 }
  
  // update opportunity Salesteam
    public void updateOppsalesTeam(){
        List<Opportunity> opps=new List<Opportunity>();
        Set<String> Oppset=new Set<String>();
        if(CommonUtils==null){
            CommonUtils=new OP_SSF_CommonUtils();
        }   
           for(Id OppID:OpportunityAccountId.keyset()){
                   List<User_Assignment__c> Account_UserAssgnment=UAMap.get(OpportunityAccountId.get(OppID));
                    for(User_Assignment__c assignment:Account_UserAssgnment){
                        Oppset.add(assignment.Opportunity__c);
                    }
           }    
           System.debug('Oppset*****-->'+Oppset); 
           opps=[Select owner.isActive,Opportunity_Owner__c,id, bypass_validation__c from Opportunity where id in:Oppset];
            
            for(Opportunity opp:opps){
                 opp.bypass_validation__c=true;
                 // Added by Abhishek WR 125695
                 // Added by Abhishek WR 556
                //if(houseAcct_CustomSettings[1].House_Account_User__c == opp.Opportunity_Owner__c && (user.Forecast_Group__c=='Direct'||user.Forecast_Group__c=='Maintenance Renewals')){
                if(houseAcct_CustomSettings[1].House_Account_User__c == opp.Opportunity_Owner__c && ( mapSpecial_Forecast_Groups.containskey(user.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(user.Forecast_Group__c).Ownership_Allowed__c))
                {
                        opp.Opportunity_Owner__c=Userinfo.getuserId(); 
                        opp.OwnerId=Userinfo.getuserId();   
                }
            }
            update opps;
            for(Opportunity opp:opps){
                CommonUtils.addSalesTeamMembers(salesteam.get(opp.id));
            }
            if(!opps.IsEmpty()){
                for(Opportunity opp:opps){
                    opp.bypass_validation__c=false;
                }
                update opps;
            }
        
    }
    // Create sales team member object
    public void createSalesTeam(String TeamRole,User_Assignment__c userAssgnment01)
    {
        System.debug('createSalesTeam***'+userAssgnment01);
                      
            Detail_Line__c detailln=new Detail_Line__c();
            detailln.Opportunity_Access_Level__c='Edit';
            detailln.OwnerId=UserInfo.getUserId();
            detailln.Forecast_Group__c=user.Forecast_Group__c;
            System.debug('OppteammemForecast.get(userAssgnment01.Opportunity__r.Id)***'+OppteammemForecast.get(userAssgnment01.Opportunity__r.Id));
            System.debug('user.Forecast_Group__c*****'+user.Forecast_Group__c);
            if(OppteammemForecast.get(userAssgnment01.Opportunity__r.Id).contains(user.Forecast_Group__c)){
            System.debug('welcome');
                detailln.Split__c=0;
            }else{
            System.debug('100exit');
            detailln.Split__c=100;
            }
            OpportunityTeamMember OpptyTeamMem = new OpportunityTeamMember();    
            OpptyTeamMem.OpportunityId= userAssgnment01.Opportunity__r.Id ;
            OpptyTeamMem.TeamMemberRole=TeamRole;
            OpptyTeamMem.UserId=detailln.OwnerId; 
            //Added for WR 151992. Making true as the Browsing User will always active.
             OpptyTeamMem.User =[select name, id, isActive, Forecast_group__c from user where id=:UserInfo.getUserId() limit 1];
                       
            List<SalesTeamMember> OppSalesTeam=salesteam.get(OpptyTeamMem.OpportunityId);
            if(OppSalesTeam==null){
                OppSalesTeam=new List<SalesTeamMember>();
            }   
            OppSalesTeam.add(new SalesTeamMember(false,OpptyTeamMem,detailln));
            // Add in Map
            salesteam.put(OpptyTeamMem.OpportunityId,OppSalesTeam);
    }
        
    public PageReference Ok()
    {
        PageReference nextpage= new PageReference('/a0N/o');
        nextPage.setRedirect(true);
        return nextpage;
        //return new PageReference('/a0N/o');
    }
       

    
   
   /**
     Add self to the sales team and does all validation as per requirement WR 128341 
    @param No in out parameters
    */
    
  List<MassSalesTeamOperation.OpportunityWrapper> opportunityWrapResult = new List<MassSalesTeamOperation.OpportunityWrapper>();
  List<OpportunityIntegration__c> HouseAccountId = OpportunityIntegration__c.getall().Values(); 

   
   Public void addSalesTeamMember( ){
   
   //System.debug('Method addSalesTeamMember');
    String[] userAssignemntIds= IdstoInsert;
   //System.debug('sajid '+'userAssignemntIds '+userAssignemntIds);
   
   Map<Id,Opportunity> opps=new Map<Id,Opportunity>();
   List<Opportunity> ChangeOwnerList = new List<Opportunity>();
   List<Opportunity> oppothers = new List<Opportunity>();
   //List<Opportunity> oppHouseNotOwner = new List<Opportunity>();
   List<Opportunity> DeleteHouseAccountList = new List<Opportunity>();
   successOpps=''; 
   failOpps='';
   //check the record size if greater the 200 throw an exception - This is handled by vanila functionality
   /*     
   if(userAssignemntIds.size()>200){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,Label.Number_Of_User_Assignment_Selected);
            ApexPages.addMessage(msg);
            showOkButton = True;
            return;
    }
   */ 
    // Check user permission
    Boolean InvalidAccess = restrictPermission();
    
   //System.debug('addSalesTeamMember '+'InvalidAccess  '+InvalidAccess );                 
       
       if(InvalidAccess){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,Label.Insufficient_Privilege);
            ApexPages.addMessage(msg);
            showresultsection = false;
            return;
       }
      
                   
      // get current logged in user Forecast group
      User rep=[Select id,Name, Forecast_Group__c from user where id=:Userinfo.getuserId()];
             
      // Get Assignments records
       userAssignOpp =[select Opportunity__r.Id,Opportunity__r.Opportunity_Owner__c,Opportunity__r.Name, Opportunity__c,Id,
                            Account__r.Id, Account__c ,User__r.Forecast_Group__c, User__c,Assignment_Status__c,
                            Opportunity__r.House_Account_Name__c,Assignment_Group__c,Name
                            From User_Assignment__c where user__c=:rep.id and lastmodifiedbyId=:rep.id];
        
        List<String>oppID= new List<String>() ;
       
      for(User_Assignment__c collectOppID:userAssignOpp){
          oppID.add(collectOppID.Opportunity__r.Id);
      }   
          
      opps  = new Map<Id,Opportunity>([Select owner.isactive,Account.Name,Amount,CloseDate,Name, Owner.Alias, StageName,Owner.Name from Opportunity  where id in :oppID]);             
      Map<Id,String> result= new Map<Id,String>();
      Map<Id,String> finalResult = new Map<Id,String>();
      
      //System.debug('addSalesTeamMember '+'calling User_Assignment__c  ' );
      //System.debug('addSalesTeamMember '+'userAssignOpp.size'+userAssignOpp.size() );
      
      Boolean rollbackUser=false; // when FG is not same    
      showresultsection = True;                          
      for(User_Assignment__c ua:userAssignOpp){
       //System.debug('addSalesTeamMember '+'Inside for loop  ' );
       //System.debug('addSalesTeamMember '+'rep.Forecast_Group__c  '+rep.Forecast_Group__c );                              
       //System.debug('addSalesTeamMember '+'ua.Assignment_Group__c  '+ua.Assignment_Group__c );
       // check all the user assignments having same Assignment group as users FG  
           
           if (rep.Forecast_Group__c != ua.Assignment_Group__c && ua.Assignment_Group__c != 'House Account'){  
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,UA.Name+':  '+Label.Assign_Self_Forecast_Group_Not_Same);
                ApexPages.addMessage(msg);
                showresultsection = false;
                showOkButton = True;  
                rollbackUser=true;
                break;                 
           } 
           //else if(rep.Forecast_Group__c == 'Direct' && ua.Assignment_Group__c == 'House Account'){
           else if(mapSpecial_Forecast_Groups.containskey(rep.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(rep.Forecast_Group__c).Ownership_Allowed__c)
           {
               if(ua.Opportunity__r.Opportunity_Owner__c == HouseAccountId[1].House_Account_User__c){
                     ChangeOwnerList.add(opps.get(ua.Opportunity__r.Id));    
                }
                else{
                     DeleteHouseAccountList.add(opps.get(ua.Opportunity__r.Id));
                }          
           }
           else{
                oppOthers.add(opps.get(ua.Opportunity__r.Id));
           }      
        }  
        System.debug('HouseAccount --> ' + ChangeOwnerList);
        System.debug('Delete House Account'+DeleteHouseAccountList);
        System.debug('OtherAccount --> ' + oppOthers);
        if(rollbackUser){
            for(User_Assignment__c ua:userAssignOpp){     
                ua.User__c = null;
                ua.Assignment_Status__c = 'Not Assigned';
            }
           update userAssignOpp;
           return;
 
        }
            //call the resitrict user permission method from OpportunityAssignListController 
            System.debug('oppHouse.size()------>' +ChangeOwnerList.size());
            System.debug('oppOthers.size()------>' +oppOthers.size());
           //System.debug('addSalesTeamMember '+'Pass all validations calling addsalesteamMember  ' );
            if(ChangeOwnerList!=null && ChangeOwnerList.size()>0){
                set<ID>SetOwenrOpps = new set<id>();     
                for(Opportunity opp:ChangeOwnerList){
                    SetOwenrOpps.add(opp.id);
                }
                result =new Opp_MassUserReassignment().addSalesTeamMember(rep,ChangeOwnerList,'Edit',SetOwenrOpps,null);
                finalResult.putAll(result);
            }
            

            if(DeleteHouseAccountList!=null && DeleteHouseAccountList.size()>0){
                result =new Opp_MassUserReassignment().addSalesTeamMember(rep,DeleteHouseAccountList,'Edit', null,null);
                finalResult.putAll(result);
            }
            if(oppOthers!=null && oppOthers.size()>0){
                result =new Opp_MassUserReassignment().addSalesTeamMember(rep,oppOthers ,'Edit', null,null);
                finalResult.putAll(result);
            } 
            //System.debug('addSalesTeamMember '+'result '+result  );
             
             String ResultMessage= ''; 
               
             List<User_Assignment__c>Delete_userAssignOpp = new List<User_Assignment__c>(); 
             List<User_Assignment__c>update_userAssignOpp = new List<User_Assignment__c>(); 
             System.Debug('User_Assignment__c------>' +userAssignOpp);
             for(User_Assignment__c ua:userAssignOpp){
                  String str_result=finalResult.get(ua.Opportunity__r.Id);
                  ResultMessage=ResultMessage+'<BR> ' +ua.Opportunity__r.Name+': '+str_result;
                  System.Debug('ResultMessage---------->' +ResultMessage); 
                  if(str_result!=null && str_result.contains('success')){
                      Delete_userAssignOpp.add(ua); 
                      successOpps=successOpps+' '+ua.Opportunity__r.Name + ',';
                  }
                  // Srinivas Nallapati :  WR-170057 
                  else if(str_result!=null && str_result.contains(System.label.Error_Sales_Rep_exist_on_Sales_Team)){
                      Delete_userAssignOpp.add(ua); 
                      successOpps=successOpps+' '+ua.Opportunity__r.Name + ',';                 	
                  }
                  else{
                     failOpps=failOpps+' '+ua.Opportunity__r.Name + ','; 
                     System.Debug('FailOpps---------->' +failOpps);  
                     ua.User__c=null;
                     ua.Assignment_Status__c = 'Not Assigned';
                     update_userAssignOpp.add(ua);   
                  }              
             }  
             
              if(Delete_userAssignOpp.size()>0){
                delete Delete_userAssignOpp;
            }
           if(update_userAssignOpp.size()>0){
                update update_userAssignOpp;
            }
            if(DeleteHouseAccountList.size()>0){
                List<OpportunityTeamMember> salesteam= [Select o.OpportunityId, o.UserId, o.User.Name from OpportunityTeamMember o where o.user.name='House Account' and opportunityId in:DeleteHouseAccountList];
                if(salesteam.size()>0){
                    delete salesteam;
                }
            }
            //ApexPages.Message errmsg = new ApexPages.Message(ApexPages.Severity.Info,ResultMessage );
            //ApexPages.addMessage(errmsg );  
            
            if(successOpps!=''){
                successOpps = successOpps.substring(0,successOpps.length()-1); 
                showAssignedMessage=true;
            }
            if(failOpps!=''){
                failOpps = failOpps.substring(0,failOpps.length()-1);
                showRepExist=true;   
            }
            
            showOkButton=true;                  
          System.Debug('showRepExist---------->' +showRepExist);
            System.Debug('showAssignedMessage---------->' +showAssignedMessage);

            
            
            List<Opportunity> opportunityResult = [Select owner.isactive,Amount,Account.Name,CloseDate,Id,Name,Opportunity_Owner__c,Opportunity_Owner__r.Alias,StageName from Opportunity where Id in :finalResult.keySet()];
            //MassSalesTeamOperation.OpportunityWrapper assignObj = new MassSalesTeamOperation.OpportunityWrapper();
            for(Opportunity oppty:opportunityResult){
                MassSalesTeamOperation.OpportunityWrapper resultRow = new MassSalesTeamOperation.OpportunityWrapper(oppty,true,null);
                resultRow.setResult(finalResult.get(resultRow.opp.Id));
                opportunityWrapResult.add(resultRow);
            }
           
            //new MassSalesTeamOperation().setoppWrap(opportunityWrapResult);
        }
        
        
     public List<MassSalesTeamOperation.OpportunityWrapper> getopportunityWrapResult(){
            return opportunityWrapResult;
     }
     
     /*  Code commented by Anand Sharma on 27-July-2010 for WR 141528 - duplicated id issue 
        This code was producing duplicate assignment rule recode issue.

     public static webservice String updateUserAssignment(List<String> UserAssignemntId,String userId){
         System.debug('userId '+userId);
         System.debug('UserAssignemntId------> '+UserAssignemntId);
         // Check the users exsting assignments
         List<User_Assignment__c> Existing_userAssignOpp =[select Opportunity__r.Id, Opportunity__r.Name, Opportunity__c,Id,
                            Account__r.Id, Account__c ,User__r.Forecast_Group__c, User__c,
                            Opportunity__r.House_Account_Name__c,Assignment_Group__c,Name
                            From User_Assignment__c where user__c=:userId ];
        
        for(User_Assignment__c ua:Existing_userAssignOpp){     
                ua.User__c = null;
                ua.Assignment_Status__c='Not Assigned';
        }

         List<User_Assignment__c> userAssignOpp =[select Opportunity__r.Id, Opportunity__r.Name, Opportunity__c,Id,
                            Account__r.Id, Account__c ,User__r.Forecast_Group__c, User__c,
                            Opportunity__r.House_Account_Name__c,Assignment_Group__c,Name
                            From User_Assignment__c where id in:UserAssignemntId and Assignment_Status__c='Not Assigned'];
        System.debug('userAssignOpp '+userAssignOpp );
        for(User_Assignment__c ua:userAssignOpp){     
                ua.User__c = userId;
                ua.Assignment_Status__c='In Progress';
        }
        userAssignOpp.addall(Existing_userAssignOpp);
        Database.SaveResult[] rs= Database.update( userAssignOpp );
        
        return ''+rs;
        
     }
     */ 

     //Fix for the WR 141528: Javascript error for Duplicate Id of user assignment 
     //created by Anand Sharma on 27-July-2010     
     //Created method which will update User assignment record and assigned logged user to user assignment record.
     public static webservice String updateUserAssignment(List<String> UserAssignemntId,String userId){
        System.debug('userId '+userId);
        System.debug('UserAssignemntId------> '+UserAssignemntId);
        
        // fetch existing user assignment records
        Map<Id, User_Assignment__c> map_ExistingUserAssignOpp = new Map<Id, User_Assignment__c>([select Opportunity__r.Id, Opportunity__r.Name, Opportunity__c,Id,
                                                                Account__r.Id, Account__c ,User__r.Forecast_Group__c, User__c,
                                                                Opportunity__r.House_Account_Name__c,Assignment_Group__c,Name
                                                                From User_Assignment__c where user__c=:userId ]); 
        System.debug('map_ExistingUserAssignOpp --> '+map_ExistingUserAssignOpp );
        
        // fetch user assignment record using assignment id
        Map<Id, User_Assignment__c> map_UserAssignOpp = new Map<Id, User_Assignment__c>([select Opportunity__r.Id, Opportunity__r.Name, Opportunity__c,Id,
                                                        Account__r.Id, Account__c ,User__r.Forecast_Group__c, User__c,
                                                        Opportunity__r.House_Account_Name__c,Assignment_Group__c,Name
                                                        From User_Assignment__c 
                                                        where id in:UserAssignemntId]);
        System.debug('map_UserAssignOpp --> '+map_UserAssignOpp );
        
        // Set assign user value as logged user and assignment status is In Progress for all existing user assignment records. 
        for(User_Assignment__c objUA:map_UserAssignOpp.values()){     
                objUA.User__c = userId;
                objUA.Assignment_Status__c='In Progress';
        }         
        
        // Set assign user value as null and assignment status is Not Assigned for all existing user assignment records.                                                        
        for(User_Assignment__c objUserAssgn: map_ExistingUserAssignOpp.values()){
            objUserAssgn.User__c = null;
            objUserAssgn.Assignment_Status__c ='Not Assigned';
            //check for user assignment record exist in map_UserAssignOpp
            //and if record is not exist into map_UserAssignOpp, then add to map_UserAssignOpp.
            if(!map_UserAssignOpp.containsKey(objUserAssgn.Id)){
                map_UserAssignOpp.put(objUserAssgn.Id, objUserAssgn);
            }
        }
        
        //Update User assignment records         
        Database.SaveResult[] rs= Database.update( map_UserAssignOpp.values() );
        
        return ''+rs;
        
     }     
}