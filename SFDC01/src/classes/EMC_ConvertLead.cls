/*===========================================================================+

    HISTORY                                                                  
                                                                                                       
                                                                           
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
                    Prasad Kothawade                        Custom version of standard functionality to convert Lead to opportunity.               

    08-Oct-09       Shipra Misra                            Updated to Map Few fields in opportunity and contact. This updation is in regard with TD-Convert-Lead.doc

    03 Jan 2010     Mohd Arif Sheikh        123691          "Campaign Identifier" and "Lead/Opty Description" fields are added in query as well as in function (createOpportunity).                   
    10 Feb 2010     Gajanand K Chalkapure   123877          "Created two method 'openActivitiesFromLeadToOpportunity(LeadtoConvert.Id,OpportunityId)' and createContactFromLeadToOpportunity(ContactId,OpportunityId) "
    18 Feb 2010     Mohd Arif Sheikh        123691          "Revert the changes done on 3 Jan i.e. 'exclude Campaign Identifier from the changes which has done' till further request.  
    30 Mar 2010     Arif                    DEFECT 590,591  Added Originator_Details__c,Other_Originator_Details__c in query as well as in createOpportunity function.
                                                    
    09 Apr 2010     Arif                    DEFECT 614      Change 'Campaign_Event_Name_New__c to Campaign_Event_Name__c'for Lead Object
    09 Apr 2010     Anirudh                 DEFECT 614      Change 'Campaign_Event_Name__c to Campaign_Event_Name_New__c' for Opportunity Object   
    17 Apr 2010     Arif                                    Removed 'Campaign_Identifier' from query. 
    11 Apr 2010     Shipra Misra            131548          "Change the Role in contactrole to 'Other'.Also If the 'Related Contact' field is NOT populated on the Lead, 
    26 Apr 2010     Shipra Misra            Defect 665      "Related contact field should be populated with the contact name that has resulted"   
    09 Jul 2010     Ashwini Gowda           Reqt #043       Introduced a check in createOpportunity() method and introduced  getOpportunityOwner() method for PRM Functionality.
    02 Aug 2010     Rajeev choudhary                        Convert All menthods for bulk handaling of leads.
    02 Sep 2010     Pratibh Prakash         137628          The owner of  Lead record should be added to Account Team if the lead owner IS NOT a member of the Related AccountÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¾ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢s Account team.        
    15 Nov 2010     Srinivas Nallapati                      The IIG Sales Stage should be 'Stage-1 Discovery' for the converted Opportunity. New lines added 392, 518.      
    15 Mar 2011     Shipra Misra            158373          Updations done for WR-158373 Aprimo To Salesforce Integration.
    19 May 2011     Anand Sharma            req# 2278.      DR is accepted with no related opportunity, and ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œCreate New OpportunityÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡ÃƒÂ¯Ã‚Â¿Ã‚Â½ not checked,
                                                            Display error: ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œCreate New Opportunity checkbox should be checked to create a new OpportunityÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡ÃƒÂ¯Ã‚Â¿Ã‚Â½.             
    27 June 2011    Prasad                                  Added new VMWare field.       

    19 July 2011    Prasad K                                Bug fixed Deal Reg - Contact creation was failing in mass method. Corrected the logic
    20 July 2011    Anand Sharma                            Change forcast status for EMEA to upside.  
    14 Oct 2011     Anand Sharma            WR:177290       For all opportunities created through a Deal Registration, use the following Naming convention : <CUSTOMER NAME> - <DR# XXXXXXXXX>
                                            /177282              
    14/10/2011      Arif                    177274          update 'createContact' method to fetch all contacts whether partner or not.                                     
    04/09/2011      Prasad                                  Linked to deal reg setting lead in on opp in conversion process itself
    29-Mar-2013     Uday Annapareddy        246616          Created a Helper method to get the theater from account and send the theater to populateopportunityowner trigger.
    02/05/2013      Nimai Meher             256428          Commented Title_Type__c field as part of WR - 256428 (Contact simplification) for June Release.
    13/05/2013      Hemavathi N M           261817          ELA field on oppty should map to ELA field on lead when lead is converted to oppty            
 +==================================================================================================================================*/
 

