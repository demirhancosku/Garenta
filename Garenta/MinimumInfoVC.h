//
//  MinimumInfoVC.h
//  Garenta
//
//  Created by Alp Keser on 12/31/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "Reservation.h"
#import "iToast.h"

@interface MinimumInfoVC : BaseVC <UITextFieldDelegate, UIScrollViewDelegate>
{
    UITextField *activeField;
    UIDatePicker *datePicker;
    UIBarButtonItem *barButton;
}

- (id)initWithReservation:(Reservation*)aReservation;

@property (nonatomic,retain)Reservation *reservation;
@property (nonatomic,retain)IBOutlet UIScrollView *scrollView;
@property (nonatomic,retain)IBOutlet UILabel *headerLabel;
@property (nonatomic,retain)IBOutlet  UITextField *nameTextField;
@property (nonatomic,retain)IBOutlet UITextField *surnameTextField;
@property (nonatomic,retain)IBOutlet UITextField *birthdayTextField;
@property (nonatomic,retain)IBOutlet UITextField *tcknNoTextField;
@property (nonatomic,retain)IBOutlet UITextField *emailTextField;
@property (nonatomic,retain)IBOutlet UITextField *mobileTextField;
@property (nonatomic, retain) IBOutlet UISegmentedControl *sexSegmentedControl;

@end
