//
//  QueueAppDelegate.h
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"


@interface QueueAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)IBOutlet UIWindow *window;
@property (nonatomic) JASidePanelController *viewController;


@end