global class EMC_ConvertLead {

    static Lead LeadtoConvert=null;
    static String OpportunityId=null;
    static String ContactId=null;
    static Contact contact=null;
    static String OpportunityOwnerName=null;
    
    Static Integer i;
    // uday 246616 
   // Static map to get the theater from account on opportunity.
    static map<id, account> staticMap;
    public map<id, account> theaterHelper(Set<Id> setAccID){
        system.debug('Static map '+staticmap);
        //if(staticMap==null || !setAccID.containsAll(staticMap.keyset()))
        if(staticMap==null || !staticMap.keyset().containsAll(setAccID))
        staticMap =new Map<Id, Account>([Select Id, Theater1__c, Name From Account where id in : setAccID]);
        return staticMap;
    }
    // uday 246616
    /**  
        * Method < convertLead(String lead)is for Converting Lead to Opportunity based upon lead id. >
        *   @param <'lead id'>  
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
          
    */   
    @future static public void convertLead1(String lead){
        convertLead(lead);
    }   
   
    webservice static String convertLead(String lead){
        Savepoint sp;
        try{
            //123691
            //261817 - added ELA field       
            LeadtoConvert=[select Related_Account__r.Name,ELA2__c,DealReg_Is_Vmware_related_solution__c, owner.name,id,Channel__c,Campaign_Event_Name__c, RecordTypeId, DealReg_Deal_Registration__c,
                                Other_Originator_Details__c,S_Control_Converted__c,Aprimo_AudMem_ID__c,Lead_Identifier__c,Lead_Number__c,
                                Passed_to_Partner__c,Title_Classification__c,Market_Segment__c,Decision_Criteria_Process__c,
                                CMA_Business_Need__c,Company,Description,DoNotCall,Email,FirstName,LastName,LeadSource,Lead_Originator__c,
                                OwnerId,Phone,Role__c,Related_Account__c,City,State,Street,Country,PostalCode,Department__c,
                                Originator_Details__c,HasOptedOutOfEmail,MobilePhone,Competitors__c,Other_Competitor__c,Notes_Next_Steps__c,
                                Other_CMA_Business_Need__c,Related_Contact__c,Related_Opportunity__c,Sales_Force__c,Salutation,Status,
                                Tier_2_Partner__c,Partner__c,Title,CurrencyIsoCode,DealReg_Expected_Close_Date__c from Lead where id=:lead];
            /*
            LeadtoConvert=[select Related_Account__r.Name,DealReg_Is_Vmware_related_solution__c, owner.name,id,Channel__c,Campaign_Event_Name__c, RecordTypeId, DealReg_Deal_Registration__c,
                                Other_Originator_Details__c,S_Control_Converted__c,Aprimo_AudMem_ID__c,Lead_Identifier__c,Lead_Number__c,
                                Passed_to_Partner__c,Title_Classification__c,Market_Segment__c,Decision_Criteria_Process__c,
                                CMA_Business_Need__c,Company,Description,DoNotCall,Email,FirstName,LastName,LeadSource,Lead_Originator__c,
                                OwnerId,Phone,Role__c,Related_Account__c,City,State,Street,Country,PostalCode,Department__c,
                                Originator_Details__c,HasOptedOutOfEmail,MobilePhone,Competitors__c,Other_Competitor__c,Notes_Next_Steps__c,
                                Other_CMA_Business_Need__c,Related_Contact__c,Related_Opportunity__c,Sales_Force__c,Salutation,Status,
                                Tier_2_Partner__c,Partner__c,Title,Title_Type__c,CurrencyIsoCode,DealReg_Expected_Close_Date__c from Lead where id=:lead];
            
            */
                                
            sp = Database.setSavepoint();
            //Changes-Pratibh 2-Sep-2010: Method called that validates/adds Lead Owner in Account Team of related Account
            List<Lead> tempLeadList = new List<Lead>();
            tempLeadList.add(LeadtoConvert);
            
            //added by anand on 18/05/2011 for deal reg                         
            if(LeadtoConvert.DealReg_Deal_Registration__c ==  true){              
                tempLeadList = PRM_DEALREG_RegistrationConversion.updateSalesforceStatusOfLead(tempLeadList);               
            }
            // End 
            /**/
             
            validate_createLeadOwnerAccountTeam(tempLeadList);
            OpportunityId=createOpportunity();
            contact=createContact();
            openActivitiesFromLeadToOpportunity(LeadtoConvert.Id,OpportunityId);            
            if(contact!=null){
                createContactFromLeadToOpportunity(contact,OpportunityId);
            } 
            //Updation By Shipra for 131548 "If the 'Related Contact' field on the Lead is populated, place that person in the Opportunity Contact Roles related list" 
            if(LeadtoConvert.Related_Contact__c!=null){        
                System.debug('the value of contact to be entered is whene related contact is null '+LeadtoConvert.Related_Contact__c);
                Contact relatedContact= [Select id,AccountId,Primary_Contact__c, Email, Phone from Contact where id=:LeadtoConvert.Related_Contact__c and active__c = true limit 1];
                System.debug('relatedContact value'+relatedContact);
                if(relatedContact.Email != LeadtoConvert.Email ){
                    createContactFromLeadToOpportunity(relatedContact,OpportunityId);
                }        
            } 
            updateLead();
            //End of Updation By Shipra for 131548        
            return OpportunityId;
            //return lead;
        }catch(Exception e){    
            Database.rollback(sp);
            return ''+e;
        }
    }
     
    //rajeev start
    /*
    static Map<String,Opportunity> leadWithOpportunityMap= null;
    static List<String> ContactIdLst= null;
    static Map<String,Contact> leadWithContactMap= null;
    static List<Lead> LeadtoConvertLst= null;
    */
    //@future
    webService static void convertLeads(List<Lead> leadLst){
        List<String> OppLst = new  List<String>();
        Map<String,Opportunity> leadWithOpportunityMap= new Map<String,Opportunity>();
        List<String> ContactIdLst= new List<String>();
        Map<String,Contact> leadWithContactMap= new Map<String,Contact>();
        List<Lead> LeadtoConvertLst= new List<Lead>();        
        Savepoint sp;
        try{
            //261817 - added ELA field
            LeadtoConvertLst=[select Related_Account__r.Name,ELA2__c, owner.name,id,Channel__c,Campaign_Event_Name__c,Other_Originator_Details__c,
                                    Aprimo_AudMem_ID__c,S_Control_Converted__c,Lead_Identifier__c,Passed_to_Partner__c,
                                    Title_Classification__c,Market_Segment__c,Decision_Criteria_Process__c,CMA_Business_Need__c,
                                    Company,Description,DoNotCall,Email,FirstName,LastName,LeadSource,Lead_Originator__c,OwnerId,Phone,
                                    Role__c,Related_Account__c,City,State,Street,Country,PostalCode,Department__c,Originator_Details__c,
                                    HasOptedOutOfEmail,MobilePhone,Competitors__c,Other_Competitor__c,Notes_Next_Steps__c,RecordTypeId,
                                    Other_CMA_Business_Need__c,Related_Contact__c,Related_Opportunity__c,Sales_Force__c,Salutation,
                                    Status,Tier_2_Partner__c,Partner__c,Title,CurrencyIsoCode,DealReg_Expected_Close_Date__c from Lead where id in:leadLst]; 
   /*
   LeadtoConvertLst=[select Related_Account__r.Name, owner.name,id,Channel__c,Campaign_Event_Name__c,Other_Originator_Details__c,
                                    Aprimo_AudMem_ID__c,S_Control_Converted__c,Lead_Identifier__c,Passed_to_Partner__c,
                                    Title_Classification__c,Market_Segment__c,Decision_Criteria_Process__c,CMA_Business_Need__c,
                                    Company,Description,DoNotCall,Email,FirstName,LastName,LeadSource,Lead_Originator__c,OwnerId,Phone,
                                    Role__c,Related_Account__c,City,State,Street,Country,PostalCode,Department__c,Originator_Details__c,
                                    HasOptedOutOfEmail,MobilePhone,Competitors__c,Other_Competitor__c,Notes_Next_Steps__c,RecordTypeId,
                                    Other_CMA_Business_Need__c,Related_Contact__c,Related_Opportunity__c,Sales_Force__c,Salutation,
                                    Status,Tier_2_Partner__c,Partner__c,Title,Title_Type__c,CurrencyIsoCode,DealReg_Expected_Close_Date__c from Lead where id in:leadLst]; 
   
   */         
            LeadtoConvertLst =  leadLst;                                       
            system.debug('LeadtoConvertLst '+LeadtoConvertLst);
            sp = Database.setSavepoint();
            
            //added by anand on 18/05/2011 for deal reg                         
          
                
            if(LeadtoConvertLst.size()>0){
            
                //added by anand on 18/05/2011 for deal reg                    
                System.debug('Before Salesforce LeadtoConvertLst -->' + LeadtoConvertLst);
                LeadtoConvertLst = PRM_DEALREG_RegistrationConversion.updateSalesforceStatusOfLead(LeadtoConvertLst);
                System.debug('after Salesforce LeadtoConvertLst -->' + LeadtoConvertLst);                 
                // End 
                        
                leadWithOpportunityMap = createOpportunity(LeadtoConvertLst);
                
                System.debug('Salesforce leadWithOpportunityMap -->' + leadWithOpportunityMap);
            }
            if(LeadtoConvertLst.size()>0) 
                leadWithContactMap=createContact(LeadtoConvertLst);
            if(leadWithOpportunityMap!= null && leadWithOpportunityMap.size()>0 ){
                openActivitiesFromLeadToOpportunity(leadWithOpportunityMap);

                //added by anand on 18/05/2011 for deal reg
                PRM_DEALREG_RegistrationConversion.addProductOnOpportunity(leadWithOpportunityMap);
                // End
            }
            System.debug('Salesforce leadWithContactMap -->' + leadWithContactMap);
            
            if((leadWithContactMap!= null && leadWithContactMap.size()>0) || (leadWithOpportunityMap != null && leadWithOpportunityMap.size()>0))
                createContactFromLeadToOpportunity(leadWithContactMap,leadWithOpportunityMap );        
            //check later on 
            /*   if(LeadtoConvertLst.size()>0 ){
                    List<Contact> relatedContactLst= [Select id,AccountId,Primary_Contact__c, Email, Phone from Contact where id=:LeadtoConvert.Related_Contact__c and active__c = true limit 1];            
                    createContactFromLeadToOpportunity(relatedContactLst,leadWithOpportunityMap);            
            }  */

            if(LeadtoConvertLst.size()>0)
                updateLead(LeadtoConvertLst,leadWithContactMap,leadWithOpportunityMap);          
            for(Opportunity nextOpp :leadWithOpportunityMap.Values()){
                if(nextOpp.Id !=null)
                    OppLst.add(nextOpp.Id);
            }
            System.Debug('LeadtoConvertLst ---->' + LeadtoConvertLst);            
            return ;       
        }catch(Exception e){
            
            System.Debug('IN Exception ---->' + e);    
            Database.rollback(sp);
            //  leadWithOppMap.put('error','error');
            //return leadWithOppMap ;
            // return ''+e;
            // This logic will error out all the deal regs in batch. Please set batch size for Deal reg Conversion
            for (Lead dealreg :leadLst){
                dealreg.addError( System.label.DR_Conversion_Error + 'The Error Details are '+e);
            }
            
            return ;
        }
    }
    //rajeev end

    /**
        * Method <openActivitiesFromLeadToOpportunity(String lead_Id,String opportunity_Id)> <This method is for moving openactivities(Event,Task)From Lead to Opportunity as per the requirement.>
        *   @param <'lead_Id' from Lead,'opportunity_Id' from Opportunity> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
          
    */ 
    //e.WhoId, t.WhoId set to null for PRM Release:
    
    private static void openActivitiesFromLeadToOpportunity(String lead_Id,String opportunity_Id){
        System.debug('openActivitiesFromLeadToOpportunity---->');
        List<Event> event=[Select e.ActivityDate,e.Id,e.WhoId,e.WhatId from Event e where e.WhoId=:lead_Id and e.ActivityDateTime>=:system.now()];
        for(Event e:event){
            e.WhatId=opportunity_Id; 
            e.WhoId=null;   
        }
        update event;

        List<Task> task=[Select t.IsClosed,t.Id,t.WhoId,t.WhatId from Task t where t.WhoId=:lead_Id and t.IsClosed=:false];
        for(Task t:task){
            t.WhatId=opportunity_Id;
            t.WhoId=null;
            System.debug('what id of task ---->'+t.WhatId);
        }
        update task;
    }
 
    //rajeev starts 
    private static void openActivitiesFromLeadToOpportunity(Map<String,Opportunity> oppLst  ){
        List<Event> event=[Select e.ActivityDate,e.Id,e.WhoId,e.WhatId from Event e where e.WhoId in:oppLst.keySet() and e.ActivityDateTime>=:system.now()];
        for(Event e:event){
            if(oppLst.get(e.WhoId) !=null)
                e.WhatId =  oppLst.get(e.WhoId).Id;      //opportunity_Id;    
        }
        update event;
        List<Task> task=[Select t.IsClosed,t.Id,t.WhoId,t.WhatId from Task t where t.WhoId in:oppLst.keySet() and t.IsClosed=:false];
        for(Task t:task){
            if(oppLst.get(t.WhoId) !=null)
                t.WhatId = oppLst.get(t.WhoId).Id; 
        }
        update task;
    }

    //rajeev ends 

    /**
        * Method <createContactFromLeadToOpportunity(Contact contact,String opportunity_Id) is for taking the Contacts from Lead to the Opportunuity>
        *   @param <'contact_Id' from Contact,'opportunity_Id' from Opportunity> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
          
    */
    private static void createContactFromLeadToOpportunity(Contact contactLead,String opportunity_Id){   
        OpportunityContactRole opportunity_contact_role=new OpportunityContactRole();
        opportunity_contact_role.Role='Other';
        opportunity_contact_role.ContactId=contactLead.Id;
        opportunity_contact_role.OpportunityId=opportunity_Id;
        opportunity_contact_role.isPrimary=contactLead.Primary_Contact__c;

        insert opportunity_contact_role;
        System.debug('createContactFromLeadToOpportunity'+opportunity_contact_role.id);
    }

    //rajeev starts 
    private static void createContactFromLeadToOpportunity( Map<String,Contact> contLst ,Map<String,Opportunity> oppLst){
        List<OpportunityContactRole> lstOppContactrole = new   List<OpportunityContactRole>();
        for(String nextLeadId : oppLst.keySet()){     
            OpportunityContactRole opportunity_contact_role=new OpportunityContactRole();
            opportunity_contact_role.Role='Other';
    
            if(contLst.containsKey(nextLeadId))
                opportunity_contact_role.ContactId = contLst.get(nextLeadId).Id;        
            if(oppLst.containsKey(nextLeadId))
                opportunity_contact_role.OpportunityId = oppLst.get(nextLeadId).Id;
            if(contLst.containsKey(nextLeadId))
                opportunity_contact_role.isPrimary= contLst.get(nextLeadId).Primary_Contact__c;        
            lstOppContactrole.add(opportunity_contact_role);
        }
        if(lstOppContactrole.size()>0)
            System.debug('createContactFromLeadToOpportunity lstOppContactrole '+ lstOppContactrole);
            Database.insert (lstOppContactrole, false);
    }
    //rajeev ends 

    /**
        * Method <createOpportunity()is for creating opportuntiy>
        *   @param <This method is not taking any arguments.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
    */
    private static String createOpportunity(){
        System.debug('Related_Account_name--->'+LeadtoConvert.Related_Account__c);
        // String account_name= [select Name from Account where id=:LeadtoConvert.Related_Account__c].Name;
        String account_name= LeadtoConvert.Related_Account__r.Name;
        /*Account relAcctName = [select Name from Account where id=:LeadtoConvert.Related_Account__c];
        String account_name=relAcctName.Name;*/
                
        System.debug('account_name--->'+account_name);
        // String owner_name= [select Name from User where id=:LeadtoConvert.OwnerId].Name;
        String owner_name=LeadtoConvert.owner.name;
        Opportunity convertedOpportunity = new Opportunity();
        PRM_CommonUtils utils = new PRM_CommonUtils();
         
        //added by anand on 18/05/2011 for deal reg 
        //fetch record type id for Deal Reg Approved
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c DealRegistrationSource = DataValueMap.get('DealRegistrationSource');
        CustomSettingDataValueMap__c DealRegistrationSourceProgramDetails = DataValueMap.get('DealRegistrationSourceProgramDetails');
        CustomSettingDataValueMap__c DealRegistrationOpportunityStage = DataValueMap.get('DealRegistrationOpportunityStage');
        CustomSettingDataValueMap__c DealRegistrationOpportunityIIGSalesStage = DataValueMap.get('DealRegistrationOppIIGSalesStage');
            
        List<OpportunityIntegration__c> userId = OpportunityIntegration__c.getall().Values();
        if(LeadtoConvert.DealReg_Deal_Registration__c == true){
            List<Lead> lstTempLead = new List<Lead>();
            Map<String,AccountTeamMember> lead_Acc_AccTeamMembersMap = new Map<String,AccountTeamMember>();
            lstTempLead.add(LeadtoConvert);
            Map<Id, Account> mapAccountDetails = new Map<Id, Account>([Select Id, Name From Account where id = : LeadtoConvert.Related_Account__c]);
            
            lead_Acc_AccTeamMembersMap = PRM_DEALREG_RegistrationConversion.getOpportunityOwner(lstTempLead);
            
            if(utils.isPartnerUser(LeadtoConvert.OwnerId)){
                if(lead_Acc_AccTeamMembersMap.get(LeadtoConvert.Related_Account__c) !=null){
                    convertedOpportunity.OwnerId = lead_Acc_AccTeamMembersMap.get(LeadtoConvert.Related_Account__c).UserId ;
                    // Commented for WR#177290/177282: Anand Sharma
                    //convertedOpportunity.Name  = mapAccountDetails.get(LeadtoConvert.Related_Account__c).Name+'-' +  lead_Acc_AccTeamMembersMap.get(LeadtoConvert.Related_Account__c).User.Name ;
                }else if(userId[0] !=null){
                    convertedOpportunity.OwnerId = userId[0].House_Account_User__c;
                    //convertedOpportunity.Name ='House Account';
                    // Commented for WR#177290/177282: Anand Sharma
                    //convertedOpportunity.Name = mapAccountDetails.get(LeadtoConvert.Related_Account__c).Name + '-'+ System.Label.House_Account;
                }               
            }else{
                convertedOpportunity.OwnerId = userId[0].House_Account_User__c;
                //convertedOpportunity.Name ='House Account';
                // Commented for WR#177290/177282: Anand Sharma
                //convertedOpportunity.Name = mapAccountDetails.get(LeadtoConvert.Related_Account__c).Name + '-'+ System.Label.House_Account;
            }
            // Added for WR#177290/177282: Anand Sharma
            convertedOpportunity.Name = mapAccountDetails.get(LeadtoConvert.Related_Account__c).Name + ' - DR# '+ LeadtoConvert.Lead_Number__c;
        }      
        //End 
        else{
            //Included for  PRM Reqt# 043
            if(utils.isPartnerUser(LeadtoConvert.OwnerId)){
                convertedOpportunity.OwnerId = getOpportunityOwner(LeadtoConvert.Related_Account__c,LeadtoConvert.Sales_Force__c);
              
                System.debug('convertedOpportunity.OwnerId of PowerPartner--->'+convertedOpportunity.OwnerId);
                // String OpptyOwnerName = [select Name from User where id=:convertedOpportunity.OwnerId].Name;
                System.debug('New OpptyOwnerName ----->'+OpportunityOwnerName );
                convertedOpportunity.Name=account_name+'-'+ OpportunityOwnerName;
                System.debug('New OpptyName ----->'+convertedOpportunity.Name);
            }else{
              convertedOpportunity.OwnerId=LeadtoConvert.OwnerId;
              System.debug('convertedOpportunity.OwnerId--->'+convertedOpportunity.OwnerId);
              convertedOpportunity.Name=account_name+'-'+ owner_name;
            }
        }
            
        //123691        
        //(new request on 18 Feb)convertedOpportunity.Campaign_Identifier__c=LeadtoConvert.Campaign_Identifier__c;
        //123691        
        convertedOpportunity.Campaign_Identifier__c=LeadtoConvert.Lead_Identifier__c;
        convertedOpportunity.accountid=LeadtoConvert.Related_Account__c;
        //convertedOpportunity.Name=account_name+'-'+ owner_name;
        //convertedOpportunity.LeadSource=LeadtoConvert.LeadSource;
        convertedOpportunity.Campaign_Event_Name__c=LeadtoConvert.Campaign_Event_Name__c;
        convertedOpportunity.Originator__c=LeadtoConvert.Lead_Originator__c;
        convertedOpportunity.Sales_Force__c=LeadtoConvert.Sales_Force__c;
        //convertedOpportunity.Description=LeadtoConvert.Description;
        convertedOpportunity.Partner__c=LeadtoConvert.Partner__c;
        convertedOpportunity.Sales_Channel__c=LeadtoConvert.Channel__c;
        convertedOpportunity.Tier_2_Partner__c=LeadtoConvert.Tier_2_Partner__c;
        convertedOpportunity.closeDate=System.today()+30;
        convertedOpportunity.StageName='Pipeline';
        convertedOpportunity.Created_via_Convert__c=true;
                    //261817 - added ELA field
        convertedOpportunity.ELA2__c = LeadtoConvert.ELA2__c;
        //DEFECT 591 & 590     
        convertedOpportunity.Originator_Detail__c= LeadtoConvert.Originator_Details__c;
        //convertedOpportunity.Originator__c= LeadtoConvert.Lead_Originator__c;
        convertedOpportunity.Other_Originator_Detail__c=LeadtoConvert.Other_Originator_Details__c;
        //Code Updated By Shipra on 8.10.09 for Convert lead Field mapping//
        //convertedOpportunity.Name=LeadtoConvert.Company;
        //convertedOpportunity.Partner__c=LeadtoConvert.Partner__c;

        convertedOpportunity.Next_Steps__c=LeadtoConvert.Notes_Next_Steps__c;
        convertedOpportunity.CMA_business_need__c=LeadtoConvert.CMA_Business_Need__c;
        convertedOpportunity.Other_CMA_business_need__c=LeadtoConvert.Other_CMA_Business_Need__c;
        convertedOpportunity.Market_Segment__c=LeadtoConvert.Market_Segment__c;
        convertedOpportunity.Decision_Criteria__c=LeadtoConvert.Decision_Criteria_Process__c;
        convertedOpportunity.Comments_Details__c=LeadtoConvert.Description;
        convertedOpportunity.LeadSource=LeadtoConvert.LeadSource;

        if(LeadtoConvert.Competitors__c!=null){
            if(LeadtoConvert.Competitors__c.contains(';')==false){
                convertedOpportunity.Competitor__c=LeadtoConvert.Competitors__c;
                convertedOpportunity.Other_Primary_Competitor_s__c=LeadtoConvert.Other_Competitor__c;
            }
            if(LeadtoConvert.Competitors__c.contains(';')==True){
                convertedOpportunity.Secondary_Competitor_s__c=LeadtoConvert.Competitors__c;
                convertedOpportunity.Other_Secondary_Competitor_s__c=LeadtoConvert.Other_Competitor__c;
            }
        }

        convertedOpportunity.Partner_Driven_Deal__c=LeadtoConvert.Passed_to_Partner__c;
        //End of code Updation by Shipra on 8.10.09 for Convert lead Field mapping//
        //Update by Srinivas on 15-Nov-10 defaulting IIG_Sales_Stage__c of convertedOpportunity//
        convertedOpportunity.IIG_Sales_Stage__c = 'Stage-1 Discovery';  
        //End of Update by Srinivas// 
        
        //added by anand on 18/05/2011 for deal reg     
        if(LeadtoConvert.DealReg_Deal_Registration__c == true){
            convertedOpportunity.CurrencyIsoCode = LeadtoConvert.CurrencyIsoCode;
            convertedOpportunity.Originator__c = DealRegistrationSource.DataValue__c;
            convertedOpportunity.Originator_Detail__c= DealRegistrationSourceProgramDetails.DataValue__c;
            convertedOpportunity.Linked_to_Deal_Registration__c = true;
            convertedOpportunity.Related_Deal_Registration__c=LeadtoConvert.Id;
            convertedOpportunity.bypass_validation__c = true;
            convertedOpportunity.VMWare_Related__c  =LeadtoConvert.DealReg_Is_Vmware_related_solution__c;
            if(LeadtoConvert.DealReg_Expected_Close_Date__c != null){
                convertedOpportunity.closeDate = LeadtoConvert.DealReg_Expected_Close_Date__c;
            }
            if(LeadtoConvert.DealReg_Theater__c =='EMEA' || LeadtoConvert.Theater__c =='EMEA'){
                convertedOpportunity.StageName = DealRegistrationOpportunityStage.DataValue__c;
                convertedOpportunity.IIG_Sales_Stage__c = DealRegistrationOpportunityIIGSalesStage.DataValue__c;
            }          
        }      
        //End
    
        insert convertedOpportunity; 
        System.debug('convertedOpportunity----->'+convertedOpportunity.id);

        return convertedOpportunity.id;
    }
    //return Type changed from String to Contact

    //rajeev start
    private static Map<String,Opportunity>  createOpportunity(List<Lead> leadsForOppLst){
        Map<String,Opportunity> convertedOpportunityMap = new Map<String,Opportunity>();
        //Included for  PRM Reqt# 043     
        PRM_CommonUtils utils = new PRM_CommonUtils();
        List<String> userIds = new List<String>();
        Set<String> partnerUserIds = new Set<String>();
        Map<Id, Lead> mapDealreg = new Map<Id, Lead>();
        Map<Id, Lead> mapNonDealreg = new Map<Id, Lead>();
        Map<String,AccountTeamMember> lead_Acc_AccTeamMembersMap = new Map<String,AccountTeamMember>();
        Map<String,AccountTeamMember> NonDealReg_Acc_AccTeamMembersMap = new Map<String,AccountTeamMember>();
        Map<String,AccountTeamMember> DealReg_Acc_AccTeamMembersMap = new Map<String,AccountTeamMember>();
        
        //added by anand on 18/05/2011 for deal reg 
        //fetch record type id for Deal Reg Approved
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c DealRegistrationSource = DataValueMap.get('DealRegistrationSource');
        CustomSettingDataValueMap__c DealRegistrationSourceProgramDetails = DataValueMap.get('DealRegistrationSourceProgramDetails');
        CustomSettingDataValueMap__c DealRegistrationOpportunityStage = DataValueMap.get('DealRegistrationOpportunityStage');
        CustomSettingDataValueMap__c DealRegistrationOpportunityIIGSalesStage = DataValueMap.get('DealRegistrationOppIIGSalesStage');
        //End
        Set<Id> accountIds = new Set<Id>();
        for(Lead nextLead :leadsForOppLst){
            userIds.add(nextLead.OwnerId);
            if(nextLead.DealReg_Deal_Registration__c == true ){
                mapDealreg.put(nextLead.Id, nextLead);
            }else{
                mapNonDealreg.put(nextLead.Id, nextLead);
            }
            if(nextLead.Related_Account__c != null){
                accountIds.add(nextLead.Related_Account__c);
            }           
        }
            
        //get partner user ids 
        partnerUserIds = utils.userType(userIds);
        List<OpportunityIntegration__c> userId = OpportunityIntegration__c.getall().Values();
        
        
        //added by anand on 18/05/2011 for deal reg 
        if(mapDealreg.size() > 0){
            DealReg_Acc_AccTeamMembersMap = PRM_DEALREG_RegistrationConversion.getOpportunityOwner(mapDealreg.values());
        }
        if(mapNonDealreg.size() >0){
            NonDealReg_Acc_AccTeamMembersMap = getOpportunityOwner(mapNonDealreg.values());
        }
        
        if(NonDealReg_Acc_AccTeamMembersMap.size() >0){
            for(String strAccount : NonDealReg_Acc_AccTeamMembersMap.keySet()){
                if(!DealReg_Acc_AccTeamMembersMap.containsKey(strAccount)){
                    DealReg_Acc_AccTeamMembersMap.put(strAccount,NonDealReg_Acc_AccTeamMembersMap.get(strAccount) );    
                }
            }           
        }
        lead_Acc_AccTeamMembersMap  = DealReg_Acc_AccTeamMembersMap;
        System.debug('lead_Acc_AccTeamMembersMap ---> '+ lead_Acc_AccTeamMembersMap);
        //End
        
        Map<Id, Account> mapAccountDetails = new Map<Id, Account>([Select Id,Theater1__c, Name From Account where id in : accountIds]);      
         //uday 246616 
        
        // The Below map will be used in populate opportunity owner trigger to get theaters
        staticMap=mapAccountDetails;
       //uday 246616
        //for loops starts
        for(Lead nextLead :leadsForOppLst){
            System.debug(' nextLead --->' + nextLead);
            Opportunity convertedOpportunity = new Opportunity();
            if(partnerUserIds.contains(nextLead.OwnerId) ){
                if(lead_Acc_AccTeamMembersMap.get(nextLead.Related_Account__c) !=null){
                    convertedOpportunity.OwnerId = lead_Acc_AccTeamMembersMap.get(nextLead.Related_Account__c).UserId ;
                    convertedOpportunity.Name  = mapAccountDetails.get(nextLead.Related_Account__c).Name+'-' +  lead_Acc_AccTeamMembersMap.get(nextLead.Related_Account__c).User.Name ;
                }else if(userId[0] !=null){
                    convertedOpportunity.OwnerId = userId[0].House_Account_User__c;
                    //convertedOpportunity.Name ='House Account';
                    convertedOpportunity.Name = mapAccountDetails.get(nextLead.Related_Account__c).Name + System.Label.House_Account;
                }               
            }
            if(nextLead.DealReg_Deal_Registration__c == false){
                if(convertedOpportunity.name == null && convertedOpportunity.OwnerId ==null){
                    convertedOpportunity.OwnerId=nextLead.OwnerId;
                    convertedOpportunity.Name=mapAccountDetails.get(nextLead.Related_Account__c).Name+'-'+ nextLead.owner.name;
                }
            }else{
                if(convertedOpportunity.name == null && convertedOpportunity.OwnerId ==null){
                    convertedOpportunity.OwnerId = userId[0].House_Account_User__c;
                    //convertedOpportunity.Name ='House Account';
                    convertedOpportunity.Name = mapAccountDetails.get(nextLead.Related_Account__c).Name + '-'+  System.Label.House_Account;
                }
                // Added for WR#177290/177282: Anand Sharma
                convertedOpportunity.Name = mapAccountDetails.get(nextLead.Related_Account__c).Name + ' - DR# '+ nextLead.Lead_Number__c;
            }    
                

            convertedOpportunity.Campaign_Identifier__c=nextLead.Lead_Identifier__c;
            convertedOpportunity.accountid=nextLead.Related_Account__c;
            convertedOpportunity.Campaign_Event_Name__c=nextLead.Campaign_Event_Name__c;
            convertedOpportunity.Originator__c=nextLead.Lead_Originator__c; 
            convertedOpportunity.Sales_Force__c=nextLead.Sales_Force__c;
            convertedOpportunity.Partner__c=nextLead.Partner__c;
            convertedOpportunity.Sales_Channel__c=nextLead.Channel__c;
            convertedOpportunity.Tier_2_Partner__c=nextLead.Tier_2_Partner__c;
            convertedOpportunity.closeDate=System.today()+30;
            convertedOpportunity.StageName='Pipeline';
            convertedOpportunity.Created_via_Convert__c=true;
            convertedOpportunity.Originator_Detail__c= nextLead.Originator_Details__c;
            convertedOpportunity.Other_Originator_Detail__c=nextLead.Other_Originator_Details__c;
            convertedOpportunity.Next_Steps__c=nextLead.Notes_Next_Steps__c;
            convertedOpportunity.CMA_business_need__c=nextLead.CMA_Business_Need__c;
            convertedOpportunity.Other_CMA_business_need__c=nextLead.Other_CMA_Business_Need__c;
            convertedOpportunity.Market_Segment__c=nextLead.Market_Segment__c;
            convertedOpportunity.Decision_Criteria__c=nextLead.Decision_Criteria_Process__c;
            convertedOpportunity.Comments_Details__c=nextLead.Description;
            convertedOpportunity.LeadSource=nextLead.LeadSource;
            //261817 - added ELA field
            convertedOpportunity.ELA2__c = nextLead.ELA2__c;
            

            if(nextLead.Competitors__c!=null){
                if(nextLead.Competitors__c.contains(';')==false){
                    convertedOpportunity.Competitor__c=nextLead.Competitors__c;
                    convertedOpportunity.Other_Primary_Competitor_s__c=nextLead.Other_Competitor__c;
                }

                if(nextLead.Competitors__c.contains(';')==True){
                    convertedOpportunity.Secondary_Competitor_s__c=nextLead.Competitors__c;
                    convertedOpportunity.Other_Secondary_Competitor_s__c=nextLead.Other_Competitor__c;
                }
            }

            convertedOpportunity.Partner_Driven_Deal__c= nextLead.Passed_to_Partner__c;
            //Update by Srinivas on 15-Nov-10 defaulting IIG_Sales_Stage__c of convertedOpportunity//
            convertedOpportunity.IIG_Sales_Stage__c = 'Stage-1 Discovery';  
            //End of Update by Srinivas//
            
            //added by anand on 18/05/2011 for deal reg 
            System.debug(' nextLead.DealReg_Expected_Close_Date__c --->' + nextLead.DealReg_Expected_Close_Date__c);
            if(nextLead.DealReg_Deal_Registration__c == true){
                convertedOpportunity.CurrencyIsoCode = nextLead.CurrencyIsoCode;
                convertedOpportunity.bypass_validation__c = true;
                convertedOpportunity.Originator__c = DealRegistrationSource.DataValue__c;
                convertedOpportunity.Originator_Detail__c= DealRegistrationSourceProgramDetails.DataValue__c;
                convertedOpportunity.Linked_to_Deal_Registration__c = true;
                convertedOpportunity.Related_Deal_Registration__c=nextLead.Id;
                convertedOpportunity.VMWare_Related__c  = nextLead.DealReg_Is_Vmware_related_solution__c;
                if(nextLead.DealReg_Expected_Close_Date__c != null){
                    convertedOpportunity.closeDate = nextLead.DealReg_Expected_Close_Date__c;                   
                }
                if(nextLead.DealReg_Theater__c =='EMEA' || nextLead.Theater__c =='EMEA'){
                    convertedOpportunity.StageName = DealRegistrationOpportunityStage.DataValue__c;
                    convertedOpportunity.IIG_Sales_Stage__c = DealRegistrationOpportunityIIGSalesStage.DataValue__c;
                    //'Stage-3 Solution Overview';
                    
                }
            }
            //End
            
            //adding opportunities here finally 
            convertedOpportunityMap.put(nextLead.Id,convertedOpportunity);
        }

        system.debug('convertedOpportunityMap.values '+convertedOpportunityMap.values());
        //for loop ends
        if(convertedOpportunityMap.size()>0)
            insert convertedOpportunityMap.values();
            system.debug('after Opportunity Ctraetion: convertedOpportunityMap.values '+convertedOpportunityMap.values());
        return convertedOpportunityMap;
    }
    //rajeev end 

    /**
        * Method <createContact()is for creating Contact>
        *   @param <This method is not taking any arguments.> 
        *   @return <Contact> - < Returning created Contact Object.>
        *   @throws exception-<No exception >
    */    
    private static Contact createContact(){
        boolean isContactPresent=false;
        ContactId=null;
        System.debug('LeadtoConvert.email----->'+LeadtoConvert.email);
        //Contact AccountContact=null;
        Contact AccountContact=null;
        
        if( LeadtoConvert.email==null ){
            ContactId= null;
            return AccountContact;
        }
        try{
            // Changed by Arif(177274)
            AccountContact= [Select id,AccountId,Primary_Contact__c, Email, Phone from Contact where Email=:LeadtoConvert.email and active__c = true limit 1];                 
        }catch (QueryException e){
            AccountContact=null;
        }
        System.debug('AccountContact----->'+AccountContact);
        If(AccountContact!=null){
            isContactPresent=true;            
            ContactId=AccountContact.Id;
        //added--------
            return AccountContact;
        }

        //  Contact Convertedcontact=null;
        if(!isContactPresent){
            AccountContact=new Contact();
            AccountContact.Salutation=LeadtoConvert.Salutation;
            AccountContact.FirstName=LeadtoConvert.FirstName;
            AccountContact.LastName=LeadtoConvert.LastName;
            AccountContact.Title= LeadtoConvert.Title;
            //AccountContact.Title_Type__c= LeadtoConvert.Title_Type__c;
            AccountContact.Email= LeadtoConvert.Email;
            AccountContact.Phone= LeadtoConvert.Phone;
            AccountContact.DoNotCall=LeadtoConvert.DoNotCall;
            AccountContact.Ownerid= LeadtoConvert.Ownerid;
            AccountContact.accountid= LeadtoConvert.Related_Account__c;     
            //Code Updated By Shipraa on 8.10.09 for Convert lead Field mapping//
            AccountContact.MailingCity=LeadtoConvert.city;
            AccountContact.MailingStreet=LeadtoConvert.Street;
            AccountContact.MailingState=LeadtoConvert.State;
            AccountContact.MailingCountry=LeadtoConvert.Country;
            AccountContact.MailingPostalCode=LeadtoConvert.PostalCode;
            AccountContact.Title_Classification__c=LeadtoConvert.Title_Classification__c;
            AccountContact.Department=LeadtoConvert.Department__c;
            AccountContact.Role__c=LeadtoConvert.Role__c;
            AccountContact.HasOptedOutOfEmail=LeadtoConvert.HasOptedOutOfEmail;
            AccountContact.MobilePhone=LeadtoConvert.MobilePhone;
            //Updations done for WR-158373 Aprimo To Salesforce Integration.
            AccountContact.Aprimo_AudMem_ID__c = LeadToConvert.Aprimo_AudMem_ID__c;
            //End of Code Updated By Shipraaon 8.10.09 for Convert lead Field mapping//            

            insert (AccountContact);
            ContactId= AccountContact.id;
        }
        return AccountContact;
    }

    //rajeev starts 
    private static Map<String,Contact> createContact(List<Lead> LeadtoContact){
        //boolean isContactPresent=false;
        //ContactId=null;
        
        List<Contact> CnotactstoInsert = new List<Contact>();
        System.Debug('ListOfLeadsToContact--->' +LeadtoContact);
        Map<String,Contact> accountContactMap = new Map<String,Contact>();
        List<String> leadEmails = new List<String>();
        List<Contact> filterContacts = new List<Contact>();
        //get all contact of leads on email matching and active=true 
        for(Lead nextLead :LeadtoContact){
            if(nextLead.Email != null && nextLead.Email != ''){
                leadEmails.add(nextLead.email);
            }            
        }
        if(leadEmails.size() >0){
            filterContacts = [Select id,AccountId,Primary_Contact__c, Email,Active__c ,Partner_Contact__c, Phone from Contact where Email in:leadEmails and active__c = true ];
        }           

        //loop starts 
        Set<String> setContactId = new Set<String>();
        Set<String> setContactEmail = new Set<String>();        
        for(Lead nextLead :LeadtoContact){                               
            Contact AccountContact = null;
            boolean CreateContact=true;
            //changed by Arif(177274)
            for(Contact nextContact :filterContacts){
                if(nextContact.email == nextLead.email && nextContact.active__c ==true){
                    CreateContact = false;
                    break;
                }
                         
            }                
            //  ContactId=AccountContact.Id;
            if(AccountContact == null && CreateContact){
                AccountContact = new Contact();
                AccountContact.Salutation=nextLead.Salutation;
                AccountContact.FirstName=nextLead.FirstName;
                AccountContact.LastName=nextLead.LastName;
                AccountContact.Title= nextLead.Title;
                //AccountContact.Title_Type__c= nextLead.Title_Type__c;
                AccountContact.Email= nextLead.Email;
                AccountContact.Phone= nextLead.Phone;
                AccountContact.DoNotCall=nextLead.DoNotCall;
                if(nextLead.Ownerid != null){
                    AccountContact.Ownerid= nextLead.Ownerid;
                }            
                AccountContact.accountid= nextLead.Related_Account__c;
           
                //Code Updated By Shipraa on 8.10.09 for Convert lead Field mapping//
    
                AccountContact.MailingCity=nextLead.city;
                AccountContact.MailingStreet=nextLead.Street;
                AccountContact.MailingState=nextLead.State;
                AccountContact.MailingCountry=nextLead.Country;
                AccountContact.MailingPostalCode=nextLead.PostalCode;
                AccountContact.Title_Classification__c=nextLead.Title_Classification__c;
                AccountContact.Department=nextLead.Department__c;
                AccountContact.Role__c=nextLead.Role__c;
                AccountContact.HasOptedOutOfEmail=nextLead.HasOptedOutOfEmail;
                AccountContact.MobilePhone=nextLead.MobilePhone;
                //End of Code Updated By Shipraaon 8.10.09 for Convert lead Field mapping//            
                
                //Updations done for WR-158373 Aprimo To Salesforce Integration.
                AccountContact.Aprimo_AudMem_ID__c = nextLead.Aprimo_AudMem_ID__c;
            }                                
            if(AccountContact != null && AccountContact.Id != null){
                if((!setContactId.contains(AccountContact.Id))&& AccountContact.Email != null && (!setContactEmail.contains(AccountContact.Email.toUpperCase()))){                
                    setContactId.add(AccountContact.Id);
                    setContactEmail.add(AccountContact.Email.toUpperCase());
                    accountContactMap.put(nextLead.Id,AccountContact);  
                    
                }
            }else{
                if(AccountContact != null && AccountContact.Email != null && (!setContactEmail.contains(AccountContact.Email.toUpperCase()))){                
                    setContactEmail.add(AccountContact.Email.toUpperCase());
                    accountContactMap.put(nextLead.Id,AccountContact);  
                    // added by prasad
                    CnotactstoInsert.add(AccountContact);                                                                        
                }
                
            }             
            //ContactId= AccountContact.id;
        }
        System.Debug('accountContactMap.values() ---->' + accountContactMap.values());
        // updated by prasad
        if(CnotactstoInsert.size()>0){
              insert CnotactstoInsert;
            //upsert accountContactMap.values();            
        }
        return accountContactMap;
    }
    //rajeev ends 

    /**
        * Method <updateLead()is for Updating the Lead based on lead 'status','contact id','opportunity id' and 'S_Control_Converted' status>
        *   @param <This method is not taking any arguments.> 
        *   @return <void  - < Returning nothing.>
        *   @throws exception-<No exception >
    */    
    private static void updateLead(){
        LeadtoConvert.Status='Converted to Opportunity';
        System.debug('the value of LeadtoConvert.Related_Contact__c '+LeadtoConvert.Related_Contact__c);
        //Defect 665
        if(LeadtoConvert.Related_Contact__c==null)
        {
            LeadtoConvert.Related_Contact__c=ContactId;
        }
        //Defect 665
        LeadtoConvert.Related_Opportunity__c=OpportunityId;    
        LeadtoConvert.S_Control_Converted__c=true;    
        update LeadtoConvert;    
    }

    //rajeev starts 
    private static void updateLead(List<Lead> leadLst , Map<String,Contact> contLst ,Map<String,Opportunity> oppLst){            
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead nextLead :leadLst){
            nextLead.Status='Converted to Opportunity';
            //Defect 665
            if(nextLead.Related_Contact__c==null && contLst.get(nextLead.Id) !=null){
                nextLead.Related_Contact__c= contLst.get(nextLead.Id).Id;
            }
            //Defect 665
            if(oppLst.get(nextLead.Id) !=null)
                nextLead.Related_Opportunity__c= oppLst.get(nextLead.Id).Id;
    
            nextLead.S_Control_Converted__c=true;            
            leadsToUpdate.add(nextLead);
        } 
        //if(leadsToUpdate.size()>0)
            //update leadsToUpdate;    
    }
    //rajeev ends 

    /**
        * Method <getOpportunityOwner()is to get the Owner of the Opportunity >
        *   @param <This method is taking AccountId and Sales_Force__c as arguments.> 
        *   @return <void  - < Returning nothing.>
        *   @throws exception-<No exception >
    */
    public static String getOpportunityOwner(Id AccountId,String SalesForceType){         
        //Get all Users with Sales-Sales Rep role for the Account on the Lead from Account Team
        List<AccountTeamMember> accountTeamMember = [Select a.AccountId, a.Id, a.TeamMemberRole, a.UserId,a.User.Name,a.User.BU_Attribute__c from AccountTeamMember a  where a.AccountId =:AccountId and a.TeamMemberRole='Sales-Sales Rep' order by User.Name];     
        String OpptyOwner;
        List<OpportunityIntegration__c> userId = OpportunityIntegration__c.getall().Values();
        System.debug('accountTeamMember.size()---->'+accountTeamMember.size());
        System.debug('SalesForceType---->'+SalesForceType);
        if(accountTeamMember.size()>0){
            for(AccountTeamMember accountTeam: accountTeamMember){
                System.debug('accountTeam.User.BU_Attribute__c'+accountTeam.User.BU_Attribute__c);
                // Check if the Sales Force on the Lead is EMC, select the user with the BU Attribute containing Core
                if(accountTeam.User.BU_Attribute__c.contains('Core') && SalesForceType=='EMC'){
                    OpptyOwner=accountTeam.UserId;
                    OpportunityOwnerName=accountTeam.User.Name;
                }
                //Check if the Sales Force on the Lead is ESG, select the user with the BU Attribute containing CMA
                else if(accountTeam.User.BU_Attribute__c.contains('CMA') && SalesForceType=='ESG'){
                    OpptyOwner=accountTeam.UserId;
                    OpportunityOwnerName=accountTeam.User.Name;
                } 
                else{
                    OpptyOwner = userId[0].House_Account_User__c;
                    OpportunityOwnerName=System.Label.House_Account;
                }      
            }
        }
        //If No Users found on Account Team then assign the Owner of the Opportunity to be HouseAccountUser
        else{
            //List<OpportunityIntegration__c> userId = OpportunityIntegration__c.getall().Values();
            OpptyOwner = userId[0].House_Account_User__c;
            OpportunityOwnerName=System.Label.House_Account;
        }
        System.debug('OpptyOwner---->'+OpptyOwner);
        return OpptyOwner;
    }


    //rajeev starts 
    public static Map<String,AccountTeamMember> getOpportunityOwner(List<Lead> leadLst){         
       
    List<String> relAccIds = new List<String>();
    Map<String,List<accountTeamMember>> accWithTeamMembersMap = new Map<String,List<accountTeamMember>>();
    Map<String,AccountTeamMember> accWithTeamMemberReturnMap = new   Map<String,AccountTeamMember>();
    //lead with its related account id
    Map<String,Lead> leadWithRelAccMap = new Map<String,Lead> ();

    for(Lead nextLead : leadLst){
        relAccIds.add(nextLead.Related_Account__c);
        leadWithRelAccMap.put(nextLead.Related_Account__c,nextLead);
    }

    //Get all Users with Sales-Sales Rep role for the Account on the Lead from Account Team
    List<AccountTeamMember> accountTeamMember = [Select a.AccountId, a.Id, a.TeamMemberRole, a.UserId,a.User.Name,a.User.BU_Attribute__c from AccountTeamMember a  where a.AccountId in:relAccIds and (a.TeamMemberRole='Sales-Sales Rep' or a.TeamMemberRole='Inside Sales-Sales Rep') order by TeamMemberRole,User.Name];     
    //String OpptyOwner;
    //System.debug('accountTeamMember.size()---->'+accountTeamMember.size());

    for(AccountTeamMember nextMember :accountTeamMember){
        if(accWithTeamMembersMap.get(nextMember.AccountId) !=null)
            accWithTeamMembersMap.get(nextMember.AccountId).add(nextMember);
        else{
            List<AccountTeamMember> accountTeamMemLst = new List<AccountTeamMember>();
            accountTeamMemLst.add(nextMember);
            accWithTeamMembersMap.put(nextMember.AccountId,accountTeamMemLst);
        }
    }

    for(String accId :accWithTeamMembersMap.keySet()){
        for(AccountTeamMember accountTeam: accWithTeamMembersMap.get(accId)){
            // Check if the Sales Force on the Lead is EMC, select the user with the BU Attribute containing Core
            if(accountTeam.TeamMemberRole=='Sales-Sales Rep' && accountTeam.User.BU_Attribute__c.contains('Core') && leadWithRelAccMap.get(accId).Sales_Force__c=='EMC'){
                if(accWithTeamMemberReturnMap.get(accId) ==null || accWithTeamMemberReturnMap.get(accId).TeamMemberRole=='Inside Sales-Sales Rep' )
                    accWithTeamMemberReturnMap.put(accId,accountTeam);
            }
            
            //Check if the Sales Force on the Lead is ESG, select the user with the BU Attribute containing CMA
            else if(accountTeam.TeamMemberRole=='Sales-Sales Rep' && accountTeam.User.BU_Attribute__c.contains('CMA') && leadWithRelAccMap.get(accId).Sales_Force__c =='ESG'){          
                if(accWithTeamMemberReturnMap.get(accId) ==null || accWithTeamMemberReturnMap.get(accId).TeamMemberRole=='Inside Sales-Sales Rep' )
                    accWithTeamMemberReturnMap.put(accId,accountTeam);
                //OpptyOwner=accountTeam.UserId;
                //OpportunityOwnerName=accountTeam.User.Name;
            } 
            else if(accountTeam.TeamMemberRole=='Inside Sales-Sales Rep' ){        
                if(accWithTeamMemberReturnMap.get(accId) ==null)
                    accWithTeamMemberReturnMap.put(accId,accountTeam);
                //OpptyOwner=accountTeam.UserId;
                //OpportunityOwnerName=accountTeam.User.Name;
            }                      
        }
    }
    return accWithTeamMemberReturnMap ;

    }
    //rajeev ends 


    /**
        * Method <deployEMC_ConvertLead()is for Unit Testing>
        *   @param <This method is not taking any arguments.> 
        *   @return <void  - < Returning nothing.>
        *   @throws exception-<No exception >
     */
    /*  public static testmethod void deployEMC_ConvertLead(){

    // EMC_ConvertLead emcConvertLead = new EMC_ConvertLead();
            //Updated Test class for 131548//
            Account acc= new Account(name='Deploy'); 
            Account acc2= new Account(name='Deploy2'); 
        
            insert acc;
        
            Contact contact1 =new Contact(FirstName='John' , LastName='Doe',Email='doe_john@emc.com',accountid=acc.id);
        
            insert contact1;
        
            Lead lead= new Lead(Company='Deploy Lead',LastName='Doe',Related_Account__c=acc.id,Related_Contact__c=contact1.id,email='doe_john1@emc.com');
        
            insert lead;
            Lead leadNext= new Lead(Company='Deploy Lead 2',LastName='Doe 2',Related_Account__c=acc2.id,email='doe_john12@emc.com');
        
            insert leadNext;
            
            convertLead(''+lead.id);
            convertLead(''+leadNext.id);
             
            Opportunity opportunity=new Opportunity(name='test',SO_Number__c='1234',StageName='Pipeline',CloseDate=date.today());
            
            insert opportunity;
            Opportunity opportunity2=new Opportunity(name='test123',SO_Number__c='12345',StageName='Pipeline',CloseDate=date.today());
            
            insert opportunity2;

                       
            EMC_ConvertLead.openActivitiesFromLeadToOpportunity(lead.id,opportunity.id);
            EMC_ConvertLead.openActivitiesFromLeadToOpportunity(leadNext.id,opportunity2.id);
            EMC_ConvertLead.createContactFromLeadToOpportunity(contact1,opportunity.id);
           
//Lead lead=[select id,Channel__c,Campaign_Event_Name__c,S_Control_Converted__c,Description,DoNotCall,Email,FirstName,LastName,LeadSource,Lead_Originator__c,OwnerId,Phone,Related_Account__c,Related_Contact__c,Related_Opportunity__c,Sales_Force__c,Salutation,Status,Tier_2_Partner__c,Partner__c,Title,Title_Type__c from Lead Limit 1 ];
      }*/
    /*
    Method validates and adds the owner of  Lead record to Account Team 
    if the lead owner IS NOT a member of the Related AccountÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¾ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢s Account team. 
    @param leadList: List of Lead records
    */
    public static void validate_createLeadOwnerAccountTeam(List<Lead> leadList){
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Set<Id>> account_AccountTeamMembersMap = new Map<Id,Set<Id>>();//Map to store AccountId and corresponding AccountTeamMember ids.
        List<AccountShare> accShareForInsert =  new List<AccountShare>();  
        List<AccountTeamMember> accTeamMemberInsert =  new List<AccountTeamMember>(); 
        Boolean createAccountTeamFlag =  false;
                
        for(i=0; i<leadList.size(); i++){
            accountIds.add(leadList[i].Related_Account__c);
        }
        
        AccountTeamMember[] accountTeamMembers = [Select Id, AccountId, UserId
                                                    from AccountTeamMember 
                                                    where AccountId in: accountIds];
                                                    
        //Creating AccountId and corresponding AccountTeamMember Id map.
        for(i=0; i<accountTeamMembers.size(); i++){
            if(account_AccountTeamMembersMap.containsKey(accountTeamMembers[i].AccountId)){
                account_AccountTeamMembersMap.get(accountTeamMembers[i].AccountId).add(accountTeamMembers[i].UserId);
            }
            else{
                account_AccountTeamMembersMap.put(accountTeamMembers[i].AccountId, new Set<Id>());
                account_AccountTeamMembersMap.get(accountTeamMembers[i].AccountId).add(accountTeamMembers[i].UserId);
            }
        }
        
        //Processing lead records
        for(i=0; i<leadList.size(); i++){
            createAccountTeamFlag =  false;//Resetting flag
            if(account_AccountTeamMembersMap.get(leadList[i].Related_Account__c)!=null){
                //Lead Owner not present in AccountTeamMembers of related Account 
                if(!(account_AccountTeamMembersMap.get(leadList[i].Related_Account__c).contains(leadList[i].OwnerId))){
                    //Create Account Team
                    createAccountTeamFlag =  true;
                }
            }
            else{
                //Create Account Team
                createAccountTeamFlag =  true;
            }
            if(createAccountTeamFlag == true){
                AccountTeamMember tempActTeamMember = new AccountTeamMember();
                tempActTeamMember.AccountId = leadList[i].Related_Account__c;
                tempActTeamMember.UserId = leadList[i].OwnerId;
                tempActTeamMember.TeamMemberRole = 'Lead Owner';
                accTeamMemberInsert.add(tempActTeamMember);
                
                AccountShare tempAccShare = new AccountShare();
                tempAccShare.AccountId = leadList[i].Related_Account__c;
                tempAccShare.UserOrGroupId = leadList[i].OwnerId;
                tempAccShare.AccountAccessLevel = 'Edit';
                tempAccShare.OpportunityAccessLevel = 'Edit';
                tempAccShare.CaseAccessLevel = 'Edit';
                accShareForInsert.add(tempAccShare);                
            }
        }        
        if(accTeamMemberInsert.size()>0){
            insert accTeamMemberInsert;
            insert accShareForInsert;
        }        
    } 
}