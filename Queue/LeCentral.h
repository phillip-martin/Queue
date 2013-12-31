//
//  LeCentral.h
//  Queue
//
//  Created by Ethan on 12/30/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

@protocol LeCentral<NSObject>
-(void)centralDidRefresh;
-(void)centralStatePoweredOff;
-(void)centralDidConnect:(CBPeripheral *)peripheral;
@end



@interface LeCentral : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, assign) id<LeCentral> centralDelegate;
@property (nonatomic) CBCentralManager *centralManager;
@property (nonatomic) CBPeripheral *connectedPeripheral;
@property (nonatomic) CBCharacteristic *libraryCharacteristic;
@property (nonatomic) CBCharacteristic *playlistCharacteristic;
@property (nonatomic) NSMutableArray *detectedPeripherals;
@property (nonatomic) NSMutableData *data;

-(void)stopScan;
-(void)scan;
-(NSMutableArray *)getHostLibrary;
-(void)cleanup;
-(void)writeHostPlaylist:(NSMutableArray *)newPlaylist;


@end
