/*===========================================================================+
 |  Created History                                                                  
                                                                 
 |  DATE       DEVELOPER  WORK REQUEST    DESCRIPTION                               
 |  ====       =========  ============    =========== 
 |  30-Sep-11  Leonard V                  Test class for all the presales Apex classes
 
    Updated History                                                                  
                                                                 
 |  DATE       DEVELOPER  WORK REQUEST   DESCRIPTION                                
 |  ====       =========  ============   =========== 
 |  7-OCT-11   Leonard V                 Updated the test class to include only Presales_SLA_Class,Presales_Operations
                                         Presales_UpdateCaseTeams & Presales_Case_Page_Controller to avoid governor limit
 |  DATE       DEVELOPER  WORK REQUEST   DESCRIPTION                              
 |  ====       =========  ============   =========== 
 |  10-OCT-11   Leonard V                 Updated the test class to include all the Apex Classes with out exceed the governor limit
 |  
 |  06/01/2012     Leonard Victor         Updated to incorporate jan Bucket release    
 |  23/02/2012     Leonard Victor         Updated to incorporate March 2012 Bucket release    
 |  09/05/2012     Leonard Victor         Updated to incorporate June 2012 Release
 |  28/11/2012     Ganesh Soma            Added new 5 methods in the test class 'PreSales_Tc' for increasing code coverage of Presales_Operations/Presales_Quote/Presales_PartnerCaseOperation/Presales_UpdateCaseTeams/Presales_SendMailToManager/Presales_CaseShare_Class classes:
 |                                        1) PreSales_Tc_Test1 2) PreSales_Tc_Test2 3) PreSales_Tc_UpdateCaseTeams  4) PreSales_Tc_SendMailToManager  5) PreSales_Tc_PreSalesCaseShare
 |                                        'updateCase' method commented by Ganesh on 26Nov2012 after writing the method 'PreSales_Tc_UpdateCaseTeams'
 |                                        'preSalesCaseShare' method commented by Ganesh on 27Nov2012 after writing the method  PreSales_Tc_PreSalesCaseShare
 |                                        'preSalesSendemailmethod' commented by Ganesh on 26Nov2012 after writing the method 'PreSales_Tc_SendMailToManager'
 |  18April2013    Ganesh Soma WR#252927  Increased Code Coverage
 +==================================================================================================================================================================*/

@isTest(seealldata = true)
private class PreSales_Tc {
    
   public Static List<Case> caseLst = new List<Case>();
   public Static List<Contact> contLst = new List<Contact>();
   public Static List<Opportunity> oppLst = [Select id from Opportunity limit 2];
   public Static List<User> lstUser = [Select Id,email,Country__C,UserRoleId  from user where Profile_Name__c like 'Presales%' and  UserRoleId!=null and isActive = true Limit 2];
   public Static List<Opportunity> lstOpp= new List<Opportunity>();
    public Static List<Account> acctLst = new List<Account>();
    
   
  //Method for Creation Of Account    
    public void createAccount(){
       
        System.debug('Inside Account Creation');     
        Account acctObj = new Account();
        acctObj.Name = 'PreSalese Testing';
        acctObj.Synergy_Account_Number__c = '123456';
        acctLst.add(acctObj);
        Database.insert(acctLst);
        System.debug('Account Created'); 
        acctLst = [Select ID,Synergy_Account_Number__c  from Account where Name =:acctLst[0].Name];
        //return acctLst;
    }
    
    // Method For Contact Creation
    
     public void createContact(){

        List<RecordType> recList = [ Select Id, Name from RecordType where sObjectType ='Contact' AND Name='EMC Internal Contact'];
        for(Integer c=0;c<4;c++){
        Contact contObj = new Contact();
        contObj.LastName = 'Tester';
        contObj.Phone = '999999999';
        if (c==2)
        contObj.Email = 'Leonard.Victor@accenture.com';
        else
        contObj.Email = 'test'+c+'@acc.com';
        if(c==3)
            contObj.RecordTypeId = recList[0].id;
        contLst.add(contObj);
        }
        Database.insert(contLst);
        System.debug('Contact Created'); 
        
        contLst = [Select ID,Email,Phone from Contact where id in:contLst];
        
        
    }
    
    //Method for Creation Of Opportunity
    public void createOpportunity(){
      for(Integer i=0;i<2;i++){   
                Opportunity opp_Obj = new Opportunity();
                opp_Obj.AccountId =acctLst[0].id;
                opp_Obj.Name = 'TEST';
                opp_Obj.StageName = 'TEST';
                opp_Obj.CloseDate = Date.today()+10;
                opp_Obj.Sales_Force__c = 'EMC';
                opp_Obj.Sales_Channel__c = 'Direct';
                opp_Obj.VMWare_Related__c = 'VMWare Backup';
                lstOpp.add(opp_Obj);
           }
            
        Database.insert(lstOpp);
        lstOpp =[select ID,Name from Opportunity where id in:lstOpp];
       
    }
          
    //Method for Creation Of Case
    
    public void createCase(){
        List<Case> lstCase = new List<Case>(); 
        Map<String , Id> recid = new Map<String , Id>();
       
       List<RecordType> recList = [Select id,name from recordtype where name in ('Professional Services Inquiry' , 'Technical Drawings')];


       for(RecordType rec:recList){

            recid.put(rec.name,rec.id);

       }
        
        for(Integer i=1 ; i<=4; i++){
                Case caseObj_Insert = new Case();
                caseObj_Insert.Description = 'TEST1';
                caseObj_Insert.Subject = 'TEST1';
                caseObj_Insert.Origin = 'System';
                
                caseObj_Insert.Type = 'Application RFP Assistance';
                caseObj_Insert.Record_Type_Hidden__c = 'Application RFP Assistance';
                caseObj_Insert.RecordTypeId = recList[0].id;
                
                if(i==2){
                
                caseObj_Insert.Type = 'Technical Drawings';
                caseObj_Insert.Record_Type_Hidden__c = 'Technical Drawings';
                caseObj_Insert.RecordTypeId = recList[1].id;
                caseObj_Insert.Case_to_Account__c=false;
                
                }

              //  caseObj_Insert.Ownerid = lstUser[0].id;
                caseObj_Insert.Opportunity_Name__c =oppLst[0].id;
                  caseObj_Insert.ContactId = contLst[0].id;
                caseObj_Insert.Contact_Email1__c= contLst[0].email;
                 caseObj_Insert.Priority = 'High';
                  caseObj_Insert.Status = 'Open';
             

                //Used Case with Closed Status
                if(i==3){
                caseObj_Insert.Status = 'Closed';
                }
                if(i==4){
                caseObj_Insert.Status = 'Escalate';
                }
                lstCase.add(caseObj_Insert);
        }
        //Case Insertion
           
        Database.insert(lstCase);
        caseLst = lstCase;
     //caseLst =[select ID,Is_contact__c,LastModifiedDate,status,RecordTypeId,parentid,Contact_Name_User__c,Country__c,ownerid,contact_Email1__c  from Case where id in :lstCase];
      
    }

