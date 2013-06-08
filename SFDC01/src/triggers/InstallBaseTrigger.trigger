trigger InstallBaseTrigger on Install_Base__c (after undelete, after delete, after insert, after update)
{
	if(Trigger.isDelete)
		InstallBaseServices.updateAccountInstallBaseProductsAndFamilies(Trigger.old);
	else
		InstallBaseServices.updateAccountInstallBaseProductsAndFamilies(Trigger.new);
}