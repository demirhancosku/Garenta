//
//  PaymentTableViewController.h
//  Garenta
//
//  Created by Alp Keser on 6/19/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
#import "WYPopoverController.h"

@interface PaymentTableViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate,WYPopoverControllerDelegate>

@property (strong,nonatomic) UIButton *hideButton;
@property (strong,nonatomic) Reservation *reservation;
@property (strong,nonatomic) CreditCard *creditCard;

@property (weak, nonatomic) IBOutlet UITextField *creditCardNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameOnCardTextField;
@property (weak, nonatomic) IBOutlet UITextField *expirationMonthTextField;
@property (weak, nonatomic) IBOutlet UITextField *expirationYearTextField;
@property (weak, nonatomic) IBOutlet UITextField *cvvTextField;
@property (weak, nonatomic) IBOutlet UITextField *garentaTlTextField;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

- (BOOL)checkRequiredFields;
@end
