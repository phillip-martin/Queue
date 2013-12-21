//
//  QueueTableViewController.h
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>


@protocol QueueTableViewControllerDelegate; // forward declaration

@interface QueueTableViewController : UITableViewController <MPMediaPickerControllerDelegate, UITableViewDelegate, UITabBarDelegate, UITableViewDataSource>
{
    __unsafe_unretained id <QueueTableViewControllerDelegate> delegate;
    IBOutlet UITableView *currentQueue;
    //IBOutlet UIBarButtonItem *songInfo; Do we want this? for voting?
    IBOutlet UIBarButtonItem *addMusicButton;
    
}

@property (nonatomic, assign) id <QueueTableViewControllerDelegate> delegate;
@property (nonatomic) UITableView *currentQueue;
@property (nonatomic) UIBarButtonItem *addMusicButton;

@end

@protocol QueueTableViewControllerDelegate

- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;

@end