//
//  ForgotPasswordVC.h
//  Garenta
//
//  Created by Kerem Balaban on 23.02.2015.
//  Copyright (c) 2015 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordVC : UITableViewController <UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *countryArray;
@property (strong, nonatomic) NSMutableArray *secretQuestionsArray;

@end
