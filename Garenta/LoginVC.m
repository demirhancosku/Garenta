//
//  LoginVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)login:(id)sender;

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
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(releaseAllTextFields)];
    [self.view addGestureRecognizer:singleFingerTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super   viewWillAppear:animated];

    [_usernameTextField setText:@"suleyman.nalci@abh.com.tr"];
    [_passwordTextField setText:@"p1976"];
    
    [[self view] setBackgroundColor:[ApplicationProperties getWhite]];
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
        [self loginToSap];
    
        User *user = [ApplicationProperties getUser];
        
        if ([user isLoggedIn]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hoşgeldiniz" message:[NSString stringWithFormat:@"Sayın %@ %@", [user name], [user surname]] delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }
    }
    else
    {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Kullanıcı adı ve şifre giriniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
    
    [alert show];
    return;
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


- (void)loginToSap
{
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZMOB_REZ_LOGIN"];
        
        NSData *passwordData = [_passwordTextField.text dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
        NSString *base64Encoded = [passwordData base64EncodedStringWithOptions:0];
        
        [handler addImportParameter:@"IV_PASSWORD" andValue:base64Encoded];
        [handler addImportParameter:@"IV_FREETEXT" andValue:_usernameTextField.text];
        [handler addImportParameter:@"IV_LANGU" andValue:@"T"];
        
        [handler addTableForReturn:@"ET_RETURN"];
        [handler addTableForReturn:@"ET_PARTNERS"];
        [handler addTableForReturn:@"ET_CARDTYPES"];
    
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            
            NSString *sysubrc = [export valueForKey:@"EV_SUBRC"];
            
            if ([sysubrc isEqualToString:@"0"]) {
                
                NSDictionary *tables = [response objectForKey:@"TABLES"];
                NSDictionary *allPartners = [tables objectForKey:@"ZMOB_LOGIN_ALL_PARTNERS"];
                
                if (allPartners.count > 0) {
                    
                    for (NSDictionary *tempDict in allPartners) {
                        User *user = [User new];
                        
                        NSDateFormatter *formatter = [NSDateFormatter new];
                        [formatter setDateFormat:@"yyyy-MM-dd"];
                        
                        [user setName:[tempDict valueForKey:@"MC_NAME2"]];
                        [user setMiddleName:[tempDict valueForKey:@"NAMEMIDDLE"]];
                        [user setSurname:[tempDict valueForKey:@"MC_NAME1"]];
                        [user setKunnr:[tempDict valueForKey:@"PARTNER"]];
                        [user setUsername:_usernameTextField.text];
                        [user setPassword:base64Encoded];
                        [user setPartnerType:[tempDict valueForKey:@"MUSTERI_TIPI"]];
                        [user setCompany:[tempDict valueForKey:@"FIRMA_KODU"]];
                        [user setCompanyName:[tempDict valueForKey:@"FIRMA_NAME1"]];
                        [user setCompanyName2:[tempDict valueForKey:@"FIRMA_NAME2"]];
                        [user setMobileCountry:[tempDict valueForKey:@"MOBILE_ULKE"]];
                        [user setMobile:[tempDict valueForKey:@"MOBILE"]];
                        [user setEmail:[tempDict valueForKey:@"EMAIL"]];
                        [user setTckno:[tempDict valueForKey:@"TCKNO"]];
                        [user setGarentaTl:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"GARENTATL"]]];
                        [user setPriceCode:[tempDict valueForKey:@"FIYAT_KODU"]];
                        [user setPriceType:[tempDict valueForKey:@"FIYAT_TIPI"]];
                        [user setBirthday:[formatter dateFromString:[tempDict valueForKey:@"BIRTHDAY"]]];
                        [user setDriversLicenseDate:[formatter dateFromString:[tempDict valueForKey:@"EHLIYET_TARIHI"]]];
                        
                        if ([[tempDict valueForKey:@"C_PRIORITY"] isEqualToString:@"X"]) {
                            [user setIsPriority:YES];
                        }
                        
                        if ([[user partnerType] isEqualToString:@"B"]) {
                            [user setIsLoggedIn:YES];
                            [ApplicationProperties setUser:user];
                        }
                        else {
                            // Şu an sadece bireysel kullanıcıları alıyoruz
                        }
                    }
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Kullanıcı adı ve şifrenizi kontrol ederek lütfen tekrar deneyiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
                    [alert show];
                }
            }
            else {
               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Kullanıcı adı ve şifrenizi kontrol ederek lütfen tekrar deneyiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

@end
