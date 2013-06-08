@isTest
private class ProfileActionExtender_TC{
    public static testMethod void profileAction() 
    {
        ApexPages.StandardController controller = new ApexPages.StandardController(new ProfileCustom__c());
        ProfileActionExtender profileActionExtender = new ProfileActionExtender(controller );
        profileActionExtender.getSelectedTab();
        String tab='General';
        profileActionExtender.setSelectedTab(tab);
        profileActionExtender.save();
        profileActionExtender.edit();
        profileActionExtender.cancel();
        
    }
}