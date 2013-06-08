/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true) 
private class Trasnformation_RecallBatch_TC {
    
    
    
 public Static List<Account> lstAccount = new List<Account>();
 public Static List<Opportunity> lstOpp= new List<Opportunity>();
 public Static List<Pricing_Requests__c> lstPricing = new List<Pricing_Requests__c>();
 public static Integer loopLimit= 1;
 
     public void createAccount(){
        List<User> lstUser = [Select id,Theater__c ,Division__c from user where IsActive = true and Theater__c in ('APJ') and Division__c not in ('Korea','UKI','ANZ','Greater China','India','Japan','South East Asia' ) and Division__c Not in ('N/A') limit :loopLimit];
         System.debug('lstUser1---->' + lstUser);
        for(Integer k=0;k<loopLimit;k++){
        Account accObj1 = new Account();
        accObj1.ownerId =lstUser[k].Id;
        accObj1.name = 'TestAccount'+ k;
        accObj1.BillingCountry ='United States';
        accObj1.BillingCity = 'EDWARDS AFB'; 
        lstAccount.add(accObj1);
        }
        
        Database.insert(lstAccount);
        lstAccount = [Select Id,Name,ownerId FROM Account Where id in: lstAccount];
        System.debug('lstAccount---->' + lstAccount);
      }//END METHOD - CreatecustomProfiledAccount
      
       //Method for Creation Of Opportunity
    public void createOpportunity(){
       List<User> lstUser = [Select id,Theater__c ,Division__c  from user where IsActive = true and Theater__c in ('APJ') and Division__c not in ('Korea','UKI','ANZ','Greater China','India','Japan','South East Asia' ) and Division__c Not in ('N/A') limit :loopLimit];
       System.debug('lstUser---->' + lstUser);
        for(Integer k=0;k<loopLimit;k++){
        Opportunity opp_Obj = new Opportunity();
          opp_Obj.AccountId =lstAccount[k].id;
          opp_Obj.Opportunity_Owner__c = lstUser[k].id;
        //  opp_Obj.Deal_Lead__c=lstUser[k].id;
          opp_Obj.ownerId=lstUser[k].id;
          opp_Obj.Name = 'TEST'+ k;
          opp_Obj.StageName = 'TEST';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
          lstOpp.add(opp_Obj);
        }
       Database.insert(lstOpp);
     //  lstOpp =[select ID,Name,Opportunity_Owner__c , Account_Owner_Theater__c , Opportunity_Owner__r.Theater__c from Opportunity where id in:lstOpp];
       lstOpp =[Select ID,Name,Opportunity_Owner__c , Account_Owner_Theater__c ,Account_Owner_Division__c, Opportunity_Owner__r.Theater__c from Opportunity where Opportunity_Owner__r.Theater__c in ('APJ') and StageName = 'Pipeline' and Sales_Channel__c='Direct'and Account_Owner_Division__c not in ('Korea','UKI','ANZ','Greater China','India','Japan','South East Asia' ) and Account_Owner_Division__c Not in ('N/A') and id in:lstOpp ];
       System.debug('lstOpp--->' + lstOpp.size() + lstOpp);
        
        }

//Method for creation of Pricing Requests    
    public void createPricingRequest(){
    
    List<Pricing_Requests__c> lstPric = new List<Pricing_Requests__c>();
    //Select id from Opportunity
     for(Integer k=0;k<lstOpp.size();k++){
      Pricing_Requests__c priReq_Obj = new Pricing_Requests__c();
      priReq_Obj.Opportunity_Name__c = lstOpp[k].id;
      priReq_Obj.Price_Floor_Level__c = 'L4';
      priReq_Obj.How_can_we_mask_actual_discount__c = 'TEST 1234';
      priReq_Obj.Approval_Status__c ='New';
      priReq_Obj.Recalled_Flag__c = false;
      priReq_Obj.APJ_Request_Escalation__c = false;
      priReq_Obj.EMC_PRODUCTS__c='test';
      lstPric.add(priReq_Obj);
     }
     Database.insert(lstPric);
     
     lstPricing =[select id,Approval_Status__c,createdById, PR_Account_Owner_Divison__c,PR_Account_Owner_Theater__c,Opportunity_Name__r.Opportunity_Owner__c  from Pricing_Requests__c  where id in:lstPric];
     System.debug('lstPricing------>'+ lstPricing);
 } ///end of method Creation Of Pricing Requests 
  
  
  // Submit for Approval
  public void submitForApproval()
        {
          System.debug('####Inside--->');
            // Create an approval request for the Opportunity
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval automatically using Trigger');
            for(Pricing_Requests__c prObj:lstPricing){ 
            req1.setObjectId(prObj.id);
            Approval.ProcessResult result = Approval.process(req1);
            }
          //  req1.setNextApproverIds(new Id[] {opp.Next_Approver__c});
     
            // Submit the approval request for the Opportunity
            
            System.debug('#### Submitted--->');
     
        }
        //Get ProcessInstanceWorkItemId using SOQL
        public Id getWorkItemId(Id targetObjectId)
        {
            Id retVal = null;
     
            for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
                where p.ProcessInstance.TargetObjectId =: targetObjectId])
            {
                retVal  =  workItem.Id;
            }
     
            return retVal;
        }
        
   /*private static testmethod void Trasnformation_RecallBatchSchedulerTest() {
    Test.StartTest();
    String sch = '0 0 0 4 9 ?  ' ;
    try{
    system.schedule('TEST CLEAN UP- BatchDeleteData', sch, new Trasnformation_RecallBatch());
    } catch(Exception e) {
      system.debug('Exception Inside batchDeleteDataSchedulerTest()' + e );   
     }
    Test.StopTest();
  }*/
  
  private static testmethod void batchTrasnformation_RecallBatchTest() {
    Trasnformation_RecallBatch_TC testObj = new Trasnformation_RecallBatch_TC();
  
         User usr = [Select id from User where Id = :UserInfo.getUserId()];
         System.RunAs(usr)
            {  testObj.createAccount();
                testObj.createOpportunity();
              testObj.createPricingRequest();
               testObj.submitForApproval();
             for(Integer i=0;i<lstPricing.size();i++){
                        lstPricing[i].Recalled_Flag__c = true;
             }
            Database.update(lstPricing);
              //Submitting for approval
           
                
         }
    Test.StartTest();   
      DateTime delDate = system.now()- 2;
      List<ProcessInstanceWorkitem>  workitem = new List<ProcessInstanceWorkitem>([select Id, ProcessInstance.TargetObjectId,ProcessInstance.status from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in: lstPricing ]);
      System.debug('workitem  in test class===>'+ workitem);
      String query  = 'select Id,Name,Owner.Name,Recall_Comments__c from Pricing_Requests__c where EMC_PRODUCTS__c!= null and Recalled_Flag__c=true ';
       try{
      database.executebatch( new Trasnformation_RecallBatch(query) );
      } catch(Exception e) {
      system.debug('Exception Inside batchDeleteDataSchedulerTest()' + e );   
     }
    Test.StopTest();
  }
    
    
    
    
    
    
}