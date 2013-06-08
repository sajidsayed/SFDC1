global class EmployeeIntegrationOperation{
    
    Set<String> mgrBadges = new Set<String>();
    Map<String,String> mgrBadgeToIdMap = new Map<String,String>();
    List<Contact> contactsToProcess = new List<Contact>();
    List<Contact> upsertContacts = new List<Contact>();
    List<Contact> missingMgrContacts = new List<Contact>();
    List<EmpIntegrationResult> results = new List<EmpIntegrationResult>();
    String upsertError = null;
    Integer loopCount = 0;
    
    public List<EmpIntegrationResult> upsertEmployees(List<Contact> EmpDetails){

        try {
        contactsToProcess.addAll(EmpDetails);
        do {
            // reinitialize loop variables
            loopCount = loopCount + 1;
            mgrBadges.clear();
            mgrBadgeToIdMap.clear();
            upsertContacts.clear();
            missingMgrContacts.clear();

            // Get set of manager Badge numbers to use in SOQL query
            for (Integer i=0; i < contactsToProcess.size(); i++){
                if ( contactsToProcess[i].Direct_Manager_Badge__c != null
                            && contactsToProcess[i].Direct_Manager_Badge__c != '' ){
                    mgrBadges.add(contactsToProcess[i].Direct_Manager_Badge__c);
                }
            }
            
            // Create a map of Contact IDs to Badge IDs for the managers 
            for(Contact[] MgrContacts:[Select id, PowerlinkID_Badge__c from Contact where PowerlinkID_Badge__c in :mgrBadges]) {
                for(Contact mgr:MgrContacts){
                    mgrBadgeToIdMap.put(mgr.PowerlinkID_Badge__c, mgr.id);
                }
            }
            
            for (Integer i=0; i < contactsToProcess.size(); i++){
                if ( contactsToProcess[i].Direct_Manager_Badge__c == null ) {
                    // Top level manager will have null ReportsToId
                    contactsToProcess[i].ReportsToId = null;
                    upsertContacts.add(contactsToProcess[i]);
                } else {
                    if ( mgrBadgeToIdMap.containsKey(contactsToProcess[i].Direct_Manager_Badge__c) ) {
                        // manager ID found so we update the employee contact with the ID and add to the upsert array
                        contactsToProcess[i].ReportsToId = mgrBadgeToIdMap.get(contactsToProcess[i].Direct_Manager_Badge__c);
                        upsertContacts.add(contactsToProcess[i]);
                    } else {
                        missingMgrContacts.add(contactsToProcess[i]);
                    }
                }
            }
    
            Database.UpsertResult[] upsertResults 
                        = Database.Upsert(upsertContacts, Contact.PowerlinkID_Badge__c, false);
                        
            for (Integer i=0; i < upsertContacts.size(); i++){
                // add upsert results to the results array upsert failures include error message
                upsertError = null;
                if (!upsertResults[i].success) {
                    upsertError = 'Employee: ' + upsertContacts[i].FirstName + ' ' + upsertContacts[i].LastName + ' ; ';
                    for (Integer j=0; j < upsertResults[i].errors.size(); j++){
                        upsertError = upsertError
                                        + upsertResults[i].errors[j].statusCode + ' '
                                        + upsertResults[i].errors[j].message + ' ';
                    }
                }
                results.add(new EmpIntegrationResult(
                                                    upsertContacts[i].PowerlinkID_Badge__c,
                                                    upsertResults[i].success,
                                                    upsertError)
                );
            }            
    
            contactsToProcess.clear();
            contactsToProcess.addAll(missingMgrContacts);
        }
        while ( upsertContacts.size() > 0 && missingMgrContacts.size() > 0 && loopCount < 3 );

        for (Integer i=0; i < missingMgrContacts.size(); i++){
            // manager ID not found so we add an error to the results array
            results.add(new EmpIntegrationResult(
                            missingMgrContacts[i].PowerlinkID_Badge__c,
                            false,
                            'Employee: ' + missingMgrContacts[i].FirstName + ' ' + missingMgrContacts[i].LastName + ' ; '
                                + 'Manager Not Found with badge ID ' + missingMgrContacts[i].Direct_Manager_Badge__c
                            )
            );
        }

        return results;
        } catch (Exception ex) {
            results.add(new EmpIntegrationResult( null,false,ex.getMessage() ) );
            return results;
        }
    }
    
}