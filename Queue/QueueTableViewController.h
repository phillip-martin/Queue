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
    NSString *resourcePath;
}

@property (nonatomic) UITableView *currentQueue;
@property (nonatomic) NSMutableDictionary *addedSongs;
@property (nonatomic) UIBarButtonItem *addMusicButton;
@property (nonatomic) NSArray *songArray;

-(void)libraryViewController:(LibraryViewController *)libraryViewController didChooseSongs:(NSArray *)songs;
-(void)addedSong;

@end



