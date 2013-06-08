/* ===========================================================================
|  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |             P Kothawade        Initial Creation.  Procedures for creating user groups &                
 |  24-Jul-09  P Singh            assiging that group to the user created.
 |                                
 |  22-Feb-12   Leonard V         Restirct execution of code for Users having Chatter free licence
 |  05-Apr-12   Leonard V         Changed Chatter free user execution logic                       
 +===========================================================================*/


public class CreateIndividualUserGroup{
 public static void CreateGroup(List <User> users) {
 	
 	Set<Id> chatterFreeProfSet = new Set<Id>();
List<User> usrList = new List<User>();


			//Added for Chatter Free User Restriction
        				
        			Map<String,Presales_ChatterFree__c> mapChatterProfId = Presales_ChatterFree__c.getall();
					
					for(Presales_ChatterFree__c chatFree : mapChatterProfId.values()){
						chatterFreeProfSet.add(chatFree.Profile_Id__c);
					}
        			
        			for (User usr : users){
        				if(!(chatterFreeProfSet.contains(usr.ProfileId))){
        					usrList.add(usr);
        				}
        			}
        			
        			//End Of Chatter Free



 Map<String,String> userIdName=new Map<String,String>(); 
    // Get all non System Admin Users
    //for(User us:userNoChatterList){
    for(User us:usrList){
        if(us.Profile_Name__c.contains('System Administrator'))
        continue;
        userIdName.put(us.Id,us.firstName+' '+us.lastname);
    }
    
    // Create Group for each user
    Map<String,Group> IndividualGroup = new Map<String,Group>();
    for(String usId:userIdName.keySet()){
        Group gro= new group(name=userIdName.get(usId),Type='Regular');
        IndividualGroup.put(usId,Gro);
    }
    
    // Insert Groups
    insert IndividualGroup.values();

    System.debug(IndividualGroup);
    
    // Insert User as a GroupMember
    List<GroupMember> grpMemberList =new List<GroupMember>();

    for(String usId:userIdName.keySet()){
        GroupMember grpMember= new GroupMember(GroupId=(IndividualGroup.get(usId)).Id,UserOrGroupId=usId);
        grpMemberList.add(grpMember);
    }
    // inesrt into database
    insert grpMemberList;

 
}
}