//
//  AdditionalEquipmentsInfoVC.m
//  Garenta
//
//  Created by Kerem Balaban on 2.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "AdditionalEquipmentInfoVC.h"


@implementation AdditionalEquipmentInfoVC
@synthesize infoLabel,infoText;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [infoLabel setText:infoText];
}

@end
