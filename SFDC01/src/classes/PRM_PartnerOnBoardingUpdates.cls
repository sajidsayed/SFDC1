/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  28/03/2011        Arif      Req#162077 This class is used to send email,create task,update owner etc
                                           when a new Partner On Boarding record created.
 |  22/04/2011        Anil Sure    #2726        Default profile data on the profiled account of the grouping created when 
                                           onboarding partner - after step 3d of process set to 'Complete'                                                                  
 |  14/05/2011        Shalabh Sharma       Updated Code for Mails not being Routed to External Systems. 
    06/05/2011        Anirudh Singh        Updated updateRelatedProfiledAccount Method to default Values for 
 |                                         website,Phone,Approved for Partner Finder,Theater values on Profiled Account
                                           Related to Authorised Reseller Onboarding Record.    
    25 Aug 2011      Arif                  Put custom settings every where
 +==================================================================================================================**/
public class PRM_PartnerOnBoardingUpdates {
public static Boolean executeFlag = false;
public static Boolean executeFlagTRACK = false;
public static Boolean executeFlagStep4 = false;
public List<String> queueMemEmailIds = new List<String>();
map<string,Custom_Settings_Partner_OnBoarding__c> customSettingRecords  = Custom_Settings_Partner_OnBoarding__c.getAll();
/* @Method <This method execute is used to get custom setting values>
@param <This method takes Step Name and Theater values as parameter>
@return <List<Custom_Settings_Partner_OnBoarding__c>> - <Returning list of custom setting values>
@throws exception - <No Exception>
*/
    public List<Custom_Settings_Partner_OnBoarding__c> getCustomSettingValue(String StepName,String Theater,Boolean Distributor,Boolean flag){
        Map<String,Custom_Settings_Partner_OnBoarding__c> mapCustomSettingPartnerOnboarding = Custom_Settings_Partner_OnBoarding__c.getall();
        List<Custom_Settings_Partner_OnBoarding__c> lstCustomSettingValues = new List<Custom_Settings_Partner_OnBoarding__c>(); 
            if(Distributor==false){
                if(flag == true){
                    for(Integer i=0;i<100;i++){
                    String key = (StepName+ '.'+i+Theater);
                    Custom_Settings_Partner_OnBoarding__c value = mapCustomSettingPartnerOnboarding.get(key);
                    system.debug('custom setting value---------->'+value);
                        if(value!=null){
                             lstCustomSettingValues.add(value); 
                        }
                        else{
                            break;
                        }             
                    }   
                }
                else{
                    for(Integer i=1;i<100;i++){
                        String key = (StepName+ '.'+i+Theater);
                        Custom_Settings_Partner_OnBoarding__c value = mapCustomSettingPartnerOnboarding.get(key);
                        system.debug('custom setting value---------->'+value);
                            if(value!=null){
                                 lstCustomSettingValues.add(value); 
                            }
                            else{
                                break;
                            }             
                    }
                }   
            }
            else{
                for(Integer i=0;i<100;i++){
                    String key = (StepName+ '.'+i);
                    Custom_Settings_Partner_OnBoarding__c value = mapCustomSettingPartnerOnboarding.get(key);
                        if(value!=null){
                             lstCustomSettingValues.add(value); 
                        }
                        else{
                            break;
                        }   
                }    
            }
            return lstCustomSettingValues;
    }
    
/* @Method <This method execute is used to get theater wise Partner Onboarding records>
@param <This method takes List<Partner_Onboarding__c> as parameter>
@return <Map<String,List<Partner_Onboarding__c>>> - <Returning Map<String,List<Partner_Onboarding__c>>>
@throws exception - <No Exception>
*/  
    public Map<String,List<Partner_Onboarding__c>> createTheaterLists(List<Partner_Onboarding__c> lstNewPartnerOnboarding){
        List<Partner_Onboarding__c> lstNewPartnerOnBoardingAPJ = new List<Partner_Onboarding__c>();
        List<Partner_Onboarding__c> lstNewPartnerOnBoardingEMEA = new List<Partner_Onboarding__c>();
        List<Partner_Onboarding__c> lstNewPartnerOnBoardingAmericas = new List<Partner_Onboarding__c>();
        Map<String,List<Partner_Onboarding__c>> mapPOBRecords = new Map<String,List<Partner_Onboarding__c>>();
        for(Partner_Onboarding__c POBLoopVariable: lstNewPartnerOnboarding){
            if(POBLoopVariable.Region_you_are_applying_for__c == 'APJ'){
                lstNewPartnerOnBoardingAPJ.add(POBLoopVariable);
                mapPOBRecords.put('APJ',lstNewPartnerOnBoardingAPJ);
             }
             if(POBLoopVariable.Region_you_are_applying_for__c == 'EMEA'){
                lstNewPartnerOnBoardingEMEA.add(POBLoopVariable); 
                mapPOBRecords.put('EMEA',lstNewPartnerOnBoardingEMEA);
             }
             if(POBLoopVariable.Region_you_are_applying_for__c == 'Americas'){
                lstNewPartnerOnBoardingAmericas.add(POBLoopVariable);
                mapPOBRecords.put('Americas',lstNewPartnerOnBoardingAmericas);
             }  
        }
        return mapPOBRecords;
    }
/* @Method <This method execute is used to populate owner on Partner Onboarding records>
@param <This method takes List<Partner_Onboarding__c> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/    
    public void step1updatePartnerOnBoardingOwner(List<Partner_Onboarding__c> lstNewPartnerOnboarding){
        for(Partner_Onboarding__c POBloopvariable: lstNewPartnerOnboarding){
            POBloopvariable.Step_Name__c = 'STEP1';
        }
        //update lstNewPartnerOnboarding;
        List<Custom_Settings_Partner_OnBoarding__c> lstCustomPOB = new List<Custom_Settings_Partner_OnBoarding__c>();   
            for(Partner_Onboarding__c POB :lstNewPartnerOnboarding){
                system.debug('StepName before--------->'+POB.Step_Name__c); 
                system.debug('Region before--------->'+POB.Region_you_are_applying_for__c);        
            lstCustomPOB = getCustomSettingValue(POB.Step_Name__c,POB.Region_you_are_applying_for__c,false,true);
            system.debug('--------->'+lstCustomPOB);
            for (Custom_Settings_Partner_OnBoarding__c custompob: lstCustomPOB){
                system.debug('CusPOB--------->'+lstCustomPOB);
                POB.OwnerId = custompob.Owner__c;
                }
            }
        for(Partner_Onboarding__c POBloopvariable: lstNewPartnerOnboarding){
            POBloopvariable.Step_Name__c = 'STEP2';
        }
        //update lstNewPartnerOnboarding; 
        //step2createTaskforCM(lstNewPartnerOnboarding);                        
    }
/* @Method <This method execute is used to execute Step2>
@param <This method takes List<Partner_Onboarding__c> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/     
    public void step2createTaskforCM(List<Partner_Onboarding__c> lstNewPartnerOnboarding){
        List<Partner_Onboarding__c> lstStepUpdate = new List<Partner_Onboarding__c>();
        /*for(Partner_Onboarding__c POBloopvariable: lstNewPartnerOnboarding){
            POBloopvariable.Current_Status_of_Onboarding__c = 'In Progress';
        }*/
        List<Partner_Onboarding__c> lstPOBAPJ = (createTheaterLists(lstNewPartnerOnboarding)).get('APJ');
        system.debug('APJ list--------->'+lstPOBAPJ);
        List<Partner_Onboarding__c> lstPOBEMEA = (createTheaterLists(lstNewPartnerOnboarding)).get('EMEA');
        system.debug('EMEA list--------->'+lstPOBEMEA);
        List<Partner_Onboarding__c> lstPOBAmericas = (createTheaterLists(lstNewPartnerOnboarding)).get('Americas');
        system.debug('Amer list--------->'+lstPOBAmericas);
            if(lstPOBAPJ!=null){
                createTaskAndSendMail(lstPOBAPJ,false,true);
                    /*for(Partner_Onboarding__c POBloopvariable: lstPOBAPJ){
                        POBloopvariable.Step_Name__c = 'STEP3';
                        lstStepUpdate.add(POBloopvariable);
                    }*/ 
            }
            if(lstPOBEMEA!=null){
                createTaskAndSendMail(lstPOBEMEA,false,true);
                    /*for(Partner_Onboarding__c POBloopvariable: lstPOBAPJ){
                        POBloopvariable.Step_Name__c = 'STEP3';
                        lstStepUpdate.add(POBloopvariable);
                    }*/ 
            }
            if(lstPOBAmericas!=null){
                createTaskAndSendMail(lstPOBAmericas,false,true);
                    /*for(Partner_Onboarding__c POBloopvariable: lstPOBAPJ){
                        POBloopvariable.Step_Name__c = 'STEP3';
                        lstStepUpdate.add(POBloopvariable);
                    }*/ 
            }
        //if(lstStepUpdate!=null){
            //update lstStepUpdate; 
        //}  
    }
