//
//  BranchesViewController.m
//  Garenta
//
//  Created by Onur Küçük on 23.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "BranchesViewController.h"
#import "MBProgressHUD.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface BranchesViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BranchesViewController
//@synthesize office;
@synthesize officeArray;
@synthesize selectedOffice;
@synthesize filteredOfficeArray;
@synthesize searchBar;
@synthesize mapView;
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.mapView setShowsUserLocation:YES];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.mapView.hidden = true;
    self.tableView.hidden = false;
    self.mapView.delegate = self;
    self.searchBar.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }

   officeArray = [ApplicationProperties getOffices];
    
    if (officeArray.count == 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            officeArray = [Office getOfficesFromSAP];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"subOfficeName" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
            [officeArray sortUsingDescriptors:sortDescriptors];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[self tableView] reloadData];
           
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [filteredOfficeArray count];
    }
    else
    {
        return [officeArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"customCell";
   
     BranchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if ( cell == nil )
    {
        cell = [[BranchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
     Office *office = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        self.searchDisplayController.searchResultsTableView.rowHeight = [self.tableView rowHeight];
         office = [filteredOfficeArray objectAtIndex:indexPath.row];
        
    }
    
    else
    {
        office = [officeArray objectAtIndex:indexPath.row];
    }
    
    cell.branchNameLabel.text = [NSString stringWithFormat:@"%@",office.subOfficeName];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        selectedOffice = [filteredOfficeArray objectAtIndex:indexPath.row];
    }
    else
    {
    selectedOffice = [officeArray objectAtIndex:indexPath.row];
    }
    [self performSegueWithIdentifier:@"branchDetail" sender:self];
    
}

-(void)showPins
{
    for (int i = 0; i < self.officeArray.count; i++) {
       Office *office = [officeArray objectAtIndex:i];
        
        double latitude = [office.latitude doubleValue];
        double longitude = [office.longitude doubleValue];

        CLLocationCoordinate2D location;
       
        MKPointAnnotation *annotionPoint = [[MKPointAnnotation alloc]init];

        location.latitude  = latitude;
        location.longitude = longitude;

        annotionPoint.coordinate = location;
        annotionPoint.title = office.subOfficeName;
        
        [mapView addAnnotation:annotionPoint];
    }
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"subOfficeName contains[c] %@", searchText];
    filteredOfficeArray = [officeArray filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];

    
    return YES;
}
- (IBAction)segmentedControlAction:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        self.mapView.hidden = true;
        self.tableView.hidden = false;
        
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1)
    {
         [self showPins];
        
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
        
        
        CLLocation *location = [locationManager location];
        CLLocationCoordinate2D coordinate = [location coordinate];
        CLLocationCoordinate2D zoomLocation;
        
        MKCoordinateRegion viewRegion;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.9f;
        span.longitudeDelta = 0.9f;
        
        zoomLocation.latitude  = coordinate.latitude;
        zoomLocation.longitude = coordinate.longitude;
        
        viewRegion.span = span;
        viewRegion.center = zoomLocation;
        [mapView setRegion:viewRegion animated:YES];            
        
        self.tableView.hidden = true;
        self.mapView.hidden = false;
        
        

    }
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{

    static NSString *s = @"ann";
    MKAnnotationView *pin = [self.mapView dequeueReusableAnnotationViewWithIdentifier:s];
    if (annotation == [self.mapView userLocation]) {
        return nil;
    }
    if (!pin) {
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:s];
        pin.canShowCallout = YES;
        pin.calloutOffset = CGPointMake(0, 0);
        pin.canShowCallout = YES;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(mapButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = button;
        [button setTintColor:[ApplicationProperties getOrange]];
        
    }
    return pin;
}

- (void)mapView:(MKMapView *)map annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{

}
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subOfficeName==%@",view.annotation.title];
    NSArray *filterArray = [officeArray filteredArrayUsingPredicate:predicate];
    
    if (filterArray.count > 0)
    {
        selectedOffice = [filterArray objectAtIndex:0];
    }
    
    NSLog(@"%d",(int)index);

}

-(void)mapButtonClicked:(id)sender{
    [self performSegueWithIdentifier:@"branchDetail" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"branchDetail"]) {
        BranchDetailVC *destVC = (BranchDetailVC *)[segue destinationViewController];
        destVC.selectedOffice = selectedOffice;
    }
}
@end
