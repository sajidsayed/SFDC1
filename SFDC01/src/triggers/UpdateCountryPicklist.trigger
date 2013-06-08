/*==================================================================================
Name            WR     Date           Description
Shipra Misra    171026 18/08/2011     Updated This trigger to Appointment Set field's whenever Appointment set field is updated.
Anirudh Singh          28/08/2011     Added Null Check to fix Defect for PRM when DR's are getting submitted from Non Portal Page.
22/01/2011      Accenture             Updated trigger to incorporate ByPass Logic
|                                     NOTE: Please write all the code after BYPASS Logic   
=====================================================================================*/

trigger UpdateCountryPicklist on Lead (before update,before insert) {
   //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
                return;
         }
    }     
 
    List <Lead> Leads= new List<Lead>();    
    Set<String> related_accounts_id= new Set<String>(); 
    UserRole objUserRole;
    if(UserInfo.getUserRoleId()!= null && UserInfo.getUserRoleId()!= ''){ 
        objUserRole=[Select u.Name, u.Id From UserRole u where Id =:UserInfo.getUserRoleId()];
    }
    integer i=0,j=0;    
    for( i=0;i<Trigger.new.size();i++){
    
        if( (Trigger.isUpdate && Trigger.new[i].related_account__c != Trigger.old[i].related_account__c) || Trigger.isInsert)
        
            if(Trigger.new[i].related_account__c!= null){
            Leads.add(Trigger.new[i]);
            related_accounts_id.add(Trigger.new[i].related_account__c);
            }
        //WR-171026 Updated by Shipra on 18 aug 2011.
        if( (Trigger.isUpdate && Trigger.new[i].Appointment_Set__c != Trigger.old[i].Appointment_Set__c) || Trigger.isInsert)
        {
            if(Trigger.new[i].Appointment_Set__c== true){
                Trigger.new[i].Appointment_Set_By__c=UserInfo.getUserId();
                Trigger.new[i].Appointment_Set_Date__c=System.today();
                if(UserInfo.getUserRoleId()!= null && UserInfo.getUserRoleId()!= ''){
                Trigger.new[i].Appointment_Set_by_Role__c=objUserRole.Name;
                }
                
            }
             if(Trigger.new[i].Appointment_Set__c== false){
                Trigger.new[i].Appointment_Set_By__c=null;
                Trigger.new[i].Appointment_Set_Date__c=null;
                Trigger.new[i].Appointment_Set_by_Role__c='';
                
            }
        }
        //End -WR 171026.
    
    }
        if(Leads.size()==0){
    return;
    }
    
    
    Schema.DescribeFieldResult F = Lead.Country__c.getDescribe();
    List <PicklistEntry> countries =  F.getPicklistValues();

    List<Account> Related_Accounts = new List<Account>();
    Related_Accounts=[Select id,BillingCountry from Account where Id in: related_accounts_id ];
    
    Map <String,String> CountryNames = new Map<String,String>();

    //System.debug(countries.size());
    //System.debug(Related_Accounts.size());
    
    boolean CountryFound =false;
    
    for( j=0;j<Related_Accounts.size();j++){
    CountryFound =false;
    for( i=0;i<countries.size();i++){
        //System.debug('2');
       // System.debug('country'+countries[i].Value);
       // System.debug('account country'+Related_Accounts[j].BillingCountry);

        if((countries[i].Value).equalsIgnoreCase(Related_Accounts[j].BillingCountry)){
            CountryNames.put(Related_Accounts[j].id,countries[i].Value);
            CountryFound=true;
        break;
        }
        
    }
    if(!CountryFound){
        for( i=0;i<countries.size();i++){
       // System.debug('2');
       // System.debug('country'+countries[i].Value);
       // System.debug('account country'+Related_Accounts[j].BillingCountry);
       // System.debug('Condition '+((countries[i].Value).toUpperCase()).IndexOf((Related_Accounts[j].BillingCountry).toUpperCase()));
       // System.debug(((countries[i].Value).toUpperCase()));


            if( Related_Accounts[j].BillingCountry != null && ((countries[i].Value).toUpperCase()).IndexOf(Related_Accounts[j].BillingCountry.toUpperCase())==0){
                CountryNames.put(Related_Accounts[j].id,countries[i].Value);
                CountryFound=true;
        break;
            }
        
        }
    }
    if(!CountryFound){
    CountryNames.put(Related_Accounts[j].id,Related_Accounts[j].BillingCountry);
    }
  }
    
   // System.debug(CountryNames);
   // System.debug(Related_Accounts.size());

   /* for( i=0;i<Leads.size();i++){
        for( j=0;j<Related_Accounts.size();j++){
        if(Leads[i].related_account__c==Related_Accounts[j].id){
            String CountryName=CountryNames.get(Related_Accounts[j].BillingCountry);
        if (CountryName==null){
        CountryName=Related_Accounts[j].BillingCountry;
        }

        Leads[i].Country__c=CountryName;
        
     //       System.debug(CountryName);
        }
        }
    }*/
    
    for( i=0;i<Leads.size();i++){
    Leads[i].Country__c=CountryNames.get(Leads[i].Related_Account__c);

   }
   
 }