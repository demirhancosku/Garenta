//
//  BranchesViewController.h
//  Garenta
//
//  Created by Onur Küçük on 23.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Office.h"
#import "BranchDetailVC.h"
#import "BranchTableViewCell.h"

@interface BranchesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate, MKMapViewDelegate,CLLocationManagerDelegate>
{
    
}
- (IBAction)segmentedControlAction:(id)sender;
- (void)showPins;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic)Office *selectedOffice;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic)NSMutableArray *officeArray;
@property (strong,nonatomic) NSMutableArray *filteredOfficeArray;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