/* @Method <This method execute is used to execute Step3>
@param <This method takes List<Partner_Onboarding__c> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/    
    public void step3createTaskforDistributor(Map<Id,Partner_Onboarding__c> mapNewPOBRecords,Map<Id,Partner_Onboarding__c> mapOldPOBRecords){
        if(executeFlag == false){
            for(Partner_Onboarding__c POBloopvariable : mapNewPOBRecords.values()){
                if(POBloopvariable.Distributor_Approver__c!=null&&POBloopvariable.Distributor_Approver__c != mapOldPOBRecords.get(POBloopvariable.Id).Distributor_Approver__c){
                     createTaskAndSendMail(mapNewPOBRecords.values(),true,true);
                }
            }
            List<Authorized_Reseller_Onboarding_Task__c> chkListTask = [select Id, Subject__c from Authorized_Reseller_Onboarding_Task__c where Partner_Onboarding__c in : mapNewPOBRecords.values() and Subject__c =:customSettingRecords.get('STEP3.1Americas').Task_Name__c];
            system.debug('=====>task List to chk'+chkListTask);
            if(chkListTask.size()==0){
            List<Partner_Onboarding__c> lstPOBAPJ = (createTheaterLists(mapNewPOBRecords.values())).get('APJ');
            List<Partner_Onboarding__c> lstPOBEMEA = (createTheaterLists(mapNewPOBRecords.values())).get('EMEA');
            List<Partner_Onboarding__c> lstPOBAmericas = (createTheaterLists(mapNewPOBRecords.values())).get('Americas');
                for(Partner_Onboarding__c POBloopvariable : mapNewPOBRecords.values()){
                    if(POBloopvariable.Distributor_Approver__c!=null&&POBloopvariable.Distributor_Approver__c != mapOldPOBRecords.get(POBloopvariable.Id).Distributor_Approver__c){
                        if(lstPOBAPJ!=null){
                            createTaskAndSendMail(lstPOBAPJ,false,false);
                        }
                        if(lstPOBEMEA!=null){
                            createTaskAndSendMail(lstPOBEMEA,false,false);
                        }
                        if(lstPOBAmericas!=null){
                            createTaskAndSendMail(lstPOBAmericas,false,false);
                        }
                    }
                } 
            }            
                    
       /* for(Partner_Onboarding__c POBloopvariable: lstNewPartnerOnboarding){
            POBloopvariable.Step_Name__c = 'STEP4';
        }
        update lstNewPartnerOnboarding; */
    }
    system.debug('executeFlag--------->'+executeFlag);
    executeFlag = true;     
    }
/* @Method <This method execute is used to execute Step4>
@param <This method takes List<Partner_Onboarding__c> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/    
    public void step4sendmailtoCM(List<Partner_Onboarding__c> lstNewPartnerOnboarding){
        if(executeFlagStep4 == false){ 
        List<Partner_Onboarding__c> lstPOBAPJ = (createTheaterLists(lstNewPartnerOnboarding)).get('APJ');
        system.debug('step4apj--------->'+lstPOBAPJ);
        List<Partner_Onboarding__c> lstPOBEMEA = (createTheaterLists(lstNewPartnerOnboarding)).get('EMEA');
        system.debug('step4emea--------->'+lstPOBEMEA);
        List<Partner_Onboarding__c> lstPOBAmericas = (createTheaterLists(lstNewPartnerOnboarding)).get('Americas');
        system.debug('step4amer--------->'+lstPOBAmericas);
            if(lstPOBAPJ!=null){
                createTaskAndSendMail(lstPOBAPJ,false,true);
            }
            if(lstPOBEMEA!=null){
                createTaskAndSendMail(lstPOBEMEA,false,true);
            }
            if(lstPOBAmericas!=null){
                createTaskAndSendMail(lstPOBAmericas,false,true);
            }
        /*for(Partner_Onboarding__c POBloopvariable: lstNewPartnerOnboarding){
            POBloopvariable.Step_Name__c = 'STEP5';
        }
        update lstNewPartnerOnboarding;*/ 
        }
        executeFlagStep4 = true;      
    }
