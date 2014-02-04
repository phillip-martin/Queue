//
//  QueueTableViewController.h
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "LibraryViewController.h"
#import "SongStruct.h"

@interface QueueTableViewController : UITableViewController < MPMediaPickerControllerDelegate, UITableViewDelegate, UITabBarDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *currentQueue;
    IBOutlet UIBarButtonItem *addMusicButton;
    NSString *resourcePath;
}

@property (nonatomic) UITableView *currentQueue;
@property (nonatomic) NSMutableDictionary *addedSongs;
@property (nonatomic) UIBarButtonItem *addMusicButton;
@property (nonatomic) NSArray *songArray;
@property (nonatomic) BOOL addSongIsPressed;
@property (nonatomic) UIButton *goToHost;
@property (nonatomic) UIButton *goToSC;
@property (nonatomic) UIView *shadow;
@property (nonatomic) UIView *selectionBox;

-(void)refreshTable;
-(void)addSong:(SongStruct *)song;

@end




