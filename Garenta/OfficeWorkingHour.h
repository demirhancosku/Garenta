//
//  OfficeWorkingHour.h
//  Garenta
//
//  Created by Ata  Cengiz on 19.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfficeWorkingHour : NSObject

@property (nonatomic, retain) NSString *startingHour;
@property (nonatomic, retain) NSString *endingHour;
@property (nonatomic, retain) NSString *holidayDate;
@property (nonatomic, retain) NSString *mainOffice;
@property (nonatomic, retain) NSString *subOffice;
@property (nonatomic, retain) NSString *weekDay;

@end
