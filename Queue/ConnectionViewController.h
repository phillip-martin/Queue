//
//  ConnectionViewController.h
//  Queue
//
//  Created by Ethan on 12/22/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;
@import MultipeerConnectivity;

@interface ConnectionViewController : UIViewController <MCBrowserViewControllerDelegate, MCSessionDelegate, UITableViewDataSource, UITableViewDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic) IBOutlet UITableView *discoverableDevices;
@property (nonatomic) MCBrowserViewController *browserVC;
@property (nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic) MCSession *mySession;
@property (nonatomic) MCPeerID *myPeerID;
@property (nonatomic, weak) UISwitch *advertisingSwitch;
@property (nonatomic, weak) UISwitch *rangingSwitch;
@property (nonatomic, weak) MPMediaItemCollection *queue;

@end
