//
//  CalendarTimeVC.h
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapkuLibrary.h"
//@import UIKit;

#pragma mark - CalendarMonthViewController
@interface CalendarTimeVC : TKCalendarMonthViewController
{
    UISlider *mySlider;
    UITextField *sliderText;
}

@end