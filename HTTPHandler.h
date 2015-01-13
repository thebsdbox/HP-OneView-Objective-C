//
//  HTTP Handler
//
//  Created by Daniel Finneran on 11/07/2013.
//  Copyright (c) 2013 Daniel Finneran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPHandler : NSObject <NSURLConnectionDelegate> {
}

@property NSMutableArray *headers; // http headers
@property NSString *method; // POST, GET etc.
@property NSString *address; // URL
@property NSString *reponseString; 
@property (nonatomic) NSMutableData *responseData;

-(void)postRequest:(NSString *)address request:(NSString *)requestString;

@end
