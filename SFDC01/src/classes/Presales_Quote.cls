/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  07/08/2012    Shalabh Sharma           This class is used to populate qoute creator's group.     
 +==================================================================================================================**/
public class Presales_Quote {
    public void presalesSetQuoteCreatorGroup(List<Quote_Custom__c> lstQuote){
           Map<String ,String> mapUsrGrp = new Map<String , String>(); 

            User usr= [select id,Name,UserRole.Name from User where id =:UserInfo.getUserId() AND UserType != 'PowerPartner'];
            
            Map<String,PresalesAssignedServiceGroup__c> mapUserGroup = PresalesAssignedServiceGroup__c.getall();
            
            for(PresalesAssignedServiceGroup__c assGrp :mapUserGroup.values()){
                mapUsrGrp.put(assGrp.QueueorRole__c , assGrp.Value__c);
            }

            for(Quote_Custom__c quoteRecord:lstQuote){
                if(usr != null && usr.UserRole.Name!= null && (usr.UserRole.Name).contains('Presales')){
                    quoteRecord.CreatedByGroup__c =  mapUsrGrp.get(usr.UserRole.Name); 
                }                  
            } 
    }
}