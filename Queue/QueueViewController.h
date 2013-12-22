//
//  QueueViewController.h
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "QueueTableViewController.h"

@interface QueueViewController : UIViewController < MPMediaPickerControllerDelegate, AVAudioPlayerDelegate, UITabBarDelegate>
{
    
    IBOutlet UIImageView *artworkItem;
    MPMediaItemCollection *songQueue;
    AVAudioPlayer *appPlayer;
    MPMusicPlayerController *mainPlayer;
    NSURL *soundFileURL;
    IBOutlet UILabel *artistLabel;
    NSUInteger voteCount;
    MPMediaItem *nowPlayingItem;
    IBOutlet UILabel *nowPlayingLabel;
    IBOutlet UIBarButtonItem *pausePlay;
    IBOutlet UISlider *songProgress;
    BOOL playing;
    BOOL interruptedOnPlayback;
    
}

@property (nonatomic) IBOutlet UIImageView *artworkItem;
@property (nonatomic) MPMediaItemCollection *songQueue;
@property (nonatomic) AVAudioPlayer *appPlayer;
@property (nonatomic) MPMusicPlayerController *mainPlayer;
@property (nonatomic) NSURL *soundFileURL;
@property (nonatomic,readwrite) NSUInteger voteCount;
@property (nonatomic,copy) MPMediaItem *nowPlayingItem;
@property (nonatomic) IBOutlet UILabel *nowPlayingLabel;
@property (nonatomic) IBOutlet UILabel *artistLabel;
@property (nonatomic) IBOutlet UIBarButtonItem *pausePlay;
@property (nonatomic) IBOutlet UISlider *songProgress;
@property (readwrite) BOOL playing;
@property (readwrite) BOOL interruptedOnPlayback;


-(IBAction)pauseOrPlayMusic :(id)sender;
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;


@end



