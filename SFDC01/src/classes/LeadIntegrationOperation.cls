// 16 Sept 2010: Bhumika Udani : Mapped 8 new lead fields as part of WR 141132
// 20 Sept 2010: Rahul Arora   WR-146943 restrict user recipients by profile license type
// 20 Sept 2010: Dan Quinn     WR-146983 remove case sensitivity from queue assignment
// UnCommented Version of Code - Version 2 
// 10 March 2011: Worked on for March release WR 158373
// Updated Code :22 March 2011, commented Mapping done for Objective field for Wr 147709. 
// Updated for WR-163733. Break-fix for Aprimo to SFDC Integration--Leads echoing back the aprimo_id
// Updated for WR-163783.September Release. By Shipra Misra --Update Lead wrapper for new DB fields from Aprimo.
//Updated for WR-174616.November Release. By Shipra Misra --Update Lead wrapper for new Department Local fields from Aprimo.
//Updated for eBusiness integration. By Kaustav Debnath -- Update Lead wrapper for new eBiz RFQ/RFI lead record creation.

global class LeadIntegrationOperation
{




    String batchQueueId = null;
    String errorQueueId = null;
    List<QueueSobject> queues = null;
    List<LeadIntegrationResult> results = new List<LeadIntegrationResult>();
    Set<String> owneremails = new Set<String>();
    Set<String> ownerqueues = new Set<String>();
    Set<String> partyids = new Set<String>();
    Set<String> origsysrefs = new Set<String>();
    Set<String> setlicensetypes = new Set<String>();
    //Holds the set of references where Aprimo id is not null. WR-158373
    Set<String> aprimoRefs = new Set<String>();
    List<User> userlist = null;
    List<QueueSobject> queuelist = null;
    Map<String,Lead_Routing_License_Types__c> maplicensetypes = new Map<String,Lead_Routing_License_Types__c>();
    Map<String,String> OSRactivitymap = new Map<String,String>();
    Map<String,User[]> emailtousermap = new Map<String,User[]>();
    Map<String,QueueSobject[]> ownerqueuemap = new Map<String,QueueSobject[]>();
    Map<String,Account> partytoIdmap = new Map<String,Account>();
    Map<String,String> OSRtoLeadmap = new Map<String,String>();
    //Map to hold the Aprimo_Lead_ID & Lead Id. WR-158373
    Map<String,String> AprimotoLeadmap = new Map<String,String>();
    //Set of sucessfull Leads Inserted from Aprimo. For Marketing Q and A. #176284
    Set<String> setSuccessfullAprimoLeadInsert= new Set<String>();
    Map<String,String> mapQuestion= new Map<String,String>();
    Map<String,String> mapAnswer= new Map<String,String>();
    List<Marketing_Q_A__c> lstMarketingQA= new List<Marketing_Q_A__c>();
    
    Lead leadrec = null;
    List<Lead> leadsForInsert = new List<Lead>();
    String osr_key = null;
    String insertError = null;
    String activeuser = null;
    Integer activecount = 0;
    Integer maxDescr = Lead.Description.getDescribe().getLength();
    Integer maxMobile = Lead.mobilephone.getDescribe().getLength();
    Integer maxPhone = Lead.phone.getDescribe().getLength();
    Integer maxTitle = Lead.Title.getDescribe().getLength();
    //174616
    Integer maxDepartmentLoc = Lead.Department_Local__c.getDescribe().getLength();
    //*174616
    Integer maxSlsFrc = Lead.Sales_Force__c.getDescribe().getLength();
    Integer maxBU = Lead.BU__c.getDescribe().getLength();
    Integer maxClass = Lead.EMC_Classification__c.getDescribe().getLength();
    Integer maxOrigDet = Lead.Originator_Details__c.getDescribe().getLength();
    Integer maxSynStat = Lead.Original_Synergy_Status__c.getDescribe().getLength();
    Integer maxCmpEvNm = Lead.Campaign_Event_Name__c.getDescribe().getLength();
    Integer maxChannel = Lead.Channel__c.getDescribe().getLength();
    Integer maxGMDBcust = Lead.GMDB_Customer_ID__c.getDescribe().getLength();
    Integer maxOriginator = Lead.Lead_Originator__c.getDescribe().getLength();
    Integer maxRank = Lead.Lead_Rank__c.getDescribe().getLength();
    Integer maxSource = Lead.LeadSource.getDescribe().getLength();
    Integer maxAudit = Lead.Lead_Routing_Audit_Data__c.getDescribe().getLength();
    Integer maxSvcStd = Lead.Match_Service_Standardization_Status__c.getDescribe().getLength();
    Integer maxSvcClns = Lead.Match_Service_Cleanse_Status__c.getDescribe().getLength();
    Integer maxSvcPost = Lead.Match_Service_Postal_Status__c.getDescribe().getLength();
    Integer maxUrl = Lead.Website.getDescribe().getLength();
    Integer maxSalut = Lead.Salutation.getDescribe().getLength();
    Integer maxSolnInt = Lead.Solution_Interest__c.getDescribe().getLength();
    Integer maxProdInt = Lead.Product_Interest__c.getDescribe().getLength();
    Integer maxFirst = Lead.firstname.getDescribe().getLength();
    Integer maxLast = Lead.lastname.getDescribe().getLength();
    Integer maxCompany = Lead.company.getDescribe().getLength();
    Integer maxStreet = Lead.street.getDescribe().getLength();
    Integer maxCity = Lead.city.getDescribe().getLength();
    Integer maxState = Lead.state.getDescribe().getLength();
    Integer maxZip = Lead.postalcode.getDescribe().getLength();
    Integer maxCountry = Lead.country.getDescribe().getLength();
    Integer maxCountry_c = Lead.country__c.getDescribe().getLength();
    Integer maxLocFirst = Lead.contact_first_name_local__c.getDescribe().getLength(); 
    Integer maxLocLast = Lead.contact_last_name_local__c.getDescribe().getLength();
    Integer maxLocCompany = Lead.company_local__c.getDescribe().getLength();
    Integer maxLocStreet = Lead.street_local__c.getDescribe().getLength();
    Integer maxLocCity = Lead.city_local__c.getDescribe().getLength();
    Integer maxLocState = Lead.state_province_local__c.getDescribe().getLength();
    Integer maxLocZip = Lead.zip_postal_code_local__c.getDescribe().getLength();
    Integer maxLocCountry = Lead.country_local__c.getDescribe().getLength();
    Integer maxExCode = Lead.Routing_Exception_Code__c.getDescribe().getLength();
    /*Code added for eBusiness SFDC Integration*/
    Integer maxEBizRFQRFIID = Lead.eBus_RFQ_ID__c.getDescribe().getLength();
    Integer maxEBizItemsToQuote = Lead.eBus_Items_Quote__c.getDescribe().getLength();
    Integer maxEBizRFQRFIURL = Lead.eBus_RFQRFI_URL__c.getDescribe().getLength();
    Integer maxEBizRequestedPartner = Lead.eBus_Requested_Partner__c.getDescribe().getLength();
    
    Integer maxEBizUserSessionTransaction = Lead.eBus_User_sessionTransaction__c.getDescribe().getLength();
    Integer maxEBizNGOEHybris = Lead.eBus_NGOE_HybrisUserID__c.getDescribe().getLength();
    Integer maxEBizIntegrationSource= Lead.eBus_Integration_Source_ref__c.getDescribe().getLength();
    Integer maxEBizSourceId= Lead.eBus_SourceID__c.getDescribe().getLength();
    Integer maxEBizRequestedPartnerWriteIn= Lead.eBus_Requested_Partner_Write_In__c.getDescribe().getLength();
    
    /*End of Code added for eBusiness SFDC Integration*/
    //added by Shipra on 17.08.2011 for WR 163783.
    Integer maxLocTitle = Lead.Title_Local__c.getDescribe().getLength();
    //commented By Shipra On 22.03.11.
    //Adding new field to capture the Objective as provided by Marketing. WR-147709
    //Integer maxObjective = Lead.Objective__c.getDescribe().getLength();
    //End of Statement commented By Shipra On 22.03.11.
    //Adding new field to capture the Aprimo Aud Mem Id as provided by Aprimo. WR-158373 
    Integer maxAprimoAudMemID=Lead.Aprimo_AudMem_ID__c.getDescribe().getLength();
    //Adding new field to capture the Aprimo Lead Id as provided by Aprimo. WR-158373
    Integer maxAprimoLeadID=Lead.Aprimo_Lead_ID__c.getDescribe().getLength();
    
    // Mapping following new lead fields as part of WR 141132
    Integer maxMarketingCampaign = Lead.Marketing_Campaign__c.getDescribe().getLength();
    Integer maxMarketingSubCampaign = Lead.Sub_Campaign__c.getDescribe().getLength();
    Integer maxSourceCode = Lead.Source_Code__c.getDescribe().getLength();
    Integer maxAlignment = Lead.Alignment__c.getDescribe().getLength();
    Integer maxEmcMarketingContact = Lead.EMC_Marketing_Contact__c.getDescribe().getLength();
    Integer maxAssetDialogStage = Lead.Asset_Dialog_Stage__c.getDescribe().getLength();
    Integer maxAssetURL = Lead.Asset_URL__c.getDescribe().getLength();
    //Event Date doesn't require trimming hence no trimming integer variable
    //Marketing Q and A functionality.#176284
    Integer maxMarketingQuestion = Marketing_Q_A__c.Question__c.getDescribe().getLength();
    Integer maxMarketingAnswer = Marketing_Q_A__c.Answer__c.getDescribe().getLength();
    
    public List<LeadIntegrationResult> LeadIntegration(List<LeadHeader> lead_headers)
    {

        // Get the routing queue ids for batch processing
        queues = [Select q.QueueId, q.Queue.Name from QueueSobject q
                     where SobjectType = 'Lead'
                     and q.Queue.Name in ('Lead Routing Batch Queue', 'Global Routing Exception Queue')
                 ];
        for (Integer i=0; i < queues.size(); i++)
        {
            if ( queues[i].Queue.Name == 'Lead Routing Batch Queue')
            {
                batchQueueId = queues[i].QueueId;
            } else if ( queues[i].Queue.Name == 'Global Routing Exception Queue')
            {
                errorQueueId = queues[i].QueueId;
            }
        }

        // Get sets of the input data fields that will be needed for soql queries
        for (Integer i=0; i < lead_headers.size(); i++)
        {
            if ( lead_headers[i].owner_email != null
                         && lead_headers[i].owner_email != '')
                         {
                owneremails.add(lead_headers[i].owner_email);
            }
            if ( lead_headers[i].sfdc_routing_queue != null
                         && lead_headers[i].sfdc_routing_queue != null)
            {
                ownerqueues.add(lead_headers[i].sfdc_routing_queue);
            }            
            if ( lead_headers[i].party_id != null
                         && lead_headers[i].party_id != '')
            {
                partyids.add(lead_headers[i].party_id);
            }
            if ( lead_headers[i].orig_sys_reference != null
                             && lead_headers[i].orig_sys_reference != '' )
            { 
                origsysrefs.add(lead_headers[i].orig_sys_reference);
                // map of osr to activity ID so we can pass activity ID back to middleware
                if ( lead_headers[i].gmdb_activity_id != null
                         && lead_headers[i].gmdb_activity_id != '' ) 
                {
                    OSRactivitymap.put(lead_headers[i].orig_sys_reference,lead_headers[i].gmdb_activity_id);
                } 
            }
            //WR- 158373
            else
            {
                if ( lead_headers[i].text_field02!= null   && lead_headers[i].text_field02!= '' )
                { 
                    aprimoRefs.add(lead_headers[i].text_field02);
                }
                    
            }
            //End WR-158373
        }

        // Retrieve the set of Lead Routing License Types from custom settings
        maplicensetypes = Lead_Routing_License_Types__c.getAll();
        setlicensetypes = maplicensetypes.keySet();
       
        // Query and create a map of owner_email to users
        // Update the below query to filter on the basis of License Type
        for(User[] Userresults:[select id, isActive, email, Name 
                               from user where email in :owneremails
                               and Profile.UserLicense.Name in :setlicensetypes]) 
       {
            for(User userrec:Userresults)
            {
                if ( emailtousermap.containsKey(userrec.email.toLowerCase()) ) 
                {
                    userlist = emailtousermap.get(userrec.email.toLowerCase());
                    userlist.add(userrec);
                    emailtousermap.put(userrec.email.toLowerCase(), userlist);
                } else 
                {
                    userlist = new List<User>();
                    userlist.add(userrec);
                    emailtousermap.put(userrec.email.toLowerCase(), userlist);
                }
            }
        }

        // Query and create a map of owner_email to QueueSobject
        for(QueueSobject[] queueresults:[Select q.QueueId, q.Queue.Name from QueueSobject q
                                         where SobjectType = 'Lead'
                                         and q.Queue.Name in :ownerqueues]) 
        {
            for(QueueSobject queuerec:queueresults)
            {
                if ( ownerqueuemap.containsKey(queuerec.Queue.Name.toLowerCase()) ) 
                {
                    queuelist = ownerqueuemap.get(queuerec.Queue.Name.toLowerCase());
                    queuelist.add(queuerec);
                    ownerqueuemap.put(queuerec.Queue.Name.toLowerCase(), queuelist);
                } else 
                {
                    queuelist = new List<QueueSobject>();
                    queuelist.add(queuerec);
                    ownerqueuemap.put(queuerec.Queue.Name.toLowerCase(), queuelist);
                }
            }
        }

        // Query and create a map of party_id to accounts 
        for(Account[] Accounts:[Select id, Party_Id__c, Account_Status__c from Account 
                                where Party_Id__c in :partyids
                                and isDeleted != true]) 
        {
            for(Account acct:Accounts)
            {
                partytoIdmap.put(acct.Party_Id__c, acct);
            }
        }
        // Query and create a map of origsysrefs to existing Leads 
        for(Lead[] GMDBLeads:[Select id, Org_System_Reference__c from Lead
                                where Org_System_Reference__c in :origsysrefs]) 
        {
            for(Lead lead:GMDBLeads)
            {
                OSRtoLeadmap.put(lead.Org_System_Reference__c, lead.id);
            }
        }
        //Updated for WR 158373
        for(Lead[] AprimoLeads:[Select id, Aprimo_Lead_ID__c from Lead
                                where Aprimo_Lead_ID__c in : aprimoRefs]) 
        {
          for(Lead lead:AprimoLeads)
          {
            AprimotoLeadmap.put(lead.Aprimo_Lead_ID__c, lead.id);
          }
        }
        //End of update for WR-158373.
        
        for (Integer i=0; i < lead_headers.size(); i++)
        {

            // duplicate check
            if (lead_headers[i].orig_sys_reference != null && lead_headers[i].orig_sys_reference != ''
                        && OSRtoLeadmap.containsKey(lead_headers[i].orig_sys_reference) ) 
            {
                // lead already exists, so we add the lead id to the return results
                osr_key = null;
                if ( OSRactivitymap.containsKey(lead_headers[i].orig_sys_reference) )
                {
                    osr_key = OSRactivitymap.get(lead_headers[i].orig_sys_reference);
                } else 
                {
                    osr_key = lead_headers[i].orig_sys_reference;
                }
                results.add(new LeadIntegrationResult(
                            osr_key,
                            OSRtoLeadmap.get(lead_headers[i].orig_sys_reference),
                            true,
                            null)
                );
                continue;
            } else
            {
                //Updated for Aprimo to lead integration.
                if (lead_headers[i].text_field02 != null && lead_headers[i].text_field02 != ''
                        && AprimotoLeadmap.containsKey(lead_headers[i].text_field02) )
                {
                    // lead already exists, so we add the lead id to the return results
                    //osr_key = null;
                    osr_key = lead_headers[i].text_field02;
                    results.add(new LeadIntegrationResult(
                            osr_key,
                            AprimotoLeadmap.get(lead_headers[i].text_field02),
                            true,
                            null)
                    );
                    continue;
                }else 
                {
                    leadrec = createLeadObject(lead_headers[i]);
                }
            }
            
            // Initial routing logic based on party and recipient provided from source
            if (lead_headers[i].party_id != null && lead_headers[i].party_id != '') 
            {
                if ( partytoIdmap.containsKey(lead_headers[i].party_id) )
                {
                    if (partytoIdmap.get(lead_headers[i].party_id).Account_Status__c == 'Active') 
                    {
                        leadrec.related_account__c = partytoIdmap.get(lead_headers[i].party_id).Id;
                        leadrec.ownerId = batchQueueId;
                    } else 
                    {
                        updateRoutingExCode('Inactive Party ID: ' + lead_headers[i].party_id);
                        leadrec.ownerId = errorQueueId;
                    }
                } else 
                {
                    // query on party_id returned no results
                    updateRoutingExCode('Invalid Party ID: ' + lead_headers[i].party_id);
                    leadrec.ownerId = errorQueueId;
                }
            } else 
            {
                // lead_header party_id was not populated
                leadrec.ownerId = batchQueueId;
            }
            if (lead_headers[i].owner_email != null && lead_headers[i].owner_email != '') 
            {
                if (emailtousermap.containsKey(lead_headers[i].owner_email.toLowerCase())) 
                {
                    if (emailtousermap.get(lead_headers[i].owner_email.toLowerCase()).size() > 1) 
                    {
                        // more than one user with recipient email so chech how many are active
                        userlist = emailtousermap.get(lead_headers[i].owner_email.toLowerCase());
                        activeuser = null;
                        activecount = 0;
                        for (Integer j=0; j < userlist.size(); j++)
                        {
                            if (userlist[j].isActive == true)
                            {
                                activeuser = userlist[j].id;
                                activecount = activecount + 1;
                            }
                        }
                        if (activecount == 0) 
                        {
                            updateRoutingExCode('Multiple Inactive Users with Recipient Email: ' + lead_headers[i].owner_email);
                            leadrec.ownerId = errorQueueId;
                        } else if (activecount == 1) 
                        {
                            // exactly one active user with email so we assign Lead to that user
                            leadrec.ownerId = activeuser;
                        } else 
                        {
                            updateRoutingExCode('Multiple Active Users with Recipient Email: ' + lead_headers[i].owner_email);
                            leadrec.ownerId = errorQueueId;
                        }
                    } else if ( !emailtousermap.get(lead_headers[i].owner_email.toLowerCase())[0].isActive ) 
                    {
                        updateRoutingExCode('Inactive Recipient: '
                                     + emailtousermap.get(lead_headers[i].owner_email.toLowerCase())[0].name);
                        leadrec.ownerId = errorQueueId;
                    } else 
                    {
                        leadrec.ownerId = emailtousermap.get(lead_headers[i].owner_email.toLowerCase())[0].Id;
                    }
                } else 
                {
                    updateRoutingExCode('Invalid Recipient: ' + lead_headers[i].owner_email);
                    leadrec.ownerId = errorQueueId;
                }
            } else if (lead_headers[i].sfdc_routing_queue != null && lead_headers[i].sfdc_routing_queue != '') 
            {
                if ( ownerqueuemap.containsKey(lead_headers[i].sfdc_routing_queue.toLowerCase()) )
                {
                    if (ownerqueuemap.get(lead_headers[i].sfdc_routing_queue.toLowerCase()).size() > 1) 
                    {
                        updateRoutingExCode('Multiple Queues with Name: ' + lead_headers[i].sfdc_routing_queue);
                        leadrec.ownerId = errorQueueId;
                    } else 
                    {
                        leadrec.ownerId = ownerqueuemap.get(lead_headers[i].sfdc_routing_queue.toLowerCase())[0].QueueId;
                    }
                } else 
                {
                    updateRoutingExCode('Invalid Recipient Queue Name: ' + lead_headers[i].sfdc_routing_queue);
                    leadrec.ownerId = errorQueueId;
                }
            }
            leadsForInsert.add(leadrec);
        }


        Database.SaveResult[] insertResults = Database.insert(leadsForInsert, false);

        for (Integer i=0; i < leadsForInsert.size(); i++)
        {
            // add insert results to the results array - insert failures include error message
            insertError = null;
            if (!insertResults[i].success) 
            {
                for (Integer j=0; j < insertResults[i].errors.size(); j++)
                {
                    insertError = insertError
                                    + insertResults[i].errors[j].statusCode + ' '
                                    + insertResults[i].errors[j].message + ' ';
                }
            }
            // for gmdb leads, pass back activity id else pass back the orig_system_reference
            osr_key = null;
            if ( OSRactivitymap.containsKey(leadsForInsert[i].Org_System_Reference__c) )
            {
                osr_key = OSRactivitymap.get(leadsForInsert[i].Org_System_Reference__c);
            } else 
            {
                osr_key = leadsForInsert[i].Org_System_Reference__c;
            }
            //for aprimo leads, pass back the Aprimo Lead Id.
            //Updated for WR-163733. Break-fix for Aprimo to SFDC Integration--Leads echoing back the aprimo_id
            if (osr_key==null)
            {
                if(insertResults[i].success)
                {
                    setSuccessfullAprimoLeadInsert.add(leadsForInsert[i].Aprimo_Lead_ID__c);
                }
            
                if ( AprimotoLeadmap.containsKey(leadsForInsert[i].Aprimo_Lead_ID__c) )
                {
                    osr_key = AprimotoLeadmap.get(leadsForInsert[i].Aprimo_Lead_ID__c);
                } 
                else
                {
                    osr_key = leadsForInsert[i].Aprimo_Lead_ID__c;
                }   
            }
            
            
            results.add(new LeadIntegrationResult(
                                                osr_key,
                                                leadsForInsert[i].id,
                                                insertResults[i].success,
                                                insertError)
            );
        }
        //Add logic for Marketing Q and A.#176284
        for(Integer i=0; i < lead_headers.size(); i++)
        {
            Integer count=0;
            Integer LengthQA=0;
            String strQuestionKey='';
            Integer textStartPositionQuestion;
            Integer textStartPositionAnswer;
            String strAnswerKey='';
            if(lead_headers[i].text_field02==null)continue;
            if(!setSuccessfullAprimoLeadInsert.contains(lead_headers[i].text_field02))continue;
            if(lead_headers[i].text_field06==null || lead_headers[i].text_field07==null)continue;
            String[] arrQuestion = lead_headers[i].text_field06.split('\\|\\|');
            for(Integer j=0; j<arrQuestion.size(); j++)
            {
                if(arrQuestion[j]!=null) 
                {
                    if(arrQuestion[j].length()<maxMarketingQuestion )
                    {
                        LengthQA=arrQuestion[j].length();
                    }
                    else
                    {
                        LengthQA=maxMarketingQuestion;
                    }
                    strQuestionKey= arrQuestion[j].Substring(1,arrQuestion[j].split(' ',2)[0].length());
                    textStartPositionQuestion=strQuestionKey.length()+1;
                    mapQuestion.put(strQuestionKey,arrQuestion[j].Substring(textStartPositionQuestion,LengthQA));
                }
                
                count=++count;
            }
            String[] arrAnswer = lead_headers[i].text_field07.split('\\|\\|');
            for(Integer k=0; k<arrAnswer.size(); k++)
            {
                
                if(arrAnswer[k]!=null)
                {
                    if(arrAnswer[k].length()<maxMarketingAnswer)
                    {
                        LengthQA=arrAnswer[k].length();
                    }
                    else
                    {
                        LengthQA=maxMarketingAnswer;
                    }
                    strAnswerKey= arrAnswer[k].Substring(1,arrAnswer[k].split(' ',2)[0].length());
                    textStartPositionAnswer=strAnswerKey.length()+1;
                    mapAnswer.put(strAnswerKey,arrAnswer[k].Substring(textStartPositionAnswer,LengthQA));
                }
            }
            for(Integer l=1;l<count+1;l++)
            {
                Marketing_Q_A__c objMarQA= new Marketing_Q_A__c();
                objMarQA.Name=String.ValueOf(l);
                objMarQA.Question__c=mapQuestion.get(String.Valueof(l));
                objMarQA.Answer__c=mapAnswer.get(String.Valueof(l));
                objMarQA.Aprimo_Lead_ID__c=lead_headers[i].text_field02;
                lstMarketingQA.add(objMarQA);
            }
        }
        Database.SaveResult[] insertResultsForMarketingQandA = Database.insert(lstMarketingQA, false);
        for (Integer i=0; i < lstMarketingQA.size(); i++)
        {
            // add insert results to the results array - insert failures include error message
            insertError = null;
            if (!insertResultsForMarketingQandA[i].success) 
            {
                for (Integer j=0; j < insertResultsForMarketingQandA[i].errors.size(); j++)
                {
                    insertError = insertError
                                    + insertResultsForMarketingQandA[i].errors[j].statusCode + ' '
                                    + insertResultsForMarketingQandA[i].errors[j].message + ' ';
                }
            }
            // for Aprimo leads, pass back activity id else pass back the orig_system_reference
            osr_key = null;
            if ( AprimotoLeadmap.containsKey(lstMarketingQA[i].Aprimo_Lead_ID__c) )
            {
                osr_key = AprimotoLeadmap.get(lstMarketingQA[i].Aprimo_Lead_ID__c);
            } 
            else
            {
                osr_key = lstMarketingQA[i].Aprimo_Lead_ID__c;
            }   
            results.add(new LeadIntegrationResult(
                                                osr_key,
                                                lstMarketingQA[i].id,
                                                insertResultsForMarketingQandA[i].success,
                                                insertError)
            );
        }//End of Logic for Q and A.
        return results;
    }


    private Lead createLeadObject(LeadHeader ldhdr) 
    {

        Lead ldobj = new Lead();

        // do not trim OSR as this will affect duplicate checking
        ldobj.Org_System_Reference__c = ldhdr.orig_sys_reference;
        ldobj.Accept_Lead__c = false;
        ldobj.Description = trimStr(ldhdr.description, maxDescr);
        ldobj.mobilephone = trimStr(ldhdr.contact_mobile_phone, maxMobile);
        if (ldhdr.contact_phone != null && ldhdr.contact_phone != '') 
        {
            ldobj.phone = trimStr(ldhdr.contact_phone, maxPhone);
        } else if (ldhdr.company_phone_cleansed != null && ldhdr.company_phone_cleansed != '') 
        {
            ldobj.phone = trimStr(ldhdr.company_phone_cleansed, maxPhone);
        } else 
        {
            ldobj.phone = trimStr(ldhdr.company_phone_orig, maxPhone);
        }
        /*Code added for eBusiness SFDC Integration*/
        if (ldhdr.text_field08 != null && ldhdr.text_field08!= '') 
        {
           ldobj.eBus_RFQ_ID__c = trimStr(ldhdr.text_field08, maxEBizRFQRFIID);
           //ldobj.eBus_RFQ_ID__c = ldhdr.number_field01;
        }
        if (ldhdr.text_field09 != null && ldhdr.text_field09 != '') 
        {
           ldobj.eBus_Items_Quote__c = trimStr(ldhdr.text_field09, maxEBizItemsToQuote);
        }
        if (ldhdr.text_field10 != null && ldhdr.text_field10 != '') 
        {
           ldobj.eBus_RFQRFI_URL__c = trimStr(ldhdr.text_field10, maxEBizRFQRFIURL);
        }
        if (ldhdr.text_field11 != null && ldhdr.text_field11 != '') 
        {
           ldobj.eBus_Requested_Partner__c = trimStr(ldhdr.text_field11, maxEBizRequestedPartner);
        }
        if (ldhdr.text_field12 != null && ldhdr.text_field12 != '') 
        {
           ldobj.eBus_Partner_LeadAdmin__c = ldhdr.text_field12; 
        }
        if (ldhdr.text_field13 != null && ldhdr.text_field13 != '') 
        {
           ldobj.eBus_User_sessionTransaction__c = trimStr(ldhdr.text_field13, maxEBizUserSessionTransaction);
        }
        if (ldhdr.text_field14 != null && ldhdr.text_field14 != '') 
        {
           ldobj.eBus_NGOE_HybrisUserID__c = trimStr(ldhdr.text_field14, maxEBizNGOEHybris);
        }
        if (ldhdr.text_field15 != null && ldhdr.text_field15 != '') 
        {
           ldobj.eBus_Integration_Source_ref__c = trimStr(ldhdr.text_field15, maxEBizIntegrationSource);
        }
        if (ldhdr.text_field16 != null && ldhdr.text_field16 != '') 
        {
           ldobj.eBus_SourceID__c = trimStr(ldhdr.text_field16, maxEBizSourceId);
        }
        if (ldhdr.text_field17 != null && ldhdr.text_field17 != '') 
        {
           ldobj.eBus_Requested_Partner_Write_In__c = trimStr(ldhdr.text_field17, maxEBizRequestedPartnerWriteIn);
        }
        /*End of Code added for eBusiness SFDC Integration*/
        // do not trim contact email as this will return formatting errors
        ldobj.Email = ldhdr.email;
        //174616
        ldobj.Department_Local__c=trimStr(ldhdr.text_field05,maxDepartmentLoc);
        //*174616
        //ldobj.Title = trimStr(ldhdr.title, maxTitle);
        ldobj.Sales_Force__c = trimStr(ldhdr.sales_force, maxSlsFrc);
        ldobj.BU__c = trimStr(ldhdr.business_unit, maxBU);
        ldobj.EMC_Classification__c = trimStr(ldhdr.segment, maxClass);
        ldobj.Originator_Details__c = trimStr(ldhdr.originator_details, maxOrigDet);
        ldobj.Original_Synergy_Status__c = trimStr(ldhdr.original_synergy_status, maxSynStat);
        ldobj.Campaign_Event_Name__c = trimStr(ldhdr.campaign_event_name, maxCmpEvNm);
        ldobj.Channel__c = trimStr(ldhdr.channel, maxChannel);
        ldobj.Contract_End_Date__c = ldhdr.contract_end_date;
        ldobj.GMDB_Customer_ID__c = trimStr(ldhdr.gmdb_customer_id, maxGMDBcust);
        ldobj.Lead_Originator__c = trimStr(ldhdr.lead_originator, maxOriginator);
        ldobj.Lead_Rank__c = trimStr(ldhdr.lead_rank, maxRank);
        ldobj.LeadSource = trimStr(ldhdr.leadsource, maxSource );
        ldobj.Lead_Routing_Audit_Data__c = trimStr(ldhdr.audit_data, maxAudit);
        ldobj.Match_Service_Standardization_Status__c = trimStr(ldhdr.matchservice_standardization_status, maxSvcStd);
        ldobj.Match_Service_Cleanse_Status__c = trimStr(ldhdr.matchservice_cleanse_status, maxSvcClns);
        ldobj.Match_Service_Postal_Status__c = trimStr(ldhdr.matchservice_postal_status, maxSvcPost);
        ldobj.Website = trimStr(ldhdr.global_url, maxUrl);
        ldobj.Salutation = trimStr(ldhdr.salutation, maxSalut);
        // do not trim partner field at this time due to routing potential 
        ldobj.Marketing_Identified_Partner__c = ldhdr.partner;
        ldobj.Solution_Interest__c = trimStr(ldhdr.solution_interest, maxSolnInt);
        ldobj.Product_Interest__c = trimStr(ldhdr.product_interest, maxProdInt);
        // Adding 8 new fields for trimming as per WR141132
        ldobj.Asset_URL__c = trimStr(ldhdr.asset_url,maxAssetURL);
        ldobj.Marketing_Campaign__c = trimStr(ldhdr.marketing_campaign, maxMarketingCampaign);
        ldobj.Sub_Campaign__c = trimStr(ldhdr.marketing_sub_campaign, maxMarketingSubCampaign);
        ldobj.Source_Code__c = trimStr(ldhdr.source_code, maxSourceCode);
        ldobj.Alignment__c = trimStr(ldhdr.alignment, maxAlignment );
        ldobj.EMC_Marketing_Contact__c = trimStr(ldhdr.marketing_contact, maxEmcMarketingContact );
        ldobj.Asset_Dialog_Stage__c = trimStr(ldhdr.asset_dialog_stage, maxAssetDialogStage );
        ldobj.Event_Date__c = ldhdr.date_field01;
        //commented By Shipra On 22.03.11.
        //Adding new field to capture the Objective as provided by Marketing. WR-147709
        //ldobj.Objective__c = trimStr(ldhdr.objective, maxObjective);
        //End Of statement commented By Shipra On 22.03.11.
        ldobj.Aprimo_AudMem_ID__c = trimStr(ldhdr.text_field01, maxAprimoAudMemID);
        ldobj.Aprimo_Lead_ID__c = trimStr(ldhdr.text_field02, maxAprimoLeadID);
        
        Boolean useCleansed = false;
        if (ldhdr.country_cleansed != null && ldhdr.country_cleansed != '' ) 
        {
            useCleansed = true;
        }
        //Title doublebyte mapping
        if (ldhdr.text_field03 != null && ldhdr.text_field03 == 'Y') 
        {
            ldobj.Title_Local__c = trimStr(ldhdr.Title, maxLocTitle);
        } else 
        {
            ldobj.Title = trimStr(ldhdr.Title, maxTitle);
        }
        // company doublebyte mappings
        if (ldhdr.unicode_flag_companyname != null && ldhdr.unicode_flag_companyname == 'Y')
        {
            ldobj.company_local__c = trimStr(ldhdr.company_orig, maxLocCompany );
            if (useCleansed) 
            {
                ldobj.company = trimStr(ldhdr.company_cleansed, maxCompany );
            } else 
            {
                ldobj.company = trimStr(('DBLead - ' + ldhdr.company_orig), maxCompany );
            }
        } else 
        {
            if (useCleansed) 
            {
                ldobj.company = trimStr(ldhdr.company_cleansed, maxCompany );
            } else 
            {
                ldobj.company = trimStr(ldhdr.company_orig, maxCompany );
            }
        }

        // contact name doublebyte mappings
        if (ldhdr.unicode_flag_firstname != null && ldhdr.unicode_flag_firstname == 'Y') 
        {
            ldobj.firstname = trimStr( ('DBLead - ' + ldhdr.firstname), maxFirst );
            ldobj.contact_first_name_local__c = trimStr(ldhdr.firstname, maxLocFirst);
        } else 
        {
            ldobj.firstname = trimStr(ldhdr.firstname, maxFirst);
        }
        if (ldhdr.unicode_flag_lastname != null && ldhdr.unicode_flag_lastname == 'Y') 
        {
            ldobj.lastname = trimStr( ('DBLead - ' + ldhdr.lastname), maxLast );
            ldobj.contact_last_name_local__c = trimStr(ldhdr.lastname, maxLocLast);
        } else 
        {
            ldobj.lastname = trimStr(ldhdr.lastname, maxLast );
        }

        // address doublebyte mappings
        if (ldhdr.unicode_flag_address != null && ldhdr.unicode_flag_address == 'Y') 
        {
            ldobj.street_local__c = trimStr(ldhdr.address1_orig, maxLocStreet);
            ldobj.city_local__c = trimStr(ldhdr.city_orig, maxLocCity);
            ldobj.state_province_local__c = trimStr(ldhdr.state_orig, maxLocState);
            ldobj.zip_postal_code_local__c = trimStr(ldhdr.postalcode_orig, maxLocZip);
            ldobj.country_local__c = trimStr(ldhdr.country_orig, maxLocCountry );
            if (useCleansed) 
            {
                String addrconcat = ldhdr.address1_cleansed;
                if (ldhdr.address2_cleansed != null && ldhdr.address2_cleansed != '') 
                {
                    addrconcat = addrconcat + '\n' + ldhdr.address2_cleansed;
                }
                if (ldhdr.address3_cleansed != null && ldhdr.address3_cleansed != '') 
                {
                    addrconcat = addrconcat + '\n' + ldhdr.address3_cleansed;
                }
                if (ldhdr.address4_cleansed != null && ldhdr.address4_cleansed != '') 
                {
                    addrconcat = addrconcat + '\n' + ldhdr.address4_cleansed;
                }
                ldobj.street = trimStr(addrconcat, maxStreet );
                ldobj.city = trimStr(ldhdr.city_cleansed, maxCity );
                ldobj.state = trimStr(ldhdr.state_cleansed, maxState );
                ldobj.postalcode = trimStr(ldhdr.postalcode_cleansed, maxZip );
            }
        } else 
        {
            if (useCleansed) 
            {
                String addrconcat = ldhdr.address1_cleansed;
                if (ldhdr.address2_cleansed != null && ldhdr.address2_cleansed != '') 
                {
                    addrconcat = addrconcat + '\n' + ldhdr.address2_cleansed;
                }
                if (ldhdr.address3_cleansed != null && ldhdr.address3_cleansed != '') 
                {
                    addrconcat = addrconcat + '\n' + ldhdr.address3_cleansed;
                }
                if (ldhdr.address4_cleansed != null && ldhdr.address4_cleansed != '') 
                {
                    addrconcat = addrconcat + '\n' + ldhdr.address4_cleansed;
                }
                ldobj.street = trimStr(addrconcat, maxStreet );
                ldobj.city = trimStr(ldhdr.city_cleansed, maxCity );
                ldobj.state = trimStr(ldhdr.state_cleansed, maxState );
                ldobj.postalcode = trimStr(ldhdr.postalcode_cleansed, maxZip );
            } else 
            {
                ldobj.street = trimStr(ldhdr.address1_orig, maxStreet );
                ldobj.city = trimStr(ldhdr.city_orig, maxCity );
                ldobj.state = trimStr(ldhdr.state_orig, maxState );
                ldobj.postalcode = trimStr(ldhdr.postalcode_orig, maxZip );
            }
        }

        if (useCleansed) 
        {
            ldobj.country = trimStr(ldhdr.country_cleansed, maxCountry );
            ldobj.country__c = trimStr(ldhdr.country_cleansed, maxCountry_c );
        } else 
        {
            ldobj.country = trimStr(ldhdr.country_orig, maxCountry );
            ldobj.country__c = trimStr(ldhdr.country_orig, maxCountry_c );
        }


        return ldobj;
    }

    private void updateRoutingExCode(String message) 
    {
        if (leadrec.Routing_Exception_Code__c != null
                     && leadrec.Routing_Exception_Code__c != '' ) 
        {
            String newmessage = leadrec.Routing_Exception_Code__c + ' ; ' + message;
            leadrec.Routing_Exception_Code__c = trimStr(newmessage, maxExCode );
        } else 
        {
            leadrec.Routing_Exception_Code__c = trimStr(message, maxExCode);
        }
    }
    private String trimStr(String initialString, Integer maxLength) 
    {
        if (initialString == null || initialString == '') 
        {
            return null;
        } else if (initialString.length() <= maxLength) 
        {
            return initialString;
        } else 
        {
            return initialString.substring(0, maxlength);
        }
    }
    /*public List<LeadHeader> leadInformation(List<String> leadSFDCIds) 
    {
        List<LeadHeader> lstHeaderInfo=new List<LeadHeader>();
        if(leadSFDCIds.size()>0)
        {
            List<Lead> lstLead=[select id,Lead_Originator__c,eBus_RFQ_ID__c,Originator_Details__c,Date_Accepted__c,Date_Rejected__c,
                            eBus_Lead_Owner_Org__c,eBus_Lead_Owner_Name__c,eBus_Lead_Owner_Email__c,eBus_Lead_Owner_Phone__c,
                            eBus_Lead_Status__c,Lead_Number__c from Lead where id in :leadSFDCIds];
            if(lstLead!=null && lstLead.size()>0)
            {
                for(Lead leadObj: lstLead)
                {
                    LeadHeader leadHdrObj=new LeadHeader();
                    leadHdrObj.text_field08=leadObj.eBus_RFQ_ID__c;
                    leadHdrObj.originator_details=leadObj.Originator_Details__c;
                    if(leadObj.Date_Accepted__c!=null)
                    {
                        //string testdate = String.valueof(leadobj.Date_Accepted__c.date()).substring(0,10);
                        //System.debug('TestDate-->' +testdate);
                        //Date dateTemp = Date.newInstance(leadObj.Date_Accepted__c.day(),leadObj.Date_Accepted__c.month(),leadObj.Date_Accepted__c.year());
                        //String dateTemp =leadObj.Date_Accepted__c.format('dd/mm/yyyy');
                        Integer day=leadObj.Date_Accepted__c.day();
                        Integer month=leadObj.Date_Accepted__c.month();
                        Integer year=leadObj.Date_Accepted__c.year();
                        String dateTemp=String.valueOf(day)+'/'+String.valueOf(month)+'/'+String.valueOf(year);
                        System.debug('dateTemp-->' +dateTemp);
                        leadHdrObj.text_field15=dateTemp;
                        
                    }
                    if(leadObj.Date_Rejected__c!=null)
                    {
                        //Date dateTemp = Date.newInstance(leadObj.Date_Rejected__c.year(),leadObj.Date_Rejected__c.month(),leadObj.Date_Rejected__c.day());
                        Integer day=leadObj.Date_Rejected__c.day();
                        Integer month=leadObj.Date_Rejected__c.month();
                        Integer year=leadObj.Date_Rejected__c.year();
                        String dateTemp=String.valueOf(day)+'/'+String.valueOf(month)+'/'+String.valueOf(year);
                        System.debug('dateTemp-->' +dateTemp);
                        leadHdrObj.text_field16=dateTemp;
                        
                    }
                    
                    leadHdrObj.text_field09=leadObj.eBus_Lead_Owner_Org__c;
                    leadHdrObj.text_field10=leadObj.eBus_Lead_Owner_Name__c;
                    leadHdrObj.text_field11=leadObj.eBus_Lead_Owner_Email__c;
                    leadHdrObj.text_field12=leadObj.eBus_Lead_Owner_Phone__c;
                    leadHdrObj.text_field13=leadObj.eBus_Lead_Status__c;
                    leadHdrObj.text_field14=leadObj.Lead_Number__c;
                    System.debug('#### leadObj=>'+leadObj.id);
                    System.debug('#### leadHdrObj.text_field08=>'+leadHdrObj.text_field08);
                    System.debug('#### leadHdrObj.originator_details=>'+leadHdrObj.originator_details);
                    System.debug('#### leadObj.Date_Accepted__c=>'+leadObj.Date_Accepted__c);
                    System.debug('#### leadHdrObj.date_field01=>'+leadHdrObj.text_field15);
                    System.debug('#### leadHdrObj.date_field02=>'+leadHdrObj.text_field16);
                    System.debug('#### leadHdrObj.text_field09=>'+leadHdrObj.text_field09);
                    System.debug('#### leadHdrObj.text_field10=>'+leadHdrObj.text_field10);
                    System.debug('#### leadHdrObj.text_field11=>'+leadHdrObj.text_field11);
                    System.debug('#### leadHdrObj.text_field12=>'+leadHdrObj.text_field12);
                    System.debug('#### leadHdrObj.text_field13=>'+leadHdrObj.text_field13);
                    System.debug('#### leadHdrObj.text_field14=>'+leadHdrObj.text_field14);
                    lstHeaderInfo.add(leadHdrObj);
                    
                }
            }                           
            
        }
        return lstHeaderInfo;
    }*/

}