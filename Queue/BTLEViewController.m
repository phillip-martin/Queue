//
//  BTLEViewController.m
//  Queue
//
//  Created by Ethan on 12/26/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#define TRANSFER_SERVICE_UUID           @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
#define TRANSFER_CHARACTERISTIC_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D4"
#define TRANSFER_CHARACTERISTIC_ITUNES_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D3"

#define NOTIFY_MTU 20

static NSString * const kOperationCellIdentifier = @"Settings";
static NSString * const kBeaconCellIdentifier = @"Host";

static NSString * const kAdvertisingOperationTitle = @"Host A PlayList";
static NSString * const kRangingOperationTitle = @"Find A Playlist";
static NSUInteger const kNumberOfSections = 2;
static NSUInteger const kNumberOfAvailableOperations = 2;
static CGFloat const kOperationCellHeight = 44;
static CGFloat const kBeaconCellHeight = 52;
static NSString * const kBeaconSectionTitle = @"Looking for playlists...";
static NSString * const kConnectedSectionTitle = @"Connected to playlist";
static CGPoint const kActivityIndicatorPosition = (CGPoint){205, 12};
static NSString * const kBeaconsHeaderViewIdentifier = @"HostHeader";

typedef NS_ENUM(NSUInteger, NTSectionType) {
    NTSettingsSection,
    NTDetectedHostsSection
};

typedef NS_ENUM(NSUInteger, NTSettingsRow) {
    NTAdvertisingRow,
    NTRangingRow
};

#import "BTLEViewController.h"
#import "QueueTableViewController.h"
#import "QueueViewController.h"
#import "SongStruct.h"

@interface BTLEViewController ()

@end

@implementation BTLEViewController
@synthesize detectedPeripherals;
@synthesize hostName;
@synthesize centralManager;
@synthesize peripheralManager;
@synthesize myLibrary;

+(id)sharedInstance{
    static BTLEViewController *controller;
    
    @synchronized(self)
    {
        if (controller == NULL)
            controller = [[self alloc] init];
    }
    
    
    return controller;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 || [[alertView textFieldAtIndex:0].text  isEqual: @""]){
        self.advertisingSwitch.on = NO;
    }
    else{
        [peripheralManager setHostName: [alertView textFieldAtIndex:0].text];
        self.statusLabel.text = [NSString stringWithFormat:@"You are currently hosting a playlist named: %@",peripheralManager.hostName ];
    }
    
    
}

-(void)centralDidConnect:(CBPeripheral *)peripheral
{
    [self.statusLabel setText:[NSString stringWithFormat:@"Currently connected to %@",[centralManager connectedPeripheral]]];
}

-(void)centralDidRefresh
{
    NSLog(@"refreshed");
    detectedPeripherals = [centralManager detectedPeripherals];
    [self.tableView reloadData];
}

-(void)centralStatePoweredOff
{
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    hostName = @"";
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** Start advertising
 */
- (IBAction)advertisingSwitchChanged:(id)sender
{
    if (self.advertisingSwitch.on) {
        peripheralManager = [[LePeripheral alloc] init];
        UINavigationController *navController = self.tabBarController.viewControllers[0];
        QueueViewController *tempController = navController.viewControllers[0];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[tempController myLibrary]];
        [peripheralManager.libraryCharacteristic setValue:data];
        if([peripheralManager.hostName  isEqual: @""]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Playlist Name"
                                                            message:@"Please enter a name for your playlist"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }
        NSDictionary *advData = @{CBAdvertisementDataLocalNameKey:hostName, CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]};
        [peripheralManager startAdvertising:advData];
        NSLog(@"Advertising started");
        
    }
    
    else {
        [peripheralManager stopAdvertising];
        peripheralManager = nil;
        self.statusLabel.text = nil;
    }
}

/** Start ranging
 */
- (IBAction)rangingSwitchChanged:(id)sender
{
    if (self.rangingSwitch.on) {
        NSLog(@"ranging switch ON");
        // Start up the CBCentralManager
        centralManager = [[LeCentral alloc] init];
        centralManager.centralDelegate = self;
        detectedPeripherals = [[NSMutableArray alloc] init];
        self.statusLabel.text = @"Connect to a playlist";
        [centralManager scan];
        [self.tableView reloadData];
        
        
    }
    
    else {
        [centralManager stopScan];
        centralManager = nil;
        self.statusLabel.text = nil;
        NSLog(@"ranging off");
        [detectedPeripherals removeAllObjects];
        [self.tableView reloadData];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case NTSettingsSection: {
            cell = [tableView dequeueReusableCellWithIdentifier:kOperationCellIdentifier];
            switch (indexPath.row) {
                case NTAdvertisingRow:
                    cell.textLabel.text = kAdvertisingOperationTitle;
                    self.advertisingSwitch = (UISwitch *)cell.accessoryView;
                    [self.advertisingSwitch addTarget:self
                                               action:@selector(advertisingSwitchChanged:)
                                     forControlEvents:UIControlEventValueChanged];
                    break;
                case NTRangingRow:
                default:
                    cell.textLabel.text = kRangingOperationTitle;
                    self.rangingSwitch = (UISwitch *)cell.accessoryView;
                    [self.rangingSwitch addTarget:self
                                           action:@selector(rangingSwitchChanged:)
                                 forControlEvents:UIControlEventValueChanged];
                    break;
            }
        }
            break;
        case NTDetectedHostsSection:
        default: {
            
            cell = [tableView dequeueReusableCellWithIdentifier:kBeaconCellIdentifier];
            CBPeripheral *tempPeripheral = detectedPeripherals[indexPath.row];
            
            if (!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:kBeaconCellIdentifier];
            
            cell.textLabel.text = tempPeripheral.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",tempPeripheral.identifier];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
            break;
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"number of sections in table called");
    if (self.rangingSwitch.on) {
        return kNumberOfSections;       // All sections visible
    } else {
        return kNumberOfSections - 1;   // Beacons section not visible
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case NTSettingsSection:
            return kNumberOfAvailableOperations;
        case NTDetectedHostsSection:
        default:
            NSLog(@"hosts count");
            NSLog(@"%d",[detectedPeripherals count]);
            return [detectedPeripherals count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case NTSettingsSection:
            return nil;
        case NTDetectedHostsSection:
        default:
            if([centralManager connectedPeripheral] == nil){
                return kBeaconSectionTitle;
            }
            else{
                return kConnectedSectionTitle;
            }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case NTSettingsSection:
            return kOperationCellHeight;
        case NTDetectedHostsSection:
        default:
            return kBeaconCellHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSLog(@"header view");
    
    UITableViewHeaderFooterView *headerView =
    [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kBeaconsHeaderViewIdentifier];
    
    // Adds an activity indicator view to the section header
    if([centralManager connectedPeripheral] == nil){
        UIActivityIndicatorView *indicatorView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [headerView addSubview:indicatorView];
    
        indicatorView.frame = (CGRect){kActivityIndicatorPosition, indicatorView.frame.size};
    
        [indicatorView startAnimating];
    }
    return headerView;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CBPeripheral *peripheral;
	NSInteger row	= [indexPath row];
    NSInteger section = [indexPath section];
    if(section > 0){
        peripheral = [centralManager.detectedPeripherals objectAtIndex:row];
        [centralManager.centralManager connectPeripheral:peripheral options:nil];
    }
}


//When is this called??
-(NSMutableArray *)songsToArray
{
    
    return [centralManager getHostLibrary];
}

    
    


@end
