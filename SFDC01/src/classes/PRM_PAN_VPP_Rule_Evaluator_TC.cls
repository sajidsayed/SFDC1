@isTest
 private class PRM_PAN_VPP_Rule_Evaluator_TC{
     public static testMethod void testPANMethods(){
            list<Account_Groupings__c> lstGrouping = new list<Account_Groupings__c>(); 
            Map<Id,List<Account>> mapAccount = new Map<Id,List<Account>>();
            list<Id> lstGroupingId = new list<Id>();
            Map<Id,List<Account_Groupings__c>> mapGrouping = new Map<Id,List<Account_Groupings__c>>();
            list<Velocity_Rule_Results__c> lstVelocityRuleResult = new list<Velocity_Rule_Results__c>();
            list<Velocity_Rules__c> lstVelocityRule = new list<Velocity_Rules__c>();
            PRM_PAN_VPP_VelocityRuleResultsUtils PANVelocityRuleResultsUtils = new PRM_PAN_VPP_VelocityRuleResultsUtils();
            PRM_PAN_VPP_VelocityRuleResults PANVelocityRuleResults = new PRM_PAN_VPP_VelocityRuleResults();
            PRM_PAN_VPP_RuleEvaluator PANRuleEvaluator = new PRM_PAN_VPP_RuleEvaluator();
            List <EMCException> errors = new List <EMCException>();
            errors.add(new EMCException('Test Error Message','1111',new list<string>{'test1','test2'}));
            Account_Groupings__c PAN = PRM_PAN_VPP_TestClassHelper.CreatePANGrouping();
            Account_Groupings__c LogicalBlock = PRM_PAN_VPP_TestClassHelper.CreateLogicalGrouping(PAN);
            Account ProfiledAccount = PRM_PAN_VPP_TestClassHelper.createProfiledAccount();
            Account_Groupings__c Grouping = PRM_PAN_VPP_TestClassHelper.CreateCountryGrouping(ProfiledAccount,LogicalBlock);
            lstVelocityRule = PRM_PAN_VPP_TestClassHelper.CreatePanVelocityRule();
            lstVelocityRule = PRM_PAN_VPP_TestClassHelper.CreateLogicalBlockVelocityRule();
            lstGrouping.add(LogicalBlock);
            lstGroupingId.add(LogicalBlock.Id);
            Test.StartTest();
            
            lstVelocityRuleResult = PANVelocityRuleResults.createLogicalBlockVelocityRuleResults(lstGrouping);
            PANRuleEvaluator.evaluateLogicalBlockVelocityRulesUsingRule(lstVelocityRuleResult);
            PANRuleEvaluator.evaluateLogicalBlockVelocityRulesUsingRulewitherrors(lstVelocityRuleResult,'2222',errors);
            mapAccount = PANVelocityRuleResultsUtils.getProfiledAccountUnderLogicalBlock(lstGroupingId);
            lstGrouping.clear();
            lstGroupingId.clear();
            lstGrouping.add(PAN);
            lstGroupingId.add(PAN.Id);
            lstVelocityRuleResult = PANVelocityRuleResults.createPANLevelVelocityRuleResults(lstGrouping);
            PANRuleEvaluator.evaluatePanVelocityRulesUsingRule(lstVelocityRuleResult);
            PANRuleEvaluator.evaluatePanVelocityRulesUsingRulewitherrors(lstVelocityRuleResult,'3333',errors);
            mapAccount = PANVelocityRuleResultsUtils.getProfiledAccountUnderPANLevel(lstGroupingId);
            mapGrouping = PANVelocityRuleResultsUtils.getLogicalBlockUnderPAN(lstGroupingId);
            Test.StopTest();
    }
}