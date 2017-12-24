trigger TrackTrigger on  Track__c(after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
	TriggerTemplate.TriggerManager triggerManager = new TriggerTemplate.TriggerManager();
	triggerManager.addHandler(new TrackHandler(), new List<TriggerTemplate.TriggerAction>{
			TriggerTemplate.TriggerAction.afterUpdate, TriggerTemplate.TriggerAction.afterInsert,
			TriggerTemplate.TriggerAction.afterUndelete, Triggertemplate.TriggerAction.afterDelete
			});

	triggerManager.runHandlers();
}