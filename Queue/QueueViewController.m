//
//  QueueViewController.m
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "QueueViewController.h"
#import "SongStruct.h"
#import "BTLEViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface QueueViewController ()

@end

// Audio session callback function for responding to audio route changes. If playing
//		back application audio when the headset is unplugged, this callback pauses
//		playback and displays an alert that allows the user to resume or stop playback.
//
//		The system takes care of iPod audio pausing during route changes--this callback
//		is not involved with pausing playback of iPod audio.
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
	
	// ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
	// This callback, being outside the implementation block, needs a reference to the
	//		MainViewController object, which it receives in the inUserData parameter.
	//		You provide this reference when registering this callback (see the call to
	//		AudioSessionAddPropertyListener).
	QueueViewController *controller = (__bridge QueueViewController *) inUserData;
	
	// if application sound is not playing, there's nothing to do, so return.
	if (controller.appPlayer.playing == 0 ) {
        
		NSLog (@"Audio route change while application audio is stopped.");
		return;
		
	} else {
        
		// Determines the reason for the route change, to ensure that it is not
		//		because of a category change.
		CFDictionaryRef	routeChangeDictionary = inPropertyValue;
		
		CFNumberRef routeChangeReasonRef =
        CFDictionaryGetValue (
                              routeChangeDictionary,
                              CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                              );
        
		SInt32 routeChangeReason;
		
		CFNumberGetValue (
                          routeChangeReasonRef,
                          kCFNumberSInt32Type,
                          &routeChangeReason
                          );
		
		// "Old device unavailable" indicates that a headset was unplugged, or that the
		//	device was removed from a dock connector that supports audio output. This is
		//	the recommended test for when to pause audio.
		if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            
			[controller.mainPlayer pause];
			NSLog (@"Output device removed, so application audio was paused.");
            
			UIAlertView *routeChangeAlertView =
            [[UIAlertView alloc]	initWithTitle: NSLocalizedString (@"Playback Paused", @"Title for audio hardware route-changed alert view")
                                       message: NSLocalizedString (@"Audio output was changed", @"Explanation for route-changed alert view")
                                      delegate: controller
                             cancelButtonTitle: NSLocalizedString (@"StopPlaybackAfterRouteChange", @"Stop button title")
                             otherButtonTitles: NSLocalizedString (@"ResumePlaybackAfterRouteChange", @"Play button title"), nil];
			[routeChangeAlertView show];
			// release takes place in alertView:clickedButtonAtIndex: method
            
		} else {
            
			NSLog (@"A route change occurred that does not require pausing of application audio.");
		}
	}
}



@implementation QueueViewController

@synthesize songQueue;
@synthesize soundFileURL;
@synthesize mainPlayer;
@synthesize appPlayer;
@synthesize voteCount;
@synthesize nowPlayingItem;
@synthesize nowPlayingLabel;
@synthesize artworkItem;
@synthesize artistLabel;
@synthesize pausePlay;
@synthesize songProgress;
@synthesize playing;
@synthesize interruptedOnPlayback;
@synthesize myLibrary;


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

