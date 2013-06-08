/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req          DESCRIPTION                               
 |  ====            =========       ==          	=========== 
 |  25.10.2010      Anand Sharma    	       		Manager to search user, queue or partner user.  
 |  24.11.2010		Anand Sharma					Added isactive =true into query for partner user (Enternal SFDC search)  
 
 +========================================================================================================================*/

public with sharing class SearchUserQueueController {

	public String userType {get;set;}
	public String newUserName {get;set;}
	public Boolean isUserResult {get;set;}
	public Boolean isQueueResult {get;set;}
	//holds the selected Owner id
	public Id selectedOwnerId{get; set;}
	
	//holds the contact id 
	public Set<Id> selectedPartnerContactId{get; set;}
	public Id accountOwnerId{get; set;}
	/* variable hold the lead object */	
	private List<User> lstUser;
	private List<QueueSobject> lstQueue;	

	public SearchUserQueueController(){
		selectedOwnerId = null;
		newUserName = '';
	}
	
	/* @Method <This Method is used to search list of user or queue based on search user type>.
        @param <It is not taking any parameters>
        @return <Pagereference>
        @throws exception - <No Exception>
    */
	public void searchUser(){
		System.debug('Selected newUserName :' + newUserName);	
		String strQuery ='';
		selectedOwnerId = null;
		lstUser = new List<User>();
		lstQueue = new List<QueueSobject>();
		
		if(userType=='User'){
			if(UserInfo.getUserType() =='PowerPartner'){		
			
				User objUserRecord = [SELECT Id, Name , ContactId, AccountId, Contact.AccountId
										FROM User 
										WHERE Id =: UserInfo.getUserId()];
		
				Map<Id,Contact> contactRecords_Map = new Map<Id,Contact>([SELECT Id, Name 
											FROM Contact where AccountId=:objUserRecord.AccountId]);
											
				selectedPartnerContactId = 	contactRecords_Map.keySet();						
				accountOwnerId = [Select Id, OwnerId FROM Account where id=:objUserRecord.AccountId ].OwnerId;
				if(accountOwnerId=='00570000001IkMo'){
					accountOwnerId = null;
				}							
				System.debug('Selected selectedPartnerContactId :' + selectedPartnerContactId);				
				if(newUserName != ''){
					if(accountOwnerId !=null){
						strQuery = 'select id, Name, BU__c, Role__c, Username, Forecast_Group__c  from user ' 
									+ ' where ((UserType = \'PowerPartner\' and isactive =true and name ' 
									+ 'like \'%' + newUserName +'%\'  and (contactId in:selectedPartnerContactId )) '
									+ ' OR (Id =\''+ accountOwnerId + '\'))  limit 200';
					}else{
						strQuery = 'select id, Name, BU__c, Role__c, Username, Forecast_Group__c  from user ' 
								+ ' where (UserType = \'PowerPartner\' and isactive =true and name ' 
								+ 'like \'%' + newUserName +'%\'  and (contactId in:selectedPartnerContactId )) limit 200 ';

					}
				}else{
					if(accountOwnerId !=null){
						strQuery = 'select id, Name, BU__c, Role__c, Username, Forecast_Group__c  from user '
								+ 'where ( (UserType = \'PowerPartner\' and isactive =true and name != null ' 
								+ 'and contactId in:selectedPartnerContactId ) OR  (Id =\''+ accountOwnerId + '\'))  limit 200';
					}else{
						strQuery = 'select id, Name, BU__c, Role__c, Username, Forecast_Group__c  from user '
								+ 'where (UserType = \'PowerPartner\' and isactive =true and name != null ' 
								+ 'and contactId in:selectedPartnerContactId )   limit 200';

					}
				}
			}else{
				if(newUserName != ''){
					strQuery = 'select id, Name, BU__c, Role__c, Username, Forecast_Group__c  from user where '
					+ ' UserType != \'PowerPartner\' AND isactive =true and name like \'%' + newUserName +'%\' limit 200';
				}else{
					strQuery = 'select id, Name, BU__c, Role__c, Username, Forecast_Group__c  from user where '
					+ 'UserType != \'PowerPartner\' AND isactive =true and name !=null limit 200';
				}
			}
			System.debug('Selected strQuery :' + strQuery);
			lstUser = Database.query(strQuery);
			isUserResult = true;
			isQueueResult = false;
		}else if(userType=='Queue'){
			if(UserInfo.getUserType() =='PowerPartner'){
				if(newUserName != ''){
					strQuery = 'Select q.QueueId, q.Queue.Name, q.Queue.Type from QueueSobject q  '
								+ ' where q.SobjectType=\'Lead\' and q.Queue.Name like \'Partner%\' and q.Queue.Name like \'%' + newUserName +'%\' limit 200';
				}else{
					strQuery = 'Select q.QueueId, q.Queue.Name, q.Queue.Type from QueueSobject q  '
								+ 'where q.SobjectType=\'Lead\' and q.Queue.Name like \'Partner%\' limit 200';
				}
			}else{
				if(newUserName != ''){
					strQuery = 'Select q.QueueId, q.Queue.Name, q.Queue.Type from QueueSobject q  '
								+ ' where q.SobjectType=\'Lead\' and q.Queue.Name like \'%' + newUserName +'%\' limit 200';
				}else{
					strQuery = 'Select q.QueueId, q.Queue.Name, q.Queue.Type from QueueSobject q  '
								+ 'where q.SobjectType=\'Lead\' and q.Queue.Name != null limit 200';
				}	
			}
					
			lstQueue = Database.query(strQuery);	
			isUserResult = false;
			isQueueResult = true;
		}else if(userType=='PartnerUser'){
			if(newUserName != ''){
				strQuery = 'select id , Name , BU__c, Role__c , Username, Forecast_Group__c from user '
							+ ' where UserType = \'PowerPartner\' AND isactive =true and name like \'%' + newUserName + '%\' limit 200';
			}else{
				strQuery = 'select id , Name , BU__c, Role__c , Username, Forecast_Group__c from user ' 
				+ ' where UserType = \'PowerPartner\' AND isactive =true and name !=null limit 200';
			}
			System.debug('Search Query :' + strQuery);
			lstUser = Database.query(strQuery);			
			isUserResult = true;
			isQueueResult = false;		
		}
				
	}
	
	/* @Method <This Method is used to set new owner to variable and reset all variable>. 
        @param <It is not taking any parameters>
        @return <void>
        @throws exception - <No Exception>
    */
	public void ApplyFilter(){	
		resetFlags();
		System.debug('Selected ApplyFilter selectedOwnerId :' + selectedOwnerId);		
	}
	
	/* @Method <This Method is used to reset variable used>. 
        @param <It is not taking any parameters>
        @return <void>
        @throws exception - <No Exception>
    */
	private void resetFlags(){
		lstUser.clear();
		lstQueue.clear();	
		isUserResult = false;
		isQueueResult = false;
	}
	
	/* @Method <This property is used to display user record on page>. 
        @param <It is not taking any parameters>
        @return <List<User>>
        @throws exception - <No Exception>
    */
	public List<User> getUserRecords(){
		return lstUser;
	}
	
	/* @Method <This property is used to display queue record on page>. 
        @param <It is not taking any parameters>
        @return <List<Queue>>
        @throws exception - <No Exception>
    */
	public List<QueueSobject> getQueueRecords(){
		return lstQueue;
	}
	
	/* @Property <This property is used to display search option on page>. 
        @param <It is not taking any parameters>
        @return <List<String>>
        @throws exception - <No Exception>
    */
	public List<SelectOption> getItems() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('User','User'));
		options.add(new SelectOption('Queue','Queue'));
		if(Userinfo.getUserType() !='PowerPartner'){
			options.add(new SelectOption('PartnerUser','Partner User'));
		}
		return options;
	}
}