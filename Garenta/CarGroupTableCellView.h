//
//  CarGroupTableCellView.h
//  Garenta
//
//  Created by Alp Keser on 12/29/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarGroupTableCellView : UIView{

}
@property(nonatomic,retain)IBOutlet UITextView *officeName;
@property(nonatomic,retain)IBOutlet UILabel *totalLabel;
@property(nonatomic,retain)IBOutlet UILabel *payNowLabel;
@property(nonatomic,retain)IBOutlet UILabel *currencyLabel;
@property(nonatomic,retain)IBOutlet UIImageView *topBoarder;
@end
