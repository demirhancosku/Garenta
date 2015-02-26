//
//  UserCreationVC.h
//  Garenta
//
//  Created by Ata  Cengiz on 27.02.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountrySelectionVC.h"

@interface UserCreationVC : UITableViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>
{
    NSMutableArray *countryArray;
    NSMutableArray *cityArray;
    NSMutableArray *countyArray;
//    NSMutableArray *secretQuestionsArray;
}

@property (strong, nonatomic) NSMutableArray *secretQuestionsArray;
- (IBAction)continueButtonPressed:(id)sender;
- (IBAction)nationalitySegmentChanged:(id)sender;
- (void)getCountryInformationFromSAP;

@end
