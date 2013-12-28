//
//  BTLEViewController.h
//  Queue
//
//  Created by Ethan on 12/26/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreBluetooth;

@interface BTLEViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic) UISwitch *advertisingSwitch;
@property (nonatomic) UISwitch *rangingSwitch;
@property (nonatomic) UITableView *peripheralView;
@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) CBCentralManager *centralManager;
@property (nonatomic) CBMutableCharacteristic *transferCharacteristicData;
@property (nonatomic) CBMutableCharacteristic *transferCharacteristicLibrary;
@property (nonatomic) NSData *dataToSend;
@property (nonatomic, readwrite) NSInteger sendDataIndex;
@property (nonatomic) CBPeripheral *discoveredPeripheral;
@property (nonatomic) NSMutableData *data;
@property (nonatomic) NSMutableDictionary *myLibrary;
@property (nonatomic) NSMutableArray *detectedPeripherals;
@property (nonatomic) NSString *hostName;

@end
