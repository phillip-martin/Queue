//
//  MediaSourceViewController.h
//  Queue
//
//  Created by Ethan on 1/26/14.
//  Copyright (c) 2014 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LibraryViewController.h"
#import "QueueTableViewController.h"
#import "BTLEViewController.h"
#import "SCUI.h"

@interface MediaSourceViewController : UIViewController <LibraryViewControllerDelegate, MPMediaPickerControllerDelegate, QueueTableDelegate>

@property (nonatomic) IBOutlet UIButton *soundCloudButton;
@property (nonatomic) IBOutlet UIButton *hostLibraryButton;
//@property (nonatomic) IBOutlet UIButton *spotifyButton;

@property (nonatomic) SCAccount *account; //soundcloud account

@property (nonatomic) BTLEViewController *btController;

-(IBAction)addLibrarySong;
-(IBAction)addSoundCloud;

@end
