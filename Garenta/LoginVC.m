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
    [_passwordTextField setText:@"numq0"];
    
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
        NSData *passwordData = [_passwordTextField.text dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
        NSString *base64Encoded = [passwordData base64EncodedStringWithOptions:0];
        
        [ApplicationProperties loginToSap:_usernameTextField.text andPassword:base64Encoded];

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

@end
