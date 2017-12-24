public class MixBuilderController 
{
    private Id mixID;
    public Mix__c mix {get;set;}
    public List<WrapperResult> wrapper {get; set;}
    public  Set <Id> usedSongId {get; set;}
	public Set <Id> deletedSongsId {get; set;}
	public Set<Id> newSongsId {get;set;}
    public Integer mixTrackCount {get; set;}
    public Id clickedSongId {get;set;}
    public Double  mixLength {get; set;}
    public Integer remMixTracks {get; set;}
    public Double remMixLength {get; set;}
    public String filter {get; set;}

    public ApexPages.StandardSetController standardSetController {
    get{
		System.debug('I am in get method');
        if (standardSetController == null){
            List<Song__c> filteredSongs;

            if (filter.equals('Any'))
            {
                filteredSongs = [SELECT Name, Genre__c, Length_m__c
                        FROM Song__c
                ORDER BY  Name];

            }
            else
            {
                filteredSongs = [SELECT Name, Genre__c, Length_m__c
                        FROM Song__c
                        WHERE Genre__c = :filter
                ORDER BY  Name];
            }
            standardSetController = new ApexPages.StandardSetController(filteredSongs);
            standardSetController.setPageSize(5);

        }
        return standardSetController;
    }
        set{}

}

    public MixBuilderController ()
    {
        mixID = ApexPages.currentPage().getParameters().get('Id');
        wrapper = new List<WrapperResult>();
        usedSongId = new Set<Id>();
		newSongsId = new Set<Id>();
		deletedSongsId = new Set<Id>();
        filter = 'Any';

        if (mixID == null)
        {
            updateTable();
        }else
        {
            usedSongId = SongService.getUsedSongId(mixId);
            updateTable();
            mix = MixService.getMixById(mixID);
            updateMixCount();
            updateMixLength();
            updateRemMixLength();
            updateRemMixCount();
        }
    }
    public void first(){
        standardSetController.first();
        updateTable();
    }
    public void  last(){
        standardSetController.last();
        updateTable();
    }
    public void next(){
        standardSetController.next();
        updateTable();
    }
    public void previous(){
        standardSetController.previous();
        updateTable();
    }

    public  boolean hasNext(){
        return standardSetController.getHasNext();
    }
    public boolean hasPrevious(){
        return standardSetController.getHasPrevious();
    }

    public void updateTable ()
    {
		System.debug('I am in the update method');
		System.debug(filter);
        List<Song__c> filteredSongs;
        if (filter.equals('Any'))
        {
            filteredSongs = [SELECT Name, Genre__c, Length_m__c
                             FROM Song__c
                                ORDER BY  Name];

        }
        else
        {
			filteredSongs =  [SELECT Name, Genre__c, Length_m__c
			                  FROM Song__c
			                  WHERE Genre__c = :filter
			                     ORDER BY Name];

        }
		System.debug(filteredSongs);
		standardSetController = new ApexPages.StandardSetController(filteredSongs);

		System.debug(standardSetController);
		System.debug(standardSetController.getRecords());
        wrapper.clear();
        for ( Song__c song :(List<Song__c>)standardSetController.getRecords() )
        {
            System.debug(song);
            if(usedSongId.contains(song.Id))
            {
                wrapper.add(new WrapperResult(this, song, true));
            }
            else
            {
                wrapper.add(new WrapperResult(song));
            }
        }
        System.debug(wrapper);
    }

    public PageReference save()
    {
		Savepoint sp = Database.setSavepoint();
		try {
			if( mixID == null){
				mix = new Mix__c();
			}
			upsert  mix;
			List<Track__c> tracksToAdd = new List<Track__c>();
			Integer i =0;
			for( Id songId : newSongsId){
				i++;
			  tracksToAdd.add(new Track__c(name = 'Track' + i + mix.Name, Mix__c = mix.Id,Song__c = songId));
			}
			List <Track__c> tracksToDelete = new List<Track__c>();
			tracksToDelete = [SELECT Name, Mix__c, Song__c
			                 FROM  Track__c
			                 WHERE  Mix__c = :mix.Id AND Song__c in :deletedSongsId ];
			if (tracksToDelete.size() != 0){
				System.debug(tracksToDelete);
				Database.DeleteResult [] reses = Database.delete(tracksToDelete,false);
				for ( Database.DeleteResult res :reses){
					System.debug(res.isSuccess());
				}
			}
			if(tracksToAdd.size() != 0){
				System.debug(tracksToAdd);
				Database.insert(tracksToAdd,false);
			}
			newSongsId.clear();
			deletedSongsId.clear();
			usedSongId = SongService.getUsedSongId(mixId);

			return null;

		}catch (Exception i){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,i.getMessage()));
			Database.rollback(sp);
			return null;

		}

    }
    public void updateMixLength ()
    {
        this.mixLength = SongService.getLengthOfSongs(usedSongId);
    }
    public void updateRemMixLength ()
    {
        this.remMixLength = 100 - SongService.getLengthOfSongs(usedSongId);
    }
    public void updateMixCount ()
    {
        this.mixTrackCount = usedSongId.size();
    }
    public void updateRemMixCount ()
    {
        this.remMixTracks = 20 - usedSongId.size();
    }

    public List<SelectOption> getItems ()
    {
        List <SelectOption> options = new List<SelectOption>();
        List<PicklistEntry> availableGenres = Song__c.Genre__c.getDescribe().getPicklistValues();
        options.add(new SelectOption('Any','Any'));
        for (PicklistEntry genre :availableGenres)
        {
            options.add(new SelectOption(genre.getValue() ,genre.getValue()));
        }
        return options;
    }

    public void changeUsedSongs ()
    {
        if (!usedSongId.remove(this.clickedSongId))
        {
            usedSongId.add(this.clickedSongId);
			newSongsId.add(this.clickedSongId);
			deletedSongsId.remove(this.clickedSongId);

        }else{
			newSongsId.remove(this.clickedSongId);
			deletedSongsId.add(this.clickedSongId);
		}
        updateRemMixLength();
        updateMixLength();
        updateMixCount();
        updateRemMixCount();
        System.debug(usedSongId);
    }

     public class WrapperResult
    {
        public Boolean isSelected {get;set;}
        public Song__c song {get;set;}
        public MixBuilderController outerClass;
        public WrapperResult (Song__c song)
        {
            this.song = song;
            this.isSelected = false;
        }

        public WrapperResult (MixBuilderController outerClass, Song__c song,Boolean isSelected)
        {
            this.outerClass = outerClass;
            this.song = song;
            this.isSelected = isSelected;
        }

    }
}