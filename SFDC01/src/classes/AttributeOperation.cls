/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       	DEVELOPER     	WR       	DESCRIPTION                               
 |  ====       	=========     	==       	=========== 
 | 24-Aug-09  	Deepak Kapoor           	If values are Changed for any Attribute Record,
 |                                    		Fetch all user associated and Update user Fields 
 |                                    		with the updated value on Attribute Record.  
 | 28-Oct-09  	Sunil Arora             	To use Role Id instead of Role name. 
   27-Apr-10 	Prasad Kothawade         	WR#131922  
   06-May-10 	Arif                    	WR#131922 Added a new condition in 'CheckValidRoleName' method.
   22-Oct-10	Pratibh Prakash				WR 140086 updates lines: 112-122, 160-176, 26:added flag, 38: added License conditon in query.
 | 18-May-11	Shipra Misra				Added New field Super_Division__c for WR 162270. 
 	11-Jun-12	Avinash Kaltari				Added code to eliminate hardcoding of the UserLicense Id : '10070000000DVu4AAG'                                   
 | +===========================================================================*/

public class AttributeOperation{
    
   
    
    
    //This method will be called to update matching User, if found
    //WR 162270..Added New field Super_Division__c.
    @future public static void UpdateUserFound( List<String> Role_Id,List<String> BU, List<String> Sales_Role,
                                               List<String> Division,List<String> Country,List<String> Area,
                                               List<String> District,List<String> Super_Division,List<String> Theater,List<String> Super_Area,List<String> Region,List<String> Forecast_Group,Set<Id> roleId)
    {   
        //Set<Id> roleId=new Set<Id>(); 
        util.fromuserattributemapping=true;
        list<User> updateUserRecord=new list<User>();
        List<User_Attribute_Mapping__c> Attributes=new List<User_Attribute_Mapping__c>();
        Map<Id,User_Attribute_Mapping__c> attribute=new Map<Id,User_Attribute_Mapping__c>();
        for(Integer i=0;i<BU.size();i++)
        {
            //WR 162270..Added New field Super_Division__c.
            Attributes.add(new User_Attribute_Mapping__c(BU__c=BU[i],Sales_Role__c=Sales_Role[i],Division__c=Division[i],
                                                         Country__c=Country[i],Area__c=Area[i],District__c=District[i],Super_Division__c=Super_Division[i],Theater__c=Theater[i],
                                                         Super_Area__c=Super_Area[i],Region__c=Region[i],Forecast_Group__c=Forecast_Group[i], Role_Id__c=Role_Id[i]));
            
        } 
        //Fetching UserRecord based on the Roleid in Map.
        //WR 162270..Added New field Super_Division__c.
        
        
//Avinash's code begins...

		Id SalesforceLicenseID  ;
		List<UserLicense> lstUserLicence = [SELECT Name, Id FROM UserLicense where name = :System.Label.Salesforce_User_License_Name limit 1];
		if(lstUserLicence != null && lstUserLicence.size() > 0)
			SalesforceLicenseID  = lstUserLicence.get(0).id;

//Avinash's code ends.
        
        
        for(User userrecord:[Select UserRoleId,id,BU_Attribute__c,
                             Area__c,Country__c,Division__c,
                             Region__c,Role__c,Super_Area__c,
                             District__c,Super_Division__c,Theater__c,Forecast_Group__c 
                             from User where UserRoleId in:roleId
                             and Exception__c=:false and Profile.UserLicenseId = :SalesforceLicenseID]){
            //To fetch the matching attribute.
            for(Integer i=0;i<Attributes.size();i++)
            {
                attribute.put(Attributes[i].Role_Id__c,Attributes[i]);
            }
            if(attribute.containsKey(userrecord.UserRoleId))
            {
                User_Attribute_Mapping__c getMapValue=attribute.get(userrecord.UserRoleId);
                
                 // System.debug('attributeRecord'+attributeRecord);
                        userrecord.BU_Attribute__c=getMapValue.BU__c;
                        userrecord.Role__c=getMapValue.Sales_Role__c;
                        userrecord.Division__c=getMapValue.Division__c;
                        userrecord.Country__c=getMapValue.Country__c;
                        userrecord.Area__c=getMapValue.Area__c;
                        userrecord.District__c=getMapValue.District__c;
                        //WR 162270..Added New field Super_Division__c.
                        userrecord.Super_Division__c=getMapValue.Super_Division__c;
                        userrecord.Theater__c=getMapValue.Theater__c;
                        userrecord.Super_Area__c=getMapValue.Super_Area__c;
                        userrecord.Region__c=getMapValue.Region__c;
                        //Code Updated By Shipra..//
                        userrecord.Forecast_Group__c=getMapValue.Forecast_Group__c;
                        updateUserRecord.add(userrecord);

                        if(updateUserRecord.size()==100){
                            util.fromuserattributemapping=true;
                            update updateUserRecord;
                            updateUserRecord.clear();
                        }
            }
            
          }
           if(updateUserRecord.size()>0){
               util.fromuserattributemapping=true;
               update updateUserRecord;
               updateUserRecord.clear();
                System.debug('fromuserattributemapping'+util.fromuserattributemapping);
        }

    }
    //Method Called from Trigger for Checking Role Name match the role name in Hierarchy.
    public void CheckValidRoleName(List<User_Attribute_Mapping__c> AttributesCheck){
            
            Set<string> roleName = new Set<String>();
            Map<string,Id> roleNameAndId = new Map<String,Id>();
             Set<Id> roleId=new Set<Id>();
            
            
    	List<String> BU=new List<String>();
     	List<String> Sales_Role=new List<String>();
      	List<String> Division=new List<String>();
      	List<String> Country=new List<String>();
      	List<String> Area=new List<String>();
      	List<String> District=new List<String>();
      	//WR 162270..Added New field Super_Division__c.
      	List<String> Super_Division = new List<String>();
      	List<String> Theater=new List<String>();
      	List<String> Super_Area=new List<String>();
      	List<String> Region=new List<String>();
      	List<String> Forecast_Group=new List<String>();
      	List<String> Role_Id=new List<String>();
         //  List<Id> RoleIdOfExistMapping = new<ID>(); 
         
         
       System.debug('AttributesCheck' +AttributesCheck);
       
            for(Integer i=0;i<AttributesCheck.size();i++)
            {
                 roleName.add(AttributesCheck[i].Name);
                 //roleNameAndId.put(AttributesCheck[i].Name,AttributesCheck[i].Role_Id__c);
                 
            /*BU.add(AttributesCheck[i].BU__c);
            Sales_Role.add(AttributesCheck[i].Sales_Role__c);
            Division.add(AttributesCheck[i].Division__c);
            Country.add(AttributesCheck[i].Country__c);
            Area.add(AttributesCheck[i].Area__c);
            District.add(AttributesCheck[i].District__c);
            Theater.add(AttributesCheck[i].Theater__c);
            Super_Area.add(AttributesCheck[i].Super_Area__c);
            Region.add(AttributesCheck[i].Region__c);
            Forecast_Group.add(AttributesCheck[i].Forecast_Group__c);
            Role_Id.add(AttributesCheck[i].Role_Id__c);*/
            }
            
            //This select call is used to fetch Role Id
            //UserRole[] usrRole =[Select Id,Name from UserRole where Name IN: roleName];
            for(UserRole usrRole:[Select Id,Name from UserRole where Name IN: roleName])
            {
                 roleNameAndId.put(usrRole.Name,usrRole.Id);
            }
            Set<Id> RoleIdOfExistMapping = new Set<Id>();
           for(User_Attribute_Mapping__c uam:[Select Role_Id__c from User_Attribute_Mapping__c where Role_Id__c != 'null' and Role_Id__c in :roleNameAndId.values() ]){
                 RoleIdOfExistMapping.add(uam.Role_Id__c);
                 
         }                
       
            for(Integer i=0;i<AttributesCheck.size();i++)
            {
                if(roleNameAndId.containsKey(AttributesCheck[i].Name))
                {
                    // ******** WR#131922   - Changed by prasad
                    if(AttributesCheck[i].Role_Id__c==null || AttributesCheck[i].Role_Id__c==''){
                                if(!RoleIdOfExistMapping.contains(roleNameAndId.get(AttributesCheck[i].Name))){
                                    AttributesCheck[i].Role_Id__c=roleNameAndId.get(AttributesCheck[i].Name);
                                }else{
                                        AttributesCheck[i].adderror(System.Label.Duplicate_Role_Id);
                                 }       
                    }else if(AttributesCheck[i].Role_Id__c!=roleNameAndId.get(AttributesCheck[i].Name)){
                        AttributesCheck[i].adderror(System.Label.Duplicate_Role_Id); 
                    }
                    // ******** WR#131922   - Changed by prasad

                    roleId.add(roleNameAndId.get(AttributesCheck[i].Name));
                }
                else
                {
                        AttributesCheck[i].adderror(System.Label.Role_Name_does_not_exist); 
                }
            }
            for(Integer i=0;i<AttributesCheck.size();i++)
            {
                 roleName.add(AttributesCheck[i].Name);
                 //roleNameAndId.put(AttributesCheck[i].Name,AttributesCheck[i].Role_Id__c);
                 
            BU.add(AttributesCheck[i].BU__c);
            Sales_Role.add(AttributesCheck[i].Sales_Role__c);
            Division.add(AttributesCheck[i].Division__c);
            Country.add(AttributesCheck[i].Country__c);
            Area.add(AttributesCheck[i].Area__c);
            District.add(AttributesCheck[i].District__c);
            //WR 162270..Added New field Super_Division__c.
            Super_Division.add(AttributesCheck[i].Super_Division__c);
            Theater.add(AttributesCheck[i].Theater__c);
            Super_Area.add(AttributesCheck[i].Super_Area__c);
            Region.add(AttributesCheck[i].Region__c);
            Forecast_Group.add(AttributesCheck[i].Forecast_Group__c);
            Role_Id.add(AttributesCheck[i].Role_Id__c);
            }
              util.fromuserattributemapping=true;
              //Calling future method here
              //WR 162270..Added New field Super_Division__c.
        	  UpdateUserFound(Role_Id,BU,Sales_Role,Division,Country,Area,District,Super_Division,Theater,Super_Area,Region,Forecast_Group,roleId);
            
   }

/*Method will be called before deletion of "Attribute Mapping Record "
to check if the User associated with deleted attribute exist,if yes,Restrict
deletion by throwing an error*/

