trigger UpdateTrackCount on Track__c (after insert, after update,  after delete, after undelete) {
    if (   Trigger.isInsert || Trigger.isUndelete) {
        Set <Id> usedSongId = new Set <Id>();   // set of the ids of the songs we need to update
        for (Track__c track : Trigger.New) {
            usedSongId.add(track.Song__c);
        }
        Map <Id, Song__c> songs = new Map  <Id, Song__c> ([SELECT id, Track_Count__c, Track_Licenses__c FROM Song__c WHERE Id in :usedSongId ]);
        for (Track__c track : Trigger.New) {
            Song__c currentSong =  songs.get(track.Song__c);
            if (currentSong.Track_Count__c == currentSong.Track_Licenses__c) {
                track.addError('You exeeded the limits of using that song.');
            }
            else {
                currentSong.Track_Count__c++;  
                usedSongId.add(currentSong.Id);
            }           
        }
        update songs.values();
        
    }
    if(Trigger.isDelete) {
        Set <Id> usedSongId = new Set <Id>();
        for (Track__c track : Trigger.Old) {
            usedSongId.add(track.Song__c);
        }
        Map <Id, Song__c> songs = new Map  <Id, Song__c> ([SELECT id, Track_Count__c, Track_Licenses__c FROM Song__c WHERE Id in :usedSongId ]);
        for (Track__c track : Trigger.Old) {
            Song__c currentSong =  songs.get(track.Song__c);
            currentSong.Track_Count__c--;
        }

        update songs.values();
        
    }
   if(Trigger.isUpdate) {
        Set <Id> usedSongId = new Set <Id>();
       for (Track__c track : Trigger.New) {
           usedSongId.add(track.Song__c);
       }
        Map <Id, Song__c> songs = new Map  <Id, Song__c> ([SELECT id, Track_Count__c, Track_Licenses__c FROM Song__c WHERE Id in :usedSongId]);
        for (Track__c track : Trigger.New) {
           Song__c currentSong = songs.get(track.Song__c);
           Song__c laterSong = songs.get(Trigger.OldMap.get(track.Id).Song__c);
           if (laterSong != currentSong ) {
               if(currentSong.Track_Count__c == currentSong.Track_Licenses__c){
                   track.addError('You exeeded the limits of using that song.');
               }   
               else {
                   laterSong.Track_Count__c--;
                   currentSong.Track_Count__c++;
               }
           }
               
                      
       }
      update songs.values();
    }
}