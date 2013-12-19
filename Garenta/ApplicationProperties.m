//
//  ApplicationProperties.m
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "ApplicationProperties.h"

@implementation ApplicationProperties

+ (UIColor *)getOrange{
    return [UIColor colorWithRed:240.0/255.0 green:82.0/255.0 blue:35.0/255.0 alpha:1.0];
}

+ (UIColor *)getBlack{
    return [UIColor colorWithRed:26.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    
}

+ (UIColor *)getWhite{
    return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
}


+ (UIColor *)getDarkBlueColor{
    return [UIColor colorWithRed:52.0/255.0 green:109.0/255.0 blue:153.0/255.0 alpha:1.0];
}
+ (NSString*)getFont{
    return @"HelveticaNeue";
}

//sample color codes
+ (UIColor*)getMenuTableBackgorund{
    return [UIColor colorWithRed:240.0/255.0 green:234.0/255.0 blue:224.0/255.0 alpha:1.0];
}

+ (UIColor*)getMenuCellBackground{
    //    return [UIColor colorWithRed:237.0/255.0 green:103.0/255.0 blue:105.0/255.0 alpha:1.0];
    return [self getOrange];
}

+ (UIColor*)getMenuTextColor{
    return [UIColor colorWithRed:10.0/255.0 green:200.0/255.0 blue:247.0/255.0 alpha:1.0];
}

@end
