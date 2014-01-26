//
//  SCSearchViewController.h
//  Queue
//
//  Created by Ethan on 1/26/14.
//  Copyright (c) 2014 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCSearchViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>

@property IBOutlet UISearchBar *searchBar;
@property (nonatomic) NSMutableArray *filteredSCArray;

@end
