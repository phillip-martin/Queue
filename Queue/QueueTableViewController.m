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
#import "MediaSourceViewController.h"


@implementation QueueTableViewController

@synthesize currentQueue;
@synthesize addMusicButton;
@synthesize songArray;
@synthesize addSongIsPressed;
@synthesize goToHost;
@synthesize goToSC;
@synthesize shadow;
@synthesize selectionBox;

- (IBAction) addHandler {
    
    //if addMusicButton is already pressed remove the shadow and selectionBox
    if (addSongIsPressed == true) {
        [shadow removeFromSuperview];
        [selectionBox removeFromSuperview];
        addSongIsPressed = false;
        return;
    }
    else {
        addSongIsPressed = true;
    }

    
    //create another view with black background and alpha<1
    shadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    shadow.backgroundColor = [UIColor blackColor];
    shadow.alpha = 0.5;
    [self.view addSubview:shadow];

    
    //create box for choosing either from hosts library or soundcloud
    selectionBox = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-20, 20, self.view.frame.size.width/2, 100)];
    selectionBox.backgroundColor = [UIColor whiteColor];
    [shadow addSubview:selectionBox];
    
    
    //add proper buttons to selectionBox
        //go to hosts library
    self.goToHost = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, selectionBox.frame.size.width -20, selectionBox.frame.size.height/2-20)];
    [goToHost setTitle:@"Host's Library" forState:UIControlStateNormal];
    goToHost.backgroundColor = [UIColor blackColor];
    [goToHost addTarget:self action:@selector(goToHost:) forControlEvents:UIControlEventTouchUpInside];
    [selectionBox addSubview:goToHost];
    
    
        //go to sound cloud
    goToSC = [[UIButton alloc] initWithFrame:CGRectMake(10,selectionBox.frame.size.height/2+10,selectionBox.frame.size.width-20, selectionBox.frame.size.height/2-20)];
    [goToSC setTitle:@"Sound Cloud" forState:UIControlStateNormal];
    goToSC.backgroundColor = [UIColor blackColor];
    [goToSC addTarget:self action:@selector(goToSC:) forControlEvents:UIControlEventTouchUpInside];
    [selectionBox addSubview:goToSC];
    
    
}

-(void)goToHost:(id)senderA{
    NSLog(@"senderA");
    [shadow removeFromSuperview];
    [selectionBox removeFromSuperview];
    [self performSegueWithIdentifier:@"librarySegue" sender:senderA];
}

-(void)goToSC:(id)senderB{
    NSLog(@"senderB");
    [self performSegueWithIdentifier:@"SCSegue" sender:senderB];
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
<<<<<<< HEAD
=======
    
    //set addSongisPressed to false
    addSongIsPressed = false;

>>>>>>> master
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

-(void)refreshTable{
    [self.currentQueue reloadData];
}

//update our table view with added/edited songs
-(void)addSong:(SongStruct *)song{
    if([self.addedSongs objectForKey:song.identifier] == nil){
        [self.addedSongs setObject:song forKey:song.identifier];
    }
    else{
        SongStruct *temp = [self.addedSongs objectForKey:song.identifier];
        [temp Vote];
    }
    self.songArray = [self.addedSongs allValues];
	[self refreshTable];
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
    if([[segue identifier] isEqual:@"PickerSegue"]){
        UINavigationController *navController =  segue.destinationViewController;
        MediaSourceViewController *MSVC = navController.viewControllers[0];
        LeftPanelViewController *leftController = (LeftPanelViewController *)self.sidePanelController.leftPanel;
        [MSVC setLeftController:leftController];
        
    }
    else if([[segue identifier] isEqual:@"librarySegue"]){
        LibraryViewController *LVC = segue.destinationViewController;
    }
}


- (void) viewDidAppear:(BOOL)animated
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
