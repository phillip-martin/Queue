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


@implementation QueueTableViewController

@synthesize currentQueue;
@synthesize addMusicButton;
@synthesize songArray;

- (IBAction) addHandler {
    
    [self performSegueWithIdentifier:@"PickerSegue" sender:self];
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.addedSongs count];
}

//update our table view with added/edited songs
-(void)addSong:(SongStruct *)song{
    [self.addedSongs setObject:song forKey:song.strIdentifier];
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
