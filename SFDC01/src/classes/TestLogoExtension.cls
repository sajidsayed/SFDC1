@IsTest
private with sharing class TestLogoExtension {

    private static Blob generateRandomBlob(){
        return EncodingUtil.base64Decode(''+System.currentTimeMillis()+Math.roundToLong(Math.random()*10000));  
    }

    private static testmethod void testInvalidPageFlow1(){
        Account testAccount = new Account(name='test123');
        LogoExtension controller = new LogoExtension(new ApexPages.StandardController(testAccount));
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals(LogoExtension.INVALID_PAGE_FLOW,controller.error);
        System.assertEquals(true,controller.errorOccurred);
    }

    private static testmethod void testInvalidPageFlow2(){
        Logo__c logo = new Logo__c();
        Account testAccount = new Account(name='test123');
        insert testAccount; 
        PageUtils.put('accountId',testAccount.id + 'xyz');
        LogoExtension controller = new LogoExtension(new ApexPages.StandardController(logo));
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals(LogoExtension.INVALID_PAGE_FLOW,controller.error);
        System.assertEquals(true,controller.errorOccurred);
    }

    private static testmethod void testEditLogo(){
        Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        insert logo; 
        Attachment attach = new Attachment(
            Body=generateRandomBlob(),
            ContentType='txt',
            IsPrivate=false,
            Name='test.txt',
            ParentID=logo.id);
        insert attach;
        Account testAccount = new Account(name='test123',logo__c = logo.id);
        insert testAccount; 
        
        LogoExtension controller = new LogoExtension(new ApexPages.StandardController(logo));
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals(null,controller.error);
        System.assertEquals(false,controller.errorOccurred);
        System.assertNotEquals(null,controller.account);
        System.assertEquals(testAccount.id,controller.account.id);
        System.assertNotEquals(null,controller.logoRecord);
        System.assertEquals(logo.id,controller.logoRecord.id);
        System.assertNotEquals(null,controller.logoAttachment);
        System.assertEquals(attach.id,controller.logoAttachment.id);

        final Blob newBlob = generateRandomBlob();
        final String newFilename = 'test123.txt';
        controller.attachmentContentType = 'txt';
        controller.attachmentFileName = newFilename;
        controller.attachmentFile = newBlob;
        System.assertEquals(null,controller.doReplaceLogo());

        attach = [select body,name from Attachment where parentid = :logo.id];
        System.assertEquals(newFilename,attach.name);
        //System.assertEquals(newBlob.toString(),attach.body.toString());
    }

    private static testmethod void testCreateLogo(){
        Logo__c logo = new Logo__c();
        Account testAccount = new Account(name='test123');
        insert testAccount; 
        PageUtils.put('accountId',testAccount.id);
        LogoExtension controller = new LogoExtension(new ApexPages.StandardController(logo));
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals(null,controller.error);
        System.assertEquals(false,controller.errorOccurred);
        System.assertNotEquals(null,controller.account);
        System.assertEquals(testAccount.id,controller.account.id);
        System.assertEquals(logo,controller.logoRecord);
        System.assertEquals(null,controller.logoAttachment);

        final Blob newBlob = generateRandomBlob();
        final String newFilename = 'test123.txt';
        controller.attachmentContentType = 'txt';
        controller.attachmentFileName = newFilename;
        controller.attachmentFile = newBlob;
        System.assertEquals(null,controller.doReplaceLogo());

        Attachment attach = [select body,name from Attachment where parentid = :logo.id];
        System.assertEquals(newFilename,attach.name);
       // System.assertEquals(newBlob.toString(),attach.body.toString());
    }

    private static testmethod void testCreateLogoWithOrphanedLogo(){
        Logo__c logo = new Logo__c();
        logo.name = 'test.txt';
        Logo__c logo2 = new Logo__c();
        logo2.name = 'test2.txt';
        insert logo2; 
        Account testAccount = new Account(name='test123',logo__c = logo2.id);
        insert testAccount; 
        PageUtils.put('accountId',testAccount.id);
        LogoExtension controller = new LogoExtension(new ApexPages.StandardController(logo));
        PageReference next = controller.doOnLoad();
        System.assertNotEquals(null,next);
        controller.doReturn();
        controller.doCancel();
        //System.assertEquals('/' + logo2.id,next.getUrl());
    }
}