/* @Method <This method execute is used to execute Step5>
@param <This method takes List<Partner_Onboarding__c> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/    
     public void step5sendmailtoTRACK(List<Partner_Onboarding__c> lstNewPartnerOnboarding){
        if(executeFlagTRACK == false){
        system.debug('lstfortrack'+lstNewPartnerOnboarding);
        List<Partner_Onboarding__c> lstPOBAPJ = (createTheaterLists(lstNewPartnerOnboarding)).get('APJ');
        List<Partner_Onboarding__c> lstPOBEMEA = (createTheaterLists(lstNewPartnerOnboarding)).get('EMEA');
        List<Partner_Onboarding__c> lstPOBAmericas = (createTheaterLists(lstNewPartnerOnboarding)).get('Americas');
            if(lstPOBAPJ!=null){
                createTaskAndSendMail(lstPOBAPJ,false,true);
            }
            if(lstPOBEMEA!=null){
                createTaskAndSendMail(lstPOBEMEA,false,true);
            }
            if(lstPOBAmericas!=null){
                createTaskAndSendMail(lstPOBAmericas,false,true);
            }
        /*for(Partner_Onboarding__c POBloopvariable: lstNewPartnerOnboarding){
            POBloopvariable.Step_Name__c = 'STEP6';
        }      
        update lstNewPartnerOnboarding; */
       } 
        executeFlagTRACK = true;
    }
/* @Method <This method execute is used to execute Step6>
@param <This method takes List<Partner_Onboarding__c> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/    
    public void step6createTaskforExtSystems(List<Partner_Onboarding__c> lstNewPartnerOnboarding){
        List<Partner_Onboarding__c> lstPOBAPJ = (createTheaterLists(lstNewPartnerOnboarding)).get('APJ');
        List<Partner_Onboarding__c> lstPOBEMEA = (createTheaterLists(lstNewPartnerOnboarding)).get('EMEA');
        List<Partner_Onboarding__c> lstPOBAmericas = (createTheaterLists(lstNewPartnerOnboarding)).get('Americas');
            if(lstPOBAPJ!=null){
                createTaskAndSendMail(lstPOBAPJ,false,true);
            }
            if(lstPOBEMEA!=null){
                createTaskAndSendMail(lstPOBEMEA,false,true);
            }
            if(lstPOBAmericas!=null){
                createTaskAndSendMail(lstPOBAmericas,false,true);
            }
        /*for(Partner_Onboarding__c POBloopvariable: lstNewPartnerOnboarding){
            POBloopvariable.Step_Name__c = 'STEP7';
        }
        update lstNewPartnerOnboarding;*/ 
    }
