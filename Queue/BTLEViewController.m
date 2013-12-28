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
static CGPoint const kActivityIndicatorPosition = (CGPoint){205, 12};
static NSString * const kBeaconsHeaderViewIdentifier = @"HostHeader";

typedef NS_ENUM(NSUInteger, NTSectionType) {
    NTOperationsSection,
    NTDetectedBeaconsSection
};

typedef NS_ENUM(NSUInteger, NTOperationsRow) {
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // And somewhere to store the incoming data
    self.data = [[NSMutableData alloc] init];
    self.detectedPeripherals = [[NSMutableArray alloc] init];
    self.hostName = @"";
    
    //load our itunes library regardless of whether we are a host or not
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *tempTitle = [NSString stringWithFormat:NSLocalizedString([song valueForProperty:MPMediaItemPropertyTitle],@"title")];
        NSString *tempArtist = [NSString stringWithFormat:NSLocalizedString([song valueForProperty:MPMediaItemPropertyArtist],@"artist")];
        SongStruct *newSong = [[SongStruct alloc] initWithTitle:tempTitle artist:tempArtist voteCount:0];
        NSString *tempID = [NSString stringWithFormat:@"%@",newSong.strIdentifier];
        [self.myLibrary setObject:newSong forKey:tempID];
        NSLog (@"%@", tempTitle);
    }
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
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        if([self.hostName  isEqual: @""]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Playlist Name"
                                                        message:@"Please enter a name for your playlist"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }
        NSDictionary *advData = @{CBAdvertisementDataLocalNameKey:self.hostName, CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]};
        [self.peripheralManager startAdvertising:advData];
        NSLog(@"Advertising started");
    }
    
    else {
        [self.peripheralManager stopAdvertising];
        [self.peripheralManager setDelegate:nil];
        self.peripheralManager = nil;
    }
}

/** Start ranging
 */
- (IBAction)rangingSwitchChanged:(id)sender
{
    if (self.rangingSwitch.on) {
        // Start up the CBCentralManager
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
    }
    
    else {
        [self.centralManager stopScan];
        [self.centralManager setDelegate:nil];
        self.centralManager = nil;
        NSIndexSet *deletedSections = [self deletedSections];
        [self.detectedPeripherals removeAllObjects];
        
        [self.peripheralView beginUpdates];
        if (deletedSections)
            [self.peripheralView deleteSections:deletedSections withRowAnimation:UITableViewRowAnimationFade];
        [self.peripheralView endUpdates];
    }
}

#pragma mark - Index path management
- (NSArray *)indexPathsOfRemovedPeripherals:(NSArray *)peripheralArray
{
    NSMutableArray *indexPaths = nil;
    
    NSUInteger row = 0;
    for (CBPeripheral *existingPeripheral in self.detectedPeripherals) {
        BOOL stillExists = NO;
        for (CBPeripheral *tempPeripheral in peripheralArray) {
            if (existingPeripheral.name == tempPeripheral.name) {
                stillExists = YES;
                break;
            }
        }
        if (!stillExists) {
            if (!indexPaths)
                indexPaths = [NSMutableArray new];
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:NTDetectedBeaconsSection]];
        }
        row++;
    }
    
    return indexPaths;
}

- (NSArray *)indexPathsOfInsertedPeripherals:(NSArray *)peripheralArray
{
    NSMutableArray *indexPaths = nil;
    
    NSUInteger row = 0;
    for (CBPeripheral *tempPeripheral in peripheralArray) {
        BOOL isNewBeacon = YES;
        for (CBPeripheral *existingPeripheral in self.detectedPeripherals) {
            if (existingPeripheral.name == tempPeripheral.name) {
                isNewBeacon = NO;
                break;
            }
        }
        if (isNewBeacon) {
            if (!indexPaths)
                indexPaths = [NSMutableArray new];
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:NTDetectedBeaconsSection]];
        }
        row++;
    }
    
    return indexPaths;
}

- (NSArray *)indexPathsForPeripherals:(NSArray *)peripheralArray
{
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (NSUInteger row = 0; row < peripheralArray.count; row++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:NTDetectedBeaconsSection]];
    }
    
    return indexPaths;
}

- (NSIndexSet *)insertedSections
{
    if (self.rangingSwitch.on && [self.peripheralView numberOfSections] == kNumberOfSections - 1) {
        return [NSIndexSet indexSetWithIndex:1];
    } else {
        return nil;
    }
}

