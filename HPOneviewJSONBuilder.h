//
//  HPOneviewJSONBuilder.h
//  Identity Converter
//
//  Created by Daniel Finneran on 17/12/2014.
//  Copyright (c) 2014 Daniel Finneran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPOneviewJSONBuilder : NSObject

+(NSString *)login:(NSString *)username password:(NSString *)password;
+(NSString *)logoutWithID:(NSString *)cookie;  // Build logout element
+(NSString *)listBladesWithID:(NSString *)cookie;
+(NSString *)createBlankProfile;


@end
