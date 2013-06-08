trigger userAttibuteMapping on User (before insert,before update) {

Set<Id> chatterFreeProfSet = new Set<Id>();
List<User> usrList = new List<User>();

    System.debug('util.fromuserattributemapping'+util.fromuserattributemapping);
    if(!util.fromuserattributemapping){
        UserAttributesOperator fill_attributes=new UserAttributesOperator();
        if(Trigger.isInsert){
        	
        			//Added for Chatter Free User Restriction
        				
        			Map<String,Presales_ChatterFree__c> mapChatterProfId = Presales_ChatterFree__c.getall();
					
					for(Presales_ChatterFree__c chatFree : mapChatterProfId.values()){
						chatterFreeProfSet.add(chatFree.Profile_Id__c);
					}
        			
        			for (User usr : Trigger.new){
        				if(!(chatterFreeProfSet.contains(usr.ProfileId))){
        					usrList.add(usr);
        				}
        			}
        			
        			//End Of Chatter Free
        			
        					if(usrList.size()>0){
                       		      fill_attributes.createNewUsers(usrList);
        					}
        			
                     }else{
             fill_attributes.editUsers(Trigger.new,Trigger.old);
         }
     }
}