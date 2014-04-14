//
//  UserCreationVC.h
//  Garenta
//
//  Created by Ata  Cengiz on 27.02.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCreationVC : BaseVC <UITextFieldDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableData *bigData;
    NSMutableArray *countryArray;
    NSMutableArray *cityArray;
    NSMutableArray *countyArray;
    UIDatePicker *datePicker;
    UITextField *activeField;
    UIPickerView *userCreationPickerView;
    NSMutableArray *secretQuestionsArray;
    UIBarButtonItem *barButton;
    NSString *countryCode;
    NSString *secretQuestionNumber;
    
    NSURLConnection *getCountryCon;
    NSURLConnection *createUserCon;
    NSURLConnection *getSecretQuestionsCon;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *surnameTextField;
@property (nonatomic, retain) IBOutlet UITextField *birthdayTextField;
@property (nonatomic, retain) IBOutlet UITextField *tcknNoTextField;
@property (nonatomic, retain) IBOutlet UITextField *countryTextField;
@property (nonatomic, retain) IBOutlet UITextField *adressTextField;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *mobileTextField;
@property (nonatomic, retain) IBOutlet UISegmentedControl *nationSegmentedControl;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UITextField *password2TextField;
@property (nonatomic, retain) IBOutlet UITextField *secretQuestionTextField;
@property (nonatomic, retain) IBOutlet UITextField *secretAnswerTextField;



@end
