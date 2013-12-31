//
//  LibraryViewController.m
//  Queue
//
//  Created by Ethan on 12/30/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "LibraryViewController.h"
#import "BTLEViewController.h"
#import "QueueTableViewController.h"
#import "SongStruct.h"

@interface LibraryViewController ()

@end

@implementation LibraryViewController
@synthesize libraryData;
@synthesize selectedSongs;
@synthesize songButtons;
@synthesize doneButton;


-(IBAction)done:(id)sender
{
    [self.delegate libraryViewController:self didChooseSongs:selectedSongs];
}

-(IBAction)addHandler:(id)sender
{
    UIButton *senderButton = (UIButton *)sender;
    [selectedSongs addObject:[libraryData objectAtIndex:[senderButton tag]]];
}

- (id)initWithLibrary:(NSArray *)library
{
    self = [super init];
    if (self) {
        libraryData = library;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    selectedSongs = [[NSMutableArray alloc] init];
    songButtons = [[NSMutableArray alloc] init];

    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationController.navigationItem.rightBarButtonItem = doneButton;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [libraryData count] > 0 ? 0:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [libraryData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Song";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 7.5, 230.0, 20)];
    titleLabel.font = [UIFont systemFontOfSize:17.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:titleLabel];
    
    UILabel *artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, 230.0, 25.0)];
    artistLabel.font = [UIFont systemFontOfSize:12.0];
    artistLabel.textAlignment = NSTextAlignmentLeft;
    artistLabel.textColor = [UIColor darkGrayColor];
    artistLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:artistLabel];
    
    
    UIButton *addButton = (UIButton *)cell.accessoryView;
    [addButton addTarget:self action:@selector(addHandler:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTag:[indexPath row]];
    [songButtons addObject:addButton];
    [cell.contentView addSubview:addButton];
    
    SongStruct *tempSong = [libraryData objectAtIndex:[indexPath row]];
    [artistLabel setText:tempSong.artist];
    [titleLabel setText:tempSong.title];
    
    
    
    return cell;
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
