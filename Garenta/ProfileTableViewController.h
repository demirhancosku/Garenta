//
//  ProfileTableViewController.h
//  Garenta
//
//  Created by Ata Cengiz on 28/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileTableViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate, UITextFieldDelegate>
{
    NSMutableArray *countryArray;
    NSMutableArray *cityArray;
    NSMutableArray *countyArray;
}

- (IBAction)updateButtonPressed:(id)sender;
- (IBAction)changePassword:(id)sender;

@end