 //RecordType Controller Method Starts Here
  static testMethod void  recordTypeController(){
    
            try{
                
                    //Invoking contact creation and Case creation Methods for creating test Data
                   
                   PreSales_Tc testObj = new PreSales_Tc();
                       testObj.createContact();
                    
                        
                   Test.starttest(); 

                      testObj.createCase();
                       
                //Setting Apex values and assinging values to the controller
                ApexPages.currentpage().getParameters().put('id',caseLst[0].id); 
                Test.setCurrentPageReference(new PageReference('flag=0'+caseLst[0].id)); 
                ApexPages.StandardController controller = new ApexPages.StandardController(caseLst[0]);  
            
                //Invoking the controller class with the Apex Controller and desiered object type
                Presales_RecordTypeListController caseObj = new Presales_RecordTypeListController(controller);
                  
                 caseObj.sObjectType = 'Case';  
                 caseObj.getItems();
                 caseObj.checkParentCase();
                 caseObj.createChildCase();
                 
                 

                Test.stoptest();
            } catch (System.DmlException e){
                  System.debug('DML exception: ' + e.getDmlMessage(0));   
            }
    
  }//RecordType Controller Method Ends Here
        
    //Closure Test Method Begins Here
    static testMethod void  preSalesOpp(){
          try{

                    //Invoking contact creation and Case creation Methods for creating test Data
                    PreSales_Tc testObj = new PreSales_Tc();
                   // testObj.createAccount();
                    testObj.createContact();
                    lstUser[0].email = contLst[0].Email;
                    lstUser[1].email = contLst[1].Email;
                    Database.update(lstUser);
                  //  testObj.createOpportunity();
                    testObj.createCase();  

           
                    //Control Statement to restrict the Operation class to be called with out any case                    
            if(caseLst.size()>0){           
            Map<ID,Case> caseMap = new Map<ID,Case>(caseLst);
            
         
    
           //Invoking Operation Class to populate login User details
           
              Test.starttest();
              
               //  caseLst =[select ID,Customer_Account_Name__c,Opportunity_Name__c,Division__c,Country__c,
                   //     AccountId,Contact_Phone1__c,Contact_Email1__c,Area__c,District__c,Theatre__c,
                    //    Is_contact__c,OwnerID from Case where id IN :caseMap.keySet()];
                        
           System.debug('Case_List------>' +caseLst[0].OwnerID);
                   
           Presales_Operations objOper = new Presales_Operations();
           
           objOper.populateLoginUserDetails(caseLst);
         
          List<Profile> userProfile = [select Id, Name from Profile where name= 'APJ Core TC'];
          
          
             List<User> u = [Select id,name,alias,email,emailencodingkey,lastname,languagelocalekey,localesidkey
                           ,profileid,timezonesidkey,username from user where profileid =:userProfile[0].id  and IsActive = true limit 1];
               
              // System.debug('u---->'+u.name+'U.ID'+u.id+'U.profid'+u.profileid);
         
           //Updating the case with different Oppertunity to satisfy trigger condition
           caseLst[0].Opportunity_Name__c =oppLst[1].Id ;
           caseLst[0].OwnerId = lstUser[1].ID ;
           caseLst[0].Contact_Email1__c = null;
           caseLst[0].Contactid = null;
           Database.update(caseLst);
        
                       caseLst =[select ID,Customer_Account_Name__c,Opportunity_Name__c,Division__c,Country__c,
                        AccountId,Contact_Phone1__c,Contact_Email1__c,Area__c,District__c,Theatre__c,
                        Is_contact__c,OwnerID from Case where id =:caseLst[0].id];
                        

           objOper.checkIFRequestorUserOrContact(caseLst);
            
          System.runAs(u[0]){
           objOper.checkValidationOnCaseUpdate(caseMap,caseMap);
           
           }
      
            Test.stoptest();
           }
           } catch (System.DmlException e){
                    System.debug('DML exception: ' + e.getDmlMessage(0));   
           }
                    
   } // Operataion Method Ends Here
            
  
    //CasePageController Method Begins Here
   
   static testMethod void casePageController(){
    
            try{
                
                        
                 List<Id> lstId = new List<Id>();
                 //Invoking contact creation and Case creation Methods for creating test Data
                 PreSales_Tc testObj = new PreSales_Tc();
                // testObj.createAccount();
                 testObj.createContact();
             

                testObj.createCase();
                 caseLst =[select ID,LastModifiedDate,status,Record_Type_Hidden__c,contact_Email1__c  from Case where id in :caseLst];
                 Test.starttest();
                 
                 //Creating New Attachment Object and creating a reocrd for attachment object
                    Attachment att = new Attachment();     
                    List<Attachment> attLst = new List<Attachment>();  
                    String myString = 'StringToBlob';
                    Blob myBlob = Blob.valueof(myString);
                    
                    //List<Case> lst_Case = [Select ID,Escalation__c,IsEscalated,CaseNumber,Record_Type_Hidden__c from Case where Id =:lstCase];
                    
                    System.debug('CASELIST__>'+caseLst);
                  
                    att.ParentId=caseLst[0].Id;
                    att.Body=myBlob;
                    att.Name='File1';
                    att.ContentType = 'doc,txt,jpeg';
                    attLst.add(att);
                    
                  //Invoking the controller class with Apex Standard Controller
                    ApexPages.currentpage().getParameters().put('Id',caseLst[0].id); 
                    ApexPages.StandardController controller = new ApexPages.StandardController(caseLst[0]);  
                    Presales_Case_Page_Controller caseObj= new Presales_Case_Page_Controller(controller);
                    Presales_Case_Page_Controller caseObj1= new Presales_Case_Page_Controller();
              
                    caseObj.newAttachments=attLst;         
                    caseObj.addMore();
                    caseObj.Save();
                    caseObj.getApplicationID();
                    caseObj.createInstance();
                    Presales_Case_Page_Controller.getDescription('APJ');
                Test.stoptest();
              
            } catch (System.DmlException e){
                  System.debug('DML exception: ' + e.getDmlMessage(0));   
            }
    
      }//CasePageController Method Ends Here      
   
   
   
  
   /*     
       //This method commented by Ganesh on 26Nov2012 after writing the method PreSales_Tc_UpdateCaseTeams
      //Update Case Method Begins Here       
   static testMethod void  updateCase(){
     
            try{
               
                  //Invoking contact creation and Case creation Methods for creating test Data
                  PreSales_Tc testObj = new PreSales_Tc();
                 // testObj.createAccount();
                   testObj.createContact();
                 // testObj.createOpportunity();
                   testObj.createCase();

                   Test.starttest();
                  List<Case> lstCase = new List<Case>();
                  //Taking Open status case from list of cases created above
                  lstCase = [Select id,status from case where status =:'Open' and id in :caseLst];
                  Presales_UpdateCaseTeams update_Obj = new Presales_UpdateCaseTeams();
                  Presales_UpdateCaseTeams update_Obj1 = new Presales_UpdateCaseTeams();
                  Presales_UpdateCaseTeams update_Obj2 = new Presales_UpdateCaseTeams();
                  String eMail = contLst[0].Email+';'+contLst[1].Email;
                  System.debug('emailllll---->'+eMail);
                  //Invoking Email method with the caseId and set of email ids
                  update_Obj.addToCcToCaseTeam(lstCase[0].id,eMail,'test@acc.com' , 'test@acc.com');
                  lstUser[0].email = 'Test@acc.com';
                  lstUser[1].email = 'Test@acc.com';
                  System.debug('USER LIST' +lstUser);
                  Database.update(lstUser);
                  String eMail2=lstUser[0].email+';'+lstUser[1].email;  
                  System.debug('emai2222222222---->'+eMail2);
                  //Invoking Email method with the caseId and set of email ids
                  update_Obj2.addToCcToCaseTeam(lstCase[0].id,eMail2,'test@acc.com' , 'test@acc.com');
                  update_Obj2.populateRequestorDetailsEmailToCase(lstCase[0].id,eMail2);
                 lstCase[0].status = 'Closed';
                 update lstCase;
                  lstCase = [Select id,status from case where status =:'Closed'  and id in :caseLst];
                  
                  String eMail1='update@acc.com;update1@acc.com';  
                   //Invoking Email method with the caseId and set of email ids
                 update_Obj1.addToCcToCaseTeam(lstCase[0].id,eMail1,'test@acc.com' ,'test@acc.com');
                 
        
            Test.stoptest();
        } catch (System.DmlException e){
            System.debug('DML exception: ' + e.getDmlMessage(0));   
        }
     }//Update Case Method Ends Here
     
     */
     
