public with sharing class LoopAccount {
	/*test comment*/
	public LoopAccount()
	{
		System.debug('Inside the constructor');
		List<Account> rec = [SELECT Id, Name FROM Account LIMIT 10];
		System.debug('The size of the list is '+rec.size());
		//Get an interator
		
		Iterator<Account> it = rec.iterator();
		while(it.hasNext())
		{
			Account obj= it.next();
			System.debug('Name : '+obj.Name);		
		}
	}
	public void dummyMethod()
	{
		system.debug('DONE DONA DUN DONE');
	}
}