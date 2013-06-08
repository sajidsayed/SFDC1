/*==================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 

| 29/9/2010      Karthik Shivprakash      1074          This class is used to edit
                                                        My Company Profile fields 
|                                                       on account and to save new
                                                        values on the account.
|
  08/10/2010     Karthik Shivprakash       --           Update the constructor to
|                                                       show the selected values and
                                                        stored values on the account
|                                                       fields.
|11/10/2012     Krishna Pydavula         204075         Added two fields 3rd PartyVirtualization and 3rd PartyNetworking
+==================================================================================================*/


public class PRM_EditMyPublicProfile {
    
    //Created account sObject along with getter and setter
    Public Account accounts {get; set;}
    
 
    //Used to store the multi-piclist values.
    List<SelectOption> BusinessFocus;
    List<SelectOption> ProductFocus;
    List<SelectOption> ApplicationEnvironments;
    List<SelectOption> IndustryVerticals;
    List<SelectOption> PartyVirtualization;
    List<SelectOption> PartyNetworking;
    
    //Used to give access only to Admin for Partner Finder Profile user.
    Public boolean hasAccess {get;set;}
    
    //Used to get and set the values from the visual force page for the field
    //Partnership Overview.
    Public String Partnership_Overview {get;set;}
    
    //Used to get and set the values from the visual force page for the field
    //Company Description
    Public String Partner_Self_Description_Long {get;set;}
    
    //Used to get and set the values from the visual force page for the field
    //Product Focus
    Public List<String> Product_Focus {get;set;}
    
    //Used to get and set the values from the visual force page for the field
    //Application Environments
    Public List<String> Application_Environments {get;set;}
    
    //Used to get and set the values from the visual force page for the field
    //Industry Verticals
    Public List<String> Industry_Verticals {get;set;}
    
    //Used to get and set the values from the visual force page for the field
    //Business Focus
    Public List<String> Business_Focus {get;set;}
    
     //Used to get and set the values from the visual force page for the field
    //Business Focus
    Public List<String> Party_Virtualization {get;set;}
    
    //Used to get and set the values from the visual force page for the field
    //Business Focus
    Public List<String> Party_Networking {get;set;}
    
       

/*@Method <This method getBusinessFocus used to get the multi-picklist
            values from the account via metadata for the field Business Focus>
@param <This method does not take any parameters>
@return <SelectOption> - <selected multi-picklist values from configuration>
@throws exception - <No Exception>
*/    

