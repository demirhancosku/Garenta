//
//  BranchDetailVC.m
//  Garenta
//
//  Created by Onur Küçük on 29.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "BranchDetailVC.h"

@interface BranchDetailVC ()
@property (strong, nonatomic)NSString *hour;
@end

@implementation BranchDetailVC
@synthesize selectedOffice;
@synthesize tableView;
@synthesize officeHours;
@synthesize holidayDatesArray;
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [ self.mapView.delegate self];

    
    
    
    
    officeHours = [[NSArray alloc]init];
    holidayDatesArray = [[NSArray alloc]init];
    officeHours = selectedOffice.workingDates;
    if ([selectedOffice.holidayDates count]!=0) {
        holidayDatesArray = selectedOffice.holidayDates;
    }
    numberOfWorkingDay = officeHours.count;
    if (numberOfWorkingDay>7) {
        numberOfWorkingDay = 7;
    }
    switch (numberOfWorkingDay) {
        case 5:
            self.hour = [NSString stringWithFormat:@"%@ - %@\n  - \n - ",[[officeHours objectAtIndex:1] startTime], [[officeHours objectAtIndex:1]endingHour]];
            break;
        case 6:
            self.hour = [NSString stringWithFormat:@"%@ - %@\n%@ - %@\n - ",[[officeHours objectAtIndex:1] startTime], [[officeHours objectAtIndex:1]endingHour],[[officeHours objectAtIndex:5]startTime],[[officeHours objectAtIndex:5]endingHour]];
            break;
        case 7:
            self.hour = [NSString stringWithFormat:@"%@ - %@\n%@ - %@\n%@ - %@",[[officeHours objectAtIndex:1] startTime], [[officeHours objectAtIndex:1]endingHour],[[officeHours objectAtIndex:5]startTime],[[officeHours objectAtIndex:5]endingHour],[[officeHours objectAtIndex:6]startTime],[[officeHours objectAtIndex:6]endingHour]];
            break;
        default:
            break;
    }
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        BranchInfoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"branchInfo" forIndexPath:indexPath];
        cell.branchNameLabel.text = selectedOffice.subOfficeName;
        cell.branchAddressLabel.text = selectedOffice.address;
        [cell.branchTelLabel setTitle:[NSString stringWithFormat:@"%@",selectedOffice.tel] forState:UIControlStateNormal];
        cell.branchTelLabel.layer.cornerRadius = 5;
        cell.branchTelLabel.layer.borderColor = [cell.branchTelLabel tintColor].CGColor;
        cell.branchTelLabel.layer.borderWidth=1.0f;

        return cell;

    }
    else 
    {
        
        BranchMapCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"branchMap" forIndexPath:indexPath];

        NSString *holidayDates = @"";
        cell.navigationButton.layer.cornerRadius = 5;
        cell.navigationButton.layer.borderColor = [cell.navigationButton tintColor].CGColor;
        cell.navigationButton.layer.borderWidth=1.0f;
        
        
        if ([holidayDatesArray count] == 0) {
            cell.holidayDates.hidden = true;
            cell.holidayDaysLabel.hidden = true;

        }
        else
        {
            cell.holidayDates.hidden = false;
            cell.holidayDaysLabel.hidden = false;
           

            for (int i = 0; i<[holidayDatesArray count]; i++) {
                NSString *date = [[NSString alloc]init];
                date = [NSString stringWithFormat:@"%@ \n",[[holidayDatesArray objectAtIndex:i]holidayDate]];
                holidayDates = [holidayDates stringByAppendingString:date];
            }
            
            
            
        }
        
        cell.officeHoursLabel.text = self.hour;
        cell.holidayDates.text = holidayDates;
        
        [cell showBranchPin:selectedOffice];
        [self showBranchPin];
        
        return cell;
            
    }
    
}
-(void)showBranchPin
{
    double latitude = [selectedOffice.latitude doubleValue];
    double longitude = [selectedOffice.longitude doubleValue];
  
    
    CLLocationCoordinate2D location;
    MKPointAnnotation *annotionPoint = [[MKPointAnnotation alloc]init];
    
    MKCoordinateRegion viewRegion;
    MKCoordinateSpan span;
   
    span.latitudeDelta = 0.7f;
    span.longitudeDelta = 0.7f;
    
    
    location.latitude  = latitude;
    location.longitude = longitude;
    
    viewRegion.span = span;
    viewRegion.center = location;

    
    annotionPoint.coordinate = location;
//    annotionPoint.title = selectedOffice.subOfficeName;
//    annotionPoint.title = @"Buraya navigasyon kurmak için tıklayın";
//    viewRegion = MKCoordinateRegionMakeWithDistance(location, 1000, 1000);

    
    [self.mapView addAnnotation:annotionPoint];
    [self.mapView setRegion:viewRegion animated:YES];
    [self.mapView selectAnnotation:annotionPoint animated:YES];
}

-(IBAction)callPhone:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Şubeyi Ara" message:[NSString stringWithFormat:@"%@ şubesi aransın mı?", [selectedOffice subOfficeName]] delegate:self cancelButtonTitle:@"Ara" otherButtonTitles:@"Vazgeç", nil];
    [alert show];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", selectedOffice.tel]]];
    }
    [alertView dismissWithClickedButtonIndex:1 animated:YES];
}
- (IBAction)navigateToBranch:(id)sender {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    
    [locationManager setDelegate:self];
    
    [locationManager startUpdatingLocation];
    
    MKMapItem *currentLocationItem = [MKMapItem mapItemForCurrentLocation];
    double latitude = [selectedOffice.latitude doubleValue];
    double longitude = [selectedOffice.longitude doubleValue];
    
    CLLocationCoordinate2D location;
    
    location.latitude  = latitude;
    location.longitude = longitude;
    
    MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil];
    
    MKMapItem *destinationLocItem = [[MKMapItem alloc] initWithPlacemark:place];
    
    destinationLocItem.name = [selectedOffice subOfficeName];
    
    NSArray *mapItemsArray = [NSArray arrayWithObjects:currentLocationItem, destinationLocItem, nil];
    
    NSDictionary *dictForDirections = [NSDictionary dictionaryWithObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
    
    [MKMapItem openMapsWithItems:mapItemsArray launchOptions:dictForDirections];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
