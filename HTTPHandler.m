//
//  HTTP Handler
//
//  Created by Daniel Finneran on 11/07/2013.
//  Copyright (c) 2013 Daniel Finneran. All rights reserved.
//

#import "HTTPHandler.h"

@interface HTTPHandler ()
{
    NSURLConnection *connection;
}
@end


@implementation HTTPHandler

-(id)init
{
    self = [super init];
    
    if (self)
    {
        _headers = [NSMutableArray array];
    }
    return self;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    //NSLog(@"start");
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the instance variable you declared
    //NSLog(@"recieving data of Size %lu adding to %lu", [data length], [_responseData length]);
    //NSLog(@"Data: %@", [NSString stringWithUTF8String:[data bytes]]);
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    //NSLog(@"end");
    //NSLog(@"%lu", _responseData.length);

    [[NSNotificationCenter defaultCenter] postNotificationName:_reponseString object:nil];

    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"HTTP Error");
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    else
    {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

-(void)postRequest:(NSString *)address request:(NSString *)requestString
{
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:address]];
    
    // Specify that it will be a POST request
    [request setHTTPMethod:_method];
    
    // This is how we set header fields
    for (NSArray *header in _headers) { //Iterate through headers
        [request setValue:[header objectAtIndex:1]
       forHTTPHeaderField:[header objectAtIndex:0]];
    }
    // Convert your data and set your request's HTTPBody property
    NSData *requestBodyData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
    // Create url connection and fire request
   // NSLog(@"%@", [[NSString alloc] initWithData:[request HTTPBody]
     //                                  encoding:NSUTF8StringEncoding]);

    connection = [[NSURLConnection alloc] initWithRequest:request
                                                 delegate:self];

}

@end

