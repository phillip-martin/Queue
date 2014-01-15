//
//  QueueAppDelegate.m
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QueueAppDelegate.h"
#import "LeftPanelViewController.h"
#import "SongStruct.h"

@implementation QueueAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    self.viewController = [[JASidePanelController alloc] init];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
    LeftPanelViewController *leftPanel = [storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
	self.viewController.leftPanel = leftPanel;
    [leftPanel setBTLE:[storyboard instantiateViewControllerWithIdentifier:@"BTLEController"]];
    
    [leftPanel setQVC:[storyboard instantiateViewControllerWithIdentifier:@"nowPlayingController"]];
    
    [leftPanel setQTVC:[storyboard instantiateViewControllerWithIdentifier:@"centerViewController"]];
    
	self.viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[leftPanel QTVC]];
	
    /*[[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      NSForegroundColorAttributeName,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
      NSShadowAttributeName,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      NSShadowAttributeName,
      [UIFont fontWithName:@"Arial-Bold" size:0.0],
      NSFontAttributeName,
      nil]];*/
    
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    //initialize all of QVC's data required to function
    [leftPanel QVC].myLibrary = [[NSMutableArray alloc] init];
    [leftPanel QVC].songQueue = [[NSMutableArray alloc] init];
    [leftPanel QVC].appPlayer = [[AVPlayer alloc] init];
    
    //initialize all of QTVC's data required to function
    [leftPanel QTVC].addedSongs = [[NSMutableDictionary alloc] init];
    
    //load our itunes library regardless of whether we are a host or not
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [everything items];
    
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *tempTitle = [NSString stringWithFormat:NSLocalizedString([song valueForProperty:MPMediaItemPropertyTitle],@"title")];
        NSString *tempArtist = [NSString stringWithFormat:NSLocalizedString([song valueForProperty:MPMediaItemPropertyArtist],@"artist")];
        SongStruct *newSong = [[SongStruct alloc] initWithTitle:tempTitle artist:tempArtist voteCount:0 bufferData:nil songURL:(NSURL *)[song valueForProperty:MPMediaItemPropertyAssetURL] albumArtwork:[song valueForProperty:MPMediaItemPropertyArtwork]];
        [[[leftPanel QVC] myLibrary] addObject:newSong];
        NSLog (@"%@", tempTitle);
    }
    NSLog(@"%lul songs loaded from library",(unsigned long)[[[leftPanel QVC] myLibrary] count]);
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
