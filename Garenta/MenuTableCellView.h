//
//  MenuTableCellView.h
//  Garenta
//
//  Created by Alp Keser on 12/25/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableCellView : UIView
- (id)initWithFrame:(CGRect)frame andIndex:(int) aIndex;
@property(nonatomic,assign)int index;
@end
