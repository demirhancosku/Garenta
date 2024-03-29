//
//  LoginVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "LoginVC.h"
#import "ReservationSummaryVC.h"
#import "MailSoapHandler.h"
#import "OldReservationListVC.h"
#import "GarentaPointTableViewController.h"
#import "ForgotPasswordVC.h"
#import "UserCreationVC.h"

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) NSArray *userList;
@property (strong,nonatomic) WYPopoverController *popOver;

- (IBAction)login:(id)sender;
- (IBAction)forgetMyPassword:(id)sender;

@end

@implementation LoginVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    countryArray = [[NSMutableArray alloc] init];
    secretQuestionsArray = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(releaseAllTextFields)];
    [self.view addGestureRecognizer:singleFingerTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self view] setBackgroundColor:[ApplicationProperties getWhite]];
    
    if (self.shouldNotPop) {
        [[self navigationItem] setLeftBarButtonItem:self.leftButton];
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

- (IBAction)login:(id)sender
{
    if (![_usernameTextField.text isEqualToString:@""] && ![_passwordTextField.text isEqualToString:@""])
    {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *passwordData = [_passwordTextField.text dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
            NSString *base64Encoded = [passwordData base64EncodedStringWithOptions:0];
            
            self.userList = [User loginToSap:_usernameTextField.text andPassword:base64Encoded];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                
                if (self.userList != nil && self.userList.count == 1 && ![[ApplicationProperties getUser] isLoggedIn]) {
                    User *user = [self.userList objectAtIndex:0];
                    user.isLoggedIn = YES;
                    [user setUserList:self.userList];
                    [ApplicationProperties setUser:user];
                    
                    NSString *message = @"";
                    if ([user.middleName isEqualToString:@""]) {
                        message = [NSString stringWithFormat:@"Sayın %@ %@", [user name], [user surname]];
                    }
                    else{
                        message = [NSString stringWithFormat:@"Sayın %@ %@ %@", [user name], [user middleName], [user surname]];
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hoşgeldiniz" message:message delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                    
                    [self goToView];
                }
                else if (self.userList != nil && self.userList.count > 1 && ![[ApplicationProperties getUser] isLoggedIn]){
                    [self showUserList];
                }
            });
        });
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Kullanıcı adı ve şifre giriniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)showUserList {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Lütfen Kullanıcı Seçimi Yapınız"];
    
    for (User *tempUser in self.userList) {
        
        NSString *buttonTitle = @"";
        
        if ([tempUser.middleName isEqualToString:@""]) {
            buttonTitle = [NSString stringWithFormat:@"%@ %@", tempUser.name, tempUser.surname];
        }
        else {
            buttonTitle = [NSString stringWithFormat:@"%@ %@ %@", tempUser.name, tempUser.middleName, tempUser.surname];
            
        }
        
        if ([[tempUser partnerType] isEqualToString:@"B"]) {
            buttonTitle = [NSString stringWithFormat:@"%@ (Bireysel)", buttonTitle];
        }
        if ([[tempUser partnerType] isEqualToString:@"K"]) {
            buttonTitle = [NSString stringWithFormat:@"%@ (%@)", buttonTitle,tempUser.companyName];
        }
        
        [alert addButtonWithTitle:buttonTitle];
    }
    
    [alert setDelegate:self];
    [alert setTag:1];
    [alert show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //e-posta ile şifre hatırlat
    if (buttonIndex == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Lütfen yeni şifrenizin gönderilmesi için üye e-mail adresinizi giriniz" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Devam", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert setTag:2];
        
        [alert show];
    }
    //telefon ile şifre hatırlat
    else if (buttonIndex == 1){
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            [self getCountryInformationFromSAP];
            [self getSecurityQuestionList];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [self performSegueWithIdentifier:@"toForgotPasswordSegue" sender:self];
            });
        });
        
    }
}

