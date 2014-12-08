//
//  PaymentTableViewController.m
//  Garenta
//
//  Created by Alp Keser on 6/19/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "PaymentTableViewController.h"
#import "CreditCard.h"
#import "AdditionalEquipment.h"
#import "WYStoryboardPopoverSegue.h"
#import "OldCardSelectionVC.h"
#import "MBProgressHUD.h"
#import "ReservationApprovalVC.h"
#import "AgreementsVC.h"

@interface PaymentTableViewController ()

@property (strong,nonatomic) WYPopoverController *myPopoverController;
@property(strong,nonatomic) NSArray *requiredFields;

- (IBAction)reservationCompleteButtonPressed:(id)sender;
@end

@implementation PaymentTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_reservation.etExpiry.count > 0) {
        [_totalPriceLabel setText:[NSString stringWithFormat:@"%.02fTL(1. Taksit)", [[_reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:_garentaTlTextField.text andIsMontlyRent:YES andIsCorparatePayment:NO andIsPersonalPayment:NO] floatValue]]];
        [_totalPriceLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    }
    else if ([[ApplicationProperties getUser] isLoggedIn] && [[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
        [_totalPriceLabel setText:[NSString stringWithFormat:@"%.02fTL(Personel)", [[_reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:@"0" andIsMontlyRent:NO andIsCorparatePayment:NO andIsPersonalPayment:YES] floatValue]]];
        [_totalPriceLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    }
    else {
        [_totalPriceLabel setText:[NSString stringWithFormat:@"%.02f TL",[[_reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:_garentaTlTextField.text andIsMontlyRent:NO andIsCorparatePayment:NO andIsPersonalPayment:NO] floatValue]]];
    }

    _requiredFields = [NSArray arrayWithObjects:_creditCardNumberTextField,_nameOnCardTextField,_expirationMonthTextField,_expirationYearTextField,_cvvTextField, nil];
    
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        NSString *name = @"";
        if (![[[ApplicationProperties getUser] middleName] isEqualToString:@""] && [[ApplicationProperties getUser] middleName] != nil) {
            name = [NSString stringWithFormat:@"%@ %@", [[ApplicationProperties getUser] name], [[ApplicationProperties getUser] middleName]];
        }
        else {
            name = [[ApplicationProperties getUser] name];
        }
        
        _nameOnCardTextField.text = [NSString stringWithFormat:@"%@ %@", name, [[ApplicationProperties getUser] surname]];
        
    }
    else {
        
        NSString *name = @"";
        if (![[[_reservation temporaryUser] middleName] isEqualToString:@""] && [[_reservation temporaryUser] middleName] != nil) {
            name = [NSString stringWithFormat:@"%@ %@", [[_reservation temporaryUser] name], [[_reservation temporaryUser] middleName]];
        }
        else {
            name = [[_reservation temporaryUser] name];
        }
        
        _nameOnCardTextField.text = [NSString stringWithFormat:@"%@ %@", name, _reservation.temporaryUser.surname];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"oldCardSelected" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
        [[self myPopoverController] dismissPopoverAnimated:YES];
        [self prepareTextFields:note];
        [self.tableView reloadData];
    }];
}

- (void)prepareTextFields:(NSNotification *)note
{
    _creditCard = [CreditCard new];
    _creditCard = note.object;
    
    if (_creditCard.cardNumber == nil)
        [self setTextFieldsEnable:YES];
    else
        [self setTextFieldsEnable:NO];
    
//    _nameOnCardTextField.text = _creditCard.nameOnTheCard;
    _creditCardNumberTextField.text = _creditCard.cardNumber;
    _expirationMonthTextField.text = _creditCard.expirationMonth;
    _expirationYearTextField.text = _creditCard.expirationYear;
    _cvvTextField.text = _creditCard.cvvNumber;
}

- (void)setTextFieldsEnable:(BOOL)boolean
{
    _nameOnCardTextField.enabled = boolean;
    _creditCardNumberTextField.enabled = boolean;
    _expirationMonthTextField.enabled = boolean;
    _expirationYearTextField.enabled = boolean;
    _cvvTextField.enabled = boolean;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        if ([[ApplicationProperties getUser] isPriority]) {
            [self getUserCreditCardsFromSAP];
        }
        
        self.garentaTlTextField.placeholder = [NSString stringWithFormat:@"Bakiyeniz : %@", [[ApplicationProperties getUser] garentaTl]];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getUserCreditCardsFromSAP {
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZMOB_KDK_GET_CUSTOMER_KK"];
        
        [handler addImportParameter:@"I_KUNNR" andValue:[[ApplicationProperties getUser] kunnr]];
        
        [handler addTableForReturn:@"ET_CARDS"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            
            NSString *result = [export valueForKey:@"E_RETURN"];
            
            if ([result isEqualToString:@"T"]) {
                
                NSDictionary *tables = [response objectForKey:@"TABLES"];
                NSDictionary *cardsArray = [tables objectForKey:@"ZNET_INT_S023"];
                
                NSMutableArray *creditCards = [NSMutableArray new];
                
                for (NSDictionary *tempDict in cardsArray) {
                    CreditCard *tempCard = [[CreditCard alloc] init];
                    tempCard.cardNumber = [tempDict valueForKey:@"KARTNO"];
                    tempCard.uniqueId = [tempDict valueForKey:@"UNIQUE_ID"];
                    [creditCards addObject:tempCard];
                }
                
                [[ApplicationProperties getUser] setCreditCards:creditCards];
                [[self tableView] reloadData];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *) textField.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self.tableView scrollToRowAtIndexPath:indexPath
                                              atScrollPosition:UITableViewScrollPositionTop
                                                      animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 1) //kart no
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c]) {
                return NO;
            }
        }
        
        if (range.location == 19) {
            return NO;
        }
        
        if ([string length] == 0)
        {
            return YES;
        }
        
        if ((range.location == 4) || (range.location == 9) || (range.location == 14)) {
            NSString *str = [NSString stringWithFormat:@"%@ ",_creditCardNumberTextField.text];
            _creditCardNumberTextField.text = str;
        }
        
        return YES;
    }
    
    if (textField.tag == 2 || textField.tag == 3 || textField.tag == 4) // tarih ay-yıl alanı
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c]) {
                return NO;
            }
        }
        
        switch (textField.tag)
        {
            case 2:
                if (range.location == 2)
                    return NO;
                break;
            case 3:
                if (range.location == 4)
                    return NO;
                break;
            case 4:
                if (range.location == 3)
                    return NO;
                break;
            default:
                break;
        }
    }
    
    if (textField.tag == 5)
    {
        [_totalPriceLabel setText:[NSString stringWithFormat:@"%.02f TL",[[_reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:string andIsMontlyRent:NO andIsCorparatePayment:NO andIsPersonalPayment:NO] floatValue]]];
    }
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self releaseAllTextFields];
    
    if (indexPath.row == 0 && [[[ApplicationProperties getUser] creditCards] count] > 0)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"toOldCardSegue" sender:cell];
    }
    else if (indexPath.row == 0 && [[[ApplicationProperties getUser] creditCards] count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Kayıtlı kredi kartınız bulunamamıştır" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)releaseAllTextFields
{
    [_nameOnCardTextField resignFirstResponder];
    [_creditCardNumberTextField resignFirstResponder];
    [_expirationMonthTextField resignFirstResponder];
    [_expirationYearTextField resignFirstResponder];
    [_cvvTextField resignFirstResponder];
    [_garentaTlTextField resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toOldCardSegue"]) {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.preferredContentSize = CGSizeMake(320, 280);   
        
        self.myPopoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
        self.myPopoverController.delegate = self;
        
        [(OldCardSelectionVC *)segue.destinationViewController setPickerData:[[ApplicationProperties getUser] creditCards]];
    }
    if ([[segue identifier] isEqualToString:@"toReservationApprovalVCSegue"]) {
        [(ReservationApprovalVC*)[segue destinationViewController] setReservation:_reservation];
    }
    if ([[segue identifier] isEqualToString:@"toAgreementVCSegue"]) {
        [(AgreementsVC*)[segue destinationViewController] setHtmlName:@"RentingAgreement"];
        [(AgreementsVC*)[segue destinationViewController] setAgreementName:@"Kiralama Anlaşması"];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [[self view] endEditing:YES];
            [self performSegueWithIdentifier:@"toAgreementVCSegue" sender:self];
        }
        if (buttonIndex == 2) {
            [self createReservation];
        }
    }
}

#pragma mark - custom methods

- (BOOL)checkRequiredFields{
    
    if (_creditCard.uniqueId != nil)
        return YES;
    
    NSString *errorMessage;
    
    NSDateComponents *dateComponents =[[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate:NSDate.date];
    
    if (_creditCardNumberTextField.text.length == 0 || _nameOnCardTextField.text.length == 0 || _expirationMonthTextField.text.length == 0 || _expirationYearTextField.text.length == 0 || _cvvTextField.text.length == 0)
        
        errorMessage = @"Lütfen tüm zorunlu alanları doldurunuz.";
    
    else if (_creditCardNumberTextField.text.length < 19)
        errorMessage = @"Kredi kartı numaranız 16 hane olmalıdır, lütfen kontrol edin.";
    
    else if (_expirationMonthTextField.text.length < 2)
        errorMessage = @"Girmiş olduğunuz ay değeri 2 hane olmalıdır, lütfen kontrol edin.";
    
    else if (_expirationMonthTextField.text.integerValue > 12 || _expirationMonthTextField.text.integerValue == 0)
        errorMessage = @"Girmiş olduğunuz ay değeri geçerli formatta değildir, lütfen kontrol edin.";
    
    else if (_expirationYearTextField.text.length < 4)
        errorMessage = @"Girmiş olduğunuz yıl değeri 4 hane olmalıdır, lütfen kontrol edin.";
    
    else if (_expirationYearTextField.text.integerValue < dateComponents.year)
        errorMessage = @"Girmiş olduğunuz yıl değeri mevcut yıldan küçük olamaz, lütfen kontrol edin.";
    
    else if (_expirationYearTextField.text.integerValue == dateComponents.year && _expirationMonthTextField.text.integerValue < dateComponents.month)
        errorMessage = @"Girmiş olduğunuz son kullanma tarihini kontrol edin.";
    
    else if (_cvvTextField.text.length < 3)
        errorMessage = @"CVV numarası 3 hane olmalıdır, lütfen kontrol edin.";
    

    if (errorMessage != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:errorMessage delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        return NO;
    }

    return YES;
}

- (void)createReservation {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        CreditCard *tempCard = [[CreditCard alloc] init];
        
        if (_creditCard.uniqueId != nil) {
            tempCard.uniqueId = _creditCard.uniqueId;
        }
        else {
            tempCard.cardNumber = [self.creditCardNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            tempCard.nameOnTheCard = self.nameOnCardTextField.text;
            tempCard.cvvNumber = self.cvvTextField.text;
            tempCard.expirationYear = self.expirationYearTextField.text;
            tempCard.expirationMonth = self.expirationMonthTextField.text;
        }
        
        _reservation.paymentNowCard = tempCard;
        
        _reservation.reservationNumber = [Reservation createReservationAtSAP:_reservation andIsPayNow:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (_reservation.reservationNumber != nil && ![_reservation.reservationNumber isEqualToString:@""]) {
                [self performSegueWithIdentifier:@"toReservationApprovalVCSegue" sender:self];
            }
        });
    });
}

- (IBAction)reservationCompleteButtonPressed:(id)sender {
    if ([self checkRequiredFields])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Kira anlaşmasını kabul edip, rezervasyonuzun yaratılmasını istediğinize emin misiniz ?" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Kira Anlaşmasını Oku", @"Kabul Ediyorum", nil];
        [alert setTag:1];
        [alert show];
    }
}

@end
