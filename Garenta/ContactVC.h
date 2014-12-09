//
//  ContactVC.h
//  Garenta
//
//  Created by Onur Küçük on 12.11.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h> 

@interface ContactVC : UIViewController <MFMailComposeViewControllerDelegate,UIAlertViewDelegate>

-(IBAction)sendSupportMail:(id)sender;
-(IBAction)sendReservationMail:(id)sender;
@end
