//
//  SCYouViewController.h
//  Queue
//
//  Created by Ethan on 1/26/14.
//  Copyright (c) 2014 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCYouViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) IBOutlet UIImageView *profilePicture;
@property (nonatomic) IBOutlet UILabel *profileName;
@property (nonatomic) IBOutlet UISegmentedControl *segmentButtons;
@property (nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSArray *tracks;

@end
