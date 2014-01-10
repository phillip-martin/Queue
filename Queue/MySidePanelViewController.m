//
//  MySidePanelViewController.m
//  Queue
//
//  Created by Ethan on 1/10/14.
//  Copyright (c) 2014 Ethan. All rights reserved.
//

#import "MySidePanelViewController.h"

@interface MySidePanelViewController ()

@end

@implementation MySidePanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    JASidePanelController *viewController = [[JASidePanelController alloc] init];
    viewController.leftPanel = [[JALeftViewController alloc] init];
    viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[JACenterViewController alloc] init]];
    self.window.rootViewController = viewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
