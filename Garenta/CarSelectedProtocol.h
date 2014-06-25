//
//  CarSelectedProtocol.h
//  Garenta
//
//  Created by Alp Keser on 6/23/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CarSelectedProtocol <NSObject>
@required
- (void)carGroupSelected:(CarGroup*)aCarGroup withOffice:(Office*)anOffice;
@end
