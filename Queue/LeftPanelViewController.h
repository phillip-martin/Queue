//
//  LeftPanelViewController.h
//  Queue
//
//  Created by Ethan on 1/10/14.
//  Copyright (c) 2014 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "QueueTableViewController.h"
#import "QueueViewController.h"
#import "BTLEViewController.h"

@interface LeftPanelViewController : UITableViewController
@property (nonatomic) QueueTableViewController *QTVC;
@property (nonatomic) QueueViewController *QVC;
@property (nonatomic) BTLEViewController *BTLE;



@end
