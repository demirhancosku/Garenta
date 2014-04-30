/*
 
 File: ServiceErrorXmlParser.h
 Abstract: Parsing server error xmls.
 
 */

#import <Foundation/Foundation.h>
#import "ServiceError.h"


// Class which parsing the service error xml.
@interface ServiceErrorXmlParser : NSObject<NSXMLParserDelegate, ServiceErrorParsing> {
    NSXMLParser *parser;
    ServiceError *error;
    NSMutableString *currentString;
    BOOL inInnerError;
}

@end
