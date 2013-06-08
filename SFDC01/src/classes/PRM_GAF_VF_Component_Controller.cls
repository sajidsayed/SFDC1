/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  23/02/2012   Anirudh Singh            This Class will be used as controller for GAF Visualforce Page Component.    
 +==================================================================================================================**/
 public class PRM_GAF_VF_Component_Controller{
     public List<String> lstSpecialty;
     private List<String> lstQuarter;
     public GAF__c GAFRecord;
     public ApexPages.standardController stdCon;
     public List<String> lstColumnHeader;
     
     public PRM_GAF_VF_Component_Controller() {
     } 
     public PRM_GAF_VF_Component_Controller(ApexPages.StandardController stdController) {
         //stdCon = stdController;
         //GAFRecord = (GAF__c)stdController.getRecord();
     } 
 
     public string sObjectType
    {
        get;
        set;
    }
    Account GAF_Related_Account = [Select Id,Partner_Type__c from Account where id = :GAFRecord.Partner_Name__c];
    public List<String> getlstSpecialty(){
        lstSpecialty = new list<string>();
       // if(GAF_Related_Account.Partner_Type__c.contains('Distributor')){
            lstSpecialty.add('BRS');
            lstSpecialty.add('Consolidate');
            lstSpecialty.add('Advanced Consolidate');
            lstSpecialty.add('Governance & Archive');
       // }
        return lstSpecialty;
    }
    public List<String> getlstQuarter(){
        lstQuarter = new list<String>();
        lstQuarter.Add('Q1');
        lstQuarter.Add('Q2');
        lstQuarter.Add('Q3');
        lstQuarter.Add('Q4');
        lstQuarter.Add('Total');
        return lstQuarter;
    }
 }