/* @Method <This method execute is used to execute Step7>
@param <This method takes List<Partner_Onboarding__c> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/    
     public void step7createTaskforCMforProfileUpdationAndWelcomeEmails(List<Partner_Onboarding__c> lstNewPartnerOnboarding){
        List<Partner_Onboarding__c> lstPOBAPJ = (createTheaterLists(lstNewPartnerOnboarding)).get('APJ');
        List<Partner_Onboarding__c> lstPOBEMEA = (createTheaterLists(lstNewPartnerOnboarding)).get('EMEA');
        List<Partner_Onboarding__c> lstPOBAmericas = (createTheaterLists(lstNewPartnerOnboarding)).get('Americas');
            if(lstPOBAPJ!=null){
                createTaskAndSendMail(lstPOBAPJ,false,true);
            }
            if(lstPOBEMEA!=null){
                createTaskAndSendMail(lstPOBEMEA,false,true);
            }
            if(lstPOBAmericas!=null){
                createTaskAndSendMail(lstPOBAmericas,false,true);
            }
    }
/* @Method <This method execute is used to create task>
@param <This method takes List<Partner_Onboarding__c>,task name, ownerId and a boolean value as parameters>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/    
    public void Create_Partner_OnboardingTask(List<Partner_Onboarding__c> lstNewPartnerOnboarding,String setSubject,String recordType,String Owner,Boolean Distributor){
        List<Authorized_Reseller_Onboarding_Task__c> ListTaskToCreate = new List<Authorized_Reseller_Onboarding_Task__c>();
        List<User> usrID;
        String setOwner;
        string ownerCheck;
        String Queue_or_emailID;
       system.debug('owner before'+Owner); 
        for(Partner_Onboarding__c POB :lstNewPartnerOnboarding){
            if(Distributor == false){
               Queue_or_emailID = Owner;
               ownerCheck = Queue_or_emailID.substring(0,3);
                    if(ownerCheck  == '00G'){
                        setOwner = Queue_or_emailID;
                    }
                    else
                    {
                        usrID = [select ID,email from User where email = :Queue_or_emailID];
                            if(usrID.size() > 0){
                                setOwner = usrID[0].ID;
                            }
                            else
                            {
                                setOwner = POB.OwnerId;
                            }
                    }
                }
            else
            {
                setOwner = POB.Distributor_Approver__c;
            }
            
            Authorized_Reseller_Onboarding_Task__c auth_task = new Authorized_Reseller_Onboarding_Task__c();
            system.debug('recordtypeId--->'+recordType);
            auth_task.RecordTypeId = recordType;
            system.debug('owner after'+setOwner);
            auth_task.OwnerId = setOwner;
            auth_task.Name = setSubject;
            //auth_task.Partner_Name__c = 'Test';
           // auth_task.Assigned_to__c = 'Test';
            auth_task.Subject__c = setSubject;
            auth_task.Partner_Onboarding__c = POB.Id;
            auth_task.Status__c = 'In progress';
            system.debug('POBOwner'+auth_task.OwnerId);
            ListTaskToCreate.add(auth_task);            
            }
       Insert ListTaskToCreate;   
    }
/* @Method <This method execute is used to send email>
@param <This method takes List<Partner_Onboarding__c>,custom setting value,a boolean value as parameters>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/    
     public void SendEmail(List<Partner_Onboarding__c> lstNewPartnerOnboarding,Custom_Settings_Partner_OnBoarding__c custom_pob,Boolean Distributor){
        String emailId;
        String[] toAdd = new String[] {};  
        String setTargetId;
        String Queue_or_emailID;
        String Queue_or_email;
        ID templateId;
        Map<Id,Id> mapPOBIdAndDistiId = new Map<Id,Id>();
        Map<Id,String> mapDistiIdAndEmail = new Map<Id,String>();
        Map<Id,Id> mapDistiIdAndContactId = new Map<Id,Id>();
        Map<String,Partner_Onboarding_Email_Service_Id__c> CustomSettingEmailServiceId = Partner_Onboarding_Email_Service_Id__c.getall();
        for(Partner_Onboarding__c POB :lstNewPartnerOnboarding){
            if((POB.Step_Name__c=='STEP5'||POB.Step_Name__c=='STEP6')&&(custom_pob.Email__c!=null)){
                Queue_or_emailID = custom_pob.Email__c;
                toAdd = get_QueueMembers(Queue_or_emailID);
            }
            else if(custom_pob.Owner__c!=null){
                Queue_or_emailID = custom_pob.Owner__c;
                toAdd = get_QueueMembers(custom_pob.Owner__c);
            }
            else{
                Queue_or_emailID = custom_pob.Owner__c; 
            }
        }   
    /* Creation of map Disti User and its email in case of Distributor */
        if(Distributor == true){
            for(Partner_Onboarding__c POB :lstNewPartnerOnboarding){
                if(POB.Distributor_Approver__c!=Null){
                    mapPOBIdAndDistiId.put(POB.Id,POB.Distributor_Approver__c);
                }
            }
       
        if(mapPOBIdAndDistiId.size()>0){
            for(User u: [Select id,email,ContactId from User where Id in: mapPOBIdAndDistiId.values()]){
                mapDistiIdAndEmail.put(u.id,u.email);
                mapDistiIdAndContactId.put(u.id,u.ContactId);
            }
                
        }
    }
      
        for(Partner_Onboarding__c POB :lstNewPartnerOnboarding){
            if(Distributor == true){
                system.debug('to add--->'+mapDistiIdAndEmail.get(mapPOBIdAndDistiId.get(POB.Id)));
                emailId = mapDistiIdAndEmail.get(mapPOBIdAndDistiId.get(POB.Id));
                toAdd.add(emailId);
            } 
            templateId = custom_pob.Template__c; 
            system.debug('to address--->'+toAdd);
            setTargetId = get_TargetId(toAdd,custom_pob);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(queueMemEmailIds!=null){
                for(String stg: queueMemEmailIds){
                    toAdd.add(stg);
                }
            }
            mail.setToAddresses(toAdd);
            mail.setSaveAsActivity(false);
            mail.setTemplateId(templateId);    
            mail.setTargetObjectId(setTargetId);
            mail.setWhatId(POB.ID);
            mail.setReplyTo(CustomSettingEmailServiceId.get('Email Id').Email_Id__c);
            Messaging.SendEmailResult [] res = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
       }
    
    }
/* @Method <This method execute is used to extract email ids of users from queue>
@param <This method takes Queue Id as parameter>
@return <List> - <Returning List of Email Ids>
@throws exception - <No Exception>
*/     
    public List<String> get_QueueMembers(String Queue_ID){
        Id[] allUserIds= new Id[] {};
        String[] allEmailIds = new String[] {}; 
        List<Groupmember> grmem;
        List<User> usr;
        string forusrchk = Queue_ID.substring(0,3);
        
        if(forusrchk  == '00G'){     
            // To get all queue members
            grmem = [select id,groupid,userorgroupid from groupmember where groupid = :Queue_ID] ;
            system.debug('grpmemdetails--->'+grmem);
            for(Groupmember grmemb : grmem){
                allUserIds.add(grmemb.userorgroupid);
            }
            
            // To get all users email
            usr = [select ID,email from User where ID in :allUserIds];
            system.debug('user---->'+usr);
            for(User us : usr) {
                allEmailIds.add(us.email);
            }
        }
        else
        {
            allEmailIds.add(Queue_ID);
        }
        
        return allEmailIds;
    
    }
/* @Method <This method execute is used to extract contact Id>
@param <This method takes List of Email Ids as parameter>
@return <String> - <Returning Contact Id>
@throws exception - <No Exception>
*/
    public String get_TargetId(List<String> allEmailIds,Custom_Settings_Partner_OnBoarding__c custom_pob){
        system.debug('all email Id Before--->'+allEmailIds);
        if(allEmailIds.size()==1 && allEmailIds[0] == custom_pob.Email__c){
          allEmailIds = get_QueueMembers(custom_pob.Owner__c);
          queueMemEmailIds = get_QueueMembers(custom_pob.Owner__c);
        }
        system.debug('all email Id after--->'+allEmailIds);
        Contact ConId = [select Id,email from Contact where email in :allEmailIds limit 1];
        system.debug('target Id--->'+ConId);
        return ConId.Id;
    }
