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

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) NSArray *userList;

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
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSData *passwordData = [_passwordTextField.text dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
            NSString *base64Encoded = [passwordData base64EncodedStringWithOptions:0];
            
            self.userList = [User loginToSap:_usernameTextField.text andPassword:base64Encoded];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (self.userList != nil && self.userList.count == 1) {
                    User *user = [self.userList objectAtIndex:0];
                    user.isLoggedIn = YES;
                    [ApplicationProperties setUser:user];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hoşgeldiniz" message:[NSString stringWithFormat:@"Sayın %@ %@", [user name], [user surname]] delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                    
                    [self goToView];
                    
                }
                else if (self.userList != nil && self.userList.count > 1){
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
    [alert setTitle:@"Seçiniz .."];
    
    for (User *tempUser in self.userList) {
        
        NSString *buttonTitle = @"";
        
        if ([tempUser.middleName isEqualToString:@""]) {
            buttonTitle = [NSString stringWithFormat:@"%@ %@", tempUser.name, tempUser.surname];
        }
        else {
            buttonTitle = [NSString stringWithFormat:@"%@ %@ %@", tempUser.name, tempUser.middleName, tempUser.surname];

        }
        
        if ([[tempUser partnerType] isEqualToString:@"B"]) {
            buttonTitle = [NSString stringWithFormat:@"%@(BIREYSEL)", buttonTitle];
        }
        if ([[tempUser partnerType] isEqualToString:@"K"]) {
            buttonTitle = [NSString stringWithFormat:@"%@(KURUMSAL)", buttonTitle];
        }
        
        [alert addButtonWithTitle:buttonTitle];
    }
    
    [alert setDelegate:self];
    [alert setTag:1];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        User *tempUser = [self.userList objectAtIndex:buttonIndex];
        tempUser.isLoggedIn = YES;
        
        [ApplicationProperties setUser:tempUser];
        [self goToView];
    }
    if (alertView.tag == 2) {
        NSString *mailAdress = [alertView textFieldAtIndex:0].text;
        
        if (mailAdress == nil && [mailAdress isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Girdiğiniz e-mail adresi boş olamaz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
        }
        else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self updateUserPasswordAtSAP:mailAdress];
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Başarılı" message:@"Yeni şifreniz mail'inize gönderildi, lütfen tekrar giriş yapınız" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Yeni şifreniz mail'inize gönderilirken hata alındı, lütfen tekrar deneyiniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
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
    if ([[segue identifier] isEqualToString:@"ToReservationSummarySegue"]) {
        [(ReservationSummaryVC *)[segue destinationViewController] setReservation:_reservation];
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
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }
    else {
        // demek ki kullanıcı bilgileri ekranından gelmiş
        [self performSegueWithIdentifier:@"ToReservationSummarySegue" sender:self];
    }
}

- (void)forgetMyPassword:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Lütfen yeni şifrenizin gönderilmesi için üye e-mail adresinizi giriniz" delegate:self cancelButtonTitle:@"Geri" otherButtonTitles:@"Devam", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert setTag:2];
    [alert show];
}

@end
