//
//  MainVC.h
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTableVC.h"
#import "Office.h"

@interface MainVC : UIViewController <NSURLConnectionDelegate>
{
    MainTableVC *tableViewController;
    CGRect viewFrame;
    
    NSMutableArray *officeWorkingSchedule;
}

- (id)initWithFrame:(CGRect)frame;
@end
