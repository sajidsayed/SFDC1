// 18 Nov 2010: Dan Quinn WR-152328 Mods for PRM Lead Routing

public class MAP_LeadAssignmentWorker
{    
    private string selectClause, fromClause, whereClause, orderByClause, limitClause;
    private Map<string, string> ruleFieldToLeadFieldMap;
    private Map<string, string> ruleFieldToOperatorMap;
    private List<string> ruleFieldAttributes;
    private ID acctRuleRecTypeId, queueRuleRecTypeId, prmQueueRuleRecTypeId;
    Integer maxExCode = Lead.Routing_Exception_Code__c.getDescribe().getLength();
    
    public MAP_LeadAssignmentWorker(Map<string, string> rflMap, Map<string, string> rfoMap)
    {
        system.debug('Initializing LeadAssignmentWorker ');
        ruleFieldToLeadFieldMap = rflMap;
        ruleFieldToOperatorMap = rfoMap;
        ruleFieldAttributes =  new List<string>();
        ruleFieldAttributes.addAll(ruleFieldToLeadFieldMap.keySet());
        ruleFieldAttributes.sort();
        selectClause = 'SELECT Name, Routing_Rule_Priority_Number__c, RecordTypeId, Primary_Role__c, Queue_ID__c, Secondary_Role__c, Tertiary_Role__c, Last_Assignment_Date__c, ';
        Iterator<string> iter = ruleFieldAttributes.iterator();
        
        String attrName = null;
        do
        {
            attrName = iter.next();
            selectClause += attrName;
            if(iter.hasNext())
            {
                selectClause += ',';
            }            
        }while(iter.hasNext());
        system.debug(selectClause);
        
        acctRuleRecTypeId = MAP_LeadAssignmentUtils.getProfileOptionValue('Account_Rule_Record_Type');
        queueRuleRecTypeId = MAP_LeadAssignmentUtils.getProfileOptionValue('Queue_Rule_Record_Type');
        prmQueueRuleRecTypeId = MAP_LeadAssignmentUtils.getProfileOptionValue('Partner_Queue_Rule_Record_Type');
        system.debug('Record Type IDs: ' + acctRuleRecTypeId + ', ' + queueRuleRecTypeId + ', ' + prmQueueRuleRecTypeId);
    }
    
    public boolean processLead(Lead leadObj)
    {
        system.debug('Processing Lead: ' + leadObj.Name + ', ' + leadObj.Id);
        if(constructDynamicSoql(leadObj))
        {
            if(!applyRules(leadObj))
            {
                System.debug('processLead: applyRules method failed');
                return false;
            }
        }
        else
        {
            System.debug('processLead: constructDynamicSoql method failed');
            return false;
        }
        return true;
    }
    
    public boolean constructDynamicSoql(Lead leadObj)
    {
        fromClause = ' FROM Lead_Routing_Rule__c';
        whereClause = ' WHERE ';
        orderByClause = ' ORDER BY Routing_Rule_Priority_Number__c, Last_Assignment_Date__c ';
        limitClause = ' LIMIT 1';
        
        String leadAttrName = null, operator = null, finalWhereClause = null;
        for(string ruleAttrName: ruleFieldToLeadFieldMap.keySet())
        {
            leadAttrName = ruleFieldToLeadFieldMap.get(ruleAttrName);
            operator = ruleFieldToOperatorMap.get(ruleAttrName);
            whereClause += '(' + handleOperator(leadObj, leadAttrName, ruleAttrName, operator);
            whereClause += ' OR ' + ruleAttrName + ' = NULL ' + ')';
            finalWhereClause = whereClause;
            whereClause += ' AND ';
        }
        whereClause = finalWhereClause;

        if(leadObj.Related_Account__c == null)
         {
            whereClause += 'AND RecordTypeId != \'' + acctRuleRecTypeId + '\' ';
        }

        return true;
    }
    
    public string handleOperator(Lead leadObj, string leadAttrName, string ruleAttrName, string operator)
    {
        if(operator == null)
        {
            System.debug('handleOperator: Operator for attribute - ' + ruleAttrName + ' - not populated');
            throw new EMCException('MAP Fatal Error - handleOperator: Operator for attribute - ' + ruleAttrName + ' - not populated', 'Lead Assignment Batch Process', null);
        }
        operator = operator.toLowerCase();
        string returnValue = ruleAttrName;
        
        // defect 76 - need to escape single quotes that are causing malformed query
        string leadAttrValue = (string)leadObj.get(leadAttrName);
        if(leadAttrValue != null && leadAttrValue != '')
        {
            leadAttrValue = leadAttrValue.trim();
            leadAttrValue = string.escapeSingleQuotes(leadAttrValue);
        }
        
        if(operator == 'equals')
        {
            returnValue += ' = \'' + leadAttrValue + '\' ';
        }
        else if(operator == 'less or equal')
        {
            returnValue += ' <= \'' + leadAttrValue + '\' ';
        }
        else if(operator == 'greater or equal')
        {
            returnValue += ' >= \'' + leadAttrValue + '\' ';
        }
        else if(operator == 'includes')
        {
            returnValue += ' INCLUDES( \'' + leadAttrValue + '\') ';
        }
        else if(operator == 'contains')
        {
            returnValue += ' LIKE \'%' + leadAttrValue + '%\' ';
        }
        else
        {
            System.debug('MAP Fatal Error - handleOperator: Operator for attribute - ' + ruleAttrName + ' - not valid');
            throw new EMCException('handleOperator: Operator for attribute - ' + ruleAttrName + ' - not valid', 'Lead Assignment Batch Process', null);
        }
        
        return returnValue;
    }
    
