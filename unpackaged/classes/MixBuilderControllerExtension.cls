/**
 * Created by HP on 21.12.2017.
 */
public with sharing class MixBuilderControllerExtension
{

	public Id mixID{get;set;}
	public Mix__c mix {get;set;}
	public List<WrapperResult> wrapper {get; set;}
	public Set <Id> usedTrackIds {get; set;}
	public Set <Id> deleteTrackIds {get; set;}
	public Set<Id> insertTrackIds {get;set;}
	public Integer mixTrackCount {get; set;}
	public Id clickedSongId {get;set;}
	public Double mixLength {get; set;}
	public Integer remMixTracks {get; set;}
	public Double remMixLength {get; set;}
	public String filter {get; set;}


	public ApexPages.StandardController stController;

	private ApexPages.StandardSetController setController;

	public MixBuilderControllerExtension(ApexPages.StandardController standardController)
		{
			this.stController = standardController;
			mixID = ApexPages.currentPage().getParameters().get('Id');
			wrapper = new List<WrapperResult>();
			usedTrackIds = new Set<Id>();
			insertTrackIds = new Set<Id>();
			deleteTrackIds = new Set<Id>();
			filter = 'Any';

			if (mixID == null)
			{
				mix = new Mix__c();
				filterSongs();
				updateTable();
			} else
			{
				usedTrackIds = SongService.getUsedSongId(mixId);
				filterSongs();
				updateTable();
				mix = MixService.getMixById(mixID);
				updateMixCount();
				updateMixLength();
				updateRemMixLength();
				updateRemMixCount();
			}
		}

	public void first()
	{
		setController.first();
		updateTable();
	}

	public void last()
	{
		setController.last();
		updateTable();
	}

	public void next()
	{
		setController.next();
		updateTable();
	}

	public void previous()
	{
		setController.previous();
		updateTable();
	}

	public boolean hasNext()
	{
		return setController.getHasNext();
	}

	public boolean hasPrevious()
	{
		return setController.getHasPrevious();
	}

	public void filterSongs()
	{
		List<Song__c> filteredSongs;
		if (filter.equals('Any'))
		{
			filteredSongs = [SELECT Name, Genre__c, Length_m__c
					FROM Song__c
			ORDER BY Name];

		} else
		{
			filteredSongs = [SELECT Name, Genre__c, Length_m__c
					FROM Song__c
					WHERE Genre__c = :filter
			ORDER BY Name];

		}
		setController = new ApexPages.StandardSetController(filteredSongs);
		setController.setPageSize(5);
		wrapper.clear();
		for (Song__c song :(List<Song__c>)setController.getRecords())
		{
			System.debug(song);
			if (usedTrackIds.contains(song.Id))
			{
				wrapper.add(new WrapperResult(this, song, true));
			} else
			{
				wrapper.add(new WrapperResult(song));
			}
		}
	}

	public void updateTable()
	{
		wrapper.clear();
		for (Song__c song :(List<Song__c>)setController.getRecords())
		{
			System.debug(song);
			if (usedTrackIds.contains(song.Id))
			{
				wrapper.add(new WrapperResult(this, song, true));
			} else
			{
				wrapper.add(new WrapperResult(song));
			}
		}
		System.debug(wrapper);
	}

	public PageReference save()
	{
		Savepoint sp = Database.setSavepoint();
		try
		{
			upsert mix;
			Map <Id, Song__c> nameOfSongsMap = new Map<Id, Song__c>([SELECT Name
					FROM Song__c
					WHERE Id in :usedTrackIds OR
			Id in :insertTrackIds ]);
			List<Track__c> tracksToAdd = new List<Track__c>();
			for (Id songId : insertTrackIds)
			{
				Song__c currentSong = nameOfSongsMap.get(songId);
				tracksToAdd.add(new Track__c(name = currentSong.Name + 'Track',
						Mix__c = mix.Id, Song__c = songId));
			}
			List <Track__c> tracksToDelete = new List<Track__c>();
			tracksToDelete = [SELECT Name, Mix__c, Song__c
					FROM Track__c
					WHERE Mix__c = :mix.Id AND
			Song__c in :deleteTrackIds ];
			if (tracksToDelete.size() != 0)
			{
				System.debug(tracksToDelete);
				Database.DeleteResult [] results = Database.delete(tracksToDelete, false);
				for (Database.DeleteResult res :results)
				{
					System.debug(res.isSuccess());
				}
			}


			if (tracksToAdd.size() != 0)
			{
				System.debug(tracksToAdd);
				Database.SaveResult [] results = Database.insert(tracksToAdd, false);
				for (Database.SaveResult saveResult : results)
				{
					if (saveResult.isSuccess() == false)
					{

					}
				}

			}


			insertTrackIds.clear();
			deleteTrackIds.clear();
			usedTrackIds = SongService.getUsedSongId(mixId);

			return null;

		} catch (Exception i)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, i.getMessage()));
			Database.rollback(sp);
			return null;

		}

	}

	public void updateMixLength()
	{
		this.mixLength = SongService.getLengthOfSongs(usedTrackIds);
	}

	public void updateRemMixLength()
	{
		this.remMixLength = 100 - SongService.getLengthOfSongs(usedTrackIds);
	}

	public void updateMixCount()
	{
		this.mixTrackCount = usedTrackIds.size();
	}

	public void updateRemMixCount()
	{
		this.remMixTracks = 20 - usedTrackIds.size();
	}

	public List<SelectOption> getItems()
	{
		List <SelectOption> options = new List<SelectOption>();
		List<PicklistEntry> availableGenres = Song__c.Genre__c.getDescribe().getPicklistValues();
		options.add(new SelectOption('Any', 'Any'));
		for (PicklistEntry genre :availableGenres)
		{
			options.add(new SelectOption(genre.getValue(), genre.getValue()));
		}
		return options;
	}

	public void changeUsedSongs()
	{
		try
		{
			if (!usedTrackIds.remove(this.clickedSongId))
			{
				usedTrackIds.add(this.clickedSongId);
				insertTrackIds.add(this.clickedSongId);
				deleteTrackIds.remove(this.clickedSongId);

			} else
			{
				insertTrackIds.remove(this.clickedSongId);
				deleteTrackIds.add(this.clickedSongId);
			}

			updateRemMixLength();
			updateMixLength();
			updateMixCount();
			updateRemMixCount();
			System.debug(usedTrackIds);
		} catch (Exception i)
		{

		}
	}

	public class WrapperResult
	{
		public Boolean isSelected {
			get;set;
		}
		public Song__c song {
			get;set;
		}
		public MixBuilderControllerExtension outerClass;

		public WrapperResult(Song__c song)
			{
				this.song = song;
				this.isSelected = false;
			}

		public WrapperResult(MixBuilderControllerExtension outerClass, Song__c song, Boolean isSelected)
			{
				this.outerClass = outerClass;
				this.song = song;
				this.isSelected = isSelected;
			}

	}
}