     //Case SLA Method Begins Here
     
  static testMethod void caseSLA(){
        
           /* try{
                  
                    //Invoking contact creation and Case creation Methods for creating test Data
                    PreSales_Tc testObj = new PreSales_Tc();
                     testObj.createContact();                       
                       lstUser[0].Exception__c = true;
                       lstUser[0].email = contLst[0].Email;
                       lstUser[0].Country__c = 'United States';
                       lstUser[0].Theater__c = 'Global';
                       Database.update(lstUser);
                       
                        //Commented by Ganesh on 23jan2013
                       //lstUser = [Select id,Country__C,email from user where id in :lstUser];
                       testObj.createCase();                
                        
                        //Creating SLA object and insering a record in to it           
                        
                         Test.starttest();                
                        Presales_SLA__c slaObj = new Presales_SLA__c();
                        List<Presales_SLA__c> lstSLA = new List<Presales_SLA__c>();
                        slaObj.Case_Record_Type__c = 'Application RFP Assistance';
                        slaObj.Theater__c = 'Global';
                        slaObj.Priority__c = 'Normal';
                        slaObj.Time_to_resolution__c =20;
                        slaObj.Country__c = 'United States';
                        lstSLA.add(slaObj);
                        Database.insert(lstSLA);
                        
                        //Commented by Ganesh on 23jan2013
                        //lstSLA = [Select Case_Record_Type__c,Theater__c,Priority__c,Time_to_resolution__c,Country__c from Presales_SLA__c where id in:lstSLA  ];
                                         
                        
                        //Commented by Ganesh on 23jan2013
                        //List<Case> lst_case = [Select ID,RecordTypeId,Theatre__C,Country__C,Priority,Status,Recordtype.Name,LastModifiedDate,CreatedDate,parentid,contactid from Case where Id in:caseLst];
                
                      //Commneted by Ganesh on 23jan2013
                        //Creating Presalaes SLA Record
                         // Presales_Case_SLA_Tracking__c sla_track = new Presales_Case_SLA_Tracking__c();
                         
                          //sla_track.Case__c = caseLst[0].id;   //sla_track.Case__c = lst_case[0].id;   //Commneted by Ganesh on 23jan2013
                          //insert sla_track;
                
                          //To Check SLA Before Delete 
                          Presales_SLA_Class sla_Obj = new Presales_SLA_Class();
                           sla_Obj.chkSLABeforeDelete(lstSLA);
                           
                          
                          sla_Obj.populateChildData(caseLst,caseLst);    //sla_Obj.populateChildData(lst_case,lst_case);  //Commneted by Ganesh on 23jan2013
                          lstSLA[0].Priority__c = 'Medium';
                          lstSLA[0].Theater__c = 'APJ';
                          update lstSLA;

                          sla_Obj.presalesStdCaseTime(caseLst, 'Insert'); //sla_Obj.presalesStdCaseTime(lst_case, 'Insert'); //Commneted by Ganesh on 23jan2013
                          sla_Obj.chkUniqueSLAValidation(lstSLA , 'Insert');                    
                          delete lstSLA;
                         
                   Test.stoptest();
                    
           } catch (System.DmlException e){
                   System.debug('DML exception: ' + e.getDmlMessage(0));   
           }
                         
     */}//Case SLA Method Ends Here
     
     //Flagged Controller Method Starts Here
    static testMethod void flaggedController(){
        try{
            
                        //Invoking contact creation and Case creation Methods for creating test Data
                        PreSales_Tc testObj = new PreSales_Tc();
                      //  testObj.createAccount();
                        testObj.createContact();
                        //testObj.createOpportunity();
                        testObj.createCase();
            
                        //Creating new Attachment Object and filling up the Attachment object with required deatils
                        Test.starttest();
                        Attachment attObj = new Attachment();   
               
                        List<Attachment> attLst = new List<Attachment>();  
                        String myString = 'StringToBlob';
                        Blob myBlob = Blob.valueof(myString);
                              attObj.ParentId=caseLst[0].Id;
                        attObj.Body=myBlob;
                        attObj.Name='File1';
                        attObj.ContentType = 'doc,txt,jpeg';
                        attLst.add(attObj);
                        //Inserting in to attachment object
                        insert attLst;
                         
                     //Creating Records for RPQ WIKI object
                     RPQ_Wiki_Attachments__c wikiObj =new RPQ_Wiki_Attachments__c();
                     wikiObj.Case__c = caseLst[0].Id;
                     wikiObj.Send_to_Wiki__c = true;
                     wikiObj.Attachment_Id__c= attLst[0].id;
                     insert wikiObj;                 
                     
                     
                        
                     //Invoking Controller Class with the Apex standard Controller
                     ApexPages.currentpage().getParameters().put('id',caseLst[0].id); 
                     ApexPages.StandardController controller = new ApexPages.StandardController(caseLst[0]);  
                     Presales_FlaggedAttachmentController flgObj = new Presales_FlaggedAttachmentController(controller );
                     
                     flgObj.getAttachments();
                     flgObj.getProcessedAttachments();
                     flgObj.cancelCase();
                     
                    // flgObj.selected = true;
                     flgObj.processSelected();
                     
               
                     flgObj.cancelCase();
           Test.stoptest();
                
           } catch (System.DmlException e){
             System.debug('DML exception: ' + e.getDmlMessage(0));   
           }
              
     }//Flagged Controller Method Ends Here
     
     
     /*     
       //This method commented by Ganesh on 23Jan2013 
    //Case Inbond Method Starts Here
    static testMethod void  caseInboundEmail(){
    
            try{
            
                     //Invoking contact creation and Case creation Methods for creating test Data
                    PreSales_Tc testObj = new PreSales_Tc();
                  //  testObj.createAccount();
                     testObj.createContact();
                   //  testObj.createOpportunity();
                     testObj.createCase();

                    Test.starttest();     
                    List<Case> opnLst = [select id,status from Case where status = :'Open'  and id in:caseLst];
                    //List<Case> clsLst = [select id,status from Case where status = :'Closed'  and id in:caseLst ];
                    Map<String,id> mapCase = new Map<String ,id>();
        
                    // Create a new email, envelope object and Attachment
                    Messaging.InboundEmail email = new Messaging.InboundEmail();
                    Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
                    
                    // Create a new email subject with open case and status as escalate
                    email.subject = 'escalate'+opnLst[0].id;
                    email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
                    envelope.fromAddress = 'user@acme.com';
                
                   // setup controller object
                    Presales_EscalateCaseFromInboundEmail inBound_Obj= new Presales_EscalateCaseFromInboundEmail();
                    inBound_Obj.handleInboundEmail(email, envelope);
                  
                    List<Case> clsLst = [select id,status from Case where status = :'Closed'  and id in:caseLst ];

                    // Create a new email subject with close case and status as escalate                
                    
                    email.subject = 'escalate'+clsLst[0].id;
                    System.debug('email1.subject-->' + email.subject);

                    inBound_Obj.handleInboundEmail(email, envelope);
                
                     // Create a new email subject with close case and status as close
                    email.subject = 'close'+clsLst[0].id;
                    System.debug('email1.subject111-->' + email.subject);
                     inBound_Obj.handleInboundEmail(email, envelope);
         Test.stoptest();
         
         } catch (System.DmlException e){
                    System.debug('DML exception: ' + e.getDmlMessage(0));   
           }
    }//Case Inbound Method Ends Here
     
 */
      
