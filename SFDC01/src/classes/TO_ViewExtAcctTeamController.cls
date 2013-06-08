/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE        DEVELOPER           WR       DESCRIPTION                               
 |  ====        =========           ==       =========== 
 |  23-SEP-09   Devi Prasad Bal              Created  
 |  05-OCT-09   Devi Prasad Bal              Updated (Modification was done
 |                                           based on the review comments)               
 |   
 |  17-FEB-10   Saravanan.C        126812    Soql statement is moved to top of the for-loop to avoid Too Many SOQL Queries exception. 
 |                                
 +===========================================================================*/

/* This Apex class retrieves values from User, AccountTeamMember and AccountShare
 * objects for a particular account which is then used to display in the visualforce
 * page 'TO_ViewExtendedAccountTeam.page' 
 */
public class TO_ViewExtAcctTeamController{
    
    // A list of the inner wrapper class is being created which would store all the values to be displayed in the visualforce page 
    List<TO_WrapperTopOffender> wto_list=new List<TO_WrapperTopOffender>();
    List<TO_WrapperTopOffender> Name_wto_list=new List<TO_WrapperTopOffender>();
    List<String> Name_list =new List<String>();
    String acc_id;// acc_id is used to store the account id that would be captured from the account page 
    String user_group_shares; // it is used to store the user or group id retrieved from the AccountShares object
    String user_group_group; // it is used to store the user or group id retrieved from the Group object
    String acc_access; // it is used to store the user or group id retrieved from the Group object
    String op_access; // it is used to store the Opportunity Access Level value
    String case_access; // it is used to store the Case Access Level value 
    final String READ_ONLY = 'Read Only'; // it is used to assign access level
    final String READ_WRITE = 'Read/Write';
    final String PRIVATTE = 'Private'; // it is used to assign 'Private' access level
    final String READ = 'Read';
    final String EDIT = 'Edit';
    final String NONE = 'None';

    public String oldSortField {get;set;}
    public String newSortField {get;set;}
    
    // constructor of the class 
    public TO_ViewExtAcctTeamController(ApexPages.StandardController controller) 
    {
         this.acc_id = ((Account)controller.getRecord()).Id;
         
         if(oldSortField == null || oldSortField.length() == 0)
            oldSortField = 'BLANK';
         
         getAttributes();
    } 
        
    public List<TO_WrapperTopOffender> getWTOList()
    {
        return wto_list;
    }

    // This method retrieves values of the attributes of User, Account Team Member and Account Share, and returns a list of TO_WrapperTopOffender 
    public void getAttributes()
    {
        // This query is used to fetch information from AccountShares and AccountTeamMembers related to the Account 
        Account acc = [Select (Select UserId, TeamMemberRole From AccountTeamMembers), (Select UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel From Shares) From Account where id=:acc_id];
        //Account acc = [Select (Select UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel From Shares where RowCause='Manual') From Account where id=:acc_id]; 
        
        //a map of AccountTeamMember is created
        Map<Id, AccountTeamMember> teamMemberMap = new Map<Id, AccountTeamMember>();
        Set<Id> userIds = new Set<Id>();
        
        //User ids of the Account Team Members are added to the set userIds
        for(Integer i=0;i<acc.AccountTeamMembers.size();i++)
        {   
                userIds.add(acc.AccountTeamMembers[i].UserId);
                teamMemberMap.put(acc.AccountTeamMembers[i].UserId, acc.AccountTeamMembers[i]);
        }
        // A Map of Users of the Account Team Members is created
        Map<Id, User> userMapTeamMember= new Map<Id, User> ([Select Id, Role__c, Name, BU_Attribute__c From User where id in :userIds ORDER BY BU_Attribute__c, Role__c, Name]);
    
        Set<Id> groupIds = new Set<Id>(); //A set of groupIds is created to store the group ids of the account share

        // iterate through the AccountShares 
        for(Integer i=0;i<acc.Shares.size();i++)
        {       
            user_group_shares=acc.Shares[i].UserOrGroupId;
            // The following block of code assigns values to the required variables when the user_group_shares variable holds an id which is an individual user 
            if(user_group_shares.startsWith('005'))
            {
                AccountTeamMember teamMember = teamMemberMap.get(acc.Shares[i].UserOrGroupId);
                if(teamMember == null) // ADDITIONAL CHECK: if there are no team members then get out of the loop
                    continue; 
 
                // When AccountAccessLevel value is Read in the DB then display 'Read Only' 
                if(acc.Shares[i].AccountAccessLevel==READ)
                    acc_access=READ_ONLY;
                // When AccountAccessLevel value is Edit in the DB then display 'Read/Write' 
                else if(acc.Shares[i].AccountAccessLevel==EDIT)
                    acc_access=READ_WRITE;
                // When OpportunityAccessLevel value is Read in the DB then display 'Private'     
                if(acc.Shares[i].OpportunityAccessLevel==EDIT)
                    op_access=PRIVATTE;    
                else if(acc.Shares[i].OpportunityAccessLevel==READ)
                    op_access=READ_ONLY;   
                else if(acc.Shares[i].OpportunityAccessLevel==EDIT)
                    op_access=READ_WRITE;    
                if(acc.Shares[i].CaseAccessLevel==EDIT)
                    case_access=PRIVATTE;     
                else if(acc.Shares[i].CaseAccessLevel==READ)
                    case_access=READ_ONLY;   
                else if(acc.Shares[i].CaseAccessLevel==EDIT)
                    case_access=READ_WRITE;
                            
                //User record from the userMapTeamMember Map is retrieved to fetch BU Attribute and Sales Role
                User u = userMapTeamMember.get(user_group_shares);
                // An instance of TO_WrapperTopOffender is created which would be added to wto_list 
                TO_WrapperTopOffender wto= new TO_WrapperTopOffender();
                // Values retrieved from the AccountTeamMember, AccountShare and User object are added to the list in the following lines of code 
                wto.TeamMemberRole = teamMember.TeamMemberRole;
                wto.AccountAccessLevel=acc_access;
                wto.OpportunityAccessLevel=op_access;
                wto.CaseAccessLevel=case_access;
                wto.Name=u.Name;
                wto.BUAttribute=u.BU_Attribute__c;
                wto.SalesRole=u.Role__c;
                wto.Id=u.id;
                // Adding an instance of WrapperTopOffender with all the required field values to the WrapperTopOffender list which would be dispalyed in the visualforce page 
                wto_list.add(wto);
            }
                
            // The following block of code assigns values to the required variables when the user_group_shares variable holds an id which is a group 
            if(user_group_shares.startsWith('00G'))
            {
                groupIds.add(acc.Shares[i].UserOrGroupId);
            }
        }//end of for loop
            
        //call the fuction to create display for Group and its members
        if(groupIds.size() > 0)
            createGroupMembers(groupIds);
        //return null;
    }
    
