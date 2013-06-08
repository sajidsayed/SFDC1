/**
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  UNKONWN          UNKONWN       UNKONWN      UNKONWN
    11.6.2011       Srinivas N                  Added  'Super_Division__c' in user soql querys
 +========================================================================================================================*/

@isTest
private class UA_UserAttributesOperator_TC{
    Static Set<String> Userids=new Set<String>();
     Static Set<Id> roleId=new Set<Id>();
    Static List<User> UserList,UserList1;
    Static List<User> newList=new List<User>();
     
    Static List<String> UserRoleidList=new List<String>();
    
    
    
    private static UserRole createRole(String roleName){
        UserRole NewusrRole1=new UserRole(Name=roleName+Math.Random());
        insert NewusrRole1;
        return NewusrRole1;
    }
    
    static testMethod void runValueChangedTests() {
    /*UserRole usr1=createRole('test000000');
    UserRole usr2=createRole('test1000000');
    UserRoleidList.add(usr1.Id);
    UserRoleidList.add(usr2.Id);*/
    UserList=new List<User>([Select BU_Attribute__c,
                             id,UserRoleId,
                             Exception__c,
                             Area__c,
                             Country__c,
                             Division__c,
                             Region__c,
                             Role__c,
                             Super_Area__c,Super_Division__c,
                             District__c,
                             Theater__c,contactId,AccountId,
                             Forecast_Group__c from User where 
                             Exception__c=false and UserRoleId!=null limit 5]);

    UserList1=new List<User>([Select BU_Attribute__c,
                             id,UserRoleId,
                             Exception__c,
                             Area__c,
                             Country__c,
                             Division__c,
                             Region__c,
                             Role__c,
                             Super_Area__c,Super_Division__c,
                             District__c,
                             Theater__c,contactId,AccountId,
                             Forecast_Group__c from User where 
                             Exception__c=false and UserRoleId!=null and contactId= Null limit 2]);                             
    
    for(User usr:UserList){
    Userids.add(usr.id);
    }
   for(User usr:UserList1){
    Userids.add(usr.id);
    }
   if(UserList!= null) {
      UserList.addall(UserList1);
    }
   
    newList=new List<User>([Select BU_Attribute__c,
                            id,UserRoleId,
                            Exception__c,
                            Area__c,
                            Country__c,
                            Division__c,
                            Region__c,
                            Role__c,
                            Super_Area__c,Super_Division__c,
                            District__c,
                            Theater__c,contactId,AccountId,
                            Forecast_Group__c from User 
                            where id in: Userids and UserRoleId!=null and Exception__c=false ]);
    
        for(User usr:newList){
            usr.BU_Attribute__c='NewValue3';    
            usr.Area__c='NewValue3';
        }
        test.starttest();
        UserAttributesOperator fill_attributes=new UserAttributesOperator();
        fill_attributes.createNewUsers(UserList);
        for(Integer i=0;i<Userlist.size();i++){
            System.debug('Area**'+Userlist[i].Area__c+'---->'+newList[i].Area__c);
        }
        fill_attributes.editUsers(newList,UserList);
        test.stoptest();
    }
static testMethod void runRoleChangedTests() {
    System.debug('In Role Change Test');
    // UserRole usr1=createRole('test200000');
    // UserRole usr2=createRole('test3000000');
    // UserRoleidList.add(usr1.Id);
    // UserRoleidList.add(usr2.Id);
    System.debug('UserRoleIdList***'+UserRoleIdList);
    UserList=new List<User>([Select BU_Attribute__c,
                             id,UserRoleId,
                             Exception__c,
                             Area__c,
                             Country__c,
                             Division__c,
                             Region__c,
                             Role__c,
                             Super_Area__c,Super_Division__c,
                             District__c,
                             Theater__c,contactId,AccountId,
                             Forecast_Group__c from User where 
                             Exception__c=false and UserRoleId!=null limit 2]);
    
    for(User usr:UserList){
        Userids.add(usr.id);
        roleId.add(usr.UserRoleId);    
    }
    
    newList=new List<User>([Select BU_Attribute__c,
                            id,UserRoleId,
                            Exception__c,
                            Area__c,
                            Country__c,
                            Division__c,
                            Region__c,
                            Role__c,
                            Super_Area__c,Super_Division__c,
                            District__c,
                            Theater__c,contactId,AccountId,
                            Forecast_Group__c from User 
                            where Id in: Userids and Exception__c=false limit 2] );
    
         /*UserRole usr5=createRole('test3500000');
       for(User usr:newList){
            usr.UserRoleId=usr5.Id;
        }*/
        /*List <String> uamName;
        User_Attribute_Mapping__c[] uam=[Select Id,Name from User_Attribute_Mapping__c limit 100];
        for (integer i=0;i<uam.size();i++)
        {
            uamName.add(uam[i].Name);
        }
        
        UserRole role =[Select Id,name from UserRole where Id not In :roleId and Name not In :uamName limit 1];
        
                for(User usr:newList){
            usr.UserroleId=role.Id;    
            //usr.Area__c='NewValue3';
        }*/
    UserAttributesOperator fill_attributes=new UserAttributesOperator();
    // fill_attributes.createNewUsers(UserList);
    for(Integer i=0;i<Userlist.size();i++){
        System.debug('Role**'+Userlist[i].UserRoleId+'---->'+newList[i].UserRoleId);
    }
    fill_attributes.editUsers(newList,UserList);
       
    String str_attribute=newList[0].UserRoleId+'}'+newList[0].UserRoleId+'}'+newList[0].BU_Attribute__c+'}'+newList[0].Area__c+'}'+newList[0].Country__c+'}'+newList[0].Division__c+'}'+newList[0].Region__c+'}'+newList[0].Role__c+'}'+newList[0].Super_Area__c+'}'+newList[0].District__c+'}'+newList[0].Theater__c+'}'+newList[0].Forecast_Group__c;
    //End Of code updation..//
    List<String> StringAttributes=new List<String>();
    StringAttributes.add(str_attribute);
    UserAttributesOperator.insertNewRoleAttribute(StringAttributes);
}

}