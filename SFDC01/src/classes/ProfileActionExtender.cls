/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     DESCRIPTION                               
 |  ====       =========     ===========   
    21-Apr-10  Karthik        Updated save() Method - Defect# 644
 +===========================================================================*/

public class ProfileActionExtender {
String currentMsg;
    
    public String selectedTab='';
    ApexPages.StandardController controller1 ;
    public ProfileActionExtender(ApexPages.StandardController controller) {
    if(ApexPages.currentPage().getParameters().get('tab')!=null)
        selectedTab=ApexPages.currentPage().getParameters().get('tab');       
            controller1=controller;  
    }
    public String getSelectedTab(){
        system.debug('GET selectedTab '+selectedTab);
        return selectedTab;
    }
    public void setSelectedTab(String tab){
         selectedTab= tab;
         system.debug('SET selectedTab '+selectedTab);
    }
/* Here the save() method is updated to catch the null pointer exception.
Added the if() condition and try and catch to save() method*/
//Added by Karthik
 
    public pagereference save(){
        String Id='';
        pagereference StandardPage;
        try{
             StandardPage= controller1.save();
             System.debug('Saved '+controller1);
             System.debug('StandardPage '+StandardPage);
             if(StandardPage==null){
                 return null;
             }
             System.debug('ApexPages.currentPage().getParameters().get(id) '+ApexPages.currentPage().getParameters().get('id'));      
             if( ApexPages.currentPage().getParameters().get('id')==null){
                 Id=StandardPage.getUrl();
                 Id=Id.substring(1);
             }
             else{
                 Id= ApexPages.currentPage().getParameters().get('id');
                 system.debug(' Save selectedTab '+selectedTab);
             }
             PageReference pageRef = new PageReference((Page.AccountProfile).getUrl()+'?id='+Id+'&tab='+selectedTab);
             System.debug('pageRef'+pageRef);
             return  pageRef.setRedirect(true);
        }
        catch (DMLException e){
            System.debug('Type exception: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
            
    }
    
    public pagereference edit(){
     controller1.edit();

     system.debug('EDIT selectedTab '+selectedTab);
     return Page.AccountProfileEdit;
    }
    
     public pagereference cancel(){
         if(ApexPages.currentPage().getParameters().get('id')==null)
            return controller1.cancel();
        else        
         {  pagereference ref= controller1.cancel();
            system.debug('Cancel selectedTab '+selectedTab);
            //return Page.AccountProfile; 
            return ref;
         }
     }
}