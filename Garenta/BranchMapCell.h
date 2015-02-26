//
//  BranchMapCell.h
//  Garenta
//
//  Created by Onur Küçük on 30.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Office.h"
@interface BranchMapCell : UITableViewCell <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *navigationButton;
@property (weak, nonatomic) IBOutlet MKMapView *branchMapView;
@property (weak, nonatomic) IBOutlet UILabel *officeHoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *holidayDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *holidayDates;

-(void)showBranchPin:(Office *)selectedOffice;
@end
