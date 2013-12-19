//
//  MainVC.h
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTableVC.h"

@interface MainVC : UIViewController
{
    MainTableVC *tableViewController;
    CGRect viewFrame;
}

- (id)initWithFrame:(CGRect)frame;
@end
