//
//  LeCentral.m
//  Queue
//
//  Created by Ethan on 12/30/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "LeCentral.h"
#import "QueueTableViewController.h"
#import "SongStruct.h"

#define TRANSFER_SERVICE_UUID           @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
#define TRANSFER_CHARACTERISTIC_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D4"
#define TRANSFER_CHARACTERISTIC_ITUNES_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D3"

@implementation LeCentral
@synthesize libraryCharacteristic;
@synthesize playlistCharacteristic;
@synthesize connectedPeripheral;
@synthesize centralManager;
#pragma mark - View Lifecycle

-(id)init
{
    self = [super init];
    if(self){
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.data = [[NSMutableData alloc] init];
        self.detectedPeripherals = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Central Methods

//Check what state bluetooth is in an give an alert if it is off
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;
    
	switch ([centralManager state]) {
		case CBCentralManagerStatePoweredOff:
		{
            [self.centralDelegate centralDidRefresh];
            
			/* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            if (previousState != -1) {
                [self.centralDelegate centralStatePoweredOff];
            }
			break;
		}
        case CBCentralManagerStateUnsupported:
        {
            break;
        }
		case CBCentralManagerStateUnauthorized:
		{
			/* Tell user the app is not allowed. */
			break;
		}
            
		case CBCentralManagerStateUnknown:
		{
			/* Bad news, let's wait for another event. */
			break;
		}
            
		case CBCentralManagerStatePoweredOn:
		{
			[self scan];
			[self.centralDelegate centralDidRefresh];
			break;
		}
            
		case CBCentralManagerStateResetting:
		{
			[self.centralDelegate centralDidRefresh];
			break;
		}
	}
    
    previousState = [centralManager state];
}



/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    [centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    NSLog(@"Scanning started");
}

/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    // Ok, it's in range - have we already seen it?
    if(![self.detectedPeripherals containsObject:peripheral]){
         NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
        [self.detectedPeripherals addObject:peripheral];
        NSLog(@"%d",[self.detectedPeripherals count]);
        [self.centralDelegate centralDidRefresh];
    }
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanup];
}

-(void)stopScan
{
    [centralManager stopScan];
}

/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    //self.statusLabel.text = [NSString stringWithFormat:@"You are currently connect to playlist host %@",peripheral.name ];
    [self.centralDelegate centralDidConnect:peripheral];
    
    connectedPeripheral = peripheral;
    
    [self.centralDelegate centralDidRefresh];
    // Stop scanning
    [centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    // Clear the data that we may already have
    [self.data setLength:0];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}

//if a song was chosen with our library picker in QTVC, this is called and appends those songs to the playlist
- (void) writeHostPlaylist:(NSMutableArray *)newPlaylist
{
    NSData *tempData = [NSKeyedArchiver archivedDataWithRootObject:newPlaylist];
    [connectedPeripheral writeValue:tempData forCharacteristic:playlistCharacteristic type:CBCharacteristicWriteWithResponse];
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
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_ITUNES_UUID]] forService:service];
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
            playlistCharacteristic = characteristic;
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        
            libraryCharacteristic = characteristic;
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}

//read and return the characteristic value for the host library
-(NSMutableArray *)getHostLibrary
{
    [connectedPeripheral readValueForCharacteristic:libraryCharacteristic];
    NSData *data = libraryCharacteristic.value;
    return [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
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
        QueueTableViewController *qtvc = [QueueTableViewController sharedInstance];
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
        [centralManager cancelPeripheralConnection:peripheral];
    }
}




/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    connectedPeripheral = nil;
    
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
    if (!connectedPeripheral.isConnected) { //deprecated. Needs fixing
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (connectedPeripheral.services != nil) {
        for (CBService *service in connectedPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [connectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [centralManager cancelPeripheralConnection:connectedPeripheral];
}
@end
