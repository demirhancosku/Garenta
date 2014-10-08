//
//  UserCreationVC.h
//  Garenta
//
//  Created by Ata  Cengiz on 27.02.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCreationVC : UITableViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableData *bigData;
    NSMutableArray *countryArray;
    NSMutableArray *cityArray;
    NSMutableArray *countyArray;
    UIPickerView *userCreationPickerView;
    NSMutableArray *secretQuestionsArray;
    NSString *countryCode;
    NSString *secretQuestionNumber;
    
    NSURLConnection *getCountryCon;
    NSURLConnection *createUserCon;
    NSURLConnection *getSecretQuestionsCon;
}

- (IBAction)continueButtonPressed:(id)sender;
- (IBAction)nationalitySegmentChanged:(id)sender;

@end
