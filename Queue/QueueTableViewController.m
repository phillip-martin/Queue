//
//  QueueTableViewController.m
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "QueueTableViewController.h"
#import "BTLEViewController.h"
#import "QueueViewController.h"
#import "LeftPanelViewController.h"
#import "SongStruct.h"

@implementation QueueTableViewController

@synthesize currentQueue;
@synthesize addMusicButton;
@synthesize songArray;

- (IBAction) addHandler {
    
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
    
    /*else{
        [self performSegueWithIdentifier:@"LibraryViewSegue" sender:self];
        
    }*/
}

-(void)libraryViewController:(LibraryViewController *)libraryViewController didChooseSongs:(NSMutableArray *)songs
{
    if([songs count] > 0){
        
        LeftPanelViewController *leftController = (LeftPanelViewController *)self.sidePanelController.leftPanel;
        BTLEViewController *tempView = [leftController BTLE];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:songs];
        [tempView sendData:data toPeers:[[NSArray alloc] initWithObjects:tempView.connectedPeer, nil] reliable:YES error:nil];
        for(SongStruct *tempSong in songs){
            [self.addedSongs setObject:tempSong forKey:tempSong.strIdentifier];
        }
        [self addedSong];
    }
    if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//vote button for song
-(void)upVote:(id)sender{
    UIButton *tempButton = (UIButton *)sender;
    SongStruct *temp = [self.songArray objectAtIndex:tempButton.tag];
    [temp Vote];
    tempButton.enabled = NO; //not working
    //[self.currentQueue cellForRowAtIndexPath:tempButton.tag] remove cell button
    [self.currentQueue reloadData];
    NSArray *tempArray = [[NSArray alloc] initWithObjects:temp, nil];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tempArray];
    LeftPanelViewController *leftController = (LeftPanelViewController *)self.sidePanelController.leftPanel;
    BTLEViewController *tempView = [leftController BTLE];
    if(tempView.rangingSwitch.on && tempView.connectedPeer != nil){
        [tempView sendData:data toPeers:[[NSArray alloc] initWithObjects:tempView.connectedPeer, nil] reliable:YES error:nil];
    }
    else if (tempView.advertisingSwitch.on){
        [tempView sendData:data toPeers:[[NSArray alloc] initWithObjects:@"all",nil] reliable:YES error:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*NSFileManager* manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *path;
    NSError *error;
    if ((path = [documentPath stringByAppendingPathComponent:@"CurrentPlaylist.plist"]))
    {
        //if file exists, delete it and create new one
        if ([manager fileExistsAtPath:path] == YES) {
            [manager removeItemAtPath:path error:&error];
        }
        
        resourcePath = [[NSBundle mainBundle] pathForResource:@"CurrentPlaylist" ofType:@"plist"];
        [manager copyItemAtPath:resourcePath toPath:path error:&error];
        NSLog(@"loaded current playlist plist");
        
    }*/

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    //dismiss picker
	if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    LeftPanelViewController *leftController = (LeftPanelViewController *)self.sidePanelController.leftPanel;
    BTLEViewController *btController = [leftController BTLE];
    //add the songs to our queue table view
    for (int i = 0; i<mediaItemCollection.items.count; i++) {
        NSString *tempTitle = [NSString stringWithFormat:NSLocalizedString([[mediaItemCollection.items objectAtIndex:i] valueForProperty:MPMediaItemPropertyTitle],@"title")];
        NSString *tempArtist = [NSString stringWithFormat:NSLocalizedString([[mediaItemCollection.items objectAtIndex:i] valueForProperty:MPMediaItemPropertyArtist],@"artist")];
        //note: Do not need buffer, url or album artwork for queue table. It is simply a list
        SongStruct *newSong = [[SongStruct alloc] initWithTitle:tempTitle artist:tempArtist voteCount:1 bufferData:nil songURL:nil albumArtwork:nil];
        NSString *tempID = [NSString stringWithFormat:@"%@",newSong.strIdentifier];
        if([self.addedSongs objectForKey:tempID] == nil){
            [self.addedSongs setObject:newSong forKey:tempID];
        }
        else{
            SongStruct *temp = [self.addedSongs objectForKey:tempID];
            [temp Vote];
        }
    }
    [self addedSong];
    if(!btController.rangingSwitch.on){
        //get relevant data from songs and add them to the queue
        NSMutableArray *songData = [[NSMutableArray alloc] init];
        for(MPMediaItem *item in mediaItemCollection.items){
            SongStruct *newSong = [[SongStruct alloc] initWithTitle:[item valueForProperty:MPMediaItemPropertyTitle] artist:[item valueForProperty:MPMediaItemPropertyArtist] voteCount:1 bufferData:nil songURL:[item valueForProperty:MPMediaItemPropertyAssetURL] albumArtwork:[item valueForProperty:MPMediaItemPropertyArtwork]];
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
    else{
        //convert MPMediaItem to NSData. This will be sent to the host. The song is played once then destroyed
        NSMutableArray *songData = [[NSMutableArray alloc] init];
        [songData addObject:@"song buffer"]; //message
        for(MPMediaItem *item in mediaItemCollection.items){
            NSMutableData *data = [[NSMutableData alloc] init];
            
            NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
            AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:nil];
            const uint32_t sampleRate = 16000; // 16k sample/sec
            const uint16_t channels = 2; // 2 channel/sample (stereo)
            NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                      [NSNumber numberWithFloat:(float)sampleRate], AVSampleRateKey,
                                      [NSNumber numberWithFloat:(float)channels], AVNumberOfChannelsKey, nil];
            AVAssetReaderTrackOutput *assetOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:asset.tracks[0] outputSettings:settings];
            [assetReader addOutput:assetOutput];
            [assetReader startReading];
            // read the samples from the asset and append them subsequently
            while ([assetReader status] != AVAssetReaderStatusCompleted) {
                CMSampleBufferRef sampleBuffer = [assetOutput copyNextSampleBuffer];
                if (sampleBuffer == NULL) continue;
                CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
                size_t size = CMBlockBufferGetDataLength(blockBuffer);
                uint8_t *outBytes = malloc(size);
                CMBlockBufferCopyDataBytes(blockBuffer, 0, size, outBytes);
                CMSampleBufferInvalidate(sampleBuffer);
                CFRelease(sampleBuffer);
                [data appendBytes:outBytes length:size];
            }
            //add data to array with message as first object. This is so the devices know how to parse the data

            SongStruct *newSong = [[SongStruct alloc] initWithTitle:[item valueForProperty:MPMediaItemPropertyTitle] artist:[item valueForProperty:MPMediaItemPropertyArtist] voteCount:1 bufferData:data songURL:nil albumArtwork:[item valueForProperty:MPMediaItemPropertyArtwork]];
            [songData addObject:newSong];
        }
        NSData *labeledData = [NSKeyedArchiver archivedDataWithRootObject:songData];
        [btController sendData:labeledData toPeers:[NSArray arrayWithObject:btController.connectedPeer] reliable:YES error:nil];
        
    }
}

