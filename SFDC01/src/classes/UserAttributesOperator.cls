/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 | 25-Aug-09  Deepak Kapoor           Fetch Attributes from User Attribute Mapping 
 |                                     table based on the Selected Role.
 | 21-Oct-09  Shipra Misra            Updated for addition of Forecast Group custom field
 |                                        in creating new user and also in Edit User.
 | 28-Oct-09  Sunil Arora            To change Role name to Role Id.  
 | 02-Feb-10 Sunil Arora             To resolve defect #511.
   08-May-10 Prasad kothawade        Defect identified by J - Role name change was creating new attribute mapping though mapping exist with role id.
   19-Aug-10 Prasad Kothawade        Bypassed partner users
   21-Dec-10  Suman B                Added method populatePartnerUserAttributes() for pouplating 
                                     attribute values on partner User. Req#1176.
 | 18-May-11    Shipra Misra        Added New field Super_Division__c for WR 162270.
 | 16-July-11   Shipra Misra        Update Attribute Mapping code for error "Role Name Already Exists".WR-171462
 | 23-Feb-12    Anil                Fixed User Role Id String Too Large Issue                                    
 | +====================================================================================*/

Public class UserAttributesOperator{
    Static boolean isRoleChanged=false;

    Map<String,User_Attribute_Mapping__c> UserAttributeMap=new Map<String,User_Attribute_Mapping__c>(); 
    Map <Id,String> RoleIds = new Map <Id,String>();
     
    List <User> New_Attributes= new List <User>();
    
    
    //This method will be called when user gets updated and used to map its value with its matching User Attributre record.
    public void editUsers(List<User> new_users,List<User> old_users){
    
        List <User> users_to_update = new List <User>();
        List <String> insertUpdatedAttributes = new List <String>();
        List <User>   listpartnerusers = new List <User>();
        set<Id> partnerusercontactIds =  new set<Id>() ;

        System.debug('edit users '); 
        for(Integer i=0;i<new_users.size();i++){
            if(!new_users[i].Exception__c && new_users[i].contactId==null ){
                    if(new_users[i].BU_Attribute__c!=old_users[i].BU_Attribute__c || 
                        new_users[i].Area__c!=old_users[i].Area__c  || 
                        new_users[i].Country__c!=old_users[i].Country__c ||
                        new_users[i].Division__c!=old_users[i].Division__c ||
                        new_users[i].Region__c!=old_users[i].Region__c || 
                        new_users[i].Role__c!=old_users[i].Role__c ||
                        new_users[i].Super_Area__c!=old_users[i].Super_Area__c || 
                        new_users[i].District__c!=old_users[i].District__c ||
                        //WR 162270..Added New field Super_Division__c.
                        new_users[i].Super_Division__c!=old_users[i].Super_Division__c ||
                        //code Updation by shipra..//
                        new_users[i].Forecast_Group__c!=old_users[i].Forecast_Group__c)
                        {
                             new_users[i].adderror(System.Label.Information_In_Additional_Information_Cannot_Be_Changed);
                        }
                     //If User Role gets updated
                     else if( new_users[i].UserRoleId!=old_users[i].UserRoleId) {
                        users_to_update.add(new_users[i]);
                    }
            }
         /** Added for Req#1176. **/   
          else if(!new_users[i].Exception__c && new_users[i].contactId != null) {
             listpartnerusers.add(new_users[i]);
             partnerusercontactIds.add(new_users[i].contactId);
           }
        } // End of for -loop.

       System.debug('Partner Users '+listpartnerusers);

       if(listpartnerusers.size()>0){
         populatePartnerUserAttributes(listpartnerusers ,partnerusercontactIds); 
        }
        
        System.debug('users_to_update '+users_to_update);
        if(users_to_update.size()>0){
            fetchRoleAttributeDetails(users_to_update);
            for(User new_user:users_to_update){
                User_Attribute_Mapping__c attribute = UserAttributeMap.get(new_user.UserRoleId);
                System.debug('UserAttributeMap '+UserAttributeMap);
                System.debug('new_user.UserRoleId '+new_user.UserRoleId);
                if(attribute !=null ){
                    populateUserAtrributes(new_user,attribute);
                }else{
                     New_Attributes.add(new_user);
                 }       
                if(New_Attributes.size()>0){
                    List <String> StringAttributes = new List <String>();
                    for(User usr_attribute: new_Attributes){
                        //String str_attribute=RoleIds.get(usr_attribute.UserRoleId)+','+usr_attribute.UserRoleId+','+usr_attribute.BU_Attribute__c+','+usr_attribute.Area__c+','+usr_attribute.Country__c+','+usr_attribute.Division__c+','+usr_attribute.Region__c+','+usr_attribute.Role__c+','+usr_attribute.Super_Area__c+','+usr_attribute.District__c+','+usr_attribute.Theater__c;
                        //Code Updated By Shipra..18th May 2011//
                        //WR 162270..Added New field Super_Division__c.
                        String str_attribute=RoleIds.get(usr_attribute.UserRoleId)+'}'+usr_attribute.UserRoleId+'}'+usr_attribute.BU_Attribute__c+'}'+usr_attribute.Area__c+'}'+usr_attribute.Country__c+'}'+usr_attribute.Division__c+'}'+usr_attribute.Region__c+'}'+usr_attribute.Role__c+'}'+usr_attribute.Super_Area__c+'}'+usr_attribute.District__c+'}'+usr_attribute.Super_Division__c+'}'+usr_attribute.Theater__c+'}'+usr_attribute.Forecast_Group__c;
                        //End Ofcode updation..//
                        StringAttributes.add(str_attribute);
                    }
                     System.debug('Future call 1 '); 
                    insertNewRoleAttribute(StringAttributes);
                }
           }
        }
        
    }
  
   
    //This method will be called when new user is created.
    public void createNewUsers(List<User> users){
        system.debug('INSIDE createNewUsers ### ');
        List<User> ProcessUsers = new List<User>();
        List<User> partnerUsers = new List<User>();
        set<Id> usercontactIds = new set<Id>();

        for(User new_user:users){
                 
         if(new_user.contactId==null){
             ProcessUsers.add(new_user);
         }
         /** Added as per Req#1176 **/
         else{
          partnerUsers.add(new_user);
          usercontactIds.add(new_user.contactId);
         }
       }
       system.debug('User usercontactIds ## :' + usercontactIds );
      if(partnerUsers.size()>0){
        system.debug('INSIDE createNewUsers -Partner Users condition ### ');
         populatePartnerUserAttributes(partnerUsers ,usercontactIds); 
       }

            
       if(ProcessUsers.size()>0){
           users=ProcessUsers;
       }else{
        return;
       }
       
       fetchRoleAttributeDetails(users);

        for(User new_user:users){
            //code updated to remove Role Name Already Exists validation error when user is created.WR-171462
            if(new_user.UserRoleId!=null && new_user.Exception__c==false)
            {
                User_Attribute_Mapping__c attribute = UserAttributeMap.get(new_user.UserRoleId);
                if(attribute !=null ){
                    populateUserAtrributes(new_user,attribute);
                }else{
                    New_Attributes.add(new_user);
                }
            }
            //end of code updated for error resolution.
        }
        if(New_Attributes.size()>0){
            List <String> StringAttributes = new List <String>();
            for(User attribute: new_Attributes){
                //String str_attribute=RoleIds.get(attribute.UserRoleId)+','+attribute.UserRoleId+','+attribute.BU_Attribute__c+','+attribute.Area__c+','+attribute.Country__c+','+attribute.Division__c+','+attribute.Region__c+','+attribute.Role__c+','+attribute.Super_Area__c+','+attribute.District__c+','+attribute.Theater__c;
                //Code Updated By Shipra..on 18th May 2011//
                //WR 162270..Added New field Super_Division__c.
                String str_attribute=RoleIds.get(attribute.UserRoleId)+'}'+attribute.UserRoleId+'}'+attribute.BU_Attribute__c+'}'+attribute.Area__c+'}'+attribute.Country__c+'}'+attribute.Division__c+'}'+attribute.Region__c+'}'+attribute.Role__c+'}'+attribute.Super_Area__c+'}'+attribute.District__c+'}'+attribute.Super_Division__c+'}'+attribute.Theater__c+'}'+attribute.Forecast_Group__c;
                //End Of code updation..//
                StringAttributes.add(str_attribute);
            }
            System.debug('Future call 2 ');
            insertNewRoleAttribute(StringAttributes);
        }
    }

    //This method will be called to populate values in User from User Attribute.
    private void populateUserAtrributes(User user,User_Attribute_Mapping__c AttributeMapping){
          user.BU_Attribute__c=AttributeMapping.BU__c;
          user.Area__c=AttributeMapping.Area__c;
          user.Country__c=AttributeMapping.Country__c;
          user.Division__c=AttributeMapping.Division__c;
          user.Region__c=AttributeMapping.Region__c;
          user.Role__c=AttributeMapping.Sales_Role__c;
          user.Super_Area__c=AttributeMapping.Super_Area__c;
          user.District__c=AttributeMapping.District__c;
          //WR 162270 Shipra 18 May 2011.
          //WR 162270..Added New field Super_Division__c.
          user.Super_Division__c=AttributeMapping.Super_Division__c;
          //End of wr 162270
          user.Theater__c=AttributeMapping.Theater__c;
          //System.debug('test Populate');
          //Code Updated By Shipra..//
          user.Forecast_Group__c=AttributeMapping.Forecast_Group__c;
          //End Of code updation..//
    }

    //This method is used here to fetch User Attribute values
    private void fetchRoleAttributeDetails(List<User> users){
        List<String> role_ids=new List<String>();  
        for(integer i=0;i< users.size();i++){
            if(!users[i].Exception__c){
                role_ids.add(users[i].UserRoleId);
            }    
        }
        //This select call is used here to fetch Role name.
         for(UserRole role :[Select id,name from UserRole where id IN:role_ids]){
            RoleIds.put(role.id,role.Name);
         }
        
         for (User_Attribute_Mapping__c attribute :[Select Name,Area__c,Role_Id__c,BU__c,Country__c,District__c,Division__c,Region__c,Sales_Role__c,Super_Area__c,Super_Division__c,Theater__c,Forecast_Group__c from User_Attribute_Mapping__c where Role_Id__c IN:RoleIds.keySet()] ){
            String RoleId=attribute.Role_Id__c;
            //RoleId=RoleId.length()==18?RoleId.substring(0,15):RoleId;
            UserAttributeMap.put(RoleId,attribute);
         }


    }

      @future public static void insertNewRoleAttribute(List<String> objuser){
        
            List<User_Attribute_Mapping__c> AttributeMapping=new List<User_Attribute_Mapping__c>();
                    
            //This loop is used to get values from Users and Create User Attribute records.
            for(String fromuser:objuser){
                    String[] attribute_values=fromuser.split('}');
                    User_Attribute_Mapping__c new_attribute=new User_Attribute_Mapping__c(
                                                           Name=attribute_values[0],
                                                           Role_Id__c=attribute_values[1],
                                                           BU__c='N/A',
                                                           Area__c='N/A',
                                                           Country__c='N/A',
                                                           Division__c='N/A',
                                                           Region__c='N/A',
                                                           Sales_Role__c='N/A',
                                                           Super_Area__c='N/A',
                                                           District__c='N/A',
                                                           Super_Division__c='N/A',
                                                           Theater__c='N/A',
                                                           Updated_From_Future_Call__C=true,
                                                           Forecast_Group__c='N/A');
            
                    System.debug('attribute_values--->'+attribute_values);
                    System.debug('new_attribute--->'+new_attribute);
                    AttributeMapping.add(new_attribute);
            }

            Database.SaveResult[] result = Database.insert(AttributeMapping);
       }
       
   /* @Method <populatePartnerUserAttributes: for popualting values on PartnerUsers>
       @param <List Users>
       @param <List  Ids>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */  
  Public void populatePartnerUserAttributes(List<User> partnerUsers,Set<Id> usercontactIds) {
     Map<Id,Id> mapIdAccountIds = new Map<Id,Id>() ;
      for(Contact con : [SELECT Id,name,AccountId 
                          FROM Contact 
                          WHERE Id in : usercontactIds ]){
           mapIdAccountIds.put(con.Id,con.AccountId );
       }
     Map<Id,Account> mapIdAccount = new map<Id,Account>(
                                      [SELECT Id,Theater1__c,BillingCountry 
                                        FROM Account 
                                        WHERE Id in : mapIdAccountIds.values()]);
      system.debug(' INSIDE populatePartnerUserAttributes ');                                        
      Account partnerAccount;
      for(User puser : partnerUsers){
          partnerAccount = mapIdAccount.get(mapIdAccountIds.get(puser.contactId)) ;
           if(partnerAccount != null && !(puser.Exception__c) ) {
               puser.Theater__c = partnerAccount.Theater1__c ;
               puser.Country__c = partnerAccount.BillingCountry ;
            }
          }
    } // End of Method.      
  }