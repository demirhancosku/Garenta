//
//  AgreementsVC.h
//  Garenta
//
//  Created by Ata Cengiz on 22/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AgreementsVC : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSString *htmlName, *agreementName;

@end
