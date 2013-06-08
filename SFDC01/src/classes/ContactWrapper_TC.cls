/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              Initial Creation.
 |  Aug-2011        Saravanan C         		Test Class cleanup
 |  
 +===========================================================================*/
@isTest
private class ContactWrapper_TC { 
    static testMethod void contactWrapper()
    {        
        Contact contact = testclassUtils.getContact(); 
        ContactWrapper contactWrap = new ContactWrapper(contact);
        boolean checked=false;
        contactWrap.getChecked();
        contactWrap.getContact();
        contactWrap.setContact(contact);
        contactWrap.setChecked(checked);
        
    }
}