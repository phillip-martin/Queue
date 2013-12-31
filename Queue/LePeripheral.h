//
//  LePeripheral.h
//  Queue
//
//  Created by Ethan on 12/30/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

@interface LePeripheral : NSObject<CBPeripheralManagerDelegate>

@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) CBMutableCharacteristic *libraryCharacteristic;
@property (nonatomic) CBMutableCharacteristic *playlistCharacteristic;
@property (nonatomic) NSData *dataToSend;
@property (nonatomic, readwrite) NSInteger sendDataIndex;
@property (nonatomic) NSMutableDictionary *myLibrary;
@property (nonatomic) NSString *hostName;


-(void)bluetoothStatePoweredOff;
-(void)stopAdvertising;
-(void)startAdvertising:(NSDictionary *)data;
-(void)updatePlaylistCharacteristic;
@end
