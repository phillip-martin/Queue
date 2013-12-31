//
//  BTLEViewController.h
//  Queue
//
//  Created by Ethan on 12/26/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeCentral.h"
#import "LePeripheral.h"
@import CoreBluetooth;

@interface BTLEViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate,LeCentral>

@property (nonatomic) UISwitch *advertisingSwitch;
@property (nonatomic) UISwitch *rangingSwitch;
@property (nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) LePeripheral *peripheralManager;
@property (nonatomic) LeCentral *centralManager;
//@property (nonatomic) CBMutableCharacteristic *transferCharacteristicData;
//@property (nonatomic) CBMutableCharacteristic *transferCharacteristicLibrary;
@property (nonatomic) NSMutableArray *detectedPeripherals;
@property (nonatomic) NSString *hostName;
@property (nonatomic) NSDictionary *myLibrary;

-(NSMutableArray *)songsToArray;
+(id)sharedInstance;

@end
