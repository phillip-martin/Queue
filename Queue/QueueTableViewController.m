//
//  QueueTableViewController.m
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "QueueTableViewController.h"
#import "QueueViewController.h"
#import "BTLEViewController.h"
#import "SongStruct.h"

@implementation QueueTableViewController

@synthesize currentQueue;
@synthesize addMusicButton;
@synthesize songArray;

+(id)sharedInstance{
    static QueueTableViewController *controller;
    
    @synchronized(self)
    {
        if (controller == NULL)
            controller = [[self alloc] init];
    }

    
    return controller;
}

-(void)showLibraryPicker:(NSArray *)library
{
    
    LibraryViewController *libraryView = [[LibraryViewController alloc] initWithLibrary:library];
    libraryView.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:libraryView];
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
        [self presentViewController:navigationController animated:YES completion:nil];
    } else {
        [self presentModalViewController:navigationController animated:YES];
    }

}

- (IBAction) addHandler {
    
    UINavigationController *navBar = self.tabBarController.viewControllers[2];
    BTLEViewController *btController = navBar.viewControllers[0];
    
    if(!btController.rangingSwitch.on){
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
        //if user is connected to playlist and wants to add a song, show him the library of the host
        [self showLibraryPicker:[btController songsToArray]];
        
    }

}

-(void)libraryViewController:(LibraryViewController *)libraryViewController didChooseSongs:(NSMutableArray *)songs
{
    if(songs){
        BTLEViewController *tempView = [BTLEViewController sharedInstance];
        [tempView.centralManager writeHostPlaylist:songs];
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
    [tempButton setEnabled:NO]; //not working
    [self.currentQueue reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentQueue.dataSource = self;
    self.currentQueue.delegate = self;
    self.addedSongs = [[NSMutableDictionary alloc] init];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
	if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    UINavigationController *navBar = self.tabBarController.viewControllers[0];
    QueueViewController *mainView = navBar.viewControllers[0];
	[mainView updatePlayerQueueWithMediaCollection: mediaItemCollection];
    for (int i = 0; i<mediaItemCollection.items.count; i++) {
        NSString *tempTitle = [NSString stringWithFormat:NSLocalizedString([[mediaItemCollection.items objectAtIndex:i] valueForProperty:MPMediaItemPropertyTitle],@"title")];
        NSString *tempArtist = [NSString stringWithFormat:NSLocalizedString([[mediaItemCollection.items objectAtIndex:i] valueForProperty:MPMediaItemPropertyArtist],@"artist")];
        SongStruct *newSong = [[SongStruct alloc] initWithTitle:tempTitle artist:tempArtist voteCount:1];
        NSString *tempID = [NSString stringWithFormat:@"%@",newSong.strIdentifier];
        if([self.addedSongs objectForKey:tempID] == nil){
            [self.addedSongs setObject:newSong forKey:tempID];
        }
        else{
            SongStruct *temp = [self.addedSongs objectForKey:tempID];
            [temp Vote];
        }
    }
    self.songArray = [self.addedSongs allValues];
	[self.currentQueue reloadData];
    BTLEViewController *tempView = [BTLEViewController sharedInstance];
    [tempView.peripheralManager updatePlaylistCharacteristic];
    
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
    titleLabel.font = [UIFont systemFontOfSize:17.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:titleLabel];
    
    artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, 230.0, 25.0)];
    artistLabel.font = [UIFont systemFontOfSize:12.0];
    artistLabel.textAlignment = NSTextAlignmentLeft;
    artistLabel.textColor = [UIColor darkGrayColor];
    artistLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:artistLabel];
    
    votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.0, 30.0, 55.0, 25.0)];
    votesLabel.font = [UIFont systemFontOfSize:12.0];
    votesLabel.textAlignment = NSTextAlignmentLeft;
    votesLabel.textColor = [UIColor darkGrayColor];
    [cell.contentView addSubview:votesLabel];
    
    
    sideButton = [[UIButton alloc] initWithFrame:CGRectMake(255.0, 20.0, 55.0, 15.0)];
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
}



@end
