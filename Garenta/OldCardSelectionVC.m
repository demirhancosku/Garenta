//
//  OldCardSelectionVC.m
//  Garenta
//
//  Created by Kerem Balaban on 8.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldCardSelectionVC.h"

@implementation OldCardSelectionVC
@synthesize pickerData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cardSelectButtonPressed:(id)sender
{
    if (selectedCardNumber != nil)
    {
        _creditCard = [CreditCard new];
        
        _creditCard.nameOnTheCard = [NSString stringWithFormat:@"%@ %@",[[ApplicationProperties getUser] name],[[ApplicationProperties getUser] surname]];
        _creditCard.cardNumber = selectedCardNumber;
        _creditCard.expirationMonth = @"**";
        _creditCard.expirationYear = @"****";
        _creditCard.cvvNumber = @"***";
        _creditCard.uniqueId = selectedCardUniqueId;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"oldCardSelected" object:_creditCard];
    
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerData.count + 1;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0)
        return @"Yeni Kart";
    else
        return [[pickerData objectAtIndex:row - 1] cardNumber];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row != 0)
    {
        selectedCardNumber = [[pickerData objectAtIndex:row - 1] cardNumber];
        
        NSString *firstFour = [selectedCardNumber substringToIndex:4];
        NSString *nextTwo   = [[selectedCardNumber substringFromIndex:4] substringToIndex:2];
        NSString *lastFour  = [selectedCardNumber substringFromIndex:12];
        
        selectedCardNumber = [NSString stringWithFormat:@"%@ %@** **** %@",firstFour,nextTwo,lastFour];
        
        selectedCardUniqueId = [[pickerData objectAtIndex:row - 1] uniqueId];
    }
}

@end
