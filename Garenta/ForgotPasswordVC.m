//
//  ForgotPasswordVC.m
//  Garenta
//
//  Created by Kerem Balaban on 23.02.2015.
//  Copyright (c) 2015 Kerem Balaban. All rights reserved.
//

#import "ForgotPasswordVC.h"
#import "MBProgressHUD.h"
#import "SMSSoapHandler.h"
#import "CountrySelectionVC.h"

@interface ForgotPasswordVC ()

@property (weak, nonatomic) IBOutlet UIPickerView *secretQuestionPickerView;
@property (weak, nonatomic) IBOutlet UITextField *mobilePhoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *securityAnswerTextField;
@property (weak, nonatomic) IBOutlet UITextField *otherSecurityQuestionTextField;
@property (weak, nonatomic) IBOutlet UILabel *mobilePhoneCountryLabel;

@property (weak, nonatomic) NSString *questionId;
@property (weak, nonatomic) NSString *questionText;
@property (strong, nonatomic) NSString *kunnr;

- (IBAction)resetPassword:(id)sender;
@end

@implementation ForgotPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneCountrySelected:) name:@"phoneCountrySelected" object:nil];
    self.otherSecurityQuestionTextField.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:@"phoneCountrySelected"];
}

- (void)phoneCountrySelected:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSArray *country = [userInfo objectForKey:@"PhoneCountry"];
    
    self.mobilePhoneCountryLabel.text = country[0];
}

- (IBAction)resetPassword:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self getUserSecurityQuestion];
    });
}

- (void)getUserSecurityQuestion
{
    NSString *message = @"";
    UIAlertView *alert = [[UIAlertView alloc] init];
    [self releaseAllTextFields];
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_GET_CUSTOMER_GUVENLIK"];
        
        [handler addImportParameter:@"IV_MOBILE" andValue:self.mobilePhoneTextField.text];
        
        NSDictionary *result = [handler prepCall];
        
        if (result != nil) {
            NSDictionary *export = [result objectForKey:@"EXPORT"];
            NSString *questionId   = [export valueForKey:@"EV_GUVENSORU"];
            NSString *answer       = [export valueForKey:@"EV_GUVENCEVAP"];
            NSString *questionText = [export valueForKey:@"EV_MUSTERISORUSU"];
            self.kunnr             = [export valueForKey:@"EV_PARTNER"];
            
            if ([self.questionId isEqualToString:@"999"]) {
                
                if (![self.otherSecurityQuestionTextField.text isEqualToString:questionText] || ![self.securityAnswerTextField.text isEqualToString:answer]) {
                    
                    message = @"Güvenlik soru/cevabı yanlıştır.";
                }
            }
            else if (![self.questionId isEqualToString:questionId] || ![self.securityAnswerTextField.text isEqualToString:answer]) {
                
                message = @"Güvenlik soru/cevabı yanlıştır.";
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {

    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        if (![message isEqualToString:@""]) {
            [alert setTitle:message];
            [alert setMessage:@"Tekrar deneyebilir yada ödeme bilgilerinizi sıfırlayarak şifrenizi tekrar alabilirsiniz."];
            [alert setDelegate:self];
            [alert setTag:1];
            [alert addButtonWithTitle:@"Geri"];
            [alert addButtonWithTitle:@"Sıfırla"];
            [alert show];
        }
        else
        {
            [self createUserPassword:NO];
        }
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1) {
        [self createUserPassword:YES];
    }
}

- (void)createUserPassword:(BOOL)reset {
    NSString *generatedCode = [SMSSoapHandler generateCode];
    
    if (generatedCode == nil || [generatedCode isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"SMS gönderilemedi, lütfen tekrar deneyiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        [self sendPasswordToCrm:generatedCode andReset:reset];
    }
}

- (void)sendPasswordToCrm:(NSString *)newPassword andReset:(BOOL)reset
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *alertString = @"";
        
        @try {
            SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_UPDATE_USER_PASSWORD"];
            
            NSData *newPasswordData = [newPassword dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
            NSString *newPasswordEncoded = [newPasswordData base64EncodedStringWithOptions:0];
            
            [handler addImportParameter:@"IV_TELNO" andValue:self.mobilePhoneTextField.text];
            [handler addImportParameter:@"IV_NEWPASSWORD" andValue:newPasswordEncoded];
            [handler addImportParameter:@"FORGET_FLAG" andValue:@"X"];
            if (reset) {
                [handler addImportParameter:@"IV_KK_SIFIRLA" andValue:@"X"];
            }
            
            [handler addTableForReturn:@"ET_RETURN"];
            
            NSDictionary *response = [handler prepCall];
            
            if (response != nil) {
                NSDictionary *export = [response objectForKey:@"EXPORT"];
                
                NSString *result = [export valueForKey:@"EV_SUBRC"];
                
                if (![result isEqualToString:@"0"]) {

                }
                else {
                    [[NSUserDefaults standardUserDefaults] setObject:newPasswordEncoded forKey:@"PASSWORD"];
                    NSString *phoneNumber = self.mobilePhoneTextField.text;
                    
                    BOOL success = [SMSSoapHandler sendWebPassword:newPassword toNumber:phoneNumber];
                    
                    if (success) {
                        alertString = @"Şifreniz SMS ile gönderilmiştir. Mail adresiniz ve şifrenizi kullanarak giriş yapabilirsiniz.";
                    }
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        if (![alertString isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self releaseAllTextFields];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 1) {
        if (range.location == 10){
            return NO;
        }
    }
    
    return YES;
}

- (void)releaseAllTextFields
{
    [self.mobilePhoneTextField resignFirstResponder];
    [self.securityAnswerTextField resignFirstResponder];
    [self.otherSecurityQuestionTextField resignFirstResponder];
}

#pragma mark - Pickerview Delegation Methods

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel* tView = (UILabel*)view;
    
    if (!tView){
        tView = [[UILabel alloc] init];
        tView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    }
    
    tView.text = [[self.secretQuestionsArray objectAtIndex:row] objectAtIndex:1];
    
    return tView;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.secretQuestionsArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self.secretQuestionsArray objectAtIndex:row] objectAtIndex:1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.questionId = [[self.secretQuestionsArray objectAtIndex:row] objectAtIndex:0];
    self.questionText = [[self.secretQuestionsArray objectAtIndex:row] objectAtIndex:1];
    
    if ([self.questionId isEqualToString:@"999"]) {
        self.otherSecurityQuestionTextField.enabled = YES;
    }
    else{
        self.otherSecurityQuestionTextField.enabled = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MobilePhoneCountrySelectionSegue"]) {
        CountrySelectionVC *selectionVC = (CountrySelectionVC *)[segue destinationViewController];
        selectionVC.selectionArray = self.countryArray;
        selectionVC.searchType = 4;
    }
}


@end