    public void fetchUsers(List<User_Attribute_Mapping__c> userAttribute){
    
        Map<String,User_Attribute_Mapping__c> AttributeNameMap=new Map<String,User_Attribute_Mapping__c>();
        Map<id,String> UserRoleMap=new Map<id,String>();
        List<User_Attribute_Mapping__c> attributelist=new List<User_Attribute_Mapping__c>();
        Set<id> UserRoleidset=new Set<id>();
        list<id> idslist;
        for(User_Attribute_Mapping__c Attr:userAttribute){
            AttributeNameMap.put(Attr.Name,Attr);
        }
        for(UserRole roleid:[Select id,Name from UserRole where Name in:AttributeNameMap.keyset()]){
            UserRoleMap.put(roleid.id,roleid.Name);
        }
        for(List<User> user_Record:[Select UserRoleid,id from User where UserRoleid in:UserRoleMap.keyset() and IsActive=true]){
             System.debug('user_Record.size()---'+user_Record.size());
             if(user_Record.size()>0){
                 for(User rec:user_Record){
                     System.debug('while iterating user_Record.size()---'+user_Record.size());
                     System.debug('rec.UserRoleid'+rec.UserRoleid);
                     UserRoleidset.add(rec.UserRoleid);
                 }
                     idslist=new list<id>(UserRoleidset);
                     for(Integer i=0;i<idslist.size();i++){
                        User_Attribute_Mapping__c Attribute_Record=AttributeNameMap.get(UserRoleMap.get(idslist[i]));                
                        System.debug('Role--->User'+UserRoleMap.get(idslist[i])+'--->'+AttributeNameMap.get(UserRoleMap.get(idslist[i])));
                        if(Attribute_Record!=Null){
                             attributelist.add(Attribute_Record);
                        }
                        System.debug('attributelist.size()'+attributelist.size());
                     }
           }
       }
       for(Integer i=0;i<attributelist.size();i++){
       attributelist[i].adderror(System.Label.Cannot_delete_record);
       }
    }
 }