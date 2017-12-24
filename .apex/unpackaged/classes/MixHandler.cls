/**
 * Created by HP on 22.11.2017.
 */
public class MixHandler implements  TriggerTemplate.Handler
{
    private List<Mix__c> newValues;
    private List<Mix__c> oldValues;
    private Map<Id, Mix__c> oldMap;
    private Map<Id, Mix__c> newMap;

    public  void setValues (List<sObject> newValues, List<sObject> oldValues, Map<Id,sObject> newMap ,Map<Id,sObject> oldMap)
    {
        this.newValues = newValues;
        this.oldValues = oldValues;
        this.oldMap = (Map<Id, Mix__c>) oldMap;
    }
    
    public void handle (TriggerTemplate.TriggerAction action) 
    {
        if (action == TriggerTemplate.TriggerAction.afterDelete)
        {
            List<Track__c> relatedTracks = TrackService.getRelatedTrack(oldValues);
			Map<Id,Track__c> relatedTracksMap = new Map<Id, Track__c>(relatedTracks);
			Set <Id> songIds = Utils.getParentIds(relatedTracks, 'Song__c');
			Map<Id,Song__c> relatedSongs = SongService.getRelatedSongs(songIDs);
			SongService.recalculateTrCount(relatedSongs, relatedTracksMap);
        }
        if (action == TriggerTemplate.TriggerAction.afterUndelete)
        {
			List<Track__c> relatedTracks = TrackService.getRelatedTrack(newValues);
			Map<Id,Track__c> relatedTracksMap = new Map<Id, Track__c>(relatedTracks);
			Set <Id> songIds = Utils.getParentIds(relatedTracks, 'Song__c');
			Map<Id,Song__c> relatedSongs = SongService.getRelatedSongs(songIDs);
			SongService.recalculateTrCount(relatedSongs, relatedTracksMap);

        }
    }
}