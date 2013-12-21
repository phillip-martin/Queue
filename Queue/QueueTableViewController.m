//
//  QueueTableViewController.m
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "QueueTableViewController.h"
#import "QueueViewController.h"


@interface QueueTableViewController ()

@end

@implementation QueueTableViewController

@synthesize currentQueue;
@synthesize delegate;
@synthesize addMusicButton;


- (IBAction) addHandler: (UIBarButtonItem *)addButton {
    
	MPMediaPickerController *mediaPicker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
	
	mediaPicker.delegate = self;
	mediaPicker.allowsPickingMultipleItems = YES;
	mediaPicker.prompt = NSLocalizedString (@"Add a song to the queue", @"Choose a song to add to the queue");
	
	[mediaPicker loadView];
    
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
        [self presentViewController:mediaPicker animated:YES completion:nil];
    } else {
        [self presentModalViewController:mediaPicker animated:YES];
    }
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAddMusicButton: [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                              target: self
                                                              action: @selector(addHandler:)]];
    
    self.navigationItem.rightBarButtonItem = self.addMusicButton;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    

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
    
	[self.delegate updatePlayerQueueWithMediaCollection: mediaItemCollection];
    
	[self.currentQueue reloadData];
    
	//[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];
}

-(void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    if ([self respondsToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
	
	//[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // all songs are in the same section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    QueueViewController *mainView = (QueueViewController *) self.delegate;
    MPMediaItemCollection *songs  = mainView.songQueue;
    return [songs.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    QueueViewController *mainView = (QueueViewController *) self.delegate;
    MPMediaItemCollection *songs  = mainView.songQueue;
	MPMediaItem *anItem = (MPMediaItem *)[songs.items objectAtIndex: [indexPath row]];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
	
    cell.textLabel.text = [anItem valueForProperty:MPMediaItemPropertyTitle];
    cell.detailTextLabel.text = [anItem valueForProperty:MPMediaItemPropertyArtist];
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    NSLog(@"Here!!!");
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
