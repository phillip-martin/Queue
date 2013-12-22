//
//  QueueTableViewController.m
//  Queue
//
//  Created by Ethan on 12/18/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "QueueTableViewController.h"
#import "QueueViewController.h"

@implementation QueueTableViewController

@synthesize currentQueue;
@synthesize addMusicButton;



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
    
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentQueue.dataSource = self;
    self.currentQueue.delegate = self;
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
	[self.currentQueue reloadData];
    
	//[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];
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
    UINavigationController *navBar = self.tabBarController.viewControllers[0];
    QueueViewController *mainView = navBar.viewControllers[0];
    MPMediaItemCollection *songs  = mainView.songQueue;
    return [songs.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    UINavigationController *navBar = self.tabBarController.viewControllers[0];
    QueueViewController *mainView = navBar.viewControllers[0];
    MPMediaItemCollection *songs  = mainView.songQueue;
	MPMediaItem *anItem = (MPMediaItem *)[songs.items objectAtIndex: [indexPath row]];
    NSLog(@"%ul", [songs.items count]);
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
	
    cell.textLabel.text = [anItem valueForProperty:MPMediaItemPropertyTitle];
    cell.detailTextLabel.text = [anItem valueForProperty:MPMediaItemPropertyArtist];
    
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