    // this method is called by clicking on the column headers in the associated VF page for sorting the data ASC or DESC
    public PageReference doSorting()
    {
        List<TO_WrapperTopOffender> lstToSort = wto_list;
        List<TO_WrapperTopOffender> sortedList = new List<TO_WrapperTopOffender>();
        Set<String> stringSet = new Set<String>();
        
        Map<String,List<TO_WrapperTopOffender>> wtoMap = new  Map<String,List<TO_WrapperTopOffender>>();//Key=Country+State+Classification,Value=Account
        //This loop is used here to do sorting for Name,user Attribute and sales Role.
        for(TO_WrapperTopOffender wto: lstToSort)
        {
            String strKey = '';
            if(newSortField.equals('NAME'))
                strKey = wto.Name;
            else if(newSortField.equals('TEAM ROLE'))
                strKey = wto.TeamMemberRole;
            else if(newSortField.equals('GROUP NAME'))
                strKey = wto.GroupName;
            else if(newSortField.equals('BU'))
                strKey = wto.BUAttribute;
            else if(newSortField.equals('SALES ROLE'))
                strKey = wto.SalesRole;

            stringSet.add(strKey);
            
            if(wtoMap.containsKey(strKey))
            {   
                List<TO_WrapperTopOffender> wtoList = wtoMap.get(strKey);
                wtoList.add(wto);
                wtoMap.put(strKey,wtoList);  
            }
            else
            {
                List<TO_WrapperTopOffender> wtoList=new List<TO_WrapperTopOffender>();
                wtoList.add(wto);
                wtoMap.put(strKey,wtoList);     
            } 

        }
        List<String> stringList = new List<String>();
        for(String s: stringSet)
        {
            stringList.add(s);
        }
        //To do sorting
        stringList.sort();

        if(oldSortField.equals(newSortField))
        {
            for(Integer i=(stringList.size() - 1); i > -1;i--)
            {
                List<TO_WrapperTopOffender> wtoList = wtoMap.get(stringList[i]);
                for(TO_WrapperTopOffender wto: wtoList)
                {
                    sortedList.add(wto);
                }
            }
        }
        else
        {
            oldSortField = newSortField;
            for(Integer i=0; i<stringList.size();i++)
            {
                List<TO_WrapperTopOffender> wtoList = wtoMap.get(stringList[i]);
                for(TO_WrapperTopOffender wto: wtoList)
                {
                    sortedList.add(wto);
                }
            }
        }
        wto_list = sortedList;
        return null;
    }
    
