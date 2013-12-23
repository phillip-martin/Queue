//
//  BTLEViewController.h
//  Queue
//
//  Created by Ethan on 12/22/13.
//  Copyright (c) 2013 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;
@import CoreBluetooth;

@interface BTLEViewController : UIViewController<CBPeripheralManagerDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, weak) IBOutlet UITableView *beaconTableView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSArray *detectedBeacons;
@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic, weak) UISwitch *advertisingSwitch;
@property (nonatomic, weak) UISwitch *rangingSwitch;


@end
