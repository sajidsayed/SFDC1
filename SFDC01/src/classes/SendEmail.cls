/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 | 24-Aug-09  Ashwini Gowda           sendEmail will be used to send Email based
                                        on the EmailTemplate              
 |                      
 | 27-Aug-09   Parvinder Sing
 |  28-Aug-09   Prasad Kothawade  
 |  19-May-10   Saravanan.C   	  133981  Localized Partner Email  
 |  17-Jun-10   Saravanan.C  		  139311  Fix for "IB Correction Request" link generates an error  
 |  02-Aug-10   Shipra Misra 		  Checked in this file with new name in harvest "SendEmail" with 0th version
				    		  Previous version of same file was sendEmail.cls with version 5.                        
 +===========================================================================*/

public class SendEmail
{

    public boolean getRenderAddRecepient() {
        return renderAddRecepient;
    }

    private string body;
    private static Boolean mailSent;
    private EmailTemplate email;
    String subject;
    String searchText;
    String Contents;
    String retObject;
    List<Contact> contactResults;
    List<ContactWrapper> contactWrap= new List<ContactWrapper>();
    String relatedObjectId='';    
    Set<String> values = new Set<String>();
    Set<String> userValues = new Set<String>();
    List<String> toAddresses = new List<String>();
    String[] contactsList = new String[]{};
    String[] contactsList1 = new String[]{};
    boolean renderAddRecepient=false;
    public class MailException extends Exception {}
    boolean mailSend=false;
    //Fix for defect #216
    String BccEmail = ApexPages.currentpage().getParameters().get('bcc');
    Partner_Email_Template__c localeLanguage = new Partner_Email_Template__c();
    String ActivitySubject;
    