    // this is recursive method will called as per the number of groups 
    public void createGroupMembers(Set<Id> grpIds)
    {
        Set<Id> innerGroupIds = new Set<Id>(); //A set of groupIds is created to store the group ids of the groups within groups in account share
         
        // A List of GroupMembers of the Account Shares is created
        List<GroupMember> groupList= [Select UserOrGroupId,Group.Name From GroupMember where GroupId in :grpIds ORDER BY Group.Name];
        
        // A set of user ids of the individual members of the group is created
        Set<Id> userIds = new Set<Id>();
        for(GroupMember grpMember: groupList)
        {
            String userId = grpMember.UserOrGroupId;
            if(userId.startsWith('005'))
            {
                userIds.add(userId);
            }
        }
            
        // A Map of Users of the individual members of group is created
        Map<Id, User> groupUserMap = new Map<Id, User> ([Select Id,Role__c, Name, BU_Attribute__c From User where id in :userIds ORDER BY BU_Attribute__c,Role__c, Name]);
        Integer count = 0;
        List<AccountShare> share = [Select AccountAccessLevel From AccountShare where  AccountId = :this.acc_id]; // Added by Saravanan.C WR 126812
        
        for(GroupMember grpMember: groupList)
        {
            count =count +1;
              System.Debug('Start of for loop '+count );
              
            String userOrGroupId = grpMember.UserOrGroupId;
            
            System.Debug('userOrGroupId  '+userOrGroupId +'   '+count );
            
            if(userOrGroupId.startsWith('005'))
            {
                //User record from the userMapTeamMember Map is retrieved to fetch BU Attribute and Sales Role
                User u = groupUserMap.get(userOrGroupId);
              //  List<AccountShare> share = [Select AccountAccessLevel From AccountShare where UserOrGroupId = :grpMember.GroupId and AccountId = :this.acc_id]; // Commented by Saravanan.C WR 126812
                // An instance of TO_WrapperTopOffender is created which would be added to wto_list 
                TO_WrapperTopOffender wto= new TO_WrapperTopOffender();
                // Values retrieved from the AccountTeamMember, AccountShare and User object are added to the list in the following lines of code 
                
                for(AccountShare s :  share)
                {
                
                 if(s.AccountAccessLevel == EDIT && UserOrGroupId == grpMember.GroupId) // Added by Saravanan.C WR 126812
                    wto.AccountAccessLevel=READ_WRITE;
                }    

                wto.OpportunityAccessLevel=READ_WRITE;
                wto.CaseAccessLevel=READ_WRITE;
                wto.Name=u.Name;
                wto.BUAttribute=u.BU_Attribute__c;
                wto.SalesRole=u.Role__c;
                wto.Id=u.id;
                wto.GroupName=grpMember.Group.Name;
                // Adding an instance of WrapperTopOffender with all the required field values to the WrapperTopOffender list which would be dispalyed in the visualforce page 
                wto_list.add(wto);
            }
               
            if(userOrGroupId.startsWith('00G'))
            {
                innerGroupIds.add(grpMember.UserOrGroupId);
            }
        }// end of for loop
             
        if(innerGroupIds.size() > 0)
        {
            System.Debug('innerGroupIds.size ' +innerGroupIds.size()+'  '+count );

            createGroupMembers(innerGroupIds);
            System.Debug('call to create group completed '+count );
         }   
    }//end of method
    
    
    // The method to return back to the Account Detail Page on clicking the 'Back' button is defined here             
    public PageReference back() 
    {
        // An instance of PageReference is created here with the account id appended to it 
        PageReference pre_page = new PageReference('/'+acc_id);
        pre_page.setRedirect(true);
        
        return pre_page;// It returns the previous page that is the Account page
    }
    
    // This is an inner class which is also a wrapper class to hold values of attributes of User, AccountTeamMember and AccountShare objects 
    class TO_WrapperTopOffender 
    {
        public String Name {get; set;}// This variable is used to store the retrieved value of Name field of the member in the Account Team or Group in the Account Share        
        public String AccountAccessLevel {get; set;}// This variable is used to store the retrieved value of Account Access Level field of the member       
        public String OpportunityAccessLevel {get; set;}        
        public String CaseAccessLevel {get; set;}        
        public String TeamMemberRole {get; set;}// This variable is used to store the retrieved value of Team Role field of the member        
        public String GroupName {get; set;}// This variable is used to store the retrieved value of Group Name field of the member        
        public String BUAttribute {get; set;}        
        public String SalesRole {get; set;}// This variable is used to store the retrieved value of Role field of the member        
        public Id Id {get; set;}// This variable is used to store the retrieved value of User id field of the member        
        public Id UserOrGroupId{get; set;}// This variable is used to store the retrieved value of Group id field of the member
    }    
}