  //ClosureTime Method Starts Here
  static testMethod void  preSalesClosureTime(){
          try{
           
                    //Invoking contact creation and Case creation Methods for creating test Data
                    PreSales_Tc testObj = new PreSales_Tc();
                 //   testObj.createAccount();
                     testObj.createContact();
                  //    testObj.createOpportunity();
                     testObj.createCase();
                      Test.starttest();
                     List<Id> lstId = new List<Id>();
                     //Changing the case status to Resolved to satisfy trigger condition 
                     for(Integer k=0 ; k<caseLst.size(); k++){
                           System.debug('ListCaseID----->'+caseLst[k].id);
                           if(caseLst[k].status!= 'Resolved'){
                           caseLst[k].status ='Resolved';
                           }
                           else
                               caseLst[k].status ='Open';
                           lstId.add(caseLst[k].id);
                           caseLst[k].Is_contact__c = true;
                           
                     }
                  //Updaing the Case with Resolved status
                  Database.update(caseLst);
            Test.stoptest();
            
           } catch (System.DmlException e){
                    System.debug('DML exception: ' + e.getDmlMessage(0));   
           }
                    
   }//ClosureTime Method Ends Here
   
   /*
   //This method commented by Ganesh on 27Nov2012 after writing the method  PreSales_Tc_PreSalesCaseShare
   static testMethod void  preSalesCaseShare(){
          try{
                           
                            //Invoking contact creation and Case creation Methods for creating test Data
                            PreSales_Tc testObj = new PreSales_Tc();
                            Presales_CaseShare_Class shrObj = new Presales_CaseShare_Class();
                         //   testObj.createAccount();
                             testObj.createContact();
                        //   testObj.createOpportunity();
                            testObj.createCase();
                            Id uId;
                 
                 Test.starttest(); 
                
                Case childObj = new Case();
                childObj.Description = 'ChildCase';
                childObj.Subject = 'ChildCase';
                childObj.Record_Type_Hidden__c = 'Application RFP Assistance';
                childObj.Ownerid = lstUser[0].id;
                childObj.Opportunity_Name__c =oppLst[0].id;
                childObj.ContactId = contLst[0].id;
                childObj.Contact_Email1__c= contLst[0].email;
                childObj.parentid = caseLst[0].id;
                
                insert childObj;
                
                
                caseLst = [Select Record_Type_Developer_Name__c,parentid,id,Is_contact__c,Contact_Name_User__c,Ownerid from Case where parentid in :caseLst];
               // caseLst = [Select parentid,id,Contact_Name_User__c,Ownerid from Case where id in :childObj];
                           
                            //Filling case ids in to lstId list 
                             List<Id> lstId = new List<Id>();     
                               List<Id> userUnMatchedId= new List<Id>();   
                              Map<id,id> requestorId = new Map<id,id>();
                                Map<id,id> mapParentCaseId= new Map<id,id>();
                                Map<id,id> mapChildCaseId= new Map<id,id>();
                                 List<ID> parentId = new List<ID>();
                                Map<id,id> mapCaseOwnerId= new Map<id,id>();
                            
                                
                             for(Integer i=0;i<caseLst.size();i++){
                             lstId.add(caseLst[i].id);
                             uId=caseLst[i].Contact_Name_User__c;
                             userUnMatchedId.add(uId);
                             requestorId.put(caseLst[i].id,caseLst[i].Contact_Name_User__c);
                             mapParentCaseId.put(caseLst[i].id ,caseLst[i].ParentId);
                             mapChildCaseId.put(caseLst[i].ParentId,caseLst[i].id);
                             parentId.add(caseLst[i].ParentId);
                             mapCaseOwnerId.put(caseLst[i].id , caseLst[i].Ownerid);
                             
                             
                         }
                         Presales_CaseShare_Class.chkShareFlag1 = true;
                         Presales_CaseShare_Class.deleteShareFlag = false;
                          Presales_CaseShare_Class.chkShr= 2;
                  //  shrObj.insertUpdateShare(lstId,'U','test0@acc.com',caseLst ,parentId,false,caseLst,true,uId);      
                    shrObj.insertUpdateShare(lstId,'U','test0@acc.com',caseLst ,parentId,false,caseLst,true,uId , false);      
                   shrObj.SetParentChildAccess(lstId,parentId,requestorId,mapChildCaseId,mapParentCaseId,true , false); 
                   //shrObj.SetParentChildAccess(lstId,parentId,requestorId,mapChildCaseId,mapParentCaseId,mapCaseOwnerId);
                 Test.stoptest();
            } catch (System.DmlException e){
                    System.debug('DML exception: ' + e.getDmlMessage(0));   
           }    
     }      
     */
   
