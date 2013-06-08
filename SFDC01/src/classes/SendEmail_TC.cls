//    9 April 2010  Arif                   DEFECT 614  Change 'Campaign_Event_Name_New__c to Campaign_Event_Name__c' 
//  Aug-2011        Saravanan C                 Test Class cleanup
@isTest
private class SendEmail_TC{
    public static testMethod void sendMailSetup() 
    {       
    
        Account acct1 = testclassUtils.getAccount (); 
        
        insert acct1;
        // create Lead
        Lead lead1 = testclassUtils.getLeadrec () ;
         lead1.Related_Account__c = acct1.Id;
        insert lead1;
        
        AH_ChildObjectCounters.resetFlagsForUnitTest(); 

        Lead newLead=new Lead();
        PageReference pageRef = Page.sendmail;
      //  Test.setCurrentPageReference(pageRef);
        
        String key = 'templateName';
        String value = 'Partner Email Template';
        ApexPages.currentpage().getParameters().put(key,value);
        ApexPages.currentpage().getParameters().put('id',lead1.id);
        ApexPages.currentpage().getParameters().put('setSaveAsActivity','true');
        ApexPages.currentpage().getParameters().put('toaddress','kothawade_prasad@emc.com.prod');
        ApexPages.currentpage().getParameters().put('showAllowtoAddReceipent','true');
        System.debug('TemplateName*************'+ApexPages.currentpage().getParameters().get('templateName'));
        sendEmail sendmail01 = new sendEmail();        
        
        boolean isCheck=false;
        List<SelectOption> options1 = sendmail01.getItems();
        for (SelectOption sOp1 : options1)
        {
            if(sOp1.getLabel() =='Contact')
            {
                isCheck = true;
            }            
        }
        
        //Test data
        
        String testContents = 'Contact';
        String testSearchText = 'Test';
        String testMailBody = 'Hello';
        
        
        //Setting Test data
        
        sendmail01.setContents(testContents);
        sendmail01.setSearchText(testSearchText);
        sendmail01.setBody(testMailBody);
        
        //asserting the values
        System.assertEquals(testContents,sendmail01.getContents());
        System.assertEquals(testSearchText,sendmail01.getSearchText());
        System.assertEquals(testMailBody,sendmail01.getBody());
        
        sendmail01.getcontactResults();
        sendmail01.getContactWrap();
        sendmail01.getMailSent();
        sendmail01.getSubject();
        sendmail01.getToAddresses();
        sendmail01.doSearch();
        sendmail01.sendMail();
        sendmail01.cancel();
        sendmail01.getMailSend();
        sendmail01.getRenderAddRecepient();
        sendmail01.getItems();
        sendmail01.getBccEmail();
        sendmail01.addRecepient();
        sendmail01.addingReciepients();
        sendmail01.getlanguages();
        sendmail01.test();
        sendmail01.getSelectedLanguage();
        sendmail01.setSelectedLanguage('test language');
        
        String recipient = sendmail01.addRecepient().getURL();
        System.debug('addRecipient page url'+recipient );
        System.assertEquals('/apex/searchcontacts',recipient );
        
        String RecipientsList = sendmail01.addingReciepients().getURL();
        System.debug('addingRecipients page url'+RecipientsList);
        System.assertEquals('/apex/sendmail',RecipientsList);
        
        String Cancel = sendmail01.cancel().getURL();
        System.debug('Cancel page url'+Cancel);
        System.assertEquals('/apex/sendmail',Cancel);
        
        
        }
    
    }