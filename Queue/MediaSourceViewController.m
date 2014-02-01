//
//  MediaSourceViewController.m
//  Queue
//
//  Created by Ethan on 1/26/14.
//  Copyright (c) 2014 Ethan. All rights reserved.
//

#import "MediaSourceViewController.h"

#import "LeftPanelViewController.h"

@interface MediaSourceViewController ()

@end

@implementation MediaSourceViewController
@synthesize soundCloudButton;
@synthesize hostLibraryButton;
@synthesize account;
@synthesize btController;

-(IBAction)addLibrarySong{
    
    if(btController.advertisingSwitch.on){
        MPMediaPickerController *mediaPicker =
        [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
	
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = YES;
        mediaPicker.prompt = NSLocalizedString (@"Add a song to the queue", @"Choose a song to add to the queue");
    
    
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
            [self presentViewController:mediaPicker animated:YES completion:nil];
        } else {
            [self presentModalViewController:mediaPicker animated:YES];
        }
    }
    
    else{
     [self performSegueWithIdentifier:@"LibraryViewSegue" sender:self];
     
     }
}

-(IBAction)addSoundCloud{
    
    [self performSegueWithIdentifier:@"SCSegue" sender:self];
    
}

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
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//library view controller for clients
-(void)libraryViewController:(LibraryViewController *)libraryViewController didChooseSongs:(NSMutableArray *)songs
{
    if([songs count] > 0){
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:songs];
        [btController sendData:data toPeers:[[NSArray alloc] initWithObjects:btController.connectedPeer, nil] reliable:YES error:nil];
        for(SongStruct *tempSong in songs){
            ;
        }
        
    }
    if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// library view controller for host
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    //dismiss picker
	if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    //add the songs to our queue table view
    for (int i = 0; i<mediaItemCollection.items.count; i++) {
        NSString *tempTitle = [NSString stringWithFormat:NSLocalizedString([[mediaItemCollection.items objectAtIndex:i] valueForProperty:MPMediaItemPropertyTitle],@"title")];
        NSString *tempArtist = [NSString stringWithFormat:NSLocalizedString([[mediaItemCollection.items objectAtIndex:i] valueForProperty:MPMediaItemPropertyArtist],@"artist")];
        //note: Do not need buffer, url or album artwork for queue table. It is simply a list
        SongStruct *newSong = [[SongStruct alloc] initWithTitle:tempTitle artist:tempArtist voteCount:1 songURL:nil artwork:nil];
        NSString *tempID = [NSString stringWithFormat:@"%@",newSong.strIdentifier];
        if([self.addedSongs objectForKey:tempID] == nil){
            [self.addedSongs setObject:newSong forKey:tempID];
        }
        else{
            SongStruct *temp = [self.addedSongs objectForKey:tempID];
            [temp Vote];
        }
    }
    if(!btController.rangingSwitch.on){
        //get relevant data from songs and add them to the queue
        NSMutableArray *songData = [[NSMutableArray alloc] init];
        for(MPMediaItem *item in mediaItemCollection.items){
            SongStruct *newSong = [[SongStruct alloc] initWithTitle:[item valueForProperty:MPMediaItemPropertyTitle] artist:[item valueForProperty:MPMediaItemPropertyArtist] voteCount:1 songURL:[item valueForProperty:MPMediaItemPropertyAssetURL] artwork:[item valueForProperty:MPMediaItemPropertyArtwork]];
            NSLog(@"%@",[newSong mediaURL]);
            NSLog(@"%@",[item valueForProperty:MPMediaItemPropertyTitle]);
            //we added the song to our addedSongs dictionary already, so the votecount should be 1
            if([[self.addedSongs objectForKey:newSong.strIdentifier] votes] == 1){
                NSLog(@"here");
                [songData addObject:newSong];
                
            }
            
        }
        
        //if ranging switch is off, we are hosting a playlist.
        QueueViewController *mainView = [leftController QVC];
        //add picked songs to our media queue
        [mainView updatePlayerQueueWithMediaCollection: songData];
        //update playlist tables of all connected peers. They dont need the media data
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.songArray];
        [btController sendData:data toPeers:[[NSArray alloc] initWithObjects:@"all", nil] reliable:YES error:nil];
    }
}

-(void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"LibrarySegue"])
    {
        UINavigationController *nav = segue.destinationViewController;
        LibraryViewController *LVC = nav.viewControllers[0];
        [LVC setLibraryDelegate:self];
        [LVC setLibraryData:[btController hostLibrary]];
    }
    else if ([[segue identifier] isEqualToString:@"SCSegue"]){

        
    }
}

@end
