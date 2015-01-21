//
//  UserInfoTableViewController.h
//  Garenta
//
//  Created by Alp Keser on 6/6/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
@interface UserInfoTableViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
    NSMutableArray *countryArray;
    NSMutableArray *cityArray;
    NSMutableArray *countyArray;
    NSMutableArray *secretQuestionsArray;
    BOOL isYoungDriver;
}

- (IBAction)continueButtonPressed:(id)sender;
- (IBAction)nationalitySegmentChanged:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;
- (void)getCountryInformationFromSAP;

@property(strong,nonatomic)Reservation *reservation;

@end
