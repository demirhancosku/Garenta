//
//  ContactVC.m
//  Garenta
//
//  Created by Onur Küçük on 12.11.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ContactVC.h"

@interface ContactVC ()

@end

@implementation ContactVC

static int kGarentaLogoId = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self putLogo];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)callHeadquarter:(id)sender {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Merkez" message:@"Merkez aransın mı?" delegate:self cancelButtonTitle:@"Ara" otherButtonTitles:@"Vazgeç", nil];
        [alert show];
        
    [alert setTag:0];
//
}
-(IBAction)callReservationCenter:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Rezervasyon Merkezi" message:@"Rezervasyon merkezi aransın mı?" delegate:self cancelButtonTitle:@"Ara" otherButtonTitles:@"Vazgeç", nil];
    [alert show];
    
    [alert setTag:1];
    
//
}
-(IBAction)emergencyCall:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Acil Yardım Hattı" message:@"Acil yardım hattı  aransın mı?" delegate:self cancelButtonTitle:@"Ara" otherButtonTitles:@"Vazgeç", nil];
    [alert show];
    
//
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag]) {
        case 0:
        {
            if (buttonIndex == 0) {
            
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://02626782929"]]];
            }
            break;
        }
            
        case 1:
        {
            if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://4445478"]]];
            }
        }
            break;
            
        case 2:
        {
            if (buttonIndex == 0) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://08502225478"]]];
            }
        }
            break;
            
        default:
            break;
    }
}

-(IBAction)sendReservationMail:(id)sender
{
  NSString *mailTitle = @"Rezervasyon";
//  NSString *messageBody =@"<h1>";
  NSArray *toRecipents = [NSArray arrayWithObject:@"4445478@garenta.com.tr"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:mailTitle];
//    [mc setMessageBody:messageBody isHTML:YES];
    [mc setToRecipients:toRecipents];
    
    [self presentViewController:mc animated:YES completion:NULL];
}



-(IBAction)sendSupportMail:(id)sender
{

        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        [mailer setMailComposeDelegate:self];
        
        [mailer setSubject:@"Destek"];
        NSMutableArray *toArray = [[NSMutableArray alloc] initWithObjects:@"crm@garenta.com.tr", nil];
        [mailer setToRecipients:toArray];
        
        [self presentViewController:mailer animated:YES completion:nil];
        
    
   
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}


//puts logo on navigation bar
- (void)putLogo{
    UINavigationController *nav = [self navigationController];
    float logoRatio = (float)57 / (float)357;
    float logoWidth = nav.navigationBar.frame.size.width * 0.5;
    float logoHeight = logoWidth * logoRatio;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(nav.navigationBar.frame.size.width * 0.25, nav.navigationBar.frame.size.height * 0.15, logoWidth, logoHeight)];
    [imageView setTag:kGarentaLogoId];
    [imageView setImage:[UIImage imageNamed:@"GarentaSmallLogo.png"]];
    [[[self navigationController] navigationBar] addSubview:imageView];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