- (void)getSecurityQuestionList
{
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_GET_GUVENLIK_SORU"];
        
        [handler addImportParameter:@"I_LANGU" andValue:@"T"];
        
        [handler addTableForReturn:@"ET_SORULAR"];
        
        NSDictionary *result = [handler prepCall];
        
        if (result != nil) {
            NSDictionary *tables = [result objectForKey:@"TABLES"];
            
            NSDictionary *securityQuestion = [tables objectForKey:@"ZCRMS_GUVEN_SORU"];
            
            NSArray *arr = @[@"000", @"Soru Seçiniz..."];
            [secretQuestionsArray addObject:arr];
            
            for (NSDictionary *tempDict in securityQuestion) {
                NSArray *arr = @[[tempDict valueForKey:@"SORUKODU"], [tempDict valueForKey:@"SORUTEXT"]];
                [secretQuestionsArray addObject:arr];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)getCountryInformationFromSAP {
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_GET_ULKE_IL_ILCE"];
        
        [handler addTableForReturn:@"ET_ULKE"];
        NSDictionary *result = [handler prepCall];
        
        if (result != nil) {
            NSDictionary *export = [result objectForKey:@"EXPORT"];
            NSString *evSubrc = [export valueForKey:@"EV_SUBRC"];
            
            if ([evSubrc isEqualToString:@"0"]) {
                NSDictionary *tables = [result objectForKey:@"TABLES"];
                
                NSDictionary *countryDict = [tables objectForKey:@"T005T"];
                
                for (NSDictionary *tempDict in countryDict) {
                    NSArray *arr = @[[tempDict valueForKey:@"LAND1"], [tempDict valueForKey:@"LANDX50"]];
                    [countryArray addObject:arr];
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        User *tempUser = [self.userList objectAtIndex:buttonIndex];
        tempUser.isLoggedIn = YES;
        tempUser.userList = self.userList;
        
        [ApplicationProperties setUser:tempUser];
        [self goToView];
    }
    if (alertView.tag == 2 && buttonIndex == 1) {
        NSString *mailAdress = [alertView textFieldAtIndex:0].text;
        
        if (mailAdress == nil && [mailAdress isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Girdiğiniz e-mail adresi boş olamaz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
        }
        else {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self updateUserPasswordAtSAP:mailAdress];
                
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            });
        }
    }
}

- (void)updateUserPasswordAtSAP:(NSString *)mailAdress {
    
    NSString *alertString = @"";
    
    @try {
        
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_UPDATE_USER_PASSWORD"];
        
        // Random alpha numeric new password
        NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
        NSMutableString *aNewPassword = [NSMutableString stringWithCapacity:8];
        for (NSUInteger i = 0U; i < 8; i++) {
            u_int32_t r = arc4random() % [alphabet length];
            unichar c = [alphabet characterAtIndex:r];
            [aNewPassword appendFormat:@"%C", c];
        }
        
        NSData *newPasswordData = [aNewPassword dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
        NSString *newPasswordEncoded = [newPasswordData base64EncodedStringWithOptions:0];
        
        [handler addImportParameter:@"IV_EMAILADRESS" andValue:mailAdress];
        [handler addImportParameter:@"IV_NEWPASSWORD" andValue:newPasswordEncoded];
        [handler addImportParameter:@"FORGET_FLAG" andValue:@"X"];
        [handler addTableForReturn:@"ET_RETURN"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            
            NSString *result = [export valueForKey:@"EV_SUBRC"];
            
            if (![result isEqualToString:@"0"]) {
                
                NSDictionary *tables = [response objectForKey:@"TABLES"];
                NSDictionary *etReturn = [tables objectForKey:@"BAPIRET2"];
                
                for (NSDictionary *temp in etReturn) {
                    if ([[temp valueForKey:@"TYPE"] isEqualToString:@"E"]) {
                        alertString = [temp valueForKey:@"MESSAGE"];
                    }
                }
                
                if ([alertString isEqualToString:@""]) {
                    alertString = @"Güncelleme sırasında hata alındı. Lütfen tekrar deneyiniz";
                }
            }
            else {
                BOOL result = [MailSoapHandler sendLostPasswordMessage:aNewPassword toMail:mailAdress];
                
                if (result) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Başarılı" message:@"Yeni şifreniz mail adresinize gönderildi, lütfen tekrar giriş yapınız." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Yeni şifreniz mail adresinize gönderilirken hata alındı, lütfen tekrar deneyiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ToGarentaPointPageSegue"]) {
        [(GarentaPointTableViewController *)[segue destinationViewController] setReservation:_reservation];
    }
    if ([[segue identifier] isEqualToString:@"toForgotPasswordSegue"]) {
        [(ForgotPasswordVC *)[segue destinationViewController] setCountryArray:countryArray];
        [(ForgotPasswordVC *)[segue destinationViewController] setSecretQuestionsArray:secretQuestionsArray];
    }
    if ([[segue identifier] isEqualToString:@"toUserCreationVCSegue"]) {
        [(UserCreationVC *)[segue destinationViewController] setSecretQuestionsArray:secretQuestionsArray];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self releaseAllTextFields];
    return YES;
}

- (void)releaseAllTextFields
{
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (void)goToView {
    
    if (_reservation == nil) {
        // Giriş ekranından gelmiş
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fillUserList" object:self.userList];
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }
    else {
        // demek ki kullanıcı bilgileri ekranından gelmiş
        [self performSegueWithIdentifier:@"ToGarentaPointPageSegue" sender:self];
    }
}

- (void)forgetMyPassword:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Şifre Hatırlatma Yöntemi" delegate:self cancelButtonTitle:@"Vazgeç" destructiveButtonTitle:nil otherButtonTitles:@"Eposta",@"Telefon", nil];
        
        [action showInView:self.view];
    });
}

@end