/* @Method <This method execute is used to differenciate between Distributor and non distributor>
@param <This method takes List<Partner_Onboarding__c> and boolean value as parameters>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/     
    public void createTaskAndSendMail(List<Partner_Onboarding__c> lstPOBTheaterWise,Boolean Distributor,Boolean flag){ 
        
        system.debug('POBCS values----->'+lstPOBTheaterWise[0].Step_Name__c);
            List<Custom_Settings_Partner_OnBoarding__c> lstCustomPOB = getCustomSettingValue(lstPOBTheaterWise[0].Step_Name__c,lstPOBTheaterWise[0].Region_you_are_applying_for__c,Distributor,flag);
            system.debug('custom value list'+lstCustomPOB);
        if(Distributor == false){ 
                for (Custom_Settings_Partner_OnBoarding__c custompob: lstCustomPOB){
                    system.debug('list custom pob--->'+lstCustomPOB);
                    if(custompob.Create_Task__c==true){
                        Create_Partner_OnboardingTask(lstPOBTheaterWise,custompob.Task_Name__c,custompob.Record_Type__c,custompob.Owner__c,Distributor);
                    }
                    if(custompob.Send_Email__c==true){
                        SendEmail(lstPOBTheaterWise,custompob,false);
                        
                    } 
                }
           }
           else{
                for (Partner_Onboarding__c objPOB: lstPOBTheaterWise) {         
                    for (Custom_Settings_Partner_OnBoarding__c custompob: lstCustomPOB){
                        if(custompob.Create_Task__c==true){
                            Create_Partner_OnboardingTask(lstPOBTheaterWise,custompob.Task_Name__c,custompob.Record_Type__c,objPOB.Distributor_Approver__c,true);
                        }
                        if(custompob.Send_Email__c==true){
                            SendEmail(lstPOBTheaterWise,custompob,true);
                        } 
                    }
                } 
         }
         
    }
    public void updatePOBStatus(Map<Id,Authorized_Reseller_Onboarding_Task__c> mapNewTaskRecords,Map<Id,Authorized_Reseller_Onboarding_Task__c> mapOldTaskRecords){
        
        List<Id> lstPOBtoUpdate = new List<Id>();
        List<Id> lstPOBtoUpdateDistiRejection = new List<Id>();
        system.debug('mapNewTaskRecords.values()---->'+mapNewTaskRecords.values());
        //Set<Partner_Onboarding__c> setPOB = new Set<Partner_Onboarding__c>();
        Map<Id,Partner_Onboarding__c> mapPOB = new Map<Id,Partner_Onboarding__c>();
        List<Partner_Onboarding__c> lstPOBStatusUpdate = new List<Partner_Onboarding__c>();
        List<Authorized_Reseller_Onboarding_Task__c> lstTask = new List<Authorized_Reseller_Onboarding_Task__c>();
        for(Authorized_Reseller_Onboarding_Task__c taskLoopVariable: mapNewTaskRecords.values()){
            if(taskLoopVariable.EMC_Approval_Status__c=='Not Approved'&& taskLoopVariable.EMC_Approval_Status__c != mapOldTaskRecords.get(taskLoopVariable.Id).EMC_Approval_Status__c){
                lstPOBtoUpdate.add(taskLoopVariable.Partner_Onboarding__c);
                system.debug('status of task--->'+taskLoopVariable.Status__c);
                //taskLoopVariable.Status__c = 'Complete';
                //lstTask.add(taskLoopVariable);
            
        
            if(lstPOBtoUpdate.size()>0){
                system.debug('POB record'+lstPOBtoUpdate);
                List<Partner_Onboarding__c> lstPOBRecords = new List<Partner_Onboarding__c>([Select Id,Current_Status_of_Onboarding__c from Partner_Onboarding__c where Id in : lstPOBtoUpdate]);
                system.debug('update list'+lstPOBRecords );
                for(Partner_Onboarding__c POBloopvariable:lstPOBRecords ){
                    POBloopvariable.Current_Status_of_Onboarding__c = 'Rejected';
                    mapPOB.put(POBloopvariable.id,POBloopvariable);
                    system.debug('mapPOB---->'+mapPOB);
                }
            }
            }
            if(taskLoopVariable.EMC_Approval_Status__c=='Approved'&& taskLoopVariable.EMC_Approval_Status__c != mapOldTaskRecords.get(taskLoopVariable.Id).EMC_Approval_Status__c){
                lstPOBtoUpdate.add(taskLoopVariable.Partner_Onboarding__c);
                system.debug('status of task--->'+taskLoopVariable.Status__c);
                //taskLoopVariable.Status__c = 'Complete';
                //lstTask.add(taskLoopVariable);
           
        
            if(lstPOBtoUpdate.size()>0){
                List<Partner_Onboarding__c> lstPOBRecords = new List<Partner_Onboarding__c>([Select Id,Current_Status_of_Onboarding__c from Partner_Onboarding__c where Id in : lstPOBtoUpdate]);
                for(Partner_Onboarding__c POBloopvariable:lstPOBRecords ){
                    POBloopvariable.Current_Status_of_Onboarding__c = 'In Progress';
                    mapPOB.put(POBloopvariable.id,POBloopvariable);
                    system.debug('mapPOB---->'+mapPOB);
                }
            }
            }
         }  
        for(Authorized_Reseller_Onboarding_Task__c taskLoopVariable: mapNewTaskRecords.values()){
            List<Id> lstPOBforTrack = new List<Id>();
            if(taskLoopVariable.Account_Found_in_SFDC__c == 'Not Found'&& taskLoopVariable.Account_Found_in_SFDC__c != mapOldTaskRecords.get(taskLoopVariable.Id).Account_Found_in_SFDC__c){
                lstPOBforTrack.add(taskLoopVariable.Partner_Onboarding__c);
            }
            if(lstPOBforTrack.size()>0){
                List<Partner_Onboarding__c> lstPOBRecords = new List<Partner_Onboarding__c>([Select Id,Current_Status_of_Onboarding__c,Step_Name__c,Region_you_are_applying_for__c from Partner_Onboarding__c where Id in : lstPOBforTrack ]);
                    for(Partner_Onboarding__c POBloopvariable:lstPOBRecords){
                        system.debug('Stepname before track--->'+POBloopvariable.Step_Name__c);
                        POBloopvariable.Step_Name__c = 'STEP5';
                        mapPOB.put(POBloopvariable.id,POBloopvariable);
                        system.debug('  '+mapPOB);
                    }
            }
        }         
        
        for(Authorized_Reseller_Onboarding_Task__c taskLoopVariable: mapNewTaskRecords.values()){
            if(taskLoopVariable.Distributor_Approval_Status__c=='Not Approved'&& taskLoopVariable.Distributor_Approval_Status__c != mapOldTaskRecords.get(taskLoopVariable.Id).Distributor_Approval_Status__c){
                lstPOBtoUpdateDistiRejection.add(taskLoopVariable.Partner_Onboarding__c);
                system.debug('lstPOBfortrack---->>'+lstPOBtoUpdateDistiRejection);
                //taskLoopVariable.Status__c = 'Complete';
                //lstTask.add(taskLoopVariable);
            }
                
        
            if(lstPOBtoUpdateDistiRejection!=null){
                List<Partner_Onboarding__c> lstPOBRecords = new List<Partner_Onboarding__c>([Select Id,Current_Status_of_Onboarding__c,Step_Name__c,Region_you_are_applying_for__c from Partner_Onboarding__c where Id in : lstPOBtoUpdateDistiRejection ]);
                    for(Partner_Onboarding__c POBloopvariable:lstPOBRecords){
                        POBloopvariable.Current_Status_of_Onboarding__c = 'Deferred';
                        mapPOB.put(POBloopvariable.id,POBloopvariable);
                        system.debug('STEPname---->'+POBloopvariable.Step_Name__c);
                        if(POBloopvariable.Step_Name__c== 'STEP3'){
                            POBloopvariable.Step_Name__c = 'STEP4';
                            system.debug('lstPOBforStep4--->'+mapPOB);
                            step4sendmailtoCM(mapPOB.values());
                            if(POBloopvariable.Step_Name__c == 'STEP4'){
                                POBloopvariable.Step_Name__c = 'STEP3';
                                lstPOBStatusUpdate.add(POBloopvariable);
                            }
                        }
                        
                    }
                }
         }
       
         for(Authorized_Reseller_Onboarding_Task__c taskLoopVariable: mapNewTaskRecords.values()){
            List<Id> lstPOBforTrack = new List<Id>();
            if(taskLoopVariable.Account_added_on_grouping__c == true && taskLoopVariable.Account_added_on_grouping__c != mapOldTaskRecords.get(taskLoopVariable.Id).Account_added_on_grouping__c && taskLoopVariable.Subject__c==customSettingRecords.get('STEP6.1Americas').Task_Name__c){
                lstPOBforTrack.add(taskLoopVariable.Partner_Onboarding__c);
            }
            if(lstPOBforTrack!=null){
                List<Partner_Onboarding__c> lstPOBRecords = new List<Partner_Onboarding__c>([Select Id,Current_Status_of_Onboarding__c,Step_Name__c,Region_you_are_applying_for__c from Partner_Onboarding__c where Id in : lstPOBforTrack ]);
                    for(Partner_Onboarding__c POBloopvariable:lstPOBRecords){
                        system.debug('Stepname before track--->'+POBloopvariable.Step_Name__c);
                        POBloopvariable.Step_Name__c = 'STEP7';
                        mapPOB.put(POBloopvariable.id,POBloopvariable);
                        system.debug('  '+mapPOB);
                    }
            }
        } 
        for(Authorized_Reseller_Onboarding_Task__c taskLoopVariable: mapNewTaskRecords.values()){
            List<Authorized_Reseller_Onboarding_Task__c> lstTaskRecords = new List<Authorized_Reseller_Onboarding_Task__c>();
            List<Id> lstPOBforTrack = new List<Id>();
            if(taskLoopVariable.Status__c == 'Complete' && taskLoopVariable.Subject__c==customSettingRecords.get('STEP7.1Americas').Task_Name__c){
                lstPOBforTrack.add(taskLoopVariable.Partner_Onboarding__c);
                lstTaskRecords = [Select Id,Subject__c,Status__c from Authorized_Reseller_Onboarding_Task__c where Subject__c =:customSettingRecords.get('STEP7.0Americas').Task_Name__c and Partner_Onboarding__c in : lstPOBforTrack]; 
            }
            else if(taskLoopVariable.Status__c == 'Complete' && taskLoopVariable.Subject__c==customSettingRecords.get('STEP7.0Americas').Task_Name__c){
                lstPOBforTrack.add(taskLoopVariable.Partner_Onboarding__c);
                lstTaskRecords = [Select Id,Subject__c,Status__c from Authorized_Reseller_Onboarding_Task__c where Subject__c =:customSettingRecords.get('STEP7.1Americas').Task_Name__c and Partner_Onboarding__c in : lstPOBforTrack];       
            }       
            if(lstPOBforTrack!=null){
                for(Authorized_Reseller_Onboarding_Task__c objTask:lstTaskRecords){
                    if(objTask.Status__c == 'Complete'){
                        List<Partner_Onboarding__c> lstPOBRecords = new List<Partner_Onboarding__c>([Select Id,Current_Status_of_Onboarding__c,Step_Name__c,Region_you_are_applying_for__c from Partner_Onboarding__c where Id in : lstPOBforTrack ]);
                            for(Partner_Onboarding__c POBloopvariable:lstPOBRecords){
                                system.debug('Status *--->'+POBloopvariable.Current_Status_of_Onboarding__c);
                                POBloopvariable.Current_Status_of_Onboarding__c = 'Partner Onboarded';
                                mapPOB.put(POBloopvariable.id,POBloopvariable);
                                system.debug('  '+mapPOB);
                            }
                    }   
                }    
            }               
                    
        }   
                            
        if(lstTask!=null){
            update lstTask;
        }
        if(mapPOB!=null){       
            update mapPOB.values();
        }
        if(lstPOBStatusUpdate!=null){
            update lstPOBStatusUpdate;
        }
   }
     public void updateTaskStatus(Map<Id,Partner_Onboarding__c> mapNewPOBRecords,Map<Id,Partner_Onboarding__c> mapOldPOBRecords){
        List<Authorized_Reseller_Onboarding_Task__c> lstTaskRecords = new List<Authorized_Reseller_Onboarding_Task__c>();
        List<Authorized_Reseller_Onboarding_Task__c> lstTaskToUpdate = New List<Authorized_Reseller_Onboarding_Task__c>();   
        // List<Partner_Onboarding__c> lstPOBStepChange = new List<Partner_Onboarding__c>();
        for(Partner_Onboarding__c POBloopvariable: mapNewPOBRecords.values()){
             lstTaskRecords = [Select Id,Subject__c,Account_Found_in_SFDC__c from Authorized_Reseller_Onboarding_Task__c where Partner_Onboarding__c in : mapNewPOBRecords.keyset()];
                system.debug('lstoftaskrec'+lstTaskRecords);
                for(Authorized_Reseller_Onboarding_Task__c objTask:lstTaskRecords){         
                    if(POBloopvariable.Authorized_Reseller_Account__c!=null&& POBloopvariable.Authorized_Reseller_Account__c != mapOldPOBRecords.get(POBloopvariable.Id).Authorized_Reseller_Account__c && objTask.Subject__c ==customSettingRecords.get('STEP3.1Americas').Task_Name__c){
                        if(POBloopvariable.Account_Created_by_TRACK__c == true&& POBloopvariable.Step_Name__c == 'STEP6'){   
                            objTask.Status__c = 'Complete';
                            objTask.Account_Found_in_SFDC__c = 'Created By TRACK';
                            lstTaskToUpdate.add(objTask);
                            
                            step6createTaskforExtSystems(mapNewPOBRecords.values());
                        }
                        else if(POBloopvariable.Account_Created_by_TRACK__c != true&& POBloopvariable.Step_Name__c == 'STEP6'){
                            objTask.Status__c = 'Complete';
                            objTask.Account_Found_in_SFDC__c = 'Found';
                            lstTaskToUpdate.add(objTask);
                            step6createTaskforExtSystems(mapNewPOBRecords.values());
                        }
                    }
                    else{
                        if(objTask.Account_Found_in_SFDC__c == 'Not Found'&&objTask.Subject__c==customSettingRecords.get('STEP3.1Americas').Task_Name__c){
                            objTask.Status__c = 'Incomplete';
                            lstTaskToUpdate.add(objTask);
                            step5sendmailtoTRACK(mapNewPOBRecords.values());
                            //POBloopvariable.Step_Name__c = 'STEP6';
                            //lstPOBStepChange.add(POBloopvariable); 
                        }
                         //update lstPOBStepChange;
                    }    
                }          
        }           
        for(Partner_Onboarding__c POBloopvariable: mapNewPOBRecords.values()){
             lstTaskRecords = [Select Id,Subject__c,Account_added_on_grouping__c,Status__c from Authorized_Reseller_Onboarding_Task__c where Partner_Onboarding__c in : mapNewPOBRecords.keyset()];
                for(Authorized_Reseller_Onboarding_Task__c objTask:lstTaskRecords){
                    if(POBloopvariable.Authorized_Reseller_Account__c!=null&& objTask.Subject__c ==customSettingRecords.get('STEP6.1Americas').Task_Name__c&& objTask.Account_added_on_grouping__c == true&&objTask.Status__c!='Complete'){
                        objTask.Status__c = 'Complete';
                        lstTaskToUpdate.add(objTask);
                        system.debug('list of task final---->'+lstTaskToUpdate);
                        step7createTaskforCMforProfileUpdationAndWelcomeEmails(mapNewPOBRecords.values());
                    }
                }           
        }
       update lstTaskToUpdate; 
     }
     public void UpdateLocalLanguageFields(List<Partner_Onboarding__c> ListTrigger){
        if(ListTrigger.size()>0){
           for(Partner_Onboarding__c newonboard :ListTrigger){
               newonboard.Local_Language_Address_1__c=newonboard.Address_1__c;
               newonboard.Local_Language_Address_2__c=newonboard.Address_2__c;
               newonboard.Local_Language_City__c=newonboard.City__c;
               newonboard.Local_Language_Corporate_URL__c=newonboard.Corporate_URL__c;
               newonboard.Local_Language_Country__c=newonboard.Country__c;
               newonboard.Local_Language_E_mail_Address__c=newonboard.E_mail_Address__c;
               newonboard.Local_Language_First_Name__c=newonboard.First_Name__c;
               newonboard.Local_Language_Last_Name__c=newonboard.Last_Name__c;
               newonboard.Local_Language_Legal_Parent_Company_Name__c=newonboard.Legal_Parent_Company_Name__c;
               newonboard.Local_Language_Main_Company_Phone_Number__c=newonboard.Main_Company_Phone_Number__c;
               newonboard.Local_Language_State_Province__c=newonboard.State__c;
               newonboard.Local_Language_Title__c=newonboard.Title__c;
               newonboard.Local_Language_Zip_Postal_Code__c=newonboard.Zip_Postal_Code__c;
           } 
        }
    }
     public void updateAuthorizedResellerOnboardingTaskList(List<Authorized_Reseller_Onboarding_Task__c> ListAuthorizedResellerOnboardingTask){
        system.debug('-------->'+ListAuthorizedResellerOnboardingTask);      
        Map<Id,Id> maptask = new Map<Id,Id>();
        Set<Id> pobId = new Set<Id>();
        List<Authorized_Reseller_Onboarding_Task__c> lstUpdate = new List<Authorized_Reseller_Onboarding_Task__c>();  
            for (Authorized_Reseller_Onboarding_Task__c task : ListAuthorizedResellerOnboardingTask){
                maptask.put(task.Id,task.Partner_Onboarding__c);
            }
            for(Id pob : maptask.values()){
                pobId.add(pob);
            }
        Map<Id,Partner_Onboarding__c> mapPOB = new Map<Id,Partner_Onboarding__c>([Select Country__c,Corporate_URL__c,Main_Company_Phone_Number__c, Region_you_are_applying_for__c,Authorized_Reseller_Account__c from Partner_Onboarding__c where Id in : pobId]); 
            for(Authorized_Reseller_Onboarding_Task__c task: ListAuthorizedResellerOnboardingTask){
                if(mapPOB.get(maptask.get(task.Id))!=Null){
                    task.Country__c =mapPOB.get(maptask.get(task.Id)).Country__c;
                    task.Theater__c =mapPOB.get(maptask.get(task.Id)).Region_you_are_applying_for__c;
                if(mapPOB.get(maptask.get(task.Id)).Authorized_Reseller_Account__c!=null){
                    task.Partner_Account__c = mapPOB.get(maptask.get(task.Id)).Authorized_Reseller_Account__c;
                }  
                }       
            }
    } 

//Added by Anirudh for Req# 2830
/* @Method <This method execute is used to populate Values on Profiled Account when Grouping is setup for 
            Authorised Reseller Onbaording Record.>
@param <This method takes List Authorised Reseller Onboarding Task as input parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
public void updateRelatedProfiledAccount(List<Authorized_Reseller_Onboarding_Task__c> ListUpdatedTask){
    map<Id,Id> MapPOBIdWithAcctId = New map<Id,Id>();  
    map<Id,Id> MapAccountWithPfAccountId = new map<id,id>();    
    list<Account> AccountRelatedToTask = New list<Account>();
    list<Account> AccountToUpdate = New list<Account>();
    for (Authorized_Reseller_Onboarding_Task__c task :ListUpdatedTask){
        MapPOBIdWithAcctId.put(task.Partner_Onboarding__c,task.Partner_Account__c);
    }
    System.debug('MapPOBIdWithAcctId----->' +MapPOBIdWithAcctId);
    AccountRelatedToTask= [Select Id,Profiled_Account__c,Profiled_Account_Flag__c from Account 
                            where isPartner = true and id in:MapPOBIdWithAcctId.values()];
    if(AccountRelatedToTask.size()>0){
        for(Account acct :AccountRelatedToTask){
            if(acct.Profiled_Account_Flag__c){
                MapAccountWithPfAccountId.put(acct.Id,acct.id);
            }
            if(!acct.Profiled_Account_Flag__c){
            MapAccountWithPfAccountId.put(acct.Id,acct.Profiled_Account__c);
            }
        }
    }
    //System.Debug('MapAccountWithPfAccountId--->' +MapAccountWithPfAccountId);
    Map<Id,Account> MapProfiledAccount = New Map<Id,Account>([Select Id,Model__c,Partner_Type__c,Partner_Programs__c,RMSA_Effective_Date__c, 
                                                             Reporting_Segmentation__c,Channel_Revenue_Partner__c,Business_Focus__c,Theater1__c,Industry_Verticals__c,Application_Environments__c,Partner_Self_Description_Long__c from Account where id in :MapAccountWithPfAccountId.Values()]);      
    Map<Id,Partner_Onboarding__c> MapPOB = New Map<Id,Partner_Onboarding__c>([Select Id,Corporate_URL__c,Main_Company_Phone_Number__c,Primary_EMC_Business_Line_Interest__c,Vertical_Market_Specialization__c,Application_Environments__c,Company_Overview_1000_characters_max__c from Partner_Onboarding__c where Id in :MapPOBIdWithAcctId.keyset()]);
  System.debug('MapProfiledAccount-->' +MapProfiledAccount);
  System.debug('MapPOB-->' +MapPOB);
  for( Partner_Onboarding__c POB :MapPOB.Values() ){
      if(MapPOBIdWithAcctId.get(POB.Id)!=Null){
         if(MapAccountWithPfAccountId.keyset().contains(MapPOBIdWithAcctId.get(POB.Id))){
            Account ProfiledAccount = New Account();
            ProfiledAccount=MapProfiledAccount.get(MapAccountWithPfAccountId.get(MapPOBIdWithAcctId.get(POB.Id)));
            ProfiledAccount.Model__c = 'Open' ;
            ProfiledAccount.Partner_Type__c = 'Distribution VAR'; 
            ProfiledAccount.Partner_Programs__c = 'Authorized Reseller';
            ProfiledAccount.RMSA_Effective_Date__c = System.Today() ;
            ProfiledAccount.Reporting_Segmentation__c = 'RESELLER - INDIRECT RESELLER'; 
            ProfiledAccount.Channel_Revenue_Partner__c = 'Yes';
            ProfiledAccount.Business_Focus__c=POB.Primary_EMC_Business_Line_Interest__c;
            ProfiledAccount.Industry_Verticals__c=POB.Vertical_Market_Specialization__c;
            ProfiledAccount.Application_Environments__c=POB.Application_Environments__c;
            ProfiledAccount.Partner_Self_Description_Long__c=POB.Company_Overview_1000_characters_max__c;
            ProfiledAccount.Website=POB.Corporate_URL__c;
            ProfiledAccount.Phone=POB.Main_Company_Phone_Number__c; 
            
            if(ProfiledAccount.Theater1__c=='Americas'){
                ProfiledAccount.GTM_Designation__c='Growth' ;
            }
            else{
                ProfiledAccount.GTM_Designation__c='Other';
            }
            AccountToUpdate.add(ProfiledAccount); 
         }
                             
      }
      //AccountToUpdate.add(MapProfiledAccount.get(MapAccountWithPfAccountId.get(MapPOBIdWithAcctId.get(POB.Id))));
  }
   System.Debug('UpdateisByAnirudh---' +AccountToUpdate);
    Update AccountToUpdate;
  }
  
  //UpdateTaskStatus
  public void updateTaskStatus(List<Authorized_Reseller_Onboarding_Task__c> ListAuthorizedResellerTask){
    List<Id> TaskList=new List<Id>();
        for(Authorized_Reseller_Onboarding_Task__c  obj1 :ListAuthorizedResellerTask)
            {
            if(obj1.Status__c==customSettingRecords.get('STEP7.1Americas').Task_Name__c && obj1.CXP_Email_Sent__c && obj1.Powerlink_Email_Sent__c && obj1.Legal_Agreement_Copy_Sent_to_DMS__c)
            {

                TaskLIst.add(obj1.Partner_Onboarding__c);
            }
            
        }

    List<Partner_Onboarding__c> POBId=new List<Partner_Onboarding__c>([Select Id,Current_Status_of_Onboarding__c from Partner_Onboarding__c where Id in :TaskLIst]);
    List<Id> Defferedlist=new List<Id>();

        for(Partner_Onboarding__c P: POBId)
        {
           if(P.Current_Status_of_Onboarding__c=='Deferred')
           {
                Defferedlist.add(P.Id);
           }
        }


    
    List<Authorized_Reseller_Onboarding_Task__c> lstTasks=new List<Authorized_Reseller_Onboarding_Task__c>([Select Id from Authorized_Reseller_Onboarding_Task__c where Id in :Defferedlist]); 
    for(Authorized_Reseller_Onboarding_Task__c Auth:lstTasks)
    {
        Auth.addError('You cant Complete the Status of the Record');      
    }

}            
}