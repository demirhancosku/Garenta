//
//  CampaignCell.h
//  Garenta
//
//  Created by Kerem Balaban on 26.11.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CampaignCell : UITableViewCell

@property (strong,nonatomic) IBOutlet UIImageView *carImage;
@property (strong,nonatomic) IBOutlet UILabel *campaignTextLabel;
@property (strong,nonatomic) IBOutlet UIButton *noCancellationButton;
@property (strong,nonatomic) IBOutlet UIButton *payNowButton;
@property (strong,nonatomic) IBOutlet UIButton *payLaterButton;

@end