    //Presales Task test method starts here
  static testMethod void  preSalesTask(){
   try{
                           

                            //Invoking contact creation and Case creation Methods for creating test Data
                            PreSales_Tc testObj = new PreSales_Tc();
                        //    testObj.createAccount();
                             testObj.createContact();
                        //   testObj.createOpportunity();
                            testObj.createCase();
                           
                           
                             Test.starttest(); 
                            //Taking Unique Record Type for assigning to task object
                            
                             RecordType rType= [Select id,Name from RecordType where name ='Presales Task'];

                              //Filling data to task Object 
                              Task t = new Task();
                               List<Task> tskLSt = new List<Task>();
                               t.Priority = 'High';
                               t.WhatId = caseLst[0].id;
                               t.Subject = 'Call - PS';
                               t.VCE_Assigned_To__c = 'Test';
                              t.VCE_Last_Modifying_Partner__c  = 'Test';
                               t.RecordTypeId = rType.id;
                               tskLSt.add(t);
                   
                             //Task insertion this will call the trigger for Task
                               insert tskLSt;
                               
                               List<EmailMessage> caseEmail = new List<EmailMessage>();
                               EmailMessage emailMess = new EmailMessage();
                               emailMess.ParentId = caseLst[2].id;
                               emailMess.Incoming = true;
                               emailMess.FromAddress = contLst[1].Email;
                               emailMess.CcAddress = contLst[1].Email;
                               emailMess.BCcAddress = contLst[1].Email;
                               emailMess.toAddress = contLst[1].Email;
                               caseEmail.add(emailMess);

       
                               insert caseEmail;

                               Presales_CheckRecordType classObj = new Presales_CheckRecordType();                              
                               classObj.checkRecordType(caseLst);
                               classObj.checkTaskRecordType(tskLSt);
                               classObj.checkCaseEmailRecordType(caseEmail);
                               classObj.checkIFConversionAdmin();
                             
                             Test.stoptest();
            } catch (System.DmlException e){
                    System.debug('DML exception: ' + e.getDmlMessage(0));   
           } 
           }  //End of Presales Task test method

    /*
    //This method commented by Ganesh on 26Nov2012 after writing the method PreSales_Tc_SendMailToManager
        static testMethod void  preSalesSendemail(){
  try{
                           

                            //Invoking contact creation and Case creation Methods for creating test Data
                            PreSales_Tc testObj = new PreSales_Tc();
                         //   testObj.createAccount();
                             testObj.createContact();
                        //   testObj.createOpportunity();
                            testObj.createCase();
                             Test.starttest(); 
                             testObj.createAccount();
                            acctLst[0].Synergy_Account_Number__c = '888888';

                            update acctLst;
                             
                           Presales_SendMailToManager sndMailObj = new Presales_SendMailToManager();

                         Case cs = new Case();

                         cs = [Select id,RecordTypeId,ownerid from Case where id in:caseLst and Status = 'Escalate' limit 1];


                      //  lstUser = [Select Id,email,Country__C,UserRoleId  from user where Profile_Name__c like 'Presales%' and UserRoleId!=null and PreSales_Case_Escalated__c = true and isactive = true Limit 2];
                         
                         cs.ownerid = lstUser[1].id;
                         update cs;
                         
                         cs = [Select id,RecordTypeId,ownerid from Case where id in:caseLst and Status = 'Escalate' limit 1];

                         Map<id,Case> caseMap = new Map<id,Case>();
                         caseMap.put(cs.RecordTypeId , cs);


                          sndMailObj.findManagerOfOwner(caseMap);
                        
                             Test.stoptest();
            } catch (System.DmlException e){
                    System.debug('DML exception: ' + e.getDmlMessage(0));   
           } 
   
   }  //End of Presales Task test method
 */
 
//Test Method for Case to Opp attachment
    static testMethod void  caseToOppAtt(){
     
            try{

                 PreSales_Tc testObj = new PreSales_Tc();

                            testObj.createContact();
                            testObj.createCase();
                         Test.starttest(); 

                            caseLst = [Select id,Opportunity_Name__c,status from case where id in :caseLst and status = 'Open' and Recordtype.Name  = 'Technical Drawings' limit 1];


                            List<Attachment> attLst = new List<Attachment>();  
                            String myString = 'BodyOfAttachment';
                             String myStringUpdt = 'BodyOfAttachmentUpdate';
                            Blob myBlob = Blob.valueof(myString);
                             Blob myBlobUpdate = Blob.valueof(myStringUpdt);
                    


                            for(Integer i=0 ; i<caseLst.size(); i++){
                                caseLst[i].status = 'Closed';

                                Attachment att = new Attachment();     
                                att.ParentId=caseLst[i].Id;
                                att.Body=myBlob;
                                att.Name='File1';
                                att.ContentType = 'doc,txt,jpeg';
                                attLst.add(att);
                            }

                              //Creating New Attachment Object and creating a reocrd for attachment object


    
                        insert attLst;
                        update caseLst;


                        caseLst = [Select id,Customer_Account_Name__c,Is_Related_Account_null__c from case where id in :caseLst];

                        Map<id ,case> mapCase = new Map<Id , case>();

                            for(Case cs :caseLst){
                                
                                    mapCase.put(cs.id , cs);

                            }

                              Presales_CaseToOpportunityAttachment casetoOppObj = new Presales_CaseToOpportunityAttachment();
                              casetoOppObj.techDrawingDocsToAccount(mapCase);
                              casetoOppobj.caseAttachmentToOpportunity(mapcase);

                        attLst[0].Body = myBlobUpdate;

                        update attLst[0];

                        delete attLst[0];

                    


                    Test.stoptest();
                           

                  } catch (System.DmlException e){
                    System.debug('DML exception: ' + e.getDmlMessage(0));   
           } 
   
   }  //End of  Case to Opp attachment test method


   //Opp Reporting test method

      static testMethod void  oppReporting(){
     
            //try{

                List<Attachment> attLst = new List<Attachment>();
                 List<FeedItem> feedItemLst = new List<FeedItem>();
                List<Opportunity_Reporting__c> oppList = new List<Opportunity_Reporting__c>();
                
                 String myString = 'BodyOfAttachment';
                       
                            Blob myBlob = Blob.valueof(myString);

                              String myStringUpdate = 'BodyOfAttachmentAfterUpdate';
                       
                            Blob myBlobUpdate = Blob.valueof(myStringUpdate);
                           
                 PreSales_Tc testObj = new PreSales_Tc();

                    
                        testObj.createContact();
                         testObj.createCase();
                            
                         
                        Test.starttest(); 

                         testObj.createAccount();
                     
                        testObj.createOpportunity();

                    
                        
                        CollaborationGroup cg = new CollaborationGroup();
                        
                        cg.name = 'All Emc1';
                        cg.CollaborationType = 'Public';
                        insert cg;
                        
                        



                             FeedItem  fdItemOpp = new FeedItem();
                              fdItemOpp.body = 'Testing Feed Item';
                               fdItemOpp.ParentId= lstOpp[0].id;

                              //  feedItemLst.add(fdItem);
                            insert fdItemOpp;
                            
                                 FeedItem  fdItemAcc = new FeedItem();
                              fdItemAcc.body = 'Testing Feed Item';

                               fdItemAcc.ParentId= acctLst[0].id;
                              //  feedItemLst.add(fdItem);
                            insert fdItemAcc;
                            
                            
                                 FeedItem  fdItemGrp = new FeedItem();
                              fdItemGrp.body = 'Testing Feed Item';
                               fdItemGrp.ParentId= cg.id;
                              
                              //  feedItemLst.add(fdItem);
                            insert fdItemGrp;
                            
                            
                              // for case
                              FeedItem  fdItemCase = new FeedItem();
                              fdItemCase.body = 'Testing Feed Item for Case';

                               fdItemCase.ParentId= caseLst[0].id;
                              //  feedItemLst.add(fdItem);
                            insert fdItemCase;
        
            // Check if Feed is enabled for contact
                Schema.DescribeSObjectResult r = Contact.sObjectType.getDescribe();
                    if(r.IsFeedEnabled()){

                               FeedItem  fdItemCnt = new FeedItem();
                              fdItemCnt.body = 'Testing Feed Item';
                               fdItemCnt.ParentId= contLst[0].id;
                              
                              //  feedItemLst.add(fdItem);
                            insert fdItemCnt;
                            }
                            

                        
                
                        for(Integer i=1 ; i<=2 ; i++){

                            Attachment att = new Attachment();     
                                
                                
                            if (i<2)
                            {
                                att.ParentId=lstOpp[0].id;
                                att.Body=myBlob;
                                att.Name='File1';
                                att.ContentType = 'doc,txt,jpeg';
                                
                            }
                            else{
                                att.ParentId=acctLst[0].Id;
                                att.Body=myBlob;
                                att.Name='File1';
                                att.ContentType = 'doc,txt,jpeg';
                                
        
                            }
                            attLst.add(att);

                        }

                        insert attLst;
                        

                        attLst[0].Body = myBlobUpdate;

                        update attLst[0];

                        delete attLst[0];


                    
                        for(Integer j=1 ; j<=2 ; j++){

                        Opportunity_Reporting__c  oppReport = new Opportunity_Reporting__c();
                        if (j<2)
                        {
                            oppReport.Opportunity__c = lstOpp[0].id;
                        }
                        
                        else{

                            oppReport.Account__c = acctLst[0].id;
                        
                        }

                        oppList.add(oppReport);

                        }
                        
                        insert oppList;

                        

                        FeedComment fdComment = new FeedComment();
                        
                        fdComment.FeedItemId= fdItemAcc.id;
                        fdComment.CommentBody = 'Testing feed Comment';

                        insert fdComment;
                
                        Id  uid =  userinfo.getUserId();

                        User u = [Select id , currentstatus from User where id =: uid];

                        u.currentstatus = 'I am Updating my status';

                        update u;
                
                                        

                    Test.stoptest();
                           

                 /* } catch (System.DmlException e){
                    System.debug('DML exception: ' + e.getDmlMessage(0)); 
           }   */
   
   }  //End of  Opp Reporting test method