    public boolean applyRules(Lead leadObj)
    {
        MAP_LeadAssignmentHandler handler = new MAP_LeadAssignmentHandler(leadObj);
        ID routingExceptionQueueId = MAP_LeadAssignmentUtils.getProfileOptionValue('Routing_Exception_Queue_Id');
        string queryString = null;
        Lead_Routing_Rule__c firstMatch = null, secondMatch = null, ruleForUpdate = null;
        boolean isSuccess = true;
        
        queryString = selectClause + fromClause + whereClause + orderByClause + limitClause;
        system.debug('first match query string: ' + queryString);
        try
        {
            firstMatch = Database.query(queryString);
        }
        catch(System.QueryException ex)
        {
            System.debug('applyRules - No rules returned on first pass: Assigned lead to global routing exception queue');
            leadObj.ownerid = routingExceptionQueueId;
            leadObj.Routing_Exception_Code__c = appendExCode(leadObj.Routing_Exception_Code__c,
                                                               'No matching routing rule defined.');
            system.debug('Exception Message: ' + ex.getMessage());
            isSuccess = false;
        }
        if(isSuccess && (firstMatch.recordTypeId == acctRuleRecTypeId))
        {
            System.debug('applyRules - Found an account rule match on the first pass: Rule Id ' + firstMatch.Id);
            if(!handler.handleAccountTeamAssignment(firstMatch))
            {
                leadObj.Routing_Exception_Code__c = appendExCode(leadObj.Routing_Exception_Code__c,
                                                    'No Account Team Member Found - ' + firstmatch.Name);
                System.debug('applyRules - handler failed on account team match: Trying queue rule match');
                whereClause += 'AND RecordTypeId != \'' + acctRuleRecTypeId + '\' ';
                queryString = selectClause + fromClause + whereClause + orderByClause + limitClause;
                system.debug('second match query string: ' + queryString);
                try
                {
                    secondMatch = Database.query(queryString);
                }
                catch(System.QueryException ex)
                {
                    System.debug('applyRules - No rules returned on second match: Assigned lead to global routing exception queue');
                    leadObj.ownerid = routingExceptionQueueId;
                    leadObj.Routing_Exception_Code__c = appendExCode(leadObj.Routing_Exception_Code__c,
                                                            'No matching Queue rule defined.');
                    system.debug('Exception Message: ' + ex.getMessage());
                    isSuccess = false;
                }
                if(isSuccess)
                {
                    System.debug('applyRules - Found a queue rule match on the second pass : Rule Id ' + secondMatch.Id);
                    if(!handler.handleQueueAssignment(secondMatch))
                    {
                        leadObj.ownerid = routingExceptionQueueId;
                        leadObj.Routing_Exception_Code__c = appendExCode(leadObj.Routing_Exception_Code__c,
                                                                'Error while applying Queue Rule');
                        System.debug('applyRules - handler failed on second match too: Assigned lead to global routing exception queue');
                        isSuccess = false;
                    } else {
                        // Account Team assignment failed but Queue assignment successful so we datestamp secondMatch Rule
                        ruleForUpdate = secondMatch;
                        ruleForUpdate.Last_Assignment_Date__c = datetime.now();
                    }
                }
            } else {
                // Account Team assignment successful so we datestamp firstMatch Rule 
                ruleForUpdate = firstMatch;
                ruleForUpdate.Last_Assignment_Date__c = datetime.now();
            }
        }
        else if(isSuccess && ( firstMatch.recordTypeId == queueRuleRecTypeId || firstMatch.recordTypeId == prmQueueRuleRecTypeId ) )
        {
            System.debug('applyRules - Found a queue rule match on the first pass : Rule Id ' + firstMatch.Id);
            if(!handler.handleQueueAssignment(firstMatch))
            {
                leadObj.ownerid = routingExceptionQueueId;
                leadObj.Routing_Exception_Code__c = appendExCode(leadObj.Routing_Exception_Code__c,
                                                                'Error while applying Queue Rule');
                System.debug('applyRules - handler failed on first queue rule match: Assigned lead to global routing exception queue');
                isSuccess = false;
            } else {
                // Queue assignment successful so we datestamp firstMatch Rule
                ruleForUpdate = firstMatch;
                ruleForUpdate.Last_Assignment_Date__c = datetime.now();
            }
        }

        try {
            if (ruleForUpdate != null) {
                update ruleForUpdate;
            }
        } catch (Exception ex) {
            System.debug('Unable to set timestamp on Lead Routing Rule : ' + ruleForUpdate.Id);
        }

        return isSuccess;
    }

    private String appendExCode(String currMessage, String newMessage) {
        String concatMessage;
        if (currMessage != null && currMessage != '' ) {
            concatMessage = currMessage + ' ; ' + newMessage;
        } else {
            concatMessage = newMessage;
        }
        if (concatMessage.length() <= maxExCode ) {
            return concatMessage;
        } else {
            return concatMessage.substring(0, maxExCode);
        }

    }
}