-(void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.addedSongs count];
}

//update our table view with added/edited songs
-(void)addedSong{
    self.songArray = [self.addedSongs allValues];
	[self.currentQueue reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    UILabel *titleLabel;
    UILabel *artistLabel;
    UIButton *sideButton;
    UILabel *votesLabel;
    SongStruct *anItem = (SongStruct *)[self.songArray objectAtIndex:[indexPath row]];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 7.5, 230.0, 20)];
    titleLabel.font = [UIFont systemFontOfSize:20.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:titleLabel];
    
    artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 25.0, 230.0, 25.0)];
    artistLabel.font = [UIFont systemFontOfSize:14.0];
    artistLabel.textAlignment = NSTextAlignmentLeft;
    artistLabel.textColor = [UIColor darkGrayColor];
    artistLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:artistLabel];
    
    votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.0, 25.0, 55.0, 25.0)];
    votesLabel.font = [UIFont systemFontOfSize:14.0];
    votesLabel.textAlignment = NSTextAlignmentLeft;
    votesLabel.textColor = [UIColor darkGrayColor];
    [cell.contentView addSubview:votesLabel];
    
    
    sideButton = [[UIButton alloc] initWithFrame:CGRectMake(255.0, 15.0, 55.0, 15.0)];
    [sideButton addTarget:self action:@selector(upVote:) forControlEvents:UIControlEventTouchUpInside];
    [sideButton setTag:[indexPath row]];
    [sideButton setTitle:@"Vote" forState:UIControlStateNormal];
    [sideButton setBackgroundColor:[UIColor blackColor]];
    [cell.contentView addSubview:sideButton];
    [titleLabel setText: anItem.title];
    [artistLabel setText:anItem.artist];
    NSString *tempLabel = anItem.votes > 1 ? @"Votes":@"Vote";
    [votesLabel setText:[NSString stringWithFormat:@"%lu %@",(unsigned long)anItem.votes,tempLabel]];
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqual:@"LibraryViewSegue"]){
        UINavigationController *nav = segue.destinationViewController;
        LibraryViewController *LVC = nav.viewControllers[0];
        [LVC setLibraryDelegate:self];
        LeftPanelViewController *leftController = (LeftPanelViewController *)self.sidePanelController.leftPanel;
        BTLEViewController *tempView= [leftController BTLE];
        [LVC setLibraryData:[tempView hostLibrary]];
    }
    
}



@end
