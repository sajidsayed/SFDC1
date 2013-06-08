/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  29/12/2011    Leonard V             This class is used to populate the Synergy account in Presales_Account__c object
                                        when ever there is account created or deleted                                          
 +==================================================================================================================**/

public class Presales_Account_Operation {
    
        List<Presales_Account__c> listPreAcc = new List<Presales_Account__c>();
        
        /* @Method <This method execute is used to insert Synergy account in to Presales_Account__c object based on account creation>
            @param <This method takes List<Account> as parameter>
        @return void - <Not returning anything>
        @throws exception - <No Exception>
        */  
        
        public void insertPresalesAccount(List<Account> lstPreAcc){
            
            if(lstPreAcc.size()>0){
                for(Account acc : lstPreAcc){
                Presales_Account__c preAccObj = new Presales_Account__c();
                
                preAccObj.Accountid__c= acc.Id;
             
                preAccObj.Name = acc.Synergy_Account_Number__c;
                listPreAcc.add(preAccObj);
            }
            
        }
                
            insert listPreAcc;
        }// Insert MEthod ends here
        
           /* @Method <This method execute is used to update Synergy account in to Presales_Account__c object based on account updation>
            @param <This method takes List<Account> as parameter>
        @return void - <Not returning anything>
        @throws exception - <No Exception>
        */  
        
        public void updatePresalesAccount(List<Account> lstPreAcc){
            
            Map<ID,string> mapAcc = new Map<ID,string>();
            List<Presales_Account__c> listPreAccount  = new List<Presales_Account__c>();
            if(lstPreAcc.size()>0){
                
                
                    for(Account acc : lstPreAcc){
                    mapAcc.put(acc.id , acc.Synergy_Account_Number__c);
                }
                
                List<Presales_Account__c> lstPresalesAcc = [Select name,Accountid__c from Presales_Account__c where Accountid__c in : mapAcc.keySet()];
                
                if(lstPresalesAcc.size()>0){
                
                for(Presales_Account__c objAcc:lstPresalesAcc){
                    
                    objAcc.Name = mapAcc.get(objAcc.Accountid__c);
                    listPreAcc.add(objAcc);
                }   
                    
                }
                
                update listPreAcc;
                
            }
            
            
            
        } // Update MEthod ends here
        
    

}// Class Ends Here