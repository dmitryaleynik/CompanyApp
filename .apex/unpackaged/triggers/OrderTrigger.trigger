trigger OrderTrigger on Order__c (before insert, after insert, after update, before update,
                                  after delete, after undelete)
{
    TriggerTemplate.TriggerManager manager = new TriggerTemplate.TriggerManager();
    manager.addHandler(new OrderHandler(),new List<TriggerTemplate.TriggerAction>
                                                    { TriggerTemplate.TriggerAction.beforeInsert,
                                                      TriggerTemplate.TriggerAction.afterInsert,
                                                      TriggerTemplate.TriggerAction.afterUpdate,
                                                      TriggerTemplate.TriggerAction.beforeUpdate,
                                                      TriggerTemplate.TriggerAction.afterUndelete,
                                                      TriggerTemplate.TriggerAction.afterDelete});
    manager.runHandlers();

}