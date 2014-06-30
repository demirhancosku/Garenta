//
//  LoginVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "LoginVC.h"
#import "ZGARENTA_LOGIN_SRV_01RequestHandler.h"
#import "ZGARENTA_LOGIN_SRV_01ServiceV0.h"
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
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(releaseAllTextFields)];
    [self.view addGestureRecognizer:singleFingerTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super   viewWillAppear:animated];
    //ToDo: aalpk
    [_usernameTextField setText:@"semih.senvardar@hityazilim.com"];
    [_passwordTextField setText:@"123456"];
    
    [[self view] setBackgroundColor:[ApplicationProperties getWhite]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseLoginResponse:) name:kLoadLoginServiceCompletedNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoadLoginServiceCompletedNotification object:nil];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login:(id)sender
{
    
    if (![_usernameTextField.text isEqualToString:@""] && ![_passwordTextField.text isEqualToString:@""])
    {
        
        @try {
            [self loginToSap];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
        }

        
    }
    else
    {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Kullanıcı adı ve şifre giriniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
    
    [alert show];
    return;
    }
}


- (void)goToCreateUserView:(id)sender
{
    UserCreationVC *vc = [[UserCreationVC alloc] init];
    [[self navigationController] pushViewController:vc animated:YES];
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
    [[LoaderAnimationVC uniqueInstance] playAnimation:self.view];
    [ApplicationProperties configureLoginService];
    LoginServiceV0 *aService = [LoginServiceV0 new];
    [ApplicationProperties fillProperties:aService];
    [aService setIvFreetext:_usernameTextField.text];
    NSData *passwordData = [_passwordTextField.text
                      dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
    
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [passwordData base64EncodedStringWithOptions:0];
    
    // Print the Base64 encoded string
    NSLog(@"Encoded: %@", base64Encoded);
    [aService setIvPassword:base64Encoded];
    
    ET_CARDTYPESV0 *dummyCardTypeLine = [ET_CARDTYPESV0 new];
    [ApplicationProperties fillProperties:dummyCardTypeLine];
    [aService setET_CARDTYPESSet:[NSMutableArray arrayWithObject:dummyCardTypeLine]];
    
    ET_PARTNERSV0 *dummyPartnersLine = [ET_PARTNERSV0 new];
    [ApplicationProperties fillProperties:dummyPartnersLine];
    [aService setET_PARTNERSSet:[NSMutableArray arrayWithObject:dummyPartnersLine]];
    
    ET_LOGRETURNV0 *dummyReturnLine = [ET_LOGRETURNV0 new];
    
    [ApplicationProperties fillProperties:dummyReturnLine];
    [dummyReturnLine setRow:[NSNumber numberWithInt:0]];
    [aService setET_RETURNSet:[NSMutableArray arrayWithObject:dummyReturnLine]];
    
    [aService setEvSubrc:[NSNumber numberWithInt:0]];
    

    [[ZGARENTA_LOGIN_SRV_01RequestHandler uniqueInstance] loadLoginService:aService expand:YES];
    

}


/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

}
*/

/*
 AALPK: ilk gelen accountu aliyoruz bu accountlar seçtirilecek
 */
- (void)parseLoginResponse:(NSNotification*)notification{
    [[LoaderAnimationVC uniqueInstance] stopAnimation];
    LoginServiceV0* response = notification.userInfo[@"item"];
    UIAlertView *alert;
        User *user = [ApplicationProperties getUser];
    if ([response.EvSubrc intValue] == 0 && response.ET_PARTNERSSet.count > 0) {
        //congrats logged in
        [user setIsLoggedIn:YES];
        ET_PARTNERSV0 *partnerLine = [response.ET_PARTNERSSet objectAtIndex:0];
        [user setName:partnerLine.McName2];
        [user setMiddleName:partnerLine.Namemiddle];
        [user setSurname:partnerLine.McName1];
        [user setKunnr:partnerLine.Partner];
        [user setUsername:_usernameTextField.text];
        [user setPassword:_passwordTextField.text];
        [user setPartnerType:partnerLine.Partnertype];
        [user setCompany:partnerLine.Firma];
        [user setCompanyName:partnerLine.FirmaName1];
        [user setCompanyName2:partnerLine.FirmaName2];
        [user setMobile:partnerLine.Mobile];
        [user setEmail:partnerLine.Email];
        [user setTckno:partnerLine.Tckno];
        [user setGarentaTl:partnerLine.Garentatl];
        [ApplicationProperties setUser:user];
        alert = [[UIAlertView alloc] initWithTitle:@"Hoşgeldiniz" message:[NSString stringWithFormat:@"Sayın %@ %@, başarıyla giriş yaptınız.",user.name,user.surname] delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
            [[self navigationController] popToRootViewControllerAnimated:YES];
    }else{
        [user setIsLoggedIn:NO];
        alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Kullanıcı adı ve şifrenizi kontrol ederek lütfen tekrar deneyiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
    }
    [alert show];

    
}
@end
