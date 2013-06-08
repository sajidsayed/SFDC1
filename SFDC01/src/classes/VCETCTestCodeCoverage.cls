@isTest

private class VCETCTestCodeCoverage
{
    static VCEStatic__c taskRecType = VCEStatic__c.getInstance('VCETaskRecordType');
    static VCEStatic__c caseRecType = VCEStatic__c.getInstance('VCECaseRecordType');

    static testMethod void testCaseSharing()
    {
        Case c = new Case();
        c.Origin = 'EMC';
        c.Status = 'Assigned - Relief';
        c.Subject = 'Case 001 ' + System.DateTime.now();
        c.VCE_Last_Modifying_Partner__c = 'EMC';
        c.VCE_Originator_Open_Date__c = System.DateTime.now();
        c.VCE_Theater__c = 'EMEA';
        c.Priority = 'S1';
        c.RecordTypeId = caseRecType.Value__c;
        insert c;        
    }
        
    static testMethod void testCaseSetTransfer()
    {
        String subject = 'Case 001 ' + DateTime.newInstance(2010,12,1).date();
        Case c = new Case();
        c.Origin = 'EMC';
        c.Status = 'Assigned - Relief';
        c.Subject = subject;
        c.VCE_Last_Modifying_Partner__c = 'EMC';
        c.VCE_Originator_Open_Date__c = System.DateTime.now();
        c.VCE_Theater__c = 'EMEA';
        c.Priority = 'S1';
        c.RecordTypeId = caseRecType.Value__c;
        insert c;        
       
        c = [select VCE_Transfer__c from Case where Subject = :subject];       
        System.assertEquals(c.VCE_Transfer__c,true);        
    }
    
    static testMethod void testTaskSharing()
    {
        String subject = 'Case 001 ' + DateTime.newInstance(2010,12,1).date();
        Case c = new Case();
        c.Origin = 'CISCO';
        c.Status = 'Assigned - Relief';
        c.Subject = subject;
        c.VCE_Last_Modifying_Partner__c = 'CISCO';
        c.VCE_Originator_Open_Date__c = System.DateTime.now();
        c.VCE_Theater__c = 'EMEA';
        c.Priority = 'S1';
        c.RecordTypeId = caseRecType.Value__c;
        
        insert c;
        
        c = [select Id from Case where Subject = :subject];
        
        String taskSubject = 'Task 001 ' + DateTime.newInstance(2010,12,1).date();   
        Task t = new Task();
        t.VCE_Assigned_To__c = 'EMC';
        t.Subject = taskSubject;
        t.Status = 'New';
        t.Priority = 'Normal';
        t.VCE_Last_Modifying_Partner__c = 'EMC';
        t.RecordTypeId = taskRecType.Value__c;
        t.WhatId = c.Id;
        //11-Sep-20101: Added "Type" field as test class was failing in the Sep Release Migration fue to Custom Validation error: "FIELD_CUSTOM_VALIDATION_EXCEPTION, You must enter a value:"
        t.Type = 'Action Item';
        System.debug('T>WHATID :' + t.WhatId + 'CASE>ID :' + c.Id);
        insert t;
        System.debug('T>WHATID :' + t.WhatId);
        t.subject='update';
        update t;
    }
    
    static testMethod void testVCECaseNotesSharing()
    {
        String subject = 'Case 001 ' + DateTime.newInstance(2010,12,1).date();
        Case c = new Case();
        c.Origin = 'EMC';
        c.Status = 'Assigned - Relief';
        c.Subject = subject;
        c.VCE_Last_Modifying_Partner__c = 'EMC';
        c.VCE_Originator_Open_Date__c = System.DateTime.now();
        c.VCE_Theater__c = 'APJ';
        c.Priority = 'S1';
        c.RecordTypeId = caseRecType.Value__c;
        insert c;
        
        c = [select Id from Case where Subject = :subject];

        VCECaseNote__c note = new VCECaseNote__c();
        note.Case_Comments__c = 'New VCE Case Notes';
        note.Creation_Date__c = System.Datetime.now();
        note.Note_Type__c = 'Dial Out Connect';
        note.Visibility__c = true;
        note.case__c = c.Id;
        System.debug('case__c :' + note.case__c + 'c.Id :' + c.Id);
        insert note;
    }
    
    static testMethod void testVCEAttachmentLinkSharing()
    {
    
        String subject = 'Case 001 ' + DateTime.newInstance(2010,12,1).date();
        Case c = new Case();
        c.Origin = 'CISCO';
        c.Status = 'Assigned - Relief';
        c.Subject = subject;
        c.VCE_Last_Modifying_Partner__c = 'CISCO';
        c.VCE_Originator_Open_Date__c = System.DateTime.now();
        c.VCE_Theater__c = 'EMEA';
        c.Priority = 'S1';
        c.RecordTypeId = caseRecType.Value__c;
        insert c;
        
        c = [select Id from Case where Subject = :subject];
    
        VCEAttachmentLink__c link = new VCEAttachmentLink__c();
        link.url__c = 'www.google.co.in' ;
        link.Attached_By__c = 'CISCO';
        link.Case__c = c.Id;
        insert link;
    }
    
    static testMethod void testAttachmentSharing()
    {
        String subject = 'Case 001 ' + DateTime.newInstance(2010,12,1).date();
        Case c = new Case();
        c.Origin = 'CISCO';
        c.Status = 'Assigned - Relief';
        c.Subject = subject;
        c.VCE_Last_Modifying_Partner__c = 'CISCO';
        c.VCE_Originator_Open_Date__c = System.DateTime.now();
        c.VCE_Theater__c = 'EMEA';
        c.Priority = 'S1';
        c.RecordTypeId = caseRecType.Value__c;
        insert c;
                
        c = [select Id from Case where Subject = :subject];
    
        Attachment attach = new Attachment();
        attach.Body = Blob.valueOf('D:\\Documents and Settings\\chetan.pravin.gupta\\Desktop\\Work and Trig.txt');
        attach.Name = 'New Attachment';
        attach.ParentId = c.Id; 
        insert attach;
    }

}