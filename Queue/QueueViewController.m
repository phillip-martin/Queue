//
//  QueueViewController.m
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "QueueViewController.h"
#import "QueueTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface QueueViewController ()

@end

@implementation QueueViewController

@synthesize songQueue;
@synthesize mainPlayer;
@synthesize voteCount;
@synthesize nowPlayingItem;
@synthesize nowPlayingLabel;
@synthesize artworkItem;
@synthesize artistLabel;
@synthesize pausePlay;
@synthesize songProgress;
@synthesize playing;
@synthesize interruptedOnPlayback;


-(id)init
{
    self = [super self];
    
    return self;
}


- (void) handle_NowPlayingItemChanged: (id) notification {
    
    MPMediaItem *currentItem = [mainPlayer nowPlayingItem];
    
    // Assume that there is no artwork for the media item.
    [artworkItem setImage:[UIImage imageNamed:@"no_artwork.png"]];
    
    // Get the artwork from the current media item, if it has artwork.
    MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
    
    // Obtain a UIImage object from the MPMediaItemArtwork object
    if (artwork) {
        artworkItem.image = [artwork imageWithSize: CGSizeMake (250, 250)];
    }
    
    
    // Display the artist and song name for the now-playing media item
    [nowPlayingLabel setText: [
                               NSString stringWithFormat: @"%@", NSLocalizedString([currentItem valueForProperty: MPMediaItemPropertyTitle], @"song title")]];
     [artistLabel setText: [ NSString stringWithFormat:@"%@", NSLocalizedString([currentItem valueForProperty: MPMediaItemPropertyArtist], @"artist")]];
    
    if (mainPlayer.playbackState == MPMusicPlaybackStateStopped) {
        // Provide a suitable prompt to the user now that their chosen music has
        //		finished playing.
        [nowPlayingLabel setText: [
                                   NSString stringWithFormat: @"%@",
                                   NSLocalizedString (@"Music-ended Instructions", @"Label for prompting user to play music again after it has stopped")]];
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mainPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    
    [songProgress setValue:[mainPlayer currentPlaybackTime] animated:YES];
    [artworkItem setImage:[UIImage imageNamed:@"no_artwork.png"]];
	[nowPlayingLabel setText: NSLocalizedString (@"Instructions", @"Brief instructions to user, shown at launch")];
    [pausePlay setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
    [self registerForMediaPlayerNotifications];
    
    self.tabBarItem.image = [UIImage imageNamed:@"no_artwork.png"];
    self.tabBarItem.title = @"Now Playing";
    NSLog(@"loaded main view");
    
	    
}


- (void) registerForMediaPlayerNotifications {
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
	[notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: mainPlayer];
    [mainPlayer beginGeneratingPlaybackNotifications];
}


- (void) audioPlayerBeginInterruption: player {
    
	NSLog (@"Interrupted. The system has paused audio playback.");
	
	if (playing) {
        
		playing = NO;
		interruptedOnPlayback = YES;
	}
}

- (void) audioPlayerEndInterruption: player {
    
	NSLog (@"Interruption ended. Resuming audio playback.");
	
	// Reactivates the audio session, whether or not audio was playing
	//		when the interruption arrived.
	
	if (interruptedOnPlayback) {
        
		[mainPlayer play];
		playing = YES;
		interruptedOnPlayback = NO;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pauseOrPlayMusic:(id)sender
{
    MPMusicPlaybackState playbackState = [mainPlayer playbackState];
    
	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
		[mainPlayer play];
        [pausePlay setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateSelected];
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[mainPlayer pause];
        [pausePlay setImage:[UIImage imageNamed:@"pause_button.png"] forState:UIControlStateSelected];
	}
}

- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
    
	// Configure the music player, but only if the user chose at least one song to play
	if (mediaItemCollection) {
        
		// If there's no playback queue yet...
		if (songQueue == nil) {
            
            [self setSongQueue:mediaItemCollection];
			[mainPlayer setQueueWithItemCollection: songQueue];
			[mainPlayer play];
            
            // Obtain the music player's state so it can then be
            //		restored after updating the playback queue.
		} else {
            
			// Take note of whether or not the music player is playing. If it is
			//		it needs to be started again at the end of this method.
			BOOL wasPlaying = NO;
			if (mainPlayer.playbackState == MPMusicPlaybackStatePlaying) {
				wasPlaying = YES;
			}
			
			// Save the now-playing item and its current playback time.
			MPMediaItem *nowPlaying			= mainPlayer.nowPlayingItem;
			NSTimeInterval currentPlaybackTime	= mainPlayer.currentPlaybackTime;
            
			// Combine the previously-existing media item collection with the new one
			NSMutableArray *combinedMediaItems	= [[songQueue items] mutableCopy];
			NSArray *newMediaItems				= [mediaItemCollection items];
			[combinedMediaItems addObjectsFromArray: newMediaItems];
			
            [self setSongQueue:[MPMediaItemCollection collectionWithItems: combinedMediaItems]];
			[mainPlayer setQueueWithItemCollection: songQueue];
            
            
            
			// Apply the new media item collection as a playback queue for the music player.
			[mainPlayer setQueueWithItemCollection: songQueue];
			
			// Restore the now-playing item and its current playback time.
			mainPlayer.nowPlayingItem			= nowPlaying;
			mainPlayer.currentPlaybackTime		= currentPlaybackTime;
			
			// If the music player was playing, get it playing again.
			if (wasPlaying) {
				[mainPlayer play];
			
            }
        
        
		/*[addSong setTitle: NSLocalizedString (@"Show Music", @"Alternate title for 'Add Music' button, after user has chosen some music")
                 forState: UIControlStateNormal];*/ //not sure if we want the add button in this view controller?
        }
    }
  

}
@end