    public String  SelectedLanguage='Partner Email Template English';
    public list<EmailTemplate> collections = new list<EmailTemplate>();
    map<string,string> map_language = new map<string,string>();
    public user u = new user();
    String templateName;
    
   
    public Boolean showSelectOption{ get; set; }

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Contact','Contact'));
        //options.add(new SelectOption('User','User'));
        //options.add(new SelectOption('Partner Contacts','Partner Contacts'));
        return options;
    }
    
    public List<SelectOption> getlanguages() {
        List<SelectOption> options = new List<SelectOption>();
       for( EmailTemplate a: collections){
           if(a.name.contains(localeLanguage.language__c)){
            options.add(new SelectOption(a.name,(a.name).substring(22)));
            }
        }
        for( EmailTemplate a: collections){
           if(!a.name.contains(localeLanguage.language__c)){
            options.add(new SelectOption(a.name,(a.name).substring(22)));
            }
        }
        return options;
    }
    /*Getters and Setters used*/
    public String  getSelectedLanguage() {
    return SelectedLanguage;
    }
            
    public void setSelectedLanguage(String  SelectedLanguage) {
        this.SelectedLanguage = SelectedLanguage;
        system.debug('Inside '+SelectedLanguage);
    }
    public String getContents() {
        return Contents;
    }
    
    public void setContents(String Contents) {
        this.Contents = Contents;    
    }
    
    public String getSearchText() {
        return searchText;
    }
    
    public void setSearchText(String s) {
        searchText = s;
    }
        
    public List<Contact> getcontactResults() {    
        return contactResults;    
    }
         
    public List<ContactWrapper> getContactWrap()
    {
        return contactWrap;
    }
    

    public String getBody()
    {
        return body ;
    }
    public void setBody(String mailBody)
    {
        this.body =mailBody;
    }
    public Boolean getMailSent()
    {
        return sendEmail.mailSent;
    }
    public String getSubject()
    {
        return subject;
    }
    public List<String> getToAddresses()
    {
        return toAddresses;
    }
    //Fix for defect #216

    public String getBccEmail()
    {
        return BccEmail;
    }
    //End of Fix for defect #216

        // The doSearch method will query User or Contact object based on the Contents
    public PageReference doSearch() {
        
        contactResults=null;
        if(searchText==''||searchText.length()<=1)
        {
            searchText='a%';
        }
        
        {       
          
            contactResults=(List<Contact>)[select  name, Email, Phone from Contact where name like :(searchText+'%') OR Lastname like :(searchText+'%') Limit 1000];
            contactWrap.clear();
            for(Contact con:contactResults)
            {
                contactWrap.add(new ContactWrapper(con));
            }
        }
        return null;
        }                       
             
  public pagereference test(){
   system.debug('Inside test'+SelectedLanguage);
      init();
  return null;
  }     
        
        /*Send Mail Constructor
        Invocation Point- On invocation of the link.
        Description- Constuctor is used to initialize the merge fields.
        */     

    public sendEmail()
    { 
    templateName =  ApexPages.currentpage().getParameters().get('templateName');
    system.debug('templateName ===> ' +templateName );
       u = [Select LanguageLocaleKey From User u where id =: UserInfo.getUserId()];
        localeLanguage = Partner_Email_Template__c.getinstance(u.LanguageLocaleKey);
        system.debug('custom settings===>'+localeLanguage.language__c);
     collections =   [Select Name from EmailTemplate  where name like:('partner email template %') order by name ];
     selectedLanguage = 'partner email template '+localeLanguage.language__c;
      system.debug('selectedLanguage ===> ' +selectedLanguage );
        init();
     }
    Public void init(){ 
         system.debug(' selectedLanguage '+selectedLanguage);
        relatedObjectId=ApexPages.currentPage().getParameters().get('id');
        sendEmail.mailSent=false;

       
        //Query fields from EmailTemplate object
        
     if(templateName.startswith('Partner')){
         this.email = [Select e.Body,e.Name, e.Subject from EmailTemplate e where name=:selectedLanguage ];
         showSelectOption = True;
       }else{
         this.email = [Select e.Body,e.Name, e.Subject from EmailTemplate e where name=:templateName  ];
         showSelectOption = False;
       }
      //  
        body = email.body;
        subject = email.Subject;
        ActivitySubject = 'Email: '+subject;
        string email=ApexPages.currentpage().getParameters().get('toaddress');
        if(email!=null){
            toAddresses.add(email);
        }       
        integer initialParam;
        integer finalParam=0;    
        String Parameter;  
        integer startingIndex=0;
        integer endingIndex;  
        integer midIndex; 
        String queryToObject;
        
        if((ApexPages.currentpage().getParameters().get('showAllowtoAddReceipent'))=='true'){
            renderAddRecepient=true ;
        }else{
            renderAddRecepient=false ;
        }
         
        //Retrieve the Object Name      
                    
        //Get the actual Object paramaters in a list
        
        while(body.indexOf('{!',finalParam)>=0)
        {            
            startingIndex = body.indexOf('{!',startingIndex);
            endingIndex = body.indexOf('.',startingIndex);
            retObject = body.substring(startingIndex+2,endingIndex);
            startingIndex = endingIndex+1;
            if(retObject.equals('User'))
            {
                initialParam= body.indexOf('{!'+retObject+'.',finalParam);
                midIndex= body.indexOf('}',initialParam);
                Parameter = body.substring(initialParam+retObject.length()+3,midIndex);
                
                finalParam = midIndex+1;
                userValues.add(Parameter);                       
            }  
             else
             {
                queryToObject=retObject;
                initialParam= body.indexOf('{!'+retObject+'.',finalParam);
                midIndex= body.indexOf('}',initialParam);
                Parameter = body.substring(initialParam+retObject.length()+3,midIndex);
                
                finalParam = midIndex+1;
                values.add(Parameter);
             }                    
                    
        }        
        
          
        //Construct the query to fetch the actual values
         String Query='Select ';
         Sobject acct;
         String merge_variable;
         //Fix for defect 217
         List<String> recValues01 = new List<String>(userValues);
         List<String> recValues02 = new List<String>(values);
         //Query for user object
         //Fix for defect 217
        if(userValues.size()>0)
        {
               
        for(String str:recValues01)
        {
            if(str.equals(recValues01[recValues01.size()-1]))
            Query=Query+str;
            else  
            Query=Query+str+',';                   
        }
        
        Query= Query+' from User where id ='+'\''+UserInfo.getUserId()+'\'';
        
        //Execute the query to get the actual values of the object.
        
        acct = Database.query(Query); 
        //Assign the actual values in the template body
        for(integer b=0;b<recValues01.size();b++)
        {
            merge_variable ='{!User.'+recValues01[b]+'}';
            if(acct.get(recValues01[b])!=null)
            {
                body=body.replace(merge_variable,''+acct.get(recValues01[b]));
            }
            else
            {
                body=body.replace(merge_variable,''+'XXXXX');           
            }
        
        }   
            
        }
        //End of fix for def: 217
        //Query for other objects
                    
        Query='Select ';

        for(String str:recValues02)
        {
            if(str.equals(recValues02[recValues02.size()-1]))
            Query=Query+str;
            else  
            Query=Query+str+',';                   
        }
        
        Query= Query+' from ' +queryToObject+ ' where id ='+'\''+ApexPages.currentPage().getParameters().get('id')+'\'';
        
        //Execute the query to get the actual values of the object.
        
        acct = Database.query(Query);  
        System.debug('The final query is for retObject'+acct);
        //Assign the actual values in the template body
        for(integer j=0;j<recValues02.size();j++)
        { 
            merge_variable ='{!'+queryToObject+'.'+recValues02[j]+'}';
            if(acct.get(recValues02[j])!=null)
            {
                body=body.replace(merge_variable,''+acct.get(recValues02[j]));               
            }else{
                body=body.replace(merge_variable,''+'XXXXX');           
            }
            
        }                
    }

    
        /*Send Mail Method
        Invocation Point- Send Mail Button on Send Mail Page
        Description- This method creates and sends a mail.
        */
    public PageReference sendMail() 
    {
        Messaging.SendEmailResult[] result=null;
        try{
            sendEmail.mailSent=true;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Assign the addresses for the To and CC lists to the mail object.
         
            mail.setToAddresses(toAddresses);
            System.debug('toAddresses  '+toAddresses);
            if( toAddresses.size()==0 ){
                throw new MailException(System.Label.Recipient_Email_Address_Required);
            }
            mail.setPlainTextBody(body);
            mail.setSubject(subject); 
            //Fix for defect #216 
            mail.setBccSender(true);
            //Fix for defect #216 
            //Commented for fix of defect #227

            /*if(!retObject.equals('Account'))
            {
                mail.setSaveAsActivity(true);
                mail.setTargetObjectId(relatedObjectId);
                System.debug(relatedObjectId + ' relatedObjectId');
            }*/
             //Fix for defect #227

            if((ApexPages.currentpage().getParameters().get('setSaveAsActivity'))=='true')
            {
                Util.isFeatureCalledonAcitivity=false;
                insertTask();
            }
           result=Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           }
           catch(Exception ex ){
             ApexPages.addMessages(ex);
             
           }
           if ( result!=null){
               if(result[0].isSuccess()){
                   mailSend=true;
               }else{
                  ApexPages.addMessages(new MailException(System.Label.Mail_Failure) ); 
               }
           }
           return null;
    }
    //Fix for defect #227

    public void insertTask()
    {
        Task task = new Task();
        task.Type = 'Email';
        task.Subject = ActivitySubject;
        task.WhoId = relatedObjectId;
        task.Description = body;
        task.Status = 'Completed';
        task.ActivityDate = system.Today();
        insert task;  
    }
    //End of Fix for defect #227
  
        /*addRecepient Method
        Invocation Point- Add Recepients Button on Send Mail Page
        Description- This method redirects the control to SearchContacts Page.
        */
    public PageReference addRecepient() 
    {
         return Page.SearchContacts;
    }

    
    public PageReference addingReciepients() 
    {
        try{
            for(ContactWrapper cw:contactWrap )
                {
                    if(cw.checked){
                        String email =(cw.getContact()).Email;
                        if(email==null){
                            throw new MailException(System.Label.Contact_Doesnot_Have_Email);
                        }
                        toAddresses.add(email);
                    }
                }
        }catch(Exception ex ){
             ApexPages.addMessages(ex); 
             return null;  
        }
        return Page.sendmail;
    }

    public PageReference cancel() 
    {
        return Page.sendmail;
    }
    
     public boolean getMailSend()
     {
         return mailSend;
     }
     
   
}