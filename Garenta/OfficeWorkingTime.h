//
//  OfficeWorkingHour.h
//  Garenta
//
//  Created by Ata  Cengiz on 19.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfficeWorkingTime : NSObject

@property (nonatomic, retain) NSString *startTime;
@property (nonatomic, retain) NSString *endingHour;
@property (nonatomic, retain) NSString *weekDayCode;
@property (nonatomic, retain) NSString *mainOffice;
@property (nonatomic, retain) NSString *subOffice;
@property (nonatomic, retain) NSString *weekDayName;

@end
