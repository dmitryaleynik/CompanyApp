/**
 * Created by HP on 28.11.2017.
 */
public class Utils
{
    public static Set<Id> getParentIds (List<sObject> objects, String parentIdName)
    {
        Set<Id> parentIds = new Set <Id>();
        for ( sObject obj : objects)
        {
            Id currParentId = (Id)obj.get(parentIdName);
            parentIds.add(currParentId);
        }
        return parentIds;

    }
    public static List<sObject> getModifiedObjects(List<String> fields, List<sObject> newValues,
                                                   List<sObject> oldValues)
    {
        List<sObject> modifiedObjects = new List<sObject>();
        for (Integer i = 0; i<newValues.size(); i++)
        {
            for (String field : fields)
            {
                if (newValues.get(i).get(field) != oldValues.get(i).get(field))
                {
                    modifiedObjects.add(newValues.get(i));
                    modifiedObjects.add(oldValues.get(i));
                }
            }
        }
        return  modifiedObjects;

    }

}