//
//  BTLEViewController.h
//  Queue
//
//  Created by Ethan on 12/26/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>



@interface BTLEViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>
{
    //MC sendes state messages out of order. Add this variable to help correct
    int disconnectCount;
}

@property (nonatomic) UISwitch *advertisingSwitch;
@property (nonatomic) UISwitch *rangingSwitch;
@property (nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) MCPeerID *myPeerID;
@property (nonatomic) MCPeerID *connectedPeer;
@property (nonatomic) NSMutableArray *foundPeers;
@property (nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic) MCNearbyServiceBrowser *browser;
@property (nonatomic) MCSession *currSession;
@property (nonatomic) NSMutableArray *sessions;
@property (nonatomic) NSString *hostName;
@property (nonatomic) NSMutableArray *hostLibrary;
@property (nonatomic) UILabel *accountLabel;


- (void)sendData:(NSData *)data toPeers:(NSArray *)peerIDs reliable:(BOOL)reliable error:(NSError *__autoreleasing *)error;

@end
