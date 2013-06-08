@isTest
private class MAP_LeadRulePrioirity_TC {

    static testmethod void testPriorityRule() {

        List<RecordType> rectype = [Select r.Id, r.name from RecordType r
                                        where SobjectType = 'Lead_Routing_Rule__c'];
        Map<String, String> rectypeMap = new Map<String, String>(); 
        for (RecordType rec :rectype) {
            rectypeMap.put(rec.name, rec.id);
        }

        Lead_Routing_Rule__c qrule = new Lead_Routing_Rule__c();
        qrule.name = 'Q-TEST';
        qrule.RecordTypeId = rectypeMap.get('Queue Rule');
        qrule.BU__c = 'CORE';
        qrule.Country__c = 'United States';
        qrule.Queue_Name__c = 'ZZZZ_BADQUEUE';  
        Database.SaveResult qinsertResult = Database.insert(qrule, false);
        System.assertEquals(qinsertResult.success, false);
        qrule.Queue_Name__c = 'Lead Routing Batch Queue';   
        qinsertResult = Database.insert(qrule, false);
        //System.assertEquals(qinsertResult.success, true);

        Lead_Routing_Rule__c rule = new Lead_Routing_Rule__c();
        rule.name = 'AT-TEST';
        rule.RecordTypeId = rectypeMap.get('Account Team Rule');
        rule.BU__c = 'CORE';
        rule.Country__c = 'United States';
        rule.Primary_Role__c = 'Sales-Sales Rep';
        rule.Originator_Detail__c = 'Maintenance Tech Refresh Alert';
        rule.Marketing_Lead_Type__c = 'CMA INBOUND PIXTOOL';
        Database.SaveResult insertResult = Database.insert(rule, false);
        System.assertEquals(insertResult.success, false);

        Lead_Routing_Rule_Priority__c priority = new Lead_Routing_Rule_Priority__c();
        priority.name = 'TestPriority';
        priority.Rule_Type__c = 'Account Team Rule';
        priority.Rule_Fields__c = 'BU__c;Country__c;Originator_Detail__c;Marketing_Lead_Type__c';
        priority.Rule_Priority_Number__c = 100;
        insert priority;
        
        insertResult = Database.insert(rule, false);
        System.assertEquals(insertResult.success, true);

        priority.Rule_Type__c = 'Queue Rule';
        Database.SaveResult updateResult = Database.update(priority, false);
        System.assertEquals(updateResult.success, false);
        Database.DeleteResult deleteResult = Database.delete(priority, false);
        System.assertEquals(deleteResult.success, false);
        Database.DeleteResult deleteRule = Database.delete(rule, false);
        if (deleteRule.success) {
            deleteResult = Database.delete(priority, false);
            System.assertEquals(deleteResult.success, true);
        }
        
    }

}