+(id)sharedInstance{
    static QueueViewController *controller;
    
    @synchronized(self)
    {
        if (controller == NULL)
            controller = [[self alloc] init];
    }
    
    
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mainPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    
    [songProgress setValue:[mainPlayer currentPlaybackTime] animated:YES];
    [artworkItem setImage:[UIImage imageNamed:@"no_artwork.png"]];
	[nowPlayingLabel setText: NSLocalizedString (@"Song_title", @"Brief instructions to user, shown at launch")];
    [artistLabel setText:NSLocalizedString(@"Artist_here", @"Artist")];
    [self registerForMediaPlayerNotifications];
    
    self.tabBarItem.image = [UIImage imageNamed:@"no_artwork.png"];
    self.tabBarItem.title = @"Now Playing";
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpg"]]];
    [self setMainPlayer: [MPMusicPlayerController applicationMusicPlayer]];
    
    // By default, an application music player takes on the shuffle and repeat modes
    //		of the built-in iPod app. Here they are both turned off.
    [mainPlayer setShuffleMode: MPMusicShuffleModeOff];
    [mainPlayer setRepeatMode: MPMusicRepeatModeNone];
    
    //load our itunes library regardless of whether we are a host or not
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *tempTitle = [NSString stringWithFormat:NSLocalizedString([song valueForProperty:MPMediaItemPropertyTitle],@"title")];
        NSString *tempArtist = [NSString stringWithFormat:NSLocalizedString([song valueForProperty:MPMediaItemPropertyArtist],@"artist")];
        SongStruct *newSong = [[SongStruct alloc] initWithTitle:tempTitle artist:tempArtist voteCount:0];
        NSString *tempID = [NSString stringWithFormat:@"%@",newSong.strIdentifier];
        [myLibrary setObject:newSong forKey:tempID];
        NSLog (@"%@", tempTitle);
    }
    
    
	    
}

// If the music player was paused, leave it paused. If it was playing, it will continue to
//		play on its own. The music player state is "stopped" only if the previous list of songs
//		had finished or if this is the first time the user has chosen songs after app
//		launch--in which case, invoke play.
- (void) restorePlaybackState {
    
	if (mainPlayer.playbackState == MPMusicPlaybackStateStopped && songQueue) {
		
		[mainPlayer play];
	}
    
}

- (void) registerForMediaPlayerNotifications {
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
	[notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: mainPlayer];
    [mainPlayer beginGeneratingPlaybackNotifications];
}

- (IBAction) playAppSound: (id) sender {
    
	[mainPlayer play];
	playing = YES;
	[pausePlay setEnabled: NO];
}

// delegate method for the audio route change alert view; follows the protocol specified
//	in the UIAlertViewDelegate protocol.
- (void) alertView: routeChangeAlertView clickedButtonAtIndex: buttonIndex {
    
	if ((NSInteger) buttonIndex == 1) {
		[mainPlayer play];
	} else {
		[appPlayer setCurrentTime: 0];
		[pausePlay setEnabled: YES];
	}
	
}



#pragma mark AV Foundation delegate methods____________

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) appSoundPlayer successfully: (BOOL) flag {
    
	playing = NO;
	[pausePlay setEnabled: YES];
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
        //[pausePlay setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateSelected];
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[mainPlayer pause];
        //[pausePlay setImage:[UIImage imageNamed:@"pause_button.png"] forState:UIControlStateSelected];
	}
}

- (void) setupApplicationAudio {
	
	// Gets the file system path to the sound to play.
	NSString *soundFilePath = [[NSBundle mainBundle]	pathForResource:	@"sound"
                                                              ofType:				@"caf"];
    
	// Converts the sound's file path to an NSURL object
	NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
	self.soundFileURL = newURL;
    
	// Registers this class as the delegate of the audio session.
	[[AVAudioSession sharedInstance] setDelegate: self];
	
	// The AmbientSound category allows application audio to mix with Media Player
	// audio. The category also indicates that application audio should stop playing
	// if the Ring/Siilent switch is set to "silent" or the screen locks.
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
    /*
     // Use this code instead to allow the app sound to continue to play when the screen is locked.
     [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
     
     UInt32 doSetProperty = 0;
     AudioSessionSetProperty (
     kAudioSessionProperty_OverrideCategoryMixWithOthers,
     sizeof (doSetProperty),
     &doSetProperty
     );
     */
    
	// Registers the audio route change listener callback function
	AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     (__bridge void *)(self)
                                     );
    
	// Activates the audio session.
	
	NSError *activationError = nil;
	[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    
	
	// "Preparing to play" attaches to the audio hardware and ensures that playback
	//		starts quickly when the user taps Play
	[appPlayer prepareToPlay];
	[appPlayer setVolume: 1.0];
	[appPlayer setDelegate: self];
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









