//
//  LoginVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()

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

- (id)initWithFrame:(CGRect)frame andUser:(User *)userInfo;
{
    self = [super init];
    viewFrame = frame;
    user = [[User alloc] init];
    user = userInfo;
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    user = [[User alloc] init];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Giriş" style:UIBarButtonItemStyleBordered target:self action:@selector(login:)];
    [[self navigationItem] setRightBarButtonItem:barButton];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self prepareScreen];
    //ToDo: aalpk
//    [username setText:@"12345678901"];
//    [password setText:@"19850000"];
    //klavyeyi ilk açılışta gösterme
//    [username becomeFirstResponder];
    
    [[self view] setBackgroundColor:[ApplicationProperties getWhite]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login:(id)sender
{
    
    if (![username.text isEqualToString:@""] && ![password.text isEqualToString:@""])
    {
        [user setUsername:username.text];
        [user setPassword:password.text];

        [self loginToSap];
        //[[self navigationController] popViewControllerAnimated:YES];
        
    }
    else
    {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Kullanıcı adı ve şifre giriniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
    
    [alert show];
    return;
    }
}

- (void)prepareScreen
{

    [self setIphoneLayer];
    
//    [loginButton setTitle:@"Giriş" forState:UIControlStateNormal];
//    [[loginButton layer] setCornerRadius:5.0f];
//    [loginButton setBackgroundColor:[ApplicationProperties getOrange]];
//    [loginButton setTintColor:[ApplicationProperties getWhite]];
//    
//    [signUpButton setTitle:@"Üye Ol" forState:UIControlStateNormal];
//    [[signUpButton layer] setCornerRadius:5.0f];
//    [signUpButton setBackgroundColor:[ApplicationProperties getOrange]];
//    [signUpButton setTintColor:[ApplicationProperties getWhite]];
    
    [username setDelegate:self];
    [password setDelegate:self];
    
    [username setBorderStyle:UITextBorderStyleRoundedRect];
    [[username layer] setBorderWidth:1.0f];
    [[username layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[username layer] setCornerRadius:5.0f];
    [username setPlaceholder:@"Kullanıcı Adınızı Giriniz"];
    [username setTextAlignment:NSTextAlignmentCenter];
    
    [password setBorderStyle:UITextBorderStyleRoundedRect];
    [[password layer] setBorderWidth:1.0f];
    [[password layer] setBorderColor:[[ApplicationProperties getOrange] CGColor]];
    [[password layer] setCornerRadius:5.0f];
    [password setPlaceholder:@"Şifrenizi Giriniz"];
    [password setTextAlignment:NSTextAlignmentCenter];
    [password setSecureTextEntry:YES];
    
    [infoLabel setText:@"*Kullanıcı adınız, T.C kimlik, telefon numaranız veya e-post adresiniz olabilir"];
    [infoLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0]];
    infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel.numberOfLines = 0;
    
    [hideButton setOpaque:YES];
    [hideButton addTarget:nil action:@selector(hideKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:hideButton];
    [self.view addSubview:infoLabel];
    [self.view addSubview:userImageView];
//    [self.view addSubview:loginButton];
    [self.view addSubview:username];
    [self.view addSubview:password];
//    [self.view addSubview:signUpButton];
}

- (void)hideKeyboard:(id)sender
{
    [username resignFirstResponder];
    [password resignFirstResponder];
}

- (void)setIphoneLayer
{
    
    hideButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height)];
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.47, viewFrame.size.width * 0.8, 80)];
    
    username = [[UITextField alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.33, viewFrame.size.width * 0.8, 40)];
    
    password = [[UITextField alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.43, viewFrame.size.width * 0.8, 40)];
    
//    loginButton = [[UIButton alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.60, viewFrame.size.width * 0.8, 40)];
//    
//    signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.1, viewFrame.size.height * 0.70, viewFrame.size.width * 0.8, 40)];
    
    userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewFrame.size.width * 0.4, viewFrame.size.height * 0.05, viewFrame.size.width * 0.22, viewFrame.size.height * 0.22)];
    [userImageView setContentMode:UIViewContentModeScaleAspectFill];
    [userImageView setImage:[UIImage imageNamed:@"login_icon.png"]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self releaseAllTextFields];
    return YES;
}

- (void)releaseAllTextFields
{
    [username resignFirstResponder];
    [password resignFirstResponder];
}


- (void)loginToSap
{
    loaderVC = [[LoaderAnimationVC alloc] init];
    [loaderVC playAnimation:self.view];
    NSString *connectionString = [NSString stringWithFormat: @"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_LOGIN_SRV/LoginService(IvFreetext='%@',IvPassword='%@',IvLangu='T')?$expand=ET_PARTNERSSet,ET_CARDTYPESSet&$format=json",user.username,user.password];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:connectionString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:20.0];
    
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space
{
    return YES;
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        NSLog(@"received authentication challenge");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:[ApplicationProperties getSAPUser]
                                                                    password:[ApplicationProperties getSAPPassword]
                                                                 persistence:NSURLCredentialPersistenceForSession];
        NSLog(@"credential created");
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        NSLog(@"responded to authentication challenge");
    }
    else {
        NSLog(@"previous authentication failure");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *err;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    NSDictionary *result = [jsonDict objectForKey:@"d"];
    
    
    NSDictionary *partnersSet = [result objectForKey:@"ET_PARTNERSSet"];
    NSDictionary *cardsSet = [result objectForKey:@"ET_CARDTYPESSet"];

    //getpartner result

    NSDictionary *partnerResult = [partnersSet objectForKey:@"results"];
    NSDictionary *cardsResult = [cardsSet objectForKey:@"results"];
    
    
    if (partnerResult.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Hatalı bir kullanıcı adı ve şifre girdiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];
        [loaderVC stopAnimation];
        return;
    }
    for ( NSDictionary *aPartner in partnerResult) {
      
        user.kunnr = [aPartner objectForKey:@"Partner"];
        user.garentaTl = [aPartner objectForKey:@"Garentatl"];
        user.middleName = [aPartner objectForKey:@"NameMiddle"];
        user.mobile = [aPartner objectForKey:@"Mobile"];
//        user.kunnr = [aPartner objectForKey:@""];password
//        user.kunnr = [aPartner objectForKey:@"Partner"];ismaster
        user.companyName2 = [aPartner objectForKey:@"FirmaName2"];
        user.name = [aPartner objectForKey:@"McName2"];
        user.email = [aPartner objectForKey:@"Email"];
        user.tckno = [aPartner objectForKey:@"Tckno"];
        user.company = [aPartner objectForKey:@"Firma"];
        user.companyName = [aPartner objectForKey:@"FirmaName1"];
        user.username = username.text;
        user.password = password.text;
       //priority check
        NSString *tempKunnr;
        for (NSDictionary *aCard in cardsResult) {
            if ([user.kunnr isEqualToString:(NSString*)[aCard objectForKey:@"Partner"]]) {
                user.accountType = [aCard objectForKey:@"CardType"];
            }
        }
    }
    NSString *valueToSave = user.username;
    //save to db
    [[NSUserDefaults standardUserDefaults]
     setObject:user.kunnr forKey:@"KUNNR"];
    [[NSUserDefaults standardUserDefaults]
     setObject:user.password forKey:@"PASSWORD"];
    [user setIsLoggedIn:YES];
    [ApplicationProperties setUser:user];
    [loaderVC stopAnimation];
    [[self navigationController] popViewControllerAnimated:YES];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"gateway hatasi");
        [loaderVC stopAnimation];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Sistemde bir hata oluştu." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
    [alert show];
}


@end
