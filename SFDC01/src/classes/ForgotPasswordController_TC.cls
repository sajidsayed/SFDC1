@isTest
Private Class ForgotPasswordController_TC{
    Private static testMethod void startTest(){
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'test@salesforce.com';        
    
        System.assertEquals(controller.forgotPassword(),null); 
    }
}