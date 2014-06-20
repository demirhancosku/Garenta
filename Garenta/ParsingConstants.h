//
//  ParsingConstants.h
//  Garenta
//
//  Created by Alp Keser on 5/29/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#ifndef Garenta_ParsingConstants_h
#define Garenta_ParsingConstants_h

//Notification UserInfo keys:
extern NSString * const kResponseItem; ///< Single item response
extern NSString * const kResponseItems; ///< Multiple items response
extern NSString * const kResponseData; ///< Raw response data
extern NSString * const kRequestedMediaLink; ///< Media link item
extern NSString * const kServerResponseError; ///< Server response error
extern NSString * const kParsingError; ///< Parsing response error
extern NSString * const kResponseParentItem; ///< Item selected in the view previous to the one triggered the request
extern NSString * const kBatchRequest; ///< BatchRequest object containing the response

//Notification keys:
extern NSString * const kAuthenticationNeededNotification; ///< Notification key for request authentication challenge.



#endif
