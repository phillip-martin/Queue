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

@protocol QueueTableDelegate;

@interface QueueTableViewController : UITableViewController < MPMediaPickerControllerDelegate, UITableViewDelegate, UITabBarDelegate, UITableViewDataSource, LibraryViewControllerDelegate>
{
    IBOutlet UITableView *currentQueue;
    IBOutlet UIBarButtonItem *addMusicButton;
    NSString *resourcePath;
}

@property (nonatomic, assign) id<QueueTableDelegate> delegate;
@property (nonatomic) UITableView *currentQueue;
@property (nonatomic) NSMutableDictionary *addedSongs;
@property (nonatomic) UIBarButtonItem *addMusicButton;
@property (nonatomic) NSArray *songArray;

@end

@protocol QueueTableDelegate <NSObject>

-(void)addSong:(SongStruct *)song;

@end



