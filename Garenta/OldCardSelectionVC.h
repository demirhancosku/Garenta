//
//  OldCardSelectionVC.h
//  Garenta
//
//  Created by Kerem Balaban on 8.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreditCard.h"

@interface OldCardSelectionVC : UITableViewController <UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSString *selectedCardNumber;
    NSString *selectedCardUniqueId;
}
@property (weak, nonatomic) IBOutlet UIPickerView *pickerVC;
@property (weak, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) CreditCard *creditCard;

- (IBAction)cardSelectButtonPressed:(id)sender;
@end
