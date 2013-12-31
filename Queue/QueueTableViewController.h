//
//  QueueTableViewController.h
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "LibraryViewController.h"

@interface QueueTableViewController : UITableViewController < MPMediaPickerControllerDelegate, UITableViewDelegate, UITabBarDelegate, UITableViewDataSource, LibraryViewControllerDelegate>
{
    IBOutlet UITableView *currentQueue;
    //IBOutlet UIBarButtonItem *songInfo; Do we want this? for voting?
    IBOutlet UIBarButtonItem *addMusicButton;
    
}

@property (nonatomic) UITableView *currentQueue;
@property (nonatomic) NSMutableDictionary *addedSongs;
@property (nonatomic) UIBarButtonItem *addMusicButton;
@property (nonatomic) NSArray *songArray;

+(id)sharedInstance;
-(void)libraryViewController:(LibraryViewController *)libraryViewController didChooseSongs:(NSMutableArray *)songs;

@end



