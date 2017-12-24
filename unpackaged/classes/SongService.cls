/**
 * Created by HP on 22.11.2017.
 */
public class SongService
{
	public static void recalculateTrCount (Map<Id,Song__c> mapSong, Map<Id, Track__c> newMap)
		{
			for (Song__c song : mapSong.values())
				{
					Integer trackCount = song.Tracks__r.size();
					Integer trackLicence = (Integer)song.Track_Licenses__c;
					if(trackCount > trackLicence)
					{
						for (Track__c track : song.Tracks__r )
							{
								Track__c  triggerContextTrack = newMap.get(track.Id);
								if ( triggerContextTrack != null)
								{
									System.debug('Errrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrror');
									triggerContextTrack.addError('You exeeded the limits of using that song.');
								}
							}
					} else
					{
						song.Track_Count__c = trackCount;
					}
				}
			update mapSong.values();
		}

	public static Map<Id, Song__c> getRelatedSongs (Set<Id> relatedSongsID)
	{
		Map<Id,Song__c> relatedSongs = new Map <Id,Song__c> ([SELECT name,Genre__c, Track_Count__c, Track_Licenses__c,
				(SELECT  Name,Song__c
						FROM  Tracks__r)
				FROM  Song__c
				WHERE Id in : relatedSongsID]);
		return relatedSongs;
	}
	public static Set<Id> getUsedSongId (Id mixId){
		Set<Id> songId = new Set<Id>();
		List <Track__c> usedTrack = [SELECT Mix__c, Song__r.Id
		                             FROM Track__c
		                             where Mix__c = :mixID];
		for (Track__c track : usedTrack){
			songId.add(track.Song__r.Id);
		}
		return  songID;
	}
	public static Double getLengthOfSongs(Set<Id> songId){
		if (songId.size() == 0){
			return 0;
		}
		AggregateResult aggregateResult = [SELECT  SUM(Length_m__c) sum
		                                   FROM Song__c
		                                   WHERE Id in :songId];
		Double result = (Double) aggregateResult.get('sum');
		return result;
	}



}