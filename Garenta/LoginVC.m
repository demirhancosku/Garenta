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
    user = [[User alloc] init];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(releaseAllTextFields)];
    [self.view addGestureRecognizer:singleFingerTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    //ToDo: aalpk
    [_usernameTextField setText:@"12345678901"];
    [_passwordTextField setText:@"19850000"];
    
    [[self view] setBackgroundColor:[ApplicationProperties getWhite]];
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
        [user setUsername:_usernameTextField.text];
        [user setPassword:_passwordTextField.text];

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
    NSString *connectionString = [NSString stringWithFormat: @"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_LOGIN_SRV/LoginService(IvFreetext='%@',IvPassword='%@',IvLangu='T')?$expand=ET_PARTNERSSet,ET_CARDTYPESSet&$format=json",user.username,user.password];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:connectionString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:20.0];
    
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
//    [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES]; aalpk : gene warning
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
        [[LoaderAnimationVC uniqueInstance] stopAnimation];
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
        user.username = _usernameTextField.text;
        user.password = _passwordTextField.text;
       //priority check
//        NSString *tempKunnr;
        for (NSDictionary *aCard in cardsResult) {
            if ([user.kunnr isEqualToString:(NSString*)[aCard objectForKey:@"Partner"]]) {
                user.accountType = [aCard objectForKey:@"CardType"];
            }
        }
    }
    //save to db
    [[NSUserDefaults standardUserDefaults]
     setObject:user.kunnr forKey:@"KUNNR"];
    [[NSUserDefaults standardUserDefaults]
     setObject:user.password forKey:@"PASSWORD"];
    [user setIsLoggedIn:YES];
    [ApplicationProperties setUser:user];
    [[LoaderAnimationVC uniqueInstance] stopAnimation];
    [[self navigationController] popViewControllerAnimated:YES];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"gateway hatasi");
        [[LoaderAnimationVC uniqueInstance] stopAnimation];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:@"Sistemde bir hata oluştu." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
    [alert show];
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

}
*/

@end
