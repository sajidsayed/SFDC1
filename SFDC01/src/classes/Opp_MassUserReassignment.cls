/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     DESCRIPTION                               
 |  ====       =========     =========== 
 |  25-Mar-10  Saravanan C   Initial creation - Mass Reassignment Functionaltiy - WR 123612
 |  26-Mar-10  Prasad k      Add Sales team member methods Method 
    22-Apr-10  Karthik       Custome label "Error_Sales_Rep_exist_on_Sales_Team" is added in line 676. 
    26-Apr-10  Prasad k      Change in Add sales team member design to support Repalce method 
    28-Apr 10  Arif          Added 'setAsOwner==false' in if condition for update Share access.  
    08-Jun-10  Saravanan.C   updated for Defect 696 - WR 138230
    04-Jun-10  Arif          Added 'OpportunityAccessLevel='Read' and RowCause='Manual' in UpdateShareAccess Method in the query
    07-Jun-10  Prasad k      added fix for defect 707 
    16-Jun-10  Saravanan.C   Added fix for In-Active users on remove functionilaty 
    19-Jun-10  Shipra        Worked for  WR 138244 ITEM 3.1
    29-Jul-10  Anand Sharma  Added fix for defect 735, WR-137354: 
                                1. Changed error message display for replace fuctionality in catch block.                                   
                                2. Created new method "createResultValidationErrorResult" to populating eror message to user for opportunity which is not by passing validation rule.
                                3. Added piece of code on line 635: Validate opportunity which is not by passing validation rule.
                                4. Move code from line 816(Try Block) to 826(in finally block): This code will rest the by pass flag of opportunity to false.
    30-Jul-10  Anand Sharma  Added fix for defect 744, WR-137354: 
                                1. Added RowCause='Team' in UpdateShareAccess Method in the query because we are creating team member with rowCause='Team' in mass-reassignment
                                2. This will provide read/write acess to team member where rowCause is team.                             
   11-Aug-10   Shipra Misra  Updated Remove and replace functionality to throw exception when Oppty being updated has inactive user.
   20-Aug-10   Shipra Misra  Updated CODE for Line.507-526 at Developer script exception from EMC : Opp_MassUserReassignment : Too many SOQL queries: 101                       
   10-Jan-11   Srinivas      Worked on WR-151992, for IIG reorg. Adding new 4 Direct SST forecast groups 
   31-jan-11   Srinivas      Code Cleaned for Too many SOQL queries 101 exception . Using UserHelper Class to get User recoreds  
   04-Feb-11   Srinivas      Changed the "Contains" to "==" in getRemoveValdnExtn() for bug #808, #809
   03-Mar-11   Srinivas      Changed the byPassValdn() method to use the 'byPass'  boolean argument.    
   12-Apr-11   Srinivas      Added new method updateSplits for WR-162884  And changed Mapping method Removing Sales Team Member for Orphan Detail Lines 
 | 10-Sep-2011    Shipra M  172224  Oppty OAR: Trigger OAR when Account Owner changes from any House Account to a real user.
 | 04-Nov-2011    Srinivas  IM7249975    Fix for Prod issue MassUserassignment Remove functionality was throwing "Script thrown Exception", Because Apex Code was trying to copy split % from  Detail Line to Standard OpportunitySplit that dont allow any split grater tha 100.
   14 Mar 2012  Avinash K   Added a condition (in addSalesTeamMember() method)to check if the Split% exceeds 100 for an existing Sales Rep 
                            when removing another Rep.
+===========================================================================*/

