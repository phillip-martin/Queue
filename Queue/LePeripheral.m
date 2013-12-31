//
//  LePeripheral.m
//  Queue
//
//  Created by Ethan on 12/30/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import "LePeripheral.h"
#import "QueueTableViewController.h"
#import "QueueViewController.h"
#import "SongStruct.h"

#define TRANSFER_SERVICE_UUID           @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
#define TRANSFER_CHARACTERISTIC_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D4"
#define TRANSFER_CHARACTERISTIC_ITUNES_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D3"

#define NOTIFY_MTU 20

@implementation LePeripheral
@synthesize dataToSend;
@synthesize sendDataIndex;
@synthesize libraryCharacteristic;
@synthesize playlistCharacteristic;
@synthesize myLibrary;
@synthesize peripheralManager;
@synthesize hostName;

-(id)init
{
    self = [super init];
    if(self){
        
        peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        [self setHostName:@""];
        
    }
    
    return self;
}

-(void)updatePlaylistCharacteristic
{
    QueueTableViewController *tempView = [QueueTableViewController sharedInstance];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[tempView songArray]];
    [playlistCharacteristic setValue:data];
}

-(void)startAdvertising:(NSDictionary *)data
{
    [peripheralManager startAdvertising:data];
}


-(void)stopAdvertising
{
    [peripheralManager stopAdvertising];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    static CBPeripheralManagerState previousState = -1;
    // Opt out from any other state
    
    switch([peripheral state]){
        case CBPeripheralManagerStatePoweredOff:
        {
            //warning is shown second time
            if(previousState != -1){
                [self bluetoothStatePoweredOff];
            }
            break;
        }
        case CBPeripheralManagerStateUnauthorized:
        {
            break;
        }
        case CBPeripheralManagerStatePoweredOn:
        {
            NSLog(@"peripheralManager powered on.");
            
            
            playlistCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                        properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify
                                                                             value:nil
                                                                       permissions:CBAttributePermissionsWriteable];
            
            
            CBMutableService *transferServiceData = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                                   primary:YES];
            
            libraryCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_ITUNES_UUID]
                                                                       properties:CBCharacteristicPropertyRead
                                                                            value:nil
                                                                      permissions:CBAttributePermissionsReadable];
            
            
            
            // Add the characteristics to the service
            transferServiceData.characteristics = @[playlistCharacteristic, libraryCharacteristic];
            
            // And add it to the peripheral manager
            [peripheralManager addService:transferServiceData];
            break;
        }
        case CBPeripheralManagerStateResetting:
        {
            break;
        }
        case CBPeripheralManagerStateUnknown:
        {
            break;
        }
        case CBPeripheralManagerStateUnsupported:
        {
            break;
        }
    }
    
    previousState = [peripheralManager state];
    
}

- (void) bluetoothStatePoweredOff
{
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    if([characteristic.UUID  isEqual: TRANSFER_CHARACTERISTIC_UUID]){
        // Get the data
        QueueTableViewController *qtvc = [QueueTableViewController sharedInstance];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:qtvc.addedSongs];
        self.dataToSend = data;
        
        // Reset the index
        self.sendDataIndex = 0;
        
        // Start sending
        [self sendData];
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    
    if ([request.characteristic.UUID isEqual:playlistCharacteristic.UUID]) {
        if (request.offset > playlistCharacteristic.value.length) {
            [peripheralManager respondToRequest:request
                                       withResult:CBATTErrorInvalidOffset];
            return;
        }
        request.value = [playlistCharacteristic.value
                         subdataWithRange:NSMakeRange(request.offset,
                                                      playlistCharacteristic.value.length - request.offset)];
        [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
    else if([request.characteristic.UUID isEqual:libraryCharacteristic.UUID]) {
        if (request.offset > libraryCharacteristic.value.length) {
            [peripheralManager respondToRequest:request
                                       withResult:CBATTErrorInvalidOffset];
            return;
        }
        request.value = [libraryCharacteristic.value
                         subdataWithRange:NSMakeRange(request.offset,
                                                      libraryCharacteristic.value.length - request.offset)];
        [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    #warning "This may only handle one request at a time"
    CBATTRequest *request = [requests objectAtIndex:0];
    if ([request.characteristic.UUID isEqual:playlistCharacteristic.UUID]) {

        
        //Characteristic has been written, need to update it
        NSData *data = request.value;
        NSMutableArray *newPlaylist = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        QueueViewController *mainView = [QueueViewController sharedInstance];
        QueueTableViewController *tableView = [QueueTableViewController sharedInstance];
        for (SongStruct *item in newPlaylist) {
            //if we dont have have the song, query for it in our library, then add it
            NSString *tempID = [NSString stringWithFormat:@"%@",item.strIdentifier];
            if([tableView.addedSongs objectForKey:tempID] == nil){
                [tableView.addedSongs setObject:item forKey:tempID];
                MPMediaPropertyPredicate *artistNamePredicate =
                [MPMediaPropertyPredicate predicateWithValue: item.artist
                                                 forProperty: MPMediaItemPropertyArtist];
                
                MPMediaPropertyPredicate *albumNamePredicate =
                [MPMediaPropertyPredicate predicateWithValue: item.title
                                                 forProperty: MPMediaItemPropertyAlbumTitle];
                
                MPMediaQuery *myComplexQuery = [[MPMediaQuery alloc] init];
                
                [myComplexQuery addFilterPredicate: artistNamePredicate];
                [myComplexQuery addFilterPredicate: albumNamePredicate];
                MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:[myComplexQuery collections]];
                [mainView updatePlayerQueueWithMediaCollection: collection];
            }
            else{
                //if we have it qeued already, increment vote count
                SongStruct *temp = [tableView.addedSongs objectForKey:tempID];
                [temp Vote];
            }
            [peripheralManager respondToRequest:[requests objectAtIndex:0]
                                     withResult:CBATTErrorSuccess];
        }
        
        playlistCharacteristic.value = [NSKeyedArchiver archivedDataWithRootObject:tableView.songArray];
        
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
        BOOL didSend = [peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:playlistCharacteristic onSubscribedCentrals:nil];
            
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
            didSend = [peripheralManager updateValue:chunk forCharacteristic:playlistCharacteristic onSubscribedCentrals:nil];
            
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
                BOOL eomSent = [peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:playlistCharacteristic onSubscribedCentrals:nil];
                
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
    

@end