    public List<SelectOption> getBusinessFocus(){
        if(BusinessFocus==null){
            BusinessFocus = new List<SelectOption>();
            Schema.DescribeFieldResult BusinessFocusMultipiclist = Schema.sObjectType.Account.fields.Business_Focus__c;
            for(Schema.PickListEntry nextPickVal : BusinessFocusMultipiclist.getPicklistValues()){
                BusinessFocus.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return BusinessFocus; 
    }

/*@Method <This method getProductFocus used to get the multi-picklist
            values from the account via metadata for the field ProductFocus>
@param <This method does not take any parameters>
@return <SelectOption> - <selected multi-picklist values from configuration>
@throws exception - <No Exception>
*/ 
    
    //Used to get the multi-picklist values from the account for the field Business Focus
    public List<SelectOption> getProductFocus(){
        if(ProductFocus==null){
            ProductFocus = new List<SelectOption>();
            Schema.DescribeFieldResult ProductFocusMultipiclist = Schema.sObjectType.Account.fields.Product_Focus__c;
            for(Schema.PickListEntry nextPickVal : ProductFocusMultipiclist.getPicklistValues()){
                ProductFocus.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return ProductFocus; 
    }
 
/*@Method <This method getApplicationEnvironments used to get the multi-picklist
            values from the account via metadata for the field ApplicationEnvironments>
@param <This method does not take any parameters>
@return <SelectOption> - <selected multi-picklist values from configuration>
@throws exception - <No Exception>
*/ 
    
    public List<SelectOption> getApplicationEnvironments(){
        if(ApplicationEnvironments==null){
            ApplicationEnvironments = new List<SelectOption>();
            Schema.DescribeFieldResult ApplicationEnvironmentsMultipiclist = Schema.sObjectType.Account.fields.Application_Environments__c;
            for(Schema.PickListEntry nextPickVal : ApplicationEnvironmentsMultipiclist.getPicklistValues()){
                ApplicationEnvironments.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return ApplicationEnvironments; 
    }

/*@Method <This method getIndustryVerticals used to get the multi-picklist
            values from the account via metadata for the field IndustryVerticals>
@param <This method does not take any parameters>
@return <SelectOption> - <selected multi-picklist values from configuration>
@throws exception - <No Exception>
*/
    

    public List<SelectOption> getIndustryVerticals(){
        if(IndustryVerticals==null){
            IndustryVerticals = new List<SelectOption>();
            Schema.DescribeFieldResult IndustryVerticalsMultipiclist = Schema.sObjectType.Account.fields.Industry_Verticals__c;
            for(Schema.PickListEntry nextPickVal : IndustryVerticalsMultipiclist.getPicklistValues()){
                IndustryVerticals.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return IndustryVerticals; 
    }
    
 
    /*@Method <This method getPartyVirtualization used to get the multi-picklist
            values from the account via metadata for the field PartyVirtualization>
@param <This method does not take any parameters>
@return <SelectOption> - <selected multi-picklist values from configuration>
@throws exception - <No Exception>
*/
    

    public List<SelectOption> getPartyVirtualization(){
        if(PartyVirtualization==null){
            PartyVirtualization = new List<SelectOption>();
            Schema.DescribeFieldResult PartyVirtualizationMultipiclist = Schema.sObjectType.Account.fields.Cloud_Builder_Virtualization__c;
            for(Schema.PickListEntry nextPickVal : PartyVirtualizationMultipiclist.getPicklistValues()){
                PartyVirtualization.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return PartyVirtualization; 
    }
    
    /*@Method <This method getPartyNetworking used to get the multi-picklist
            values from the account via metadata for the field PartyNetworking>
@param <This method does not take any parameters>
@return <SelectOption> - <selected multi-picklist values from configuration>
@throws exception - <No Exception>
*/
    

    public List<SelectOption> getPartyNetworking(){
        if(PartyNetworking==null){
            PartyNetworking = new List<SelectOption>();
            Schema.DescribeFieldResult PartyNetworkingMultipiclist = Schema.sObjectType.Account.fields.Cloud_Builder_Networking__c;
            for(Schema.PickListEntry nextPickVal : PartyNetworkingMultipiclist.getPicklistValues()){
                PartyNetworking.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return PartyNetworking; 
    }

/*@Method <This method PRM_EditMyPublicProfile constructor to query on the accounts 
            to insert the new My Public profile field values>
@param <This method does not take any parameters>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/    

    public PRM_EditMyPublicProfile(){
        hasAccess=validate();
        if(hasAccess){
            System.debug('Id--->'+ApexPages.currentPage().getParameters().get('id'));
            accounts = [select id,name,Partnership_Overview__c,Partner_Self_Description_Long__c,Business_Focus__c,
                         Product_Focus__c,Application_Environments__c,Industry_Verticals__c,Cloud_Builder_Virtualization__c,Cloud_Builder_Networking__c
                         from account
                         where id = :ApexPages.currentPage().getParameters().get('id')];
          
           //Here we are splitting the multipicklist values and storing in a list
           Product_Focus = new List<String>();
           if(accounts.Product_Focus__c!=null){
               Product_Focus = accounts.Product_Focus__c.split(';');
           }
           Industry_Verticals = new List<String>();
           if(accounts.Industry_Verticals__c!=null){
               Industry_Verticals = accounts.Industry_Verticals__c.split(';');
           }
           Application_Environments = new List<String>();
           if(accounts.Application_Environments__c!=null){
               Application_Environments = accounts.Application_Environments__c.split(';');
           }
           Business_Focus = new List<String>();
           if(accounts.Business_Focus__c!=null){
               Business_Focus = accounts.Business_Focus__c.split(';');
           }
           Party_Virtualization = new List<String>();
           if(accounts.Cloud_Builder_Virtualization__c!=null){
               Party_Virtualization = accounts.Cloud_Builder_Virtualization__c.split(';');
               
           }
           Party_Networking = new List<String>();
           if(accounts.Cloud_Builder_Networking__c!=null){
               Party_Networking = accounts.Cloud_Builder_Networking__c.split(';');
               
           }
           Partner_Self_Description_Long = accounts.Partner_Self_Description_Long__c;
           Partnership_Overview = accounts.Partnership_Overview__c;
         }
    }

/*@Method <This method cancel PageReference to return back to 
            home page on cancel>
@param <This method does not take any parameters>
@return <PageReference> - <Returning home page reference on cancel>
@throws exception - <No Exception>
*/  

    public PageReference cancel(){
        return new pageReference('/home/home.jsp');
    }

/*@Method <This method validate used to validate the user is 
            of Admin Partner Finder Profile>
@param <This method does not take any parameters>
@return <Boolean> - <Returns true if the current user is Admin for Partner Finder 
                        (check box on user)>
@throws exception - <No Exception>
*/  

    private boolean validate(){
       
       User user=[select id,Is_Admin_for_Partner_Finder_Profile__c,name from User where Id=: UserInfo.getUserId() ];
       return user.Is_Admin_for_Partner_Finder_Profile__c;
    }
    
/*@Method <This method saveAccount used to save the values entered 
            from visual force page and save on the respective account>
@param <This method does not take any parameters>
@return <PageReference> - <Returning home page reference after save is
                            successful>
@throws exception - <No Exception>
*/

    public PageReference saveAccount(){
        accounts.Partnership_Overview__c = Partnership_Overview;
       accounts.Partner_Self_Description_Long__c = Partner_Self_Description_Long;

        accounts.Business_Focus__c = getCommaSeparatedValues(Business_Focus);
        
        System.debug('accounts.Business_Focus__c '+accounts.Business_Focus__c);
        
        accounts.Product_Focus__c = getCommaSeparatedValues(Product_Focus);
        accounts.Application_Environments__c = getCommaSeparatedValues(Application_Environments);
        accounts.Industry_Verticals__c = getCommaSeparatedValues(Industry_Verticals);
        accounts.Cloud_Builder_Virtualization__c=getCommaSeparatedValues(Party_Virtualization);
        accounts.Cloud_Builder_Networking__c=getCommaSeparatedValues(Party_Networking);
        update accounts;
        System.debug('After update of accounts'+accounts);
        return new pageReference('/home/home.jsp');
    }
    
    public String getCommaSeparatedValues(List<String> Values ){
        String concatinateValues='';
        if(Values !=null){
                for(String nextStr : Values){
                    if(nextStr !='')
                        concatinateValues = concatinateValues + nextStr + ';';
                }
            }
        return concatinateValues;
    }
}