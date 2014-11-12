//
//  BranchMapCell.m
//  Garenta
//
//  Created by Onur Küçük on 30.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "BranchMapCell.h"

@implementation BranchMapCell
@synthesize branchMapView;
- (void)awakeFromNib {
    // Initialization code
    _navigationButton.layer.cornerRadius = 5;
    _navigationButton.layer.borderColor = (__bridge CGColorRef)([UIColor colorWithRed:255 green:6 blue:18 alpha:1]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)showBranchPin:(Office *)selectedOffice
{
    double latitude = [selectedOffice.latitude doubleValue];
    double longitude = [selectedOffice.longitude doubleValue];
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D location;
    
    MKPointAnnotation *annotionPoint = [[MKPointAnnotation alloc]init];
    
    MKCoordinateRegion viewRegion;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    
    location.latitude  = latitude;
    location.longitude = longitude;
    
    viewRegion.span = span;
    viewRegion.center = location;
    
    annotionPoint.coordinate = location;
    annotionPoint.title = selectedOffice.subOfficeName;
    //    annotionPoint.title = @"Buraya navigasyon kurmak için tıklayın";
    
    
    [branchMapView addAnnotation:annotionPoint];
    [branchMapView setRegion:viewRegion animated:YES];
    [branchMapView selectAnnotation:annotionPoint animated:YES];
}

@end
