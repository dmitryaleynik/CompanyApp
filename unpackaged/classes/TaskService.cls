/**
 * Created by HP on 04.12.2017.
 */
public class TaskService {

    public static void createTask(List<Order__c> orders)
    {
        List<Task> relatedTasks = new List<Task> ();
        for(Order__c order : orders)
            {
                Task relTask = new Task (Priority = 'High', Status = 'Not Started',
                        Subject = 'Prepare Order - ' + order.Name,
                        OwnerId  = System.UserInfo.getUserId(),
                        Description = order.Description__c
                        );
                relatedTasks.add(relTask);

            }
       insert relatedTasks;
    }
}