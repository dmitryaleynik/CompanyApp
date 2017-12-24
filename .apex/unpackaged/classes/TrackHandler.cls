public without sharing class TrackHandler implements TriggerTemplate.Handler
{
	private List<Track__c> newValues;
	private List<Track__c> oldValues;
	private Map<Id, Track__c> oldMap;
	private Map<Id, Track__c> newMap;

	public void setValues(List<sObject> newValues, List<sObject> oldValues, Map<Id,sObject> newMap ,Map<Id, sObject> oldMap)
	{
			this.newValues = newValues;
			this.oldValues = oldValues;
		    this.newMap = (Map<Id,Track__c>)newMap;
			this.oldMap = (Map<Id, Track__c>)oldMap;
	}

	public void handle(TriggerTemplate.TriggerAction action)
    {
			if (action == TriggerTemplate.TriggerAction.afterUpdate)
			{
				List<Track__c> modSongIdTracks = Utils.getModifiedObjects(new List<String>{'Song__c'},
						newValues,oldValues);
				Set <Id> songIds = Utils.getParentIds(modSongIdTracks, 'Song__c');
				Map<Id,Song__c> relatedSongs = SongService.getRelatedSongs(songIDs);
				SongService.recalculateTrCount(relatedSongs,newMap);
				Set <Id> mixIds = Utils.getParentIds(modSongIdTracks,'Mix__c');
				Map <Id, Mix__c> mapMix = MixService.getRelatedMixes(mixIDs);
				MixService.setGenre(mapMix);
			}

			if (action == TriggerTemplate.TriggerAction.afterInsert)
			{
				Set <Id> songIds = Utils.getParentIds(newValues, 'Song__c');
				Map<Id,Song__c> relatedSongs = SongService.getRelatedSongs(songIDs);
				SongService.recalculateTrCount(relatedSongs,newMap);
				Set <Id> mixIds = Utils.getParentIds(newValues,'Mix__c');
				Map <Id, Mix__c> mapMix = MixService.getRelatedMixes(mixIDs);
				MixService.setGenre(mapMix);
			}

			if (action == TriggerTemplate.TriggerAction.afterUndelete)
			{
				Set <Id> songIds = Utils.getParentIds(newValues, 'Song__c');
				Map<Id,Song__c> relatedSongs = SongService.getRelatedSongs(songIDs);
				SongService.recalculateTrCount(relatedSongs,newMap);
				Set <Id> mixIds = Utils.getParentIds(newValues,'Mix__c');
				Map <Id, Mix__c> mapMix = MixService.getRelatedMixes(mixIDs);
				MixService.setGenre(mapMix);
			}
			if (action == TriggerTemplate.TriggerAction.afterDelete)
            {
				Set <Id> songIds = Utils.getParentIds(oldValues, 'Song__c');
				Map<Id,Song__c> relatedSongs = SongService.getRelatedSongs(songIDs);
				SongService.recalculateTrCount(relatedSongs,newMap);
				Set <Id> mixIds = Utils.getParentIds(oldValues,'Mix__c');
				Map <Id, Mix__c> mapMix = MixService.getRelatedMixes(mixIDs);
				MixService.setGenre(mapMix);
			}
		}
}