  //Added by Ganesh on 23Nov, 2012
  public static testMethod void  PreSales_Tc_Test1(){       
      
          Test.startTest();    
          
          Case objParentCase = new Case(Description = 'TESTParent',Subject = 'TEST1',Status = 'Open',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',Theatre__c = 'APJ', Division__c='Korea',Country__c= 'Hong Kong',RPQ_Quote_Number__c= '1234567890');             
          insert objParentCase;
          
          objParentCase.Status = 'Resolved';
          objParentCase.SLA_Completed__c = System.today();
          update objParentCase;
          
          
          Case objChlildCase1 = new Case(Description = 'TESTChild1',Subject = 'TEST1', parentid = objParentCase.Id,Status = 'Open',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',Theatre__c = 'APJ', Division__c='Korea',Country__c= 'Hong Kong',RPQ_Quote_Number__c= '1234567890');
          insert objChlildCase1;
          
          Case objChlildCase2 = new Case(Description = 'TESTChild2',Subject = 'TEST1', parentid = objParentCase.Id,Status = 'Open',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',Theatre__c = 'APJ', Division__c='Korea',Country__c= 'Hong Kong',RPQ_Quote_Number__c= '1234567890');
          insert objChlildCase2;
           
          objChlildCase1.Status = 'Closed';    
          update objChlildCase1;      
       
                        
          Map<Id,Case> mapParentCaseIdChildCase = new Map<Id,Case>();
          mapParentCaseIdChildCase.put(objChlildCase1.parentid,objChlildCase1); 
          //mapParentCaseIdChildCase.put(objChlildCase2.parentid,objChlildCase2);
         
          List<Quote_Custom__c> lstQuote = new List<Quote_Custom__c>(); 
          Quote_Custom__c objQuote = new Quote_Custom__c(Number_of_Configurations__c = 12,Name = '1234567890',Quote_Type__c = 'New',Case_Name__c = objChlildCase1.id);
          lstQuote.add(objQuote);
          insert lstQuote;           
         
          List<Case> lstCase = new List<Case>();
          lstCase.add(objChlildCase1);            
         
          Presales_Operations objOper = new Presales_Operations();            
          objOper.CloseParentCaseIfSLACompleted(mapParentCaseIdChildCase);
          objOper.presalesOperationsSetOwnerRole(lstCase);
          objOper.presalesOperationsSetMobile(lstCase); 
          
          Presales_Quote objPresalesQuote = new Presales_Quote();
          objPresalesQuote.presalesSetQuoteCreatorGroup(lstQuote);            
                         
          
          Test.stopTest();
   }

     //Added by Ganesh on 23Nov, 2012
  public static testMethod void  PreSales_Tc_Test2(){       
      
          Test.startTest();
          
        Account objAccount = new Account(name = 'TestPartnerAcc',Party_Number__c = '1234',BillingCountry ='Korea',Synergy_Account_Number__c = '10',Type = 'Partner',Lead_Oppty_Enabled__c = true,Partner_Type__c ='Distributor',Site_DUNS_Entity__c='001017771');
        insert objAccount;
        objAccount.IsPartner = true;
        update objAccount;
         
        Account_Groupings__c objGrouping = new Account_Groupings__c(Name = 'TestGrouping1',Active__c = true,Profiled_Account__c = objAccount.id,No_Master_Required__c = false);
        insert objGrouping;
        
        Account_Groupings__c objGrouping2 = new Account_Groupings__c(Name = 'TestGrouping1',Active__c = true,Profiled_Account__c = objAccount.id,No_Master_Required__c = false);
        insert objGrouping2;
         
        Contact contact1 = new Contact(FirstName='Test Disti Contact',LastName='Test Partner Contact',AccountId = objAccount.Id,Email = 'Contact1@abc.com',Partner_Contact2__c = true,Active__c = true);
        insert contact1;      
          
        Case objParentCase = new Case(Description = 'TESTParent',Subject = 'TEST1',Status = 'Open',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',Theatre__c = 'APJ', Division__c='Korea',Country__c= 'Hong Kong',RPQ_Quote_Number__c= '1234567890');             
        insert objParentCase;
          
        objParentCase.Status = 'Resolved';
        objParentCase.SLA_Completed__c = System.today();
        update objParentCase;
          
          
        Case objChlildCase1 = new Case(Partner_Case__c=true,Partner_Grouping_Name__c=objGrouping.Id,contactid=contact1.Id,Description = 'TESTChild1',Subject = 'TEST1', parentid = objParentCase.Id,Status = 'Open',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',Theatre__c = 'APJ', Division__c='Korea',Country__c= 'Hong Kong',RPQ_Quote_Number__c= '1234567890');
        insert objChlildCase1;
          
        Case objChlildCase2 = new Case(Partner_Case__c=true,Partner_Grouping_Name__c=objGrouping2.Id,contactid=contact1.Id,Description = 'TESTChild2',Subject = 'TEST1', parentid = objParentCase.Id,Status = 'Open',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',Theatre__c = 'APJ', Division__c='Korea',Country__c= 'Hong Kong',RPQ_Quote_Number__c= '1234567890');
        insert objChlildCase2;
           
        objChlildCase1.Status = 'Closed';
        objChlildCase1.Partner_Grouping_Name__c=objGrouping2.Id;
        update objChlildCase1;           
      
          
        List<Case> lstCase2 = new List<Case>();
        lstCase2.add(objChlildCase1);
        lstCase2.add(objChlildCase2);        
         
        List<Id> lstPartnerAccount = new  List<Id>();
        lstPartnerAccount.add(objChlildCase2.Partner_Grouping_Name__c);
        lstPartnerAccount.add(objChlildCase1.Partner_Grouping_Name__c);      
   
          
        Presales_PartnerCaseOperation objPartnerCaseOperation = new Presales_PartnerCaseOperation(); 
        objPartnerCaseOperation.insertPartner(lstCase2,true,lstPartnerAccount);          
        objPartnerCaseOperation.insertPartner(lstCase2,false,lstPartnerAccount);                     
          
        Test.stopTest();
   }
    
        //Added by Ganesh on 26Nov, 2012 
  public static testMethod void  PreSales_Tc_UpdateCaseTeams(){     
      
        Test.startTest();
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'utest', email='gantest@test.com',isactive=true,emailencodingkey='UTF-8', lastname='Unit Test',languagelocalekey='en_US',localesidkey='en_GB', profileid = p.Id,timezonesidkey='Europe/London',username='gan555@unit.test.com');
        insert u;
              
        User testUser = new User(alias = 'utest', email='sampletest@test.com',isactive=true,emailencodingkey='UTF-8', lastname='Unit Test',languagelocalekey='en_US',localesidkey='en_GB', profileid = p.Id,timezonesidkey='Europe/London',username='gan666@unit.test.com');
        insert testUser;
              
        System.RunAs(u){        
        Case objCase = new Case(OwnerId =testUser.Id,Description = 'TESTParent',Subject = 'TEST1',Status = 'Open',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',Theatre__c = 'APJ', Division__c='Korea',Country__c= 'Hong Kong',RPQ_Quote_Number__c= '1234567890');             
        insert objCase;     
        Case objCaseTeamMember = new Case(Description = 'TEST1',Subject = 'TEST1',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',contact_Email1__c   = u.email,parentID = objCase.ID);
        insert objCaseTeamMember;         
        EmailMessage emailMsg = new EmailMessage(ParentId = objCase.Id,Status  = '0',Subject='sampletest',TextBody='this is just to test');
        insert emailMsg;
        
        Presales_UpdateCaseTeams objUpdateCaseTeams = new Presales_UpdateCaseTeams();
        objUpdateCaseTeams.addToCcToCaseTeam(objCase.Id,'gantest@test.com','sampletest@test.com','sampletest@test.com');       
        objUpdateCaseTeams.populateRequestorDetailsEmailToCase(objCase.Id,'gantest@test.com');
        objUpdateCaseTeams.chkemailContents(objCase.Id,'sampletest','this is just to test');         
        }
        Test.stopTest();
   }
 
        //Added by Ganesh on 26Nov, 2012 
  public static testMethod void  PreSales_Tc_SendMailToManager(){ 
    Test.startTest();
    Profile p = [select id from profile where name='System Administrator'];
    
    User u = new User(alias = 'utest', email='gantest@test.com',isactive=true,emailencodingkey='UTF-8', lastname='Unit Test',languagelocalekey='en_US',localesidkey='en_GB', profileid = p.Id,timezonesidkey='Europe/London',username='gan333@unit.test.com');
    insert u;   
    
    User testUser = new User(alias = 'utest', email='sampletest@test.com',isactive=true,emailencodingkey='UTF-8', lastname='Unit Test',languagelocalekey='en_US',localesidkey='en_GB', profileid = p.Id,timezonesidkey='Europe/London',username='gan444@unit.test.com');
    insert testUser;
    
    System.RunAs(u){     
        
    UserRole objUserRole=new UserRole(Name='testRole');
    insert objUserRole;    
    Case objCase = new Case(Contact_Email1__c ='ganestest@test.com',OwnerId =testUser.Id,Description = 'TESTParent',Subject = 'TEST1',Status = 'Open',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',Theatre__c = 'APJ', Division__c='Korea',Country__c= 'Hong Kong',RPQ_Quote_Number__c= '1234567890');             
    insert objCase;  
    Map<Id,Case> mapCase = new Map<Id,Case>();
    mapCase.put(objCase.Id,objCase);    
    
    Map<Id,Id> mapCaseIdOwner = new Map<Id,Id>();
    mapCaseIdOwner.put(objCase.Id,objCase.OwnerId);     
    
    Map<Id,UserRole> mapRole = new Map<Id,UserRole>();
    mapRole.put(objUserRole.Id,objUserRole);    
      
    Presales_SendMailToManager objSendMailToManager = new Presales_SendMailToManager();
    objSendMailToManager.findManagerOfOwner(mapCase);
    objSendMailToManager.getUsersOnRole(mapRole);
    objSendMailToManager.sendEmail(mapCaseIdOwner);
    objSendMailToManager.addManagerToFollower(mapCaseIdOwner);
    objSendMailToManager.addOwnerToFollower(mapCase,false);     
    objSendMailToManager.removeOldOwnerRequestor(mapCase,true);
    
    
    objCase.OwnerId=u.Id;
    objCase.Contact_Email1__c = 'sampletest@test.com';
    update objCase;
    
   objSendMailToManager.addOwnerToFollower(mapCase,true);
   objSendMailToManager.removeFollowersOnClosure(mapCase);
   objSendMailToManager.removeOldOwnerRequestor(mapCase,false);
    
    }
    
    Test.stopTest();
  }
  
   //Added by Ganesh on 27Nov, 2012 
   public static testMethod void  PreSales_Tc_PreSalesCaseShare(){
    Test.startTest();
    
    Profile p = [select id from profile where name='System Administrator'];
    
    User u = new User(alias = 'utest', email='gantest@test.com',isactive=true,emailencodingkey='UTF-8', lastname='Unit Test',languagelocalekey='en_US',localesidkey='en_GB', profileid = p.Id,timezonesidkey='Europe/London',username='gan111.test@unit.test.com');
    insert u;   
    
    User testUser = new User(alias = 'utest', email='sampletest@test.com',isactive=true,emailencodingkey='UTF-8', lastname='Unit Test',languagelocalekey='en_US',localesidkey='en_GB', profileid = p.Id,timezonesidkey='Europe/London',username='gan222@unit.test.com');
    insert testUser;
    
    System.RunAs(u){ 
        
    Account objAccount = new Account(name = 'TestPartnerAcc',Party_Number__c = '1234',BillingCountry ='Korea',Synergy_Account_Number__c = '10',Type = 'Partner',Lead_Oppty_Enabled__c = true,Partner_Type__c ='Distributor',Site_DUNS_Entity__c='001017771');
    insert objAccount;
        
    Contact contact1 = new Contact(FirstName='Test Disti Contact',LastName='Test Partner Contact',AccountId = objAccount.Id,Email = 'Contact1@abc.com',Partner_Contact2__c = true,Active__c = true);
    insert contact1;    
     
   
    Case objCase = new Case(Contact_Name_User__c=u.Id,Contact_Email1__c ='sample@test.com',Description = 'TESTParent',Subject = 'TEST1',Status = 'Open',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',Theatre__c = 'APJ', Division__c='Korea',Country__c= 'Hong Kong',RPQ_Quote_Number__c= '1234567890');             
    insert objCase; 
   
    Case objCase2 = new Case(Contact_Name_User__c=u.Id,Contact_Email1__c ='sample@test.com',Description = 'TESTParent',Subject = 'TEST1',Status = 'Open',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',Theatre__c = 'APJ', Division__c='Korea',Country__c= 'Hong Kong',RPQ_Quote_Number__c= '1234567890');             
    insert objCase2;   
    
    objCase2.ParentId=objCase.Id;
    objCase2.OwnerId=testUser.Id;
    //objCase2.Contact_Email1__c = 'sampletest@test.com';
    update objCase2;  
    
    
   
    
    List<Case> lstCase1 = new  List<Case>();
    lstCase1.add(objCase);
    
    List<Case> lstCase2 = new  List<Case>();
    lstCase2.add(objCase2); 
    //lstCase2.add(objCase); 
     
    List<Case> lstCase3 = new  List<Case>();
    
    List<Id> lstCaseID = new List<Id>();
    lstCaseID.add(objCase2.Id);
    lstCaseID.add(objCase.Id);
        
    List<Id> lstParentCaseID = new List<Id>();
    lstParentCaseID.add(objCase.Id);
    
    List<Id> lstParentCaseID2 = new List<Id>();
    
    Map<id,id> mapRequestor = new Map<id,id>(); 
    mapRequestor.put(objCase2.Id,objCase2.Contact.Id);
    
    Map<id,id> mapParentCaseId = new Map<id,id>();
    mapParentCaseId.put(objCase2.ParentId,objCase2.Id);
    //mapParentCaseId.put(objCase.ParentId,objCase.Id);
    
     Map<id,id> mapParentCaseId2 = new Map<id,id>();
    
     Map<id,id> mapChildCaseId = new Map<id,id>();
     mapChildCaseId.put(objCase2.Id,objCase2.ParentId);   
        
    Presales_CaseShare_Class objPreSalesCaseShare = new Presales_CaseShare_Class();
    //Presales_CaseShare_Class.setAlreadyChangedShare();
    //Presales_CaseShare_Class.hasAlreadyChangedShare();
    objPreSalesCaseShare.insertUpdateShare(lstCaseID,'U','sample@test.com',lstCase2,lstCaseID,false,lstCase2,true,u.Id,true);  
     objPreSalesCaseShare.insertUpdateShare(lstCaseID,'U','sample@test.com',lstCase3,lstParentCaseID2,false,lstCase1,true,u.Id,true); 
    //objPreSalesCaseShare.insertUpdateShare(lstCaseID,'U','sample@test.com',lstCase2,lstParentCaseID2,false,lstCase1,true,u.Id,true); 
    objPreSalesCaseShare.SetParentChildAccess(lstCaseID,lstParentCaseID2,mapRequestor,mapParentCaseId2,mapChildCaseId,true , false);     
    objPreSalesCaseShare.SetParentChildAccess(lstCaseID,lstParentCaseID,mapRequestor,mapParentCaseId,mapChildCaseId,true , false);  
    objPreSalesCaseShare.SetParentChildAccess(lstCaseID,lstParentCaseID2,mapRequestor,mapChildCaseId,mapParentCaseId2,true , false);    
    Presales_CaseShare_Class.setAlreadyChangedShare();
    
    }
    Test.stopTest();
   }
   
    //Added by Srinivas on 12Dec, 2012 
   public static testMethod void  Presales_OppHistory(){
    Test.startTest();
    
    //Insert Account record
    Account objAccount = new Account();
    objAccount.Name = 'PreSalese Testing';
    objAccount.Synergy_Account_Number__c = '123456';
    insert objAccount;
    
    //Insert Opportunity record here
    Opportunity opp_Obj = new Opportunity();
    opp_Obj.AccountId = objAccount.id;
    opp_Obj.Name = 'TEST';
    opp_Obj.StageName = 'TEST';
    opp_Obj.CloseDate = Date.today()+10;
    opp_Obj.Sales_Force__c = 'EMC';
    opp_Obj.Sales_Channel__c = 'Direct';
    opp_Obj.VMWare_Related__c = 'VMWare Backup';
    insert opp_Obj;
    
    Opportunity objOpp = [select id,StageName,CloseDate,Amount from Opportunity where id =: opp_Obj.ID];
    objOpp.StageName = 'Test1';
    opp_Obj.CloseDate = Date.today()+20;
    opp_Obj.Amount = 250;
    update objOpp;
    
    OpportunityFieldHistory objOppHistoryStageName = new OpportunityFieldHistory();
    objOppHistoryStageName.Field = 'StageName';
    //objOppHistory.NewValue = 'Test1';
    //objOppHistory.OldValue = 'Test';
    objOppHistoryStageName.OpportunityId = objOpp.ID;
    
    OpportunityFieldHistory objOppHistoryAmount = new OpportunityFieldHistory();
    objOppHistoryAmount.Field = 'Amount';
    //objOppHistory.NewValue = 'Test1';
    //objOppHistory.OldValue = 'Test';
    objOppHistoryAmount.OpportunityId = objOpp.ID;
    
    //OpportunityFieldHistory objOppHistoryClosedDate = new OpportunityFieldHistory();
    //objOppHistoryClosedDate.Field = 'CloseDate';
    //objOppHistoryClosedDate.NewValue = Date.today()+20;
    //objOppHistoryClosedDate.OldValue = Date.today()+10;
    //objOppHistoryClosedDate.OpportunityId = objOpp.ID;
    
    
    insert objOppHistoryStageName;
    insert objOppHistoryAmount;
   //   insert objOppHistoryClosedDate;
    
    
    Case objParentCase = new Case(Opportunity_Name__c = objOpp.Id, Description = 'TESTParent',Subject = 'TEST1',Status = 'Open',Origin = 'Email',Type = 'RPQ',Record_Type_Hidden__c = 'RPQ',Theatre__c = 'APJ', Division__c='Korea',Country__c= 'Hong Kong',RPQ_Quote_Number__c= '1234567890');             
    insert objParentCase;
    ApexPages.StandardController controller = new ApexPages.StandardController(objParentCase);   
            
    //Invoking the controller class with the Apex Controller and desiered object type
    Presales_OppHistory caseObj = new Presales_OppHistory(controller);
    
    // Create a new email, envelope object and Attachment
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
    // Create a new email subject with open case and status as escalate
    email.subject = 'close'+objParentCase.id;
    email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
    envelope.fromAddress = 'user@acme.com';
    // setup controller object
    Presales_EscalateCaseFromInboundEmail inBound_Obj= new Presales_EscalateCaseFromInboundEmail();
    inBound_Obj.handleInboundEmail(email, envelope);
    
    objParentCase.Status = 'Closed';
    update objParentCase;
    
    email.subject = 'escalate'+objParentCase.id;
    email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
    envelope.fromAddress = 'user@acme.com';
    // setup controller object
     inBound_Obj.handleInboundEmail(email, envelope);
    Test.stopTest();
    
    }
} // Class Ends Here