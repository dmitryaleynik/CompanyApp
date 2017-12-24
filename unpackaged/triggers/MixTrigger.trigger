trigger MixTrigger on Mix__c (after insert, after update, after delete, after undelete)
{
	TriggerTemplate.TriggerManager triggerManager = new TriggerTemplate.TriggerManager();
	triggerManager.addHandler(new MixHandler(),  new List <TriggerTemplate.TriggerAction> {
		TriggerTemplate.TriggerAction.afterUpdate, TriggerTemplate.TriggerAction.afterInsert, TriggerTemplate.TriggerAction.afterDelete,
		TriggerTemplate.TriggerAction.afterUndelete
			});
	triggerManager.runHandlers();
}