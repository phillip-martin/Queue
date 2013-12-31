//
//  ConnectionViewController.m
//  Queue
//
//  Created by Ethan on 12/22/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "ConnectionViewController.h"
#import "QueueViewController.h"

static NSString * const XXServiceType = @"Queue-service";

@interface ConnectionViewController ()

@end

@implementation ConnectionViewController

- (void)turnOnRanging
{
    NSLog(@"Turning on ranging...");
    
    if (!self.browserVC){
        self.mySession = [[MCSession alloc] initWithPeer:self.myPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        self.mySession.delegate = self;
        
        
        self.browserVC = [[MCBrowserViewController alloc] initWithServiceType:XXServiceType
                                                                      session:self.mySession];
        self.browserVC.delegate = self;
        [self presentViewController:self.browserVC animated:YES completion:nil];
    } else {
        NSLog(@"Browser VC init skipped -- already exists");
    }
    
    UINavigationController* navBar = self.tabBarController.viewControllers[1];
    
    [navBar pushViewController:navBar.viewControllers[0] animated:YES];
}

- (void)changeRangingState:sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on) {
        [self turnOnRanging];
    } else {
        [self turnOffRanging];
    }
}

- (void)turnOffRanging
{
    self.mySession = nil;
    self.browserVC = nil;
    NSLog(@"Turned off ranging.");
}

- (void)changeAdvertisingState:sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on) {
        [self turnOnAdvertising];
    } else {
        [self turnOffAdvertising];
    }
}

- (void) turnOnAdvertising
{
    if (!self.advertiser) {
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.myPeerID discoveryInfo:nil serviceType:XXServiceType];
        
        
        self.advertiser.delegate = self;
        [self.advertiser startAdvertisingPeer];
    } else {
        NSLog(@"Advertiser init skipped -- already exists");
    }
}

- (void) turnOffAdvertising
{
    [self.advertiser stopAdvertisingPeer];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //  Setup peer ID
    self.myPeerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
   
    UINavigationController *navBar = self.tabBarController.viewControllers[1];
    QueueViewController *QVC = navBar.viewControllers[0];
    self.queue = QVC.songQueue;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [self.browserVC dismissViewControllerAnimated:YES completion:nil];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [self.browserVC dismissViewControllerAnimated:YES completion:nil];
}



// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{


}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}

-(void)sendData
{
    [self.mySession sendData:self.queue
                   toPeers:[self.mySession connectedPeers] withMode:MCSessionSendDataReliable
                     error:&error];
}




@end