Public Class Opp_MassUserReassignment{

/*** Global Variables Starts ***/
    Public User newUser,oldUser;
    OP_SSF_CommonUtils cls_oppSSF = new OP_SSF_CommonUtils();
    Map<Id,Map<Id,SalesTeamMember>> map_salesTeamMbr = new Map<Id,Map<Id,SalesTeamMember>>();
    Map<Id,List<OpportunityLineItem>> map_oppyProds = New Map<Id,List<OpportunityLineItem>>();
    Map<id,Opportunity> map_accOwner;
    List<Detail_Line__c> list_updateDetailLine = new List<Detail_Line__c>();
    List<Detail_Line__c> list_deleteDetailLine = new List<Detail_Line__c>();
    List<SalesTeamMember> List_removeslsTeamMbr = new List<SalesTeamMember>();
    Map<id,list<SalesTeamMember>> map_updateSplit = new Map<id,list<SalesTeamMember>>();
    Map<id,string> map_result = new Map<id,string>();
    Map<id,string> map_returnresult = new Map<id,string>();
    list<OP_SSF_SaveResult> oppSSFresult = new list<OP_SSF_SaveResult>();
    Map<Id,Id> ownerMap = new Map<Id,Id>();
    List<Opportunity> list_updateOppty = new List<Opportunity>();
    Map<Id,User> map_addSlsTeamMbr = new Map<Id,User>();
    List<Id> lst_addSlsTeamMbr = new List<Id>();
    List<Id> lst_byPassValdn = new List<Id>();
    List<Opportunity> lst_opptyByPassValdn ;
    Map<Id,decimal> map_replaceUserSpltPerct = new map<id,decimal>();
    Map<Id,Id> ownerMapReplace = new Map<Id,Id>();
    Id accowner;
    string error;
    Boolean isInActiveUser;
    
    //defined the boolean variable for Channel vis to run.
    Public static Boolean IsMassReassignChannelVisCalled=false;
    
    //Added by Srinivas for new IIG Forecast Groups
    Map<String,Special_Forecast_Groups__c>  mapSpecial_Forecast_Groups = Special_Forecast_Groups__c.getAll();
    //Added by srinivas for too many SOQL 101 errors
    Map<id,User> mapUsers = new Map<id,User>();   
    //////////////////////////////
    
/*** Global Variables Ends ***/
   
 
    /**
    Remove Sales Team Members (OpportunityId`s,oldUserId) records
    that are passed in input
    @param List<Id> OpportunityId - List of opportunities that need to be replaced the sales team member.
    @param oldUserId UserId that need to be removed from the sales team member.
    Author - Saravanan C
    */
    public map<id,string> remove(List<id> list_Oppty,Id userId){
        Log('Input parameters ==> '+List_Oppty+' UserId = '+UserId);
        Mapping(list_Oppty);
        Set<Id> userIds = new Set<Id>();
        userIds.add(userId);
        oldUser = getuserDetails(userIds).get(userId);
        
        // Added by Srinivas to resolve Too many SOQL 101 issue, received by developer script exception email
        Set<Id> stmUserIds = new Set<Id>();
        for(id opptyid:map_salesTeamMbr.keyset())
        {
            for( SalesTeamMember stm : map_salesTeamMbr.get(opptyid).values() )
            {
                if(stm.opptyTeamMember != null)
                    stmUserIds.add(stm.opptyTeamMember.UserId);
            }
        }
        mapUsers = UserHelper.getUserRecords(stmUserIds);
        //UserInfoMap = [Select Username, UserType, UserRoleId, Title, Theater__c, SFDC_User_ID__c, Role__c, Region__c, Profile_Name__c, ProfileId, Opportunity_Re_Open_Permission__c, Name,
        //                        Manual_Opportunity_Booking_Permission__c, Manager__c, ManagerId, IsActive, Id, Forecast_Group__c, Employee_Number__c, Email, Division__c, District__c, Country__c, Country, BU__c, Allow_Mass_Reassignment__c where id in:stmUserIds];   
        //End of Change by Srinivas
      
      For(Id Oppty: List_Oppty){
          log('map_salesTeamMbr==>'+map_salesTeamMbr.get(Oppty));
          log('Map_OppyProds ===> '+Map_OppyProds);
           if(!map_accOwner.get(oppty).Owner.isActive){                
                map_result.put(Oppty,System.Label.Inactive_Accounts);
                if(map_salesTeamMbr.containsKey(Oppty)){
                    map_salesTeamMbr.remove(Oppty);
                }
                continue;    
            }
          validationlog('Validation 01 : Enter - Is this resource already on the sales team? ');
          //Added condition map_salesTeamMbr.get(Oppty)!= null for WR-160725
          if(map_salesTeamMbr.get(Oppty)!= null && map_salesTeamMbr.get(Oppty).get(oldUser.id) != null ){
              validationlog('Validation 01 : YES ');
              validationlog('Validation 02 : Enter - Is this resource the only member on the sales team? ');
              if(map_salesTeamMbr.get(Oppty).size() == 1){
                  validationlog('Validation 02 : YES ');
                  Log('Error Message : Resource is the last member of the sales team. ');
                  map_result.put(Oppty,'Resource is the last member of the sales team. Please use "Replace" functionality.');  
              }else{
                  validationlog('Validation 02 : NO ');
                  validationlog('Validation 03 : Enter - Is this resource the account owner? ');
                  log('acc owner ==>'+map_accOwner.get(oppty).ownerId+' userid==>'+oldUser.id);
                  
                  String FG1 = ' ';
                  if(map_salesTeamMbr.get(Oppty).get(oldUser.id).detailSplit != null)
                    FG1 = map_salesTeamMbr.get(Oppty).get(oldUser.id).detailSplit.Forecast_Group__c;
                  else
                    FG1 = map_salesTeamMbr.get(Oppty).get(oldUser.id).opptyTeamMember.User.Forecast_Group__c;                  
                  
                  if(map_accOwner.get(oppty).ownerId == oldUser.id ){
                      validationlog('Validation 03 : YES  ');
                      validationlog('Validation 04 : Enter - are there other direct reps or maintanence ...? ');
                      //Srinivas Add if map_salesTeamMbr.get(Oppty).get(oldUser.id).detail.forecast group or .temMber.forecast group, 
                      // Pass same areguments to the function or If current user is not account eligible pass Argument as some eligible FG
                      //(mapSpecial_Forecast_Groups.containskey(rep.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(rep.Forecast_Group__c).Ownership_Allowed__c)

                     system.debug('FG1 '+FG1);   
                      if( !(mapSpecial_Forecast_Groups.containskey(FG1) && mapSpecial_Forecast_Groups.get(FG1).Ownership_Allowed__c) )
                      {
                          Log('Error Message : User is Account Owner and his Forecast group is not Account Owner-Eligible ');
                          map_result.put(Oppty,'User trying to remove is Account Owner and his Forecast group is not Account Owner-Eligible. Please change the ownership to valid user.');
                         
                        continue; 
                        /*for(Special_Forecast_Groups__c spfg : mapSpecial_Forecast_Groups.values())
                        {
                            if(spfg.Ownership_Allowed__c)
                                 FG1 = spfg.name;
                        }*/
                        
                      }  
                      
                     /* if(FG1 != 'Direct' || FG1 != 'Maintenance Renewals')
                      {  
                        FG1='Direct';
                        FG2 ='Maintenance Renewals';
                      }  */ 
                      //End of change by Srinivas  
                      if(getremoveValdnExtn(Oppty,FG1,true))
                      {
                          validationlog('Validation 04 : YES ');
                          // Work around for Inactive users 
                          if(isInActiveUser == False){
                           //addSplitstoUpdatereplace(Oppty,olduser.id,olduser.id,0);
                           Log('The removal was not successful because you are trying to remove the Opportunity Account Owner. Please use the Replace function instead, and choose a new Opportunity Account Owner');
                           map_result.put(Oppty,'The removal was not successful because you are trying to remove the Opportunity Account Owner. Please use the Replace function instead, and choose a new Opportunity Account Owner');
                          }else{
                               if(map_salesTeamMbr.get(Oppty).get(olduser.id).detailSplit != null){
                               log('===>check if'+accowner);
                                  map_updateSplit.put(Oppty,addSplitstoUpdatereplace(Oppty,accowner,olduser.id,map_salesTeamMbr.get(Oppty).get(olduser.id).detailsplit.Split__c));
                                 log('===>check if'+map_updateSplit);
                              }else{
                                  log('===>check else '+map_updateSplit);
                                  addSplitstoUpdatereplace(Oppty,accowner,olduser.id,0);
                              }
                           map_result.put(Oppty,'Success');
                          }
                          lst_byPassValdn.add(Oppty);
                      }else{
                      
                          validationlog('Validation 04 : NO ');
                          Log('Error Message : Cannot use other sales team member to designate ... ');
                          map_result.put(Oppty,'Cannot use other sales team member to designate as an account owner. Please use Replace functionality.');
                      
                      }
                  }else{
                      validationlog('Validation 03 : NO ');
                      validationlog('Validation 05 : Enter - Are there othere resources on the sales team ...? ');
                      //if(getremoveValdnExtn(Oppty,oldUser.Forecast_Group__c,false)){
                      if(getremoveValdnExtn(Oppty,FG1,false)){
                          validationlog('Validation 05 : YES ');
                          if(isInActiveUser == False){
                           addSplitstoUpdatereplace(Oppty,olduser.id,olduser.id,0);
                           Log('There are no active users on the sales team who share the Forecast Group of the removed users. Please review this opportunity ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“ splits may need manual adjustment. ');
                           map_result.put(Oppty,'There are no active users on the sales team who share the Forecast Group of the removed users. Please review this opportunity ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“ splits may need manual adjustment.');
                          }else{    
                              if(map_salesTeamMbr.get(Oppty).get(olduser.id).detailSplit != null){
                                  map_updateSplit.put(Oppty,addSplitstoUpdatereplace(Oppty,accowner,olduser.id,map_salesTeamMbr.get(Oppty).get(olduser.id).detailsplit.Split__c));
                              }else{
                                  addSplitstoUpdatereplace(Oppty,accowner,olduser.id,0);
                              }
                              map_result.put(Oppty,'Success');
                            }
                              lst_byPassValdn.add(Oppty);
                      }else{
                          validationlog('Validation 05 : NO ');
                          List_removeslsTeamMbr.add(map_salesTeamMbr.get(Oppty).get(oldUser.Id));
                          map_result.put(Oppty,'Success');
                          lst_byPassValdn.add(Oppty);
                      }
                  }
              }
              
          }else{
              validationlog('Validation 01 : NO ');
              Log('Error Message : Resource is NOT a member of the sale team. ');
              map_result.put(Oppty,'Resource is not a member of the sales team.');
         }

      }//For loop closing

    log('List_removeslsTeamMbr :: '+List_removeslsTeamMbr);
    log('map_updateSplit ==>'+map_updateSplit);
    
    Savepoint sp = Database.setSavepoint();

    try{
    
     if(lst_byPassValdn.size()>0){
           byPassValdn(getOpportunties(lst_byPassValdn), true);
       }
       
     if(ownerMap.size()>0){
     system.debug('ownerMap.size() '+ownerMap.size()  +ownerMap);
        changeOwner(ownerMap);
     }  
     
    if(map_updateSplit.size()>0){
        //Calling the retrieveUserData of UserHelper for all users in the SalesTeamMember of all opportunites to avoid Too many SOQL as we are calling updateSplits method in a loop
        //Coming from the FilterInactiveUser() method of OP_SSF_CommonUtils
        set<id> setuserids = new set<id>();
        for(Id splt: map_updateSplit.keyset())
        {
            for( SalesTeamMember tmpMbr: map_updateSplit.get(splt) )
                if(tmpMbr.opptyTeamMember != null)
                    setuserids.add(tmpMbr.opptyTeamMember.UserId);
        }
        UserHelper.retrieveUserData(setuserids);
        //End of Change for TOO MANY SOQLs
        /*for(Id splt: map_updateSplit.keyset()){
            cls_oppSSF.updateSplits(map_updateSplit.get(splt));
         }*/
         updateSplits(map_updateSplit);
         
     }
     
      for( string res: map_result.keyset()){
          map_returnresult.put(res,map_result.get(res));
      }
      
      if(List_removeslsTeamMbr.size()>0){    
       cls_oppSSF.removeSalesTeamMembers(List_removeslsTeamMbr);
      }
       if(lst_byPassValdn.size()>0){
           byPassValdn(getOpportunties(lst_byPassValdn), false);
       }
      log('map_returnresult try ==>'+map_returnresult);
      
      } catch (Exception e) {
      
      Database.rollback(sp);
   
      for( string res: map_result.keyset()){
          map_returnresult.put(res,'Error : '+e.getMessage());
      }

      log('map_returnresult catch ==>'+map_returnresult);

      }finally{
      list<Mass_Opp_Reassignment_log__c> updateLogResult = new list<Mass_Opp_Reassignment_log__c>();
      string tmpusername = Userinfo.getUserId();
      string tmplogTime = system.now().format('dd/MM/yyyy h:mm a') +' ' ;
          for(Id Oppty: List_Oppty){

          updateLogResult.add(new  Mass_Opp_Reassignment_log__c( Opportunity_name__c=Oppty,User__c = tmpusername,
                      Scenario__c = 'Remove',Opportunity__c = Oppty,Result__c = map_returnresult.get(Oppty),
                      log_time__c = tmplogTime));
          
          }
      insert updateLogResult;
       }
      
      log('map_result==>'+map_returnresult);
      return map_returnresult;
     }//Method Closing
     
        
    /**
    Replace Sales Team Members (OpportunityId`s,newUserId,oldUserId) records
    that are passed in input
    
    @param List<Id> OpportunityId - List of opportunities that need to be replaced the sales team member.
    @param oldUserId UserId that need to be removed from the sales team member.
    @param newUserId UserId that need to be added to the sales team member.
    Author - Saravanan C
    */
    public map<id,string> replace( List<Id> List_Oppty,Id newUserId, Id oldUserId){
        Log('Input parameters ==> '+List_Oppty+' newUserId = '+newUserId+' oldUserId = '+oldUserId);
        Mapping(List_Oppty);
        Set<Id> userIds = new Set<Id>();
        userIds.add(newUserId);
        userIds.add(oldUserId);
        Map<Id,User> userMap = new Map<Id,User>();
        userMap.putAll(getuserDetails(userIds));
        newUser = userMap.get(newUserId);
        oldUser = userMap.get(oldUserId);
        for(Id Oppty: List_Oppty)
        {
            if((!map_accOwner.get(oppty).Owner.isActive) && (map_accOwner.get(oppty).OwnerId !=oldUserId))
            {                
                map_result.put(Oppty,System.Label.Inactive_Accounts);
                if(map_salesTeamMbr.containsKey(Oppty))
                {
                    map_salesTeamMbr.remove(Oppty);
                }
                continue;   
            }
            if(map_salesTeamMbr.get(Oppty)!= null && map_salesTeamMbr.get(Oppty).get(oldUser.id) != null )
            {
                log('==>'+map_salesTeamMbr.get(Oppty));
                log('==> Old user'+oldUser.name+' New user = '+newUser.name);
                validationlog('Validation 01 : Enter - Is the old user resource same as the new resource? ');
                if(newUserId == oldUserId)
                {
                    validationlog('Validation 01 : YES ');
                    Log('Error Message : "New Resource" cannot be same as "Old Resource". ');
                    map_result.put(Oppty,'"New Resource" cannot be same as "Old Resource".Please select a different resource.');
                }else
                {         
                    validationlog('Validation 01 : NO '); 
                    validationlog('Validation 02 : Enter - Are there any prods on opportunity? ');
                    log('Map_OppyProds ===> '+Map_OppyProds);
                    if(Map_OppyProds.ContainsKey(Oppty) )
                    {
                        validationlog('Validation 02 : YES ');
                        validationlog('Validation 04 : Enter - Does the new resource have ...? ');
                        if(map_salesTeamMbr.get(Oppty).get(oldUser.id).detailSplit == null)
                        {
                            validationlog('User does have any products in Opportunity ');
                            replaceforNoProduct(Oppty);
                        }else
                        {
                            if((newUser.Forecast_Group__c == oldUser.Forecast_Group__c ) && (map_salesTeamMbr.get(Oppty).get(oldUser.id).detailSplit.Forecast_Group__c == newUser.Forecast_Group__c) )
                            {
                                validationlog('Validation 04 : YES ');
                                validationlog('Validation 05 : Enter - Is the new resource already ...? ');  
                                if(map_salesTeamMbr.get(Oppty).get(newUser.id) != null )
                                {
                                    validationlog('Validation 05 : YES ');
                                    validationlog('Validation 06 : Enter - For new resource, is the FG ...? ');
                                    if(map_salesTeamMbr.get(Oppty).get(newUser.id).detailSplit.Forecast_Group__c == newUser.Forecast_Group__c)
                                    {
                                        validationlog('Validation 06 : YES ');
                                        if(map_salesTeamMbr.get(Oppty).get(olduser.id).detailSplit != null)
                                        {
                                            map_updateSplit.put(Oppty,addSplitstoUpdatereplace(Oppty,newuser.id,olduser.id,map_salesTeamMbr.get(Oppty).get(olduser.id).detailsplit.Split__c));
                                        }else
                                        {
                                            addSplitstoUpdatereplace(Oppty,newuser.id,olduser.id,0);
                                        }
                                        replaceValdExtn(Oppty);
                                        lst_byPassValdn.add(Oppty);
                                        map_result.put(Oppty,'Success');
                                        //Defect 725//
                                        // ownerMapReplace.put(Oppty,newuser.id);
                                        //*Defect 725*//
                                        log('map_updateSplit ==>'+map_updateSplit);
                                        log('List_removeslsTeamMbr ==>'+List_removeslsTeamMbr);
                                   }else
                                   {
                                        validationlog('Validation 06 : NO ');
                                        Log('Error Message : User you have specified is already in the ...? ');
                                        map_result.put(Oppty,'User you have specified is already in the sales team with different FG. Please remove this resource before re-attempting for the replacement');
                                   }

                                }else
                                {
                                    validationlog('Validation 05 : NO ');
                                    for( SalesTeamMember stm : map_salesTeamMbr.get(Oppty).values() )
                                    {
                                        if(stm.opptyTeamMember.UserId == olduser.id)
                                        {
                                            log('stm ==>'+stm );
                                            OpportunityTeamMember tmpotm = new OpportunityTeamMember(OpportunityId=Oppty, UserId=newuser.id, TeamMemberRole=stm.opptyTeamMember.TeamMemberRole);
                                            Detail_Line__c tmpdl = new Detail_Line__c(Split__c=stm.detailSplit.Split__c, OwnerId=newuser.id, Opportunity_Access_Level__c=stm.detailSplit.Opportunity_Access_Level__c,Forecast_Group__c = newuser.Forecast_Group__c );
                                            SalesTeamMember tmp = new SalesTeamMember(false,tmpotm,tmpdl );
                                            lst_addSlsTeamMbr.add(Oppty);
                                            List_removeslsTeamMbr.add(stm);
                                            map_replaceUserSpltPerct.put(Oppty,stm.detailSplit.Split__c);
                                        }
                                    }
                                    replaceValdExtn(Oppty);
                                    lst_byPassValdn.add(Oppty);
                                    map_result.put(Oppty,'Success');
                                }  //else closing
                               
                            }else
                            {
                                validationlog('Validation 04 : NO ');
                                Log('Error Message : Oppty cannot be updated if FG`s are mismatched. ');
                                map_result.put(Oppty,'Oppty cannot be updated if FG`s are mismatched.');
                            }
                        }  
                    }else
                    {
                        replaceforNoProduct(Oppty);
                    }

                }// else colsing
            }else
            {
                map_result.put(Oppty,'Resource is not a member of the sales team.');
            }
            
        }//for loop closing

        log('List_removeslsTeamMbr ==>'+List_removeslsTeamMbr);
        log('map_result ==>'+map_result);                              
        Savepoint sp = Database.setSavepoint();
        
        try{    
     
            if(lst_byPassValdn.size()>0){
                byPassValdn(getOpportunties(lst_byPassValdn), true);
            }
            if(ownerMapReplace.size()>0){
                log('ownerMapReplace ==>'+ownerMapReplace);  
                changeOwner(ownerMapReplace);
            }  

            //added by prasad to create list of oppids to set owner
            Set<Id> SetOwnerOppIds=new Set<Id>(); 
            for(Id oppId:ownerMapReplace.keySet()){
                SetOwnerOppIds.add(oppId);
            }

            if(lst_addSlsTeamMbr.size()>0){
                log('getOpportunties(lst_addSlsTeamMbr) ==>'+getOpportunties(lst_addSlsTeamMbr));  
                log('map_replaceUserSpltPerct ==>'+map_replaceUserSpltPerct);  
                addSalesTeamMember(newUser ,getOpportunties(lst_addSlsTeamMbr),'Edit',SetOwnerOppIds,map_replaceUserSpltPerct);
            } 
      
            if(lst_byPassValdn.size()>0){
                byPassValdn(getOpportunties(lst_byPassValdn), true);
            }

    
            log('map_updateSplit ==>'+map_updateSplit);  
            log('map_updateSplit map_updateSplit.size() ==>'+map_updateSplit.size()); 
            if(map_updateSplit.size()>0){
               /* for(Id splt: map_updateSplit.keyset()){
                    log('map_updateSplit splt ==>'+splt);
                    cls_oppSSF.updateSplits(map_updateSplit.get(splt));
                }*/
                updateSplits(map_updateSplit);
                
            }
     
            if(List_removeslsTeamMbr.size()>0){    
                cls_oppSSF.removeSalesTeamMembers(List_removeslsTeamMbr);
            }
      
            for( string res: map_result.keyset()){
                map_returnresult.put(res,map_result.get(res));
            }
      
            log('map_returnresult try ==>'+map_returnresult);
      
            if(lst_byPassValdn.size()>0){
                byPassValdn(getOpportunties(lst_byPassValdn), false);
            }
      
        }catch (Exception e) {      
            Database.rollback(sp);
            //Change by Anand Sharma on 29-July-2010 : To Show proper validation rule message. 
            String strErrorMessage = 'Error : '+ e.getMessage();
            if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
            }
            //End       
            for( string res: map_result.keyset()){          
               map_returnresult.put(res, strErrorMessage);
            }
            log('map_returnresult catch ==>'+map_returnresult);

        }finally{
            list<Mass_Opp_Reassignment_log__c> updateLogResult = new list<Mass_Opp_Reassignment_log__c>();
            string tmpusername = Userinfo.getUserId();
            string tmplogTime = system.now().format('dd/MM/yyyy h:mm a') +' ' ;
            for(Id Oppty: List_Oppty){
                updateLogResult.add(new  Mass_Opp_Reassignment_log__c( Opportunity_name__c=Oppty,User__c = tmpusername,
                        Scenario__c = 'Remove',Opportunity__c = Oppty,Result__c = map_returnresult.get(Oppty),
                        log_time__c = tmplogTime));
          
            }
            insert updateLogResult;  
        }
      
        log('map_result==>'+map_returnresult);
        return map_returnresult;
    }// Method replace Closing.
    
    //////////////////////////////////////////// Private Helper Methods Starts :: Author - Saravanan C //////////////////////////////////////////////
  
    public void replaceforNoProduct(ID Oppty ){

   validationlog('Validation 02 : NO ');
                 validationlog('Validation 03 : Enter - From User Record...? ');
                 if(newUser.Forecast_Group__c == oldUser.Forecast_Group__c ){
                     validationlog('Validation 03 : YES ');
                      for( SalesTeamMember stm : map_salesTeamMbr.get(Oppty).values() ){
                           if(stm.opptyTeamMember.UserId == olduser.id){
                               OpportunityTeamMember tmpotm = new OpportunityTeamMember(OpportunityId=Oppty, UserId=newuser.id, TeamMemberRole=stm.opptyTeamMember.TeamMemberRole);
                               Detail_Line__c tmpdl;
                               SalesTeamMember tmp;
                               if(stm.detailSplit == null){
                                tmpdl = new Detail_Line__c(Split__c=0, OwnerId=newuser.id, Opportunity_Access_Level__c='Edit',Forecast_Group__c = null );
                                tmp = new SalesTeamMember(false,tmpotm,tmpdl );
                               }else{
                                tmpdl = new Detail_Line__c(Split__c=stm.detailSplit.Split__c, OwnerId=newuser.id, Opportunity_Access_Level__c=stm.detailSplit.Opportunity_Access_Level__c,Forecast_Group__c = newuser.Forecast_Group__c );
                                tmp = new SalesTeamMember(false,tmpotm,tmpdl );
                               }
                              lst_addSlsTeamMbr.add(Oppty);
                              List_removeslsTeamMbr.add(stm);
                             
                              if(Map_OppyProds.ContainsKey(Oppty) && map_salesTeamMbr.get(Oppty).get(oldUser.id).detailSplit != null){
                                  map_replaceUserSpltPerct.put(Oppty,stm.detailSplit.Split__c);
                              }else{
                                integer nullSplt;
                                  map_replaceUserSpltPerct.put(Oppty,nullSplt);
                              }
                            }
                         }
                     replaceValdExtn(Oppty);
                     lst_byPassValdn.add(Oppty);
                     map_result.put(Oppty,'Success');
                 }else{
                     validationlog('Validation 03 : NO ');
                     map_result.put(Oppty,'Oppty cannot be updated if FG`s are mismatched.');
                 }
  
  }
  
    public void byPassValdn(list<Opportunity> Oppts, Boolean byPass){
        lst_opptyByPassValdn = new List<Opportunity>();
        for(Opportunity opp: Oppts){
            //opp.bypass_validation__c=true;
            opp.bypass_validation__c=byPass;
            lst_opptyByPassValdn.add(Opp);
        }
        update lst_opptyByPassValdn;
    }
  
    public List<Opportunity> getOpportunties(List<Id> SelectedOpptyIds){
        List<Opportunity> OppList = new List<Opportunity>();
        OppList = [select id,Account.Name,Amount,CloseDate,Name, Owner.Alias,Owner.isActive, StageName,Owner.Name,bypass_validation__c from opportunity where id in: SelectedOpptyIds];
        return OppList;
    }
    
    private void replaceValdExtn(Id Oppty){
     //updated By srinivas
     validationlog('Validation 07 : Enter - Does FG of old resource Ownership eligible? ');
     if( mapSpecial_Forecast_Groups.containskey(oldUser.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(oldUser.Forecast_Group__c).Ownership_Allowed__c)
     {
         validationlog('Validation 09 : Enter - Was the old resource Account owner? ');
         if(((string)map_accOwner.get(Oppty).OwnerId).contains(oldUser.id)){
             validationlog('Validation 09 : YES ');
                 ownerMapReplace.put(Oppty,newUser.Id);
         }else{
             validationlog('Validation 09 : NO ');
            // --- END ---
         }
     }
     //End of updation.Replacement of the below code.
     else
        validationlog('Validation 07 : NO ');
     /* Commented for IIG Reorg by Srinivas
     validationlog('Validation 07 : Enter - Does FG of old resource = Direct? ');
     if(oldUser.Forecast_Group__c == 'Direct'){
         validationlog('Validation 07 : YES ');
         //...modify vanilla split %

          validationlog('Validation 09 : Enter - Was the old resource Account owner? ');
         if(((string)map_accOwner.get(Oppty).OwnerId).contains(oldUser.id)){
             validationlog('Validation 09 : YES ');
                 ownerMapReplace.put(Oppty,newUser.Id);
         }else{
             validationlog('Validation 09 : NO ');
            // --- END ---
         }
     }else{
         validationlog('Validation 07 : NO ');
         validationlog('Validation 08 : Enter - Does FG of old resource = Maintenance Renewals? ');
         if(oldUser.Forecast_Group__c == 'Maintenance Renewals'){
             validationlog('Validation 08 : YES ');
             validationlog('Validation 09 : Enter - Was the old resource Account owner? ');
             if(((string)map_accOwner.get(Oppty).OwnerId).contains(oldUser.id)){
                 validationlog('Validation 09 : YES ');
                 ownerMapReplace.put(Oppty,newUser.Id);
             }else{
                 validationlog('Validation 09 : NO ');
                // --- END ---
             }
         }
     }*/
    
     
 }//Method replaceValdExtn Closing    

    private Boolean getremoveValdnExtn(Id Oppty,string cond1,Boolean ChangeOwnerFlag){
        Decimal split = 0;
        decimal splitprcnt = 0;
        Boolean Flag = False;
        isInActiveUser = False;
        
        /*
        Srinivas : Commented this lines of code as getting Too many SOQL queries 101 
        
        //Updated code as getting mail:: Developer script exception from EMC : Opp_MassUserReassignment : Too many SOQL queries: 101
        //Date: 20 Aug '10 Sunil Bansal. Line: 509-515,523-525.
        //Added Map having user (Id,user)and using same map inside for loop , thus Removing Too many SOL ueries:101
        Set<Id> setUserIds = new Set<Id>();
        for( SalesTeamMember stm : map_salesTeamMbr.get(Oppty).values() )
        {
            setUserIds.add(stm.opptyTeamMember.UserId);
        }
        Map<Id,User> mapUsers = new Map<Id,User>([Select Id,name,Forecast_Group__c,IsActive from User where id in :setUserIds]);
        */
        
            
        for( SalesTeamMember stm : map_salesTeamMbr.get(Oppty).values() ){
            Log('check here Entering  = ' +olduser.id+ stm );
            if( !((string)(olduser.id)).contains(((String)stm.opptyTeamMember.UserId)) &&
                       ( stm.opptyTeamMember.User.Forecast_Group__c == cond1 ) ){
                Flag = True;       
                User activeUser = mapUsers.get(stm.opptyTeamMember.UserId);
                if(activeUser != null && activeUser.IsActive == True){
                    //End of update Date 20 Aug '10 // 
                     isInActiveUser = True;   
                    //  Log('check here selected  = ' + stm +'split  = '+split +'stm.detailsplit.Split__c'+stm.detailsplit.Split__c+' accowner = '+accowner );
                    if(stm.detailsplit != null && split < stm.detailsplit.Split__c ){
                        split = stm.detailsplit.Split__c;
                        accowner = stm.opptyTeamMember.UserId;
                    //    Log('check here processing  split < stm.detailsplit.Split__c ... = '+split +' accowner = '+accowner );
                    }/*else{
                        accowner = stm.opptyTeamMember.UserId;
                    }*/
                    if(split == 0){
                        accowner = stm.opptyTeamMember.UserId;
                        //     Log('check here processing  if(split == 0) = '+split +' accowner = '+accowner );
                    }   
              
                 
                }
            }
        }
        //  Log('check here Finally = split  = '+split +' accowner = '+accowner );
        //   log('map_salesTeamMbr.get(Oppty).values() ==>'+map_salesTeamMbr.get(Oppty).values());

        //if((cond1 != cond2) && accowner != null ){
        if((ChangeOwnerFlag) && accowner != null ){
            ownerMap.put(Oppty,accowner);  

        }
    
        return Flag; 
 }

    //Defect 727//
    private list<SalesTeamMember> addSplitstoUpdatereplace(Id Oppty,Id newuser,Id olduser,Decimal Split){
        list<SalesTeamMember>  tmpslsteammbr =  new list<SalesTeamMember>();
        for( SalesTeamMember stm : map_salesTeamMbr.get(Oppty).values() ){
            if(stm.detailsplit != null && stm.opptyTeamMember !=  null){ 
                log('Active User===>'+stm.detailsplit.Split__c);
                
//Avinash K - Added the following if-condition to prevent the Split Exceeding 100% when a Sales Rep is removed from a Forecast Group
                if(stm.detailsplit.Split__c + Split <= 100)
                    stm.detailsplit.Split__c = stm.detailsplit.Split__c + Split;
                    
                log('Active User===>'+stm.detailsplit.Split__c);
                if(stm.opptyTeamMember.UserId ==  newuser){
                    tmpslsteammbr.add(stm);
                }
            }
            if( stm.opptyTeamMember != null){ 
                if( stm.opptyTeamMember.UserId == olduser){  
                    log('check here sls ==>'+stm);
                    log('check here sls ==>'+stm.detailsplit);
                    if(stm.detailsplit != null){ 
                       stm.detailsplit.Split__c = 0;
                    }
                    List_removeslsTeamMbr.add(stm);
                }
            }
        }
        return   tmpslsteammbr;
    }
    //*Defect 727*//  
    private void Mapping(List<Id> List_Oppty){
        map_salesTeamMbr = cls_oppSSF.getSalesTeamMembers(List_Oppty);
        //change for Removing Sales Team Member for Orphan Detail Lines WR-162884
        map<id,set<id>> BadDeatilLinesSTMmap = new map<id,set<id>>();
        for(id opptyid : map_salesTeamMbr.keyset())
        {
            for(id uid : map_salesTeamMbr.get(opptyid).keyset())
            {
                if(map_salesTeamMbr.get(opptyid).get(uid).opptyTeamMember == null)
                    if(BadDeatilLinesSTMmap.containskey(opptyid))
                    {
                        BadDeatilLinesSTMmap.get(opptyid).add(uid);                                
                    }else
                    {
                        BadDeatilLinesSTMmap.put(opptyid, new set<id>{uid});
                    }    
            }
        }
        for(id optyid : BadDeatilLinesSTMmap.keyset())
            for(id uid : BadDeatilLinesSTMmap.get(optyid))
                map_salesTeamMbr.get(optyid).remove(uid);
        //End of change for Removing Sales Team Member for Orphan Detail Lines
       
        List<OpportunityLineItem> list_Oli ; 
        for(OpportunityLineItem Oli : [Select   OpportunityId, Id,Opportunity.AccountId, 
                                               Opportunity.Account.ownerid,
                                               Opportunity.Account.owner.name 
                                      From OpportunityLineItem o
                                      Where opportunityId in: List_Oppty]){
            if(map_oppyProds.containsKey(Oli.OpportunityId)){
                list_Oli=map_oppyProds.get(Oli.OpportunityId); 
            }else{
                list_Oli = new List<OpportunityLineItem>();
                map_oppyProds.put(Oli.OpportunityId,List_Oli);
            }
            list_Oli.add(Oli);
        } 
        //log('Map_OppyProds = '+Map_OppyProds);
       
        map_accOwner = new Map<id,Opportunity>([select accountid,owner.isActive,Opportunity_Owner__r.Id,Id,OwnerId
                                           from opportunity 
                                           where id in: List_Oppty]);
        log('map_accOwner = '+map_accOwner);
    }// Method Mapping Closing

    /*
    private User getuserDetails(Id User){
        return [Select Id,name,Forecast_Group__c,IsActive from User where id =: User];
    } 
    */
    
    private Map<Id,User> getuserDetails(Set<Id> userIds){
        Map<Id, User> userMap = new Map<Id,User>([Select Id,name,Forecast_Group__c,IsActive from User where id in: userIds]);
        return userMap;
    } 
    private void log(String logMsg){
        System.debug('*** '+logMsg+' ***');
    }
  private void validationlog(String logMsg){
    System.debug('****************************************');
    System.debug('*** '+logMsg+' ***');
    System.debug('****************************************');
  }
    //////////////////////////////////////////// Private Helper Methods Ends :: Author - Saravanan C //////////////////////////////////////////////
  
  
 
  //********************************** Mass Add ***********************************************
  //******************** Author -Prasad Kothawade *******************
      
    Map<Id,List<OpportunityLineItem>> OpportunityLineItems = new Map<Id,List<OpportunityLineItem>>();
    
    public Static boolean ExecuteOwnerChangeTrigger=true; 
    
      /*Map<Id,List<Detail_Line__c>> DetailLines = new Map<Id,List<Detail_Line__c>>();
    Map<Id,List<c>> SalesTeams = new Map<Id,List<OpportunityTeamMember>>();
    Map<Id,List<OpportunitySplit>> OpportunitySplit = new Map<Id,List<OpportunitySplit>>();
    Map<String,List<Forecast_Group_Product__c>> ProductForecastGroup = new Map<String,List<Forecast_Group_Product__c>>();
    
    List<Opportunity>UsersOpportunities=new List<Opportunity>();
    List<Opportunity>NonUsersOpportunities=new List<Opportunity>();
    */
    Set<ID> OpportunitiesWithNewRep = new Set<ID>();
    Set<ID> OpportunitiesWithRepFGProducts = new Set<ID>(); 
    Set<ID> OpportunitiesWithSameFGReps = new Set<ID>();
    
    Set<ID> ProductsOnNewRepFG=new Set<ID>(); 
    Set<ID> OpportunityIds=new Set<ID>(); 
    Set<ID> HouseAccountOpportunityIds =new Set<ID>();
    List<OpportunityTeamMember> HouseAccountTeamMember = new List<OpportunityTeamMember>();
    Map<Id,String> AccountTeams = new Map<Id,String>();    
    Map<Id,Id>OpportunityAccountMap= new Map<Id,Id>(); 
    Set<Id>setAsOwnerOppIds=new Set<Id>();
    //11 Aug 10 Shipra Misra add fix for 735
    Boolean accountOwnerExist=false;
        
         
    
    public Map<Id,String> addSalesTeamMember(User rep,List<Opportunity>Opportunities,String AccessLevel, Set<Id>setAsOwnerOppIds, Map<Id,decimal>ReplacingUserOpportunitySplitPercentage ){
                
        List<Detail_Line__c> DetailLinesToInesrt=new List<Detail_Line__c>(); 
        List<OpportunitySplit> SplitsToInesrt = new List<OpportunitySplit>();
        List<OpportunityTeamMember> opptyTeamToInsert = new List<OpportunityTeamMember>();
        List<Opportunity> SetOwnerOpps = new List<Opportunity>();
        Map<Id,String> return_result= new Map<Id,String> ();
        String Role;
         
        IsMassReassignChannelVisCalled=true;
        //  28 july 10  Anand Sharma    added fix for defect 735
        Database.SaveResult[] updateOpportunityResult=null;
        List<Opportunity> lst_SucessOpportunity = new List<Opportunity>(); 
        Map<Id, String> map_ErrorOpportunity = new Map<Id,String>();
        Map<Id, Opportunity> map_Opportunity = new Map<Id, Opportunity>();
        Set<Id> setSucessOpportunityIds = new Set<Id>();
        
        for(Opportunity objOpp : Opportunities){
            if(!map_Opportunity.containsKey(objOpp.Id)){
                objOpp.bypass_validation__c = true;
                map_Opportunity.put(objOpp.Id, objOpp);
            }           
        }
        updateOpportunityResult = Database.update(map_Opportunity.values(), false);
        for(Integer i=0; i<updateOpportunityResult.size(); i++){
            if(!updateOpportunityResult[i].isSuccess()){
                map_ErrorOpportunity.put(Opportunities.get(i).Id,updateOpportunityResult[i].getErrors()[0].getMessage());
            }else{
                lst_SucessOpportunity.add(map_Opportunity.get(updateOpportunityResult[i].getId()));
            }
        }
        
        if(lst_SucessOpportunity.size()==0){
            return createResultValidationErrorResult(map_ErrorOpportunity);
        }
        // End Changed
        
        if(setAsOwnerOppIds==null){
            setAsOwnerOppIds= new set<Id>();
        }
        
        this.setAsOwnerOppIds=setAsOwnerOppIds;
        
        for(Opportunity opp:lst_SucessOpportunity){
            System.debug('opp.Owner.isActive '+opp.Owner.isActive);
            System.debug('setAsOwnerOppIds.contains(opp.Id) '+setAsOwnerOppIds.contains(opp.Id));
            if(!opp.Owner.isActive && ! setAsOwnerOppIds.contains(opp.Id) ){                
                return_result.put(opp.Id,System.Label.Inactive_Accounts);
                continue;    
            }
            
            OpportunityIds.add(opp.Id);
            OpportunityAccountMap.put(opp.Id,opp.AccountId);
                       
            //if(setAsOwnerOppIds.contains(opp.Id) && (rep.Forecast_Group__c=='Direct'||rep.Forecast_Group__c=='Maintenance Renewals') && opp.Owner.Name=='House Account'){
            if(setAsOwnerOppIds.contains(opp.Id) && (mapSpecial_Forecast_Groups.containskey(rep.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(rep.Forecast_Group__c).Ownership_Allowed__c) && opp.Owner.Name=='House Account')
            {
                HouseAccountOpportunityIds.add(opp.Id);
            }
            if(setAsOwnerOppIds.contains(opp.id)){
                SetOwnerOpps.add(opp);
            }
        }
       
        if(OpportunityIds.size()==0){
            return return_result;
        }    
         //filterOutOpportunities            
        filterOutOpportunitiesNewRepExist(OpportunityIds,rep.Id,setAsOwnerOppIds);
        OpportunityIds.removeAll(OpportunitiesWithNewRep);
        
        /*
        Code Added-Pratibh: 27 Aug-2010, Lines 27-47
        Code for adding message to Opporunity when New Sales Rep is already present in the Sales Team
        */
        //Start-PP
        for(Id oppId: OpportunitiesWithNewRep){
            return_result.put(oppId , System.Label.Error_Sales_Rep_exist_on_Sales_Team);
        }
        //End-PP         
        // Add user as a rep *******************************************************************
         
        //if user exist on all opportunities
        // UPDATED FOR 138244 
        if(OpportunityIds.size()==0){
            if(setAsOwnerOppIds != null){
                // Set the onwer
               accountOwnerExist=true;
                Database.SaveResult[] changeOwnerReturn = changeOwner(SetOwnerOpps,Rep);
                return_result.putAll(processResult(changeOwnerReturn,SetOwnerOpps));
                return return_result;

            }
            System.debug('All Opps has the rep error out for all');
            return createResultUserExistResult() ;
        }
       // UPDATED FOR 138244 
 
        // Create list of opp to process
        List<Opportunity>OpportunitiesToProcess=lst_SucessOpportunity.deepClone(); 
        integer index=0;
        for(Opportunity opp:lst_SucessOpportunity){
            if(OpportunitiesWithNewRep.contains(opp.Id)){
               OpportunitiesToProcess.remove(index);
            }else{
                index++;
           }     
        }
        
        //bucketOpportunitiesOnUserFG
        getProductsOnNewRepFG(rep.Forecast_Group__c);
        
        //filter out opp on user FGproduct
        filteroutOpportunitiesOnUserFGProduct(OpportunityIds);
        
          //set products of same FG
        setOpportunityLineItems();
        
        // Process UsersOpportunities
        //hasOpportunityReps
        System.debug('2 OpportunitiesWithRepFGProducts  '+OpportunitiesWithRepFGProducts);
        filteroutOpportunitiesHavingReps(OpportunitiesWithRepFGProducts,rep.Forecast_Group__c);
        System.debug('3 OpportunitiesWithRepFGProducts  '+OpportunitiesWithRepFGProducts);
        //create detail Line - 0/100 %
        for(ID OppId:OpportunitiesWithRepFGProducts){
            decimal split;
            if(ReplacingUserOpportunitySplitPercentage!=null && ReplacingUserOpportunitySplitPercentage.get(OppId)!=null){
                split= ReplacingUserOpportunitySplitPercentage.get(OppId);
            
            }else if(OpportunitiesWithSameFGReps.contains(OppId) ){
                split=0;
            }else{
                split=100;
            }
            
            System.debug('OpportunityLineItems.get(OppId) '+OpportunityLineItems.get(OppId));
            System.debug('OppId '+OppId);
            DetailLinesToInesrt.addAll(createDetailLines(Rep,OppId,OpportunityLineItems.get(OppId),rep.Forecast_Group__c,split));
            //if(rep.Forecast_Group__c=='Direct'){
            if(mapSpecial_Forecast_Groups.containskey(rep.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(rep.Forecast_Group__c).Save_Standard_Split__c )
            {
                SplitsToInesrt.add(createSplit(OppId,rep.Id,split));
            }
        }
                        
        // Process NonUsersOpportunities
        Map<Id,String> AccountTeamRoleMap=getAccountTeams(OpportunityAccountMap.values(),rep.Id);
        for(ID OppId:OpportunityIds){
            Role=AccountTeamRoleMap.get(OpportunityAccountMap.get(OppId));
            if(Role==null){
                Role='Other';
            }
            opptyTeamToInsert.add(new OpportunityTeamMember(OpportunityId=OppId,UserId=Rep.Id,TeamMemberRole=role));               
        }
                      
        Savepoint sp =null;
        sp= Database.setSavepoint();

        Database.SaveResult[] detailLine_result=null;
        Database.SaveResult[] oppTeam_result=null;
        Database.SaveResult[] split_result=null;
        Database.SaveResult[] updateOpp_result=null;
        Database.SaveResult[] changeOwnerResult=null;
        try{
            //by pass the validation rules
            List<Opportunity> byPassOpps= new List<Opportunity>();
            for(Opportunity opp: lst_SucessOpportunity){
                if(setAsOwnerOppIds.contains(opp.id) || !OpportunitiesWithNewRep.contains(opp.Id)){
                opp.bypass_validation__c=true;
                byPassOpps.add(opp);
                }
            }
            //sp= Database.setSavepoint();
            Database.update(byPassOpps,false);          
            // Set the onwer
            changeOwnerResult = changeOwner(SetOwnerOpps,Rep);                              
            if(HouseAccountTeamMember.size()>0){
                Database.delete(HouseAccountTeamMember,false); 
            }                                        
            oppTeam_result=Database.insert(opptyTeamToInsert,false);
            System.debug('oppTeam_result '+oppTeam_result);
            split_result=Database.insert(SplitsToInesrt,false);
            System.debug('DetailLinesToInesrt  '+DetailLinesToInesrt);            
            // set the team member id on detail lines
            setTeamMemberIdonDetailLines(opptyTeamToInsert,DetailLinesToInesrt);
            detailLine_result= Database.insert(DetailLinesToInesrt, false);            
            // update Share access
            if(AccessLevel=='Edit'){
                //OpportunityIds.removeAll(setAsOwnerOppIds);
                updateShareAccess(OpportunityIds,Rep);   
                OpportunityIds.addAll(setAsOwnerOppIds);
            }                   
        }catch(DMLException e){ 
            //Database.rollback(sp);           
            System.debug('Exception '+e);
            ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.Error,System.Label.Exception1+e);
            ApexPages.addMessage(msg1);
            
        }
        finally{
            // rest Flag
            for(Opportunity objOpp : lst_SucessOpportunity){
                objOpp.bypass_validation__c = false;                    
            } 
            updateOpp_result=Database.update(lst_SucessOpportunity,false);     

            if(setAsOwnerOppIds.size()>0){
              return_result.putAll(processResult(changeOwnerResult,SetOwnerOpps));                  
            }
            return_result.putAll(createResultUserExistResult());
            //    7 June 10  Prasad k      added fix for defect 707
            Map<Id,String> tempResMap = new Map<Id,String>();
            tempResMap = processResult(updateOpp_result,lst_SucessOpportunity);
            for(Id oppId: tempResMap.keySet()){
                if(!return_result.containsKey(oppId)){
                    return_result.put(oppId,tempResMap.get(oppId));
                }
            }
            //return_result.putAll(processResult(updateOpp_result,lst_SucessOpportunity));
            //28 july 10  Anand Sharma  added fix for defect 735
            return_result.putAll(createResultValidationErrorResult(map_ErrorOpportunity));
                       
            createLog(return_result);   
        }
          
        return return_result;
    }
    
    // Call this method to just change the owner of the opportunities.
    // This method will not create any detail lines as well will not add owner on sales team
    public List<Database.SaveResult> changeOwner(Map<id,id>SetOwnerOpps){
        List<Database.SaveResult> changeOwnerResult=null;
        // Defect 731 *Replaced {} to ()//
        list<opportunity> changeOpptyOwner = new list<opportunity>([select id,ownerid,Opportunity_Owner__c  from Opportunity 
                         where id in: SetOwnerOpps.keyset()]);
        //***Defect 731***//
        /*log('SetOwnerOpps.keyset ===>'+SetOwnerOpps.keyset());
        changeOpptyOwner = [select id,ownerid,Opportunity_Owner__c  from Opportunity 
                         where id in: SetOwnerOpps.keyset()]; */  
                         log('changeOpptyOwner ===>'+changeOpptyOwner );
        for(opportunity opp  : changeOpptyOwner ){
            for(id mapping :   SetOwnerOpps.keyset()){
                if(opp.id == mapping  ){
                    opp.bypass_validation__c=true;
                    opp.Opportunity_Owner__c = SetOwnerOpps.get(mapping);
                    opp.ownerId=SetOwnerOpps.get(mapping);
                }
            }
        }
        if( changeOpptyOwner.size()>0 ){
            // Do not execute owner change trigger logic
            ExecuteOwnerChangeTrigger=false;
            changeOwnerResult=Database.update(changeOpptyOwner,false);   
        }                                         
        return changeOwnerResult;
    }
    
    public List<Database.SaveResult> changeOwner(List<Opportunity>SetOwnerOpps,user Rep){
    
        List<Database.SaveResult> changeOwnerResult=null;
        
        for(Opportunity opp: SetOwnerOpps){
        opp.bypass_validation__c=true;
        opp.Opportunity_Owner__c=Rep.Id;
        opp.ownerId=Rep.Id;
        }
                
        if(SetOwnerOpps.size()>0 ){
            // Do not execute owner change trigger logic
            ExecuteOwnerChangeTrigger=false;
            changeOwnerResult=Database.update(SetOwnerOpps,false);   
        }  
        return changeOwnerResult;
    }
    
    private Map<Id,String> processResult(List <DataBase.SaveResult> results,List<Opportunity>opps ){
        Map<Id,String> return_result= new Map<Id,String> (); 
        system.debug('opps   '+opps );
        system.debug('results '+results);
        integer index=0;
        String successMessage=System.Label.Success_Message1;
        if(results!=null){
            for(Database.SaveResult result: results){
                //  7 June 10  Prasad k      added fix for defect 707
                if(index< opps.size() && setAsOwnerOppIds.contains(opps[index].Id)){
                    //11 Aug 10 Shipra Misra for defect 735
                    if(accountOwnerExist==true)
                    {
                        successMessage=System.Label.Success_Message3;
                    }
                    else
                    {
                        successMessage=System.Label.Success_Message2;
                        System.debug('the value of opps.size() is '+opps.size()+'The value of setAsOwnerOppIds is '+setAsOwnerOppIds);
                        System.debug('the value of opps[index].Id is '+opps[index].Id+' The value of index is '+index);
                    }
                }else{
                    successMessage=System.Label.Success_Message1;                        
                }
                return_result.put(opps[index].Id,result.isSuccess()? successMessage :result.getErrors()[0].getMessage());
                index++;  
            }          
        }          
        return return_result;
    }
    
    private Map<Id,String> getAccountTeams(List<Id>AccountIds,Id RepId ){
       Map<Id,String> AccountTeamRoleMap = new Map<Id,String>();
       List<AccountTeamMember> AccountTeams= [Select AccountId,TeamMemberRole,UserId from AccountTeamMember where accountId in:AccountIds and UserId=:RepId ];
       for(AccountTeamMember member :AccountTeams){
           AccountTeamRoleMap.put(member.AccountId,member.TeamMemberRole); 
       }
      return AccountTeamRoleMap;
    }
    
    private Map<Id,String> createResultUserExistResult(){
        Map<Id,String> return_result= new Map<Id,String>();
        String ErrorMessage=System.Label.Error_Sales_Rep_exist_on_Sales_Team;//Added by Karthik
          
          for(Id oppid: OpportunitiesWithNewRep){
                return_result.put(oppid,ErrorMessage);
          }
          return return_result;
    }
    public void setOpportunityLineItems (){
        List<OpportunityLineItem> opline;
        List<OpportunityLineItem> OpportunityProducts=[Select opportunity.CurrencyIsoCode,Quote_Amount__c,UnitPrice,PricebookEntry.Product2.Id,OpportunityId,id,PricebookEntry.Product2.Name from OpportunityLineItem where PricebookEntry.Product2Id in :ProductsOnNewRepFG and OpportunityId in :OpportunitiesWithRepFGProducts];
        System.debug('ProductsOnNewRepFG  '+ProductsOnNewRepFG);
        System.debug('OpportunitiesWithRepFGProducts '+OpportunitiesWithRepFGProducts);            
        System.debug('OpportunityProducts  '+OpportunityProducts);
        For(OpportunityLineItem OpportunityProduct:OpportunityProducts){
            opline = OpportunityLineItems.get(OpportunityProduct.OpportunityId);
            if (opline==null){
                opline=new List<OpportunityLineItem>();
            }
            opline.add(OpportunityProduct);
            OpportunityLineItems.put(OpportunityProduct.OpportunityId,opline);          
        }
    }
    
    
     private OpportunitySplit createSplit( Id OppId,Id RepId,Decimal splitPct){
        
        OpportunitySplit splitInfo = new OpportunitySplit(  OpportunityId=OppId,
                                                            SplitPercentage=splitPct,
                                                            SplitOwnerId=RepId,
                                                            SplitNote=splitPct+' %'); 
        
        return splitInfo; 
    }
    private List<Detail_Line__c> createDetailLines(User Rep ,Id OppId, List<OpportunityLineItem> OpportunityLineItems,String ForecastGroup, Decimal split){
        List<Detail_Line__c> DetailLines = new List<Detail_Line__c>();
        for(OpportunityLineItem opptyProduct:OpportunityLineItems){
            System.debug('opptyProduct  '+opptyProduct);
            System.debug('Rep  '+Rep);
            DetailLines.add( new Detail_Line__c(Opportunity__c=opptyProduct.OpportunityId,
                                      Forecast_Group__c=ForecastGroup,
                                      Split__c=split,
                                      Direct_Amount__c=opptyProduct.UnitPrice,
                                      Opportunity_Product__c=opptyProduct.Id,
                                      OpportunityTeamMember__c=Rep.Id,
                                      OwnerId=Rep.Id,
                                      Owner__c=Rep.Id,
                                      Product__c=opptyProduct.PricebookEntry.Product2Id,
                                      Quote_Amount__c=opptyProduct.Quote_Amount__c, 
                                      CurrencyIsoCode=opptyProduct.opportunity.CurrencyIsoCode));
        }
        return DetailLines;
    }
    private void updateShareAccess(Set<Id>OppIds,User Rep){
        List<OpportunityShare> oppshares =[Select o.OpportunityAccessLevel, o.OpportunityId, o.RowCause, o.UserOrGroupId from OpportunityShare o  where OpportunityId in:OppIds and UserOrGroupId=:Rep.Id and o.OpportunityAccessLevel='Read'and (o.RowCause='Manual' OR o.RowCause='Team')];
        for(OpportunityShare oppshare:oppshares){
                oppshare.OpportunityAccessLevel='Edit';
        }
        update oppshares;
    }
    // Opportunities having reps on salesteam of new rep's FG
    private void filteroutOpportunitiesHavingReps (Set<Id>OpportunityIds,String FG){
        AggregateResult[] ForecastGroupCount = [Select OpportunityId, COUNT(id) cnt from OpportunityTeamMember o where OpportunityId in :OpportunityIds and User.Forecast_Group__c =:FG GROUP BY OpportunityId having COUNT(id)>0];
        for( AggregateResult row:ForecastGroupCount ){
            OpportunitiesWithSameFGReps.add( (ID)(row.get('OpportunityId')));
            System.debug( '*************Count ' + ForecastGroupCount[0].get('cnt'));
        } 
    }
    /*
        method checks the user is on salesteam og the Opportunity if exist and returns the opps does not have the rep. 
    */
    private void filterOutOpportunitiesNewRepExist( Set<ID>OpportunityIDs, ID RepID,set<Id> setAsOwnerOppIds){
        
        OpportunityTeamMember[] OpportunityTeams =null; 
        if(setAsOwnerOppIds.size()==0){
         OpportunityTeams=[Select OpportunityId,id,User.Name from OpportunityTeamMember o where OpportunityId in :OpportunityIDs and UserId =:RepID];
        }else{
            OpportunityTeams=[Select OpportunityId,id,User.Name from OpportunityTeamMember o where OpportunityId in :OpportunityIDs and (UserId =:RepID or User.Name='House Account')] ;
        }
        for( OpportunityTeamMember member :OpportunityTeams ){
            if(member.User.Name=='House Account' && setAsOwnerOppIds.contains(member.OpportunityId) ){
                HouseAccountTeamMember.add(member);
            }else{
                OpportunitiesWithNewRep.add(member.OpportunityId);
            }
        }
    }   
    
    private void filteroutOpportunitiesOnUserFGProduct(Set<ID>OpportunityIDs){
        List <OpportunityLineItem>OpportunityProducts =[Select o.OpportunityId, o.PricebookEntryId, o.PricebookEntry.Product2Id from OpportunityLineItem o where PricebookEntry.Product2Id in :ProductsOnNewRepFG and OpportunityId in :OpportunityIDs];
        for(OpportunityLineItem product:OpportunityProducts){
            OpportunitiesWithRepFGProducts.add(product.OpportunityId);
        } 
        System.debug(' OpportunitiesWithRepFGProducts  '+OpportunitiesWithRepFGProducts);
    }
    private void getProductsOnNewRepFG(String FG){
        List<Forecast_Group_Product__c> ForecastGroupProducts =[Select f.Forecast_Mapping__c, f.Forecast_Mapping__r.Forecast_Group__c, f.Product__c from Forecast_Group_Product__c f where Forecast_Mapping__r.Forecast_Group__c=:FG];
        for(Forecast_Group_Product__c FGP: ForecastGroupProducts){
            ProductsOnNewRepFG.add(FGP.Product__c);
        }
    }
    
    private void  createLog (Map<Id,String> result ){
        System.debug('result '+result);
        list<Mass_Opp_Reassignment_log__c> LogResult = new list<Mass_Opp_Reassignment_log__c>();
        string tmpusername = Userinfo.getUserId();
        string tmplogTime = system.now().format('dd/MM/yyyy h:mm a') +' ' ;
        for(Id Oppty: result.keySet() ){
          LogResult.add(new  Mass_Opp_Reassignment_log__c( Opportunity_name__c=Oppty,User__c =tmpusername,
                  Scenario__c = 'Add User',Opportunity__c = Oppty,Result__c = result.get(Oppty),
                  log_time__c = tmplogTime));

        }
        database.insert(LogResult); 
    }       

   private List<Detail_Line__c> setTeamMemberIdonDetailLines(List<OpportunityTeamMember>OppTeams,List<Detail_Line__c> DetailLines){

        Map<String,String>OppTeammemberMap=new Map<String,String>();
        
        for(OpportunityTeamMember member:OppTeams){
            OppTeammemberMap.put(member.OpportunityId,member.id);
        }
        
        for(Detail_Line__c detailLine:DetailLines){
           detailLine.OpportunityTeamMember__c= OppTeammemberMap.get(detailLine.Opportunity__c);
            
        }
            
        return DetailLines;
    }
    
    // 28 july 10  Anand Sharma added fix for defect 735
    private Map<Id,String> createResultValidationErrorResult(Map<Id, String> map_ErrorOpportunity){
        Map<Id,String> return_result= new Map<Id,String>();
            
          for(Id oppid: map_ErrorOpportunity.keySet()){
                return_result.put(oppid,map_ErrorOpportunity.get(oppid));
          }
          return return_result;
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /* Srinivas Added for removing Too many SOQL errors */
    public OP_SSF_SaveResult updateSplits(Map<id,list<SalesTeamMember>> MapSplits)
    {
       
       List<Detail_Line__c> detailsToUpdt = new List<Detail_Line__c>();  
       List<OpportunitySplit> splitToUpdt = new List<OpportunitySplit>();
       List<OpportunityTeamMember> opptyTeamToUpdt = new List<OpportunityTeamMember>();
       List<OpportunityShare> shareToUpdt = new List<OpportunityShare>();
       
       Map<id,List<Detail_Line__c>> mapDetailLines = new Map<id,List<Detail_Line__c>>();
       for(Detail_Line__c dl : [select Opportunity__c,Id,Split__c,OwnerId  from Detail_Line__c where Opportunity__c in :MapSplits.keySet()])
       {
            if(mapDetailLines.containskey(dl.Opportunity__c))
                mapDetailLines.get(dl.Opportunity__c).add(dl);
            else
                mapDetailLines.put(dl.Opportunity__c, new list<Detail_Line__c>{dl});
       }
      
       Map<id,list<OpportunityTeamMember>> mapOpportunityTeamMembers = new Map<id,list<OpportunityTeamMember>>();
       for(OpportunityTeamMember otm : [select OpportunityId,Id,UserId,TeamMemberRole
                                                from OpportunityTeamMember
                                                where OpportunityId in :MapSplits.keySet()])
       {
            if(mapOpportunityTeamMembers.containskey(otm.OpportunityId))
                mapOpportunityTeamMembers.get(otm.OpportunityId).add(otm);
            else
                mapOpportunityTeamMembers.put(otm.OpportunityId, new list<OpportunityTeamMember>{otm});
       }                                                
          
       Map<id,list<OpportunityShare>> mapOpportunitesShares = new Map<id,list<OpportunityShare>>();
       for(OpportunityShare os : [select OpportunityId,Id,RowCause,UserOrGroupId,OpportunityAccessLevel
                                                from OpportunityShare
                                                where OpportunityId in :MapSplits.keySet()
                                                and (RowCause='Team')])
       {
            if(mapOpportunitesShares.containskey(os.OpportunityId))
                mapOpportunitesShares.get(os.OpportunityId).add(os);
            else
                mapOpportunitesShares.put(os.OpportunityId, new list<OpportunityShare>{os});
       }                                                                                  
      
       Map<id,list<OpportunitySplit>> mapOpportunitySplits = new Map<id,list<OpportunitySplit>>();                                         
       for(OpportunitySplit osplit : [select Id,OpportunityId,SplitOwnerId,SplitPercentage 
                                                from OpportunitySplit
                                                where splittype.developername = 'Overlay' AND OpportunityId in :MapSplits.keySet()])
       {
            if(mapOpportunitySplits.containskey(osplit.OpportunityId))
                mapOpportunitySplits.get(osplit.OpportunityId).add(osplit);
            else
                mapOpportunitySplits.put(osplit.OpportunityId, new list<OpportunitySplit>{osplit});
       }                                                 
       
       for(List<SalesTeamMember> splits : MapSplits.values())
       {
           log('updateSplits:splits='+splits);
            
           //Filter out the inactive users in the list
           splits = cls_oppSSF.filterInactiveUsers(splits);  
           Map<String,SalesTeamMember> slsTeamMap = new Map<String,SalesTeamMember>();
           Map<Id,String> opptyIdMap = new Map<Id,Id>(); 
           
            
           //Map the input parameters by OpportunityId and User Id 
           for(SalesTeamMember teamMbr:splits){
                slsTeamMap.put(teamMbr.opptyTeamMember.OpportunityId+'_'+((String)teamMbr.opptyTeamMember.UserId).substring(0,15),
                                teamMbr);
                if(!opptyIdMap.containsKey(teamMbr.opptyTeamMember.OpportunityId)){
                    opptyIdMap.put(teamMbr.opptyTeamMember.OpportunityId,teamMbr.opptyTeamMember.OpportunityId);
                }
           }
           String key;
           log('updateSplits:opptyIdMap='+opptyIdMap);
           log('updateSplits:slsTeamMap='+slsTeamMap);
           //Get all detail Lines for the opportunies in question
           for(id i:opptyIdMap.keyset())
           for(Detail_Line__c detail: mapDetailLines.get(i))
           {
                key =detail.Opportunity__c+'_'+((String)detail.OwnerId).substring(0,15);
               //Set the new Split values based on what's passed in
                if(slsTeamMap.containsKey(key)){
                    detail.Split__c=slsTeamMap.get(key).detailSplit.Split__c;
                    detailsToUpdt.add(detail);
                }                               
           }
           
           //Get all OpptyTeamMembers for Opportunities and update the TeamMemberRole
           for(id i:opptyIdMap.keyset())
           for(OpportunityTeamMember teamMbr: mapOpportunityTeamMembers.get(i))
           {
                key =teamMbr.OpportunityId+'_'+((String)teamMbr.UserId).substring(0,15);
               //Set the new Split values based on what's passed in
                if(slsTeamMap.containsKey(key)){
                    teamMbr.TeamMemberRole = slsTeamMap.get(key).opptyTeamMember.TeamMemberRole;
                    opptyTeamToUpdt.add(teamMbr);
                }                               
           }
        
           //Get all OpptyShares for Opportunities and update the TeamMemberRole
           for(id i:opptyIdMap.keyset())
           for(OpportunityShare share: mapOpportunitesShares.get(i))
           {
                key =share.OpportunityId+'_'+((String)share.UserOrGroupId).substring(0,15);
               //Set the new Split values based on what's passed in
                if(slsTeamMap.containsKey(key)){
                    share.OpportunityAccessLevel = slsTeamMap.get(key).detailSplit.Opportunity_Access_Level__c;
                    shareToUpdt.add(share);
                }                               
           }
           
           
           //Get all OpportunitySplit for the opportunies in question
           for(id i:opptyIdMap.keyset())
           for(OpportunitySplit splitInfo: mapOpportunitySplits.get(i))
           {
                key =splitInfo.OpportunityId+'_'+((String)splitInfo.SplitOwnerId).substring(0,15);
                //Set the new Split values based on what's passed in
                log('updateSplits:key='+key);
                System.debug('opptyIdMap'+opptyIdMap);
                if(slsTeamMap.containsKey(key)){
                    log('updateSplits:key found in slsTeamMap !!!!');
                    log('updateSplits:slsTeamMap.get(key).detailSplit.Forecast_Group__c='+slsTeamMap.get(key).detailSplit.Forecast_Group__c);
                    
                    if(mapSpecial_Forecast_Groups.containskey(slsTeamMap.get(key).detailSplit.Forecast_Group__c) && mapSpecial_Forecast_Groups.get(slsTeamMap.get(key).detailSplit.Forecast_Group__c).Save_Standard_Split__c )
                    {
                        //Srinivas N : Change for ticket IM7249975 
                        if(slsTeamMap.get(key).detailSplit.Split__c > 100)
                            splitInfo.SplitPercentage=100;
                        else
                            splitInfo.SplitPercentage=slsTeamMap.get(key).detailSplit.Split__c;
                        //End of Change for IM7249975    
                        System.debug('slsTeamMap.get(key).detailSplit.Split__c--->'+slsTeamMap.get(key).detailSplit.Split__c);
                        splitInfo.SplitNote=slsTeamMap.get(key).detailSplit.Split__c+' %';
                        System.debug('slsTeamMap.get(key).detailSplit.Split__c+'+slsTeamMap.get(key).detailSplit.Split__c+' %');
                        splitToUpdt.add(splitInfo);
                    }
                }
           }
        }//End of FOR 
        log('updateSplits:opptyTeamToUpdt='+opptyTeamToUpdt);
        log('updateSplits:shareToUpdt='+shareToUpdt);
        log('updateSplits:detailsToUpdt='+detailsToUpdt);
        log('updateSplits:splitToUpdt='+splitToUpdt);
        List<Database.SaveResult> saveRes;
     
        try{
            Database.update(opptyTeamToUpdt);
            Database.update(shareToUpdt);
            saveRes=Database.update(detailsToUpdt);
            Database.update(splitToUpdt);
            OpportunityOperation integLog = new OpportunityOperation();
            integLog.insertOpportunityIntgLog(new List<id>(MapSplits.keyset()));
            
        }catch(Exception ex){
  
            throw new OP_SSF_Exception(100,ex);
        }
        OP_SSF_SaveResult result = new OP_SSF_SaveResult(detailsToUpdt);
        result.dmlSaveResult=saveRes;
        return result;
    }//End of updateSplits method

}