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
@isTest
private class TC_PRM_JobFactory {

    static testMethod void JobFactoryTest() {
        String Theater='Americas';
        String Level = 'All';
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        PRM_JobFactory facotry = new PRM_JobFactory();
        facotry.getStagingTheaterJob();
        facotry.getEducationMasterJob();
        facotry.getVPPJobs(Theater,Level);
        facotry.getRollupJob(Theater);
        facotry.getEducationMatchingJobs(Theater);
        facotry.getPartnerLevrageJobs(Theater);
        //facotry.getVPPRuleEvaluaterJob( Theater,'Partner_Grouping','All');
        facotry.getPanVPPBuildVRRJobs( Theater,'Partner_Grouping_Logical_Block');
        facotry.getFunctionalAreaJob(Theater);
        PRM_JobFactory.loglimits('PRM_VPP_VelocityRuleResultJob1');
    }
    

    static testMethod void JobFactoryTest2() {
        String Theater='All';
        String Level = 'All';
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        PRM_JobFactory facotry = new PRM_JobFactory();
        facotry.getStagingTheaterJob();
        facotry.getEducationMasterJob();
        facotry.getVPPJobs(Theater,Level);
        facotry.getRollupJob(Theater);
        facotry.getEducationMatchingJobs(Theater);
        facotry.getPartnerLevrageJobs(Theater);
        //facotry.getVPPRuleEvaluaterJob( Theater,'Partner_Grouping','All');
        facotry.getPanVPPBuildVRRJobs( Theater,'Partner_Grouping_Logical_Block');
        facotry.getFunctionalAreaJob(Theater);
    }

    static testMethod void JobFactoryTestLevelCountry() {
        String Theater='All';
        String Level = 'Country';
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        PRM_JobFactory facotry = new PRM_JobFactory();
        facotry.getStagingTheaterJob();
        facotry.getEducationMasterJob();
        facotry.getVPPJobs(Theater,Level);
        facotry.getRollupJob(Theater);
        facotry.getEducationMatchingJobs(Theater);
        facotry.getPartnerLevrageJobs(Theater);
        //facotry.getVPPRuleEvaluaterJob( Theater,'Partner_Grouping','All');
        facotry.getPanVPPBuildVRRJobs( Theater,'Partner_Grouping_Logical_Block');
        facotry.getFunctionalAreaJob(Theater);
    }
    static testMethod void JobFactoryTestLevelLogicalBlock() {
        String Theater='All';
        String Level = 'Logical Block';
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        PRM_JobFactory facotry = new PRM_JobFactory();
        facotry.getStagingTheaterJob();
        facotry.getEducationMasterJob();
        facotry.getVPPJobs(Theater,Level);
        facotry.getRollupJob(Theater);
        facotry.getEducationMatchingJobs(Theater);
        facotry.getPartnerLevrageJobs(Theater);
        //facotry.getVPPRuleEvaluaterJob( Theater,'Partner_Grouping','All');
        facotry.getPanVPPBuildVRRJobs( Theater,'Partner_Grouping_Logical_Block');
        facotry.getFunctionalAreaJob(Theater);
    }
    static testMethod void JobFactoryTestLevelPANTheater() {
        String Theater='All';
        String Level = 'PAN Theater';
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];                   
        System.runAs(insertUser){
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        } 
        PRM_JobFactory facotry = new PRM_JobFactory();
        facotry.getStagingTheaterJob();
        facotry.getEducationMasterJob();
        facotry.getVPPJobs(Theater,Level);
        facotry.getRollupJob(Theater);
        facotry.getEducationMatchingJobs(Theater);
        facotry.getPartnerLevrageJobs(Theater);
        //facotry.getVPPRuleEvaluaterJob( Theater,'Partner_Grouping','All');
        facotry.getPanVPPBuildVRRJobs( Theater,'Partner_Grouping_Logical_Block');
        facotry.getFunctionalAreaJob(Theater);
    }

}