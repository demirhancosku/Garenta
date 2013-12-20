//
//  CalendarTimeVC.m
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CalendarTimeVC.h"

#pragma mark - CalendarMonthViewController
@implementation CalendarTimeVC

- (NSUInteger) supportedInterfaceOrientations{
	return  UIInterfaceOrientationMaskPortrait;
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


#pragma mark View Lifecycle
- (void) viewDidLoad{
	[super viewDidLoad];
//	self.title = NSLocalizedString(@"Month Grid", @"");
	[self.monthView selectDate:[NSDate date]];
    
    
    

}

- (void)viewWillAppear:(BOOL)animated
{
    sliderText = [[UITextField alloc] initWithFrame:CGRectMake(self.monthView.frame.size.width * 0.05, self.monthView.frame.size.height * 1.1, self.monthView.frame.size.width * 0.15, 50)];
    
    mySlider = [[UISlider alloc] initWithFrame:CGRectMake(self.monthView.frame.size.width * 0.2, self.monthView.frame.size.height * 1.1, self.monthView.frame.size.width * 0.6, 50)];
    [mySlider addTarget:self action:@selector(sliderValueChanged:)
       forControlEvents:UIControlEventValueChanged];
    
    [mySlider setMinimumValue:0.0];
    [mySlider setMaximumValue:24.0];
    [mySlider setUserInteractionEnabled:YES];
    
    [[self view] addSubview:mySlider];
}

- (void)sliderValueChanged:(id)sender
{
    NSDate *localDate = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    NSString *dateString = [timeFormatter stringFromDate: localDate];
    
    sliderText.text = dateString;
    [[self view] addSubview:sliderText];
    
    [mySlider setValue:[[sliderText text] floatValue]];
}

@end

