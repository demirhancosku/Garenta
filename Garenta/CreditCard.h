//
//  CreditCard.h
//  Garenta
//
//  Created by Alp Keser on 6/28/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreditCard : NSObject
@property (strong,nonatomic) NSString *cardNumber;
@property (strong,nonatomic) NSString *cvvNumber;
@property (strong,nonatomic) NSString *nameOnTheCard;
@property (strong,nonatomic) NSString *expirationMonth;
@property (strong,nonatomic) NSString *expirationYear;
@end
