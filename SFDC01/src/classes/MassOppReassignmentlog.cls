/*
    HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     DESCRIPTION                               
 |  ====       =========     =========== 
 |   
    11-Jul-10  Shipra		Worked for removing  �etrieve id limit reached�error when clicking on Mass Reassignment History -->
*/
public with sharing class MassOppReassignmentlog {

    public PageReference Back() {
        return Page.MassReassign;
    }


/*    public PageReference sortByUser() {
    query('User__r.name asc');
       return null;
    }


    public PageReference sortByLogtime() {
    query('log_time__c asc');
        return null;
    }


    public PageReference sortByScenario() {
    query('Scenario__c asc');
        return null;
    }
*/

    public string orderby;
    Boolean oppy,Scenario=false,logtime,user;
    Mass_Opp_Reassignment_log__c[] result = new Mass_Opp_Reassignment_log__c[]{};
    list<Mass_Opp_Reassignment_log__c> bind = new list<Mass_Opp_Reassignment_log__c>();
    public List<Mass_Opp_Reassignment_log__c> getresults(){
     return result;
    }

    public MassOppReassignmentlog(){
      /*   results = [select id,Scenario__c,User__r.name,opportunity_name__r.name,opportunity__c,
                       result__c,log_time__c from Mass_Opp_Reassignment_log__c order by opportunity_name__r.name desc]; 
        */
                      query('opportunity_name__r.name asc');
     }

      
/*    public PageReference sortByOppy() {
    query('opportunity_name__r.name asc');
        return null;
    }
    
*/

   public list<Mass_Opp_Reassignment_log__c> query(string orderby){
   system.debug('==>'+orderby);
   string s = 'select id,Scenario__c,User__r.name,opportunity_name__r.name,opportunity__c,result__c,log_time__c from Mass_Opp_Reassignment_log__c order by '+ orderby+ ' limit 1000';
   return result = Database.query(s);
   
   }
   
   public void querylist(string orderby){
   system.debug('==>'+orderby);
   string s = 'select id,Scenario__c,User__r.name,opportunity_name__r.name,opportunity__c,result__c,log_time__c from Mass_Opp_Reassignment_log__c order by '+ orderby+ ' limit 1000';
   result = Database.query(s);
   bind.clear();
    for(Mass_Opp_Reassignment_log__c a: result){
    
    bind.add(a);
    }
   
   }
   

}