- (NSIndexSet *)deletedSections
{
    if (!self.rangingSwitch.on && [self.peripheralView numberOfSections] == kNumberOfSections) {
        return [NSIndexSet indexSetWithIndex:1];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case NTOperationsSection: {
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
        case NTDetectedBeaconsSection:
        default: {
            CBPeripheral *tempPeripheral = self.detectedPeripherals[indexPath.row];
            
            cell = [tableView dequeueReusableCellWithIdentifier:kBeaconCellIdentifier];
            
            if (!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:kBeaconCellIdentifier];
            
            cell.textLabel.text = self.hostName;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",tempPeripheral.identifier];
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }
            break;
    }
    
    return cell;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 || [[alertView textFieldAtIndex:0].text  isEqual: @""]){
        self.advertisingSwitch.on = NO;
    }
    else{
        self.hostName = [alertView textFieldAtIndex:0].text;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.rangingSwitch.on) {
        return kNumberOfSections;       // All sections visible
    } else {
        return kNumberOfSections - 1;   // Beacons section not visible
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case NTOperationsSection:
            return kNumberOfAvailableOperations;
        case NTDetectedBeaconsSection:
        default:
            return [self.detectedPeripherals count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case NTOperationsSection:
            return nil;
        case NTDetectedBeaconsSection:
        default:
            return kBeaconSectionTitle;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case NTOperationsSection:
            return kOperationCellHeight;
        case NTDetectedBeaconsSection:
        default:
            return kBeaconCellHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView =
    [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kBeaconsHeaderViewIdentifier];
    
    // Adds an activity indicator view to the section header
    UIActivityIndicatorView *indicatorView =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [headerView addSubview:indicatorView];
    
    indicatorView.frame = (CGRect){kActivityIndicatorPosition, indicatorView.frame.size};
    
    [indicatorView startAnimating];
    
    return headerView;
}

///////////////////////Central Methods
/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...
    
    // ... so start scanning
    [self scan];
    
}

-(void)foundPeripherals
{
    
    if ([self.detectedPeripherals count] == 0) {
        NSLog(@"No beacons found nearby.");
    } else {
        NSLog(@"Found %lu %@.", (unsigned long)[self.detectedPeripherals count],
              [self.detectedPeripherals count] > 1 ? @"Hosts" : @"Host");
    }
    
    NSIndexSet *insertedSections = [self insertedSections];
    NSIndexSet *deletedSections = [self deletedSections];
    NSArray *deletedRows = [self indexPathsOfRemovedPeripherals:self.detectedPeripherals];
    NSArray *insertedRows = [self indexPathsOfInsertedPeripherals:self.detectedPeripherals];
    NSArray *reloadedRows = nil;
    if (!deletedRows && !insertedRows)
        reloadedRows = [self indexPathsForPeripherals:self.detectedPeripherals];
    
    [self.peripheralView beginUpdates];
    if (insertedSections)
        [self.peripheralView insertSections:insertedSections withRowAnimation:UITableViewRowAnimationFade];
    if (deletedSections)
        [self.peripheralView deleteSections:deletedSections withRowAnimation:UITableViewRowAnimationFade];
    if (insertedRows)
        [self.peripheralView insertRowsAtIndexPaths:insertedRows withRowAnimation:UITableViewRowAnimationFade];
    if (deletedRows)
        [self.peripheralView deleteRowsAtIndexPaths:deletedRows withRowAnimation:UITableViewRowAnimationFade];
    if (reloadedRows)
        [self.peripheralView reloadRowsAtIndexPaths:reloadedRows withRowAnimation:UITableViewRowAnimationNone];
    [self.peripheralView endUpdates];
}


/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    [self foundPeripherals];
    NSLog(@"Scanning started");
}

/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) {
        return;
    }
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    if (RSSI.integerValue < -35) {
        return;
    }
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    // Ok, it's in range - have we already seen it?
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        /*// And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];*/
        [self.detectedPeripherals addObject:peripheral];
        [self foundPeripherals];
    }
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanup];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Stop scanning
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    // Clear the data that we may already have
    [self.data setLength:0];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_ITUNES_UUID]]) {
            
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        NSData *data = characteristic.value;
        NSMutableArray *newData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        UINavigationController *navBar = self.tabBarController.viewControllers[1];
        QueueTableViewController *qtvc = navBar.viewControllers[0];
        for(int i = 0; i < newData.count; i++){
            SongStruct *song = newData[i];
            if([qtvc.addedSongs objectForKey:song.strIdentifier] == nil){
                [qtvc.addedSongs setObject:song forKey:song.strIdentifier];
            }
            else{
                SongStruct *temp = [qtvc.addedSongs objectForKey:song.strIdentifier];
                if(song.votes > temp.votes){
                    [temp Vote];
                }
            }
        }
    }
    else{
        // Otherwise, just add the data on to what we already have
        [self.data appendData:characteristic.value];
    }
    
    
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic.. We dont care about Itunes library change
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}




/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    self.discoveredPeripheral = nil;
    
    // We're disconnected, so start scanning again
    [self scan];
}


/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (!self.discoveredPeripheral.isConnected) { //deprecated. Needs fixing
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}
////////////////////////////End Central Methods


//<------------------------Peripheral Methods-------------->
/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristicData = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsWriteable];
    
    // Then the service
    CBMutableService *transferServiceData = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    self.transferCharacteristicLibrary = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_ITUNES_UUID]
                                                                         properties:CBCharacteristicPropertyNotify
                                                                              value:nil
                                                                        permissions:CBAttributePermissionsReadable];
    

    
    
    // Add the characteristics to the service
    transferServiceData.characteristics = @[self.transferCharacteristicData, self.transferCharacteristicLibrary];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferServiceData];
    
    
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    if([characteristic.UUID  isEqual: TRANSFER_CHARACTERISTIC_UUID]){
        // Get the data
        UINavigationController *navBar = self.tabBarController.viewControllers[1];
        QueueTableViewController *qtvc = navBar.viewControllers[0];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:qtvc.addedSongs];
        self.dataToSend = data;
    
        // Reset the index
        self.sendDataIndex = 0;
    
        // Start sending
        [self sendData];
    }
    else{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.myLibrary];
        self.dataToSend = data;
        
        // Reset the index
        self.sendDataIndex = 0;
        
        // Start sending
        [self sendData];

           
    }
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}


/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}


/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData];
}

#pragma mark - Switch Methods

//<-------------End peripheral methods----------->


@end
