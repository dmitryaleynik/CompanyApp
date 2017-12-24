/**
 * Created by HP on 22.11.2017.
 */
public class TrackService
{
    public static List<Track__c> getRelatedTrack (List<Mix__c> mixes)
    {
        Set<Id> mixesID = new Set<Id>();
        for (Mix__c mix : mixes)
        {
            mixesID.add(mix.Id);
        }
        return [SELECT name,Song__c FROM Track__c WHERE Mix__c IN :mixesId];
    }

}