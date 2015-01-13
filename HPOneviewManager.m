//
//  HPOneviewManager.m
//  Identity Converter
//
//  Created by Daniel Finneran on 17/12/2014.
//  Copyright (c) 2014 Daniel Finneran. All rights reserved.
//

#import "HPOneviewManager.h"
#import "HPOneviewJSONBuilder.h"
#import "HTTPHandler.h"




@interface HPOneviewManager ()
{
    NSDictionary *networkData;
    NSDictionary *networkSetsData;
    NSDictionary *fcNetworksData;
    NSDictionary *enclosureGroupsData;
    NSDictionary *serversData;
    NSDictionary *serverHardwareData;
    BOOL isBusy; // defines state of UCS Manager
    NSMutableArray *headers;
}

@end

@implementation HPOneviewManager

-(id)init
{
    self = [super init];
    if (self)
    {
        headers = [NSMutableArray array];
        // Add http headers
        [headers addObject:@[@"Content-Type",@"application/json"]];
        [headers addObject:@[@"X-Api-Version",@"120"]];
    }
    return self;
}

-(id)initWithUsername:(NSString *)username Password:(NSString *)password
{
    self = [self init];
    
    if (self)
    {
        [self setUsername:username];
        [self setPassword:password];
    }
    return self;
}


-(void)wait // blocking
{   if (_blocking) {
        while (isBusy) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
            if (!_blocking)
                isBusy=false; // Allow someone to [HPOneviewManager setBlocking:False];
        }
    }
}

-(void)postRequestWithNotification:(NSString*)notification withRequest:(NSString *)request
{
    //Mutex lock added to ensure that a bunch of operations wont trample over one another
    //@synchronized(_http)
    //{
        HTTPHandler *httpHandler = [[HTTPHandler alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:NSSelectorFromString(notification) name:notification object:nil];
        httpHandler.headers = headers;
        //httpHandler.method = _http.method;
        [httpHandler setReponseString:notification];
        [httpHandler postRequest:[[@"https://" stringByAppendingString:_hostname] stringByAppendingString:_uri] request:request];
        NSLog(@"Registered %@", notification);
        [self wait];
    //}
}

-(void)postRequestWithNotification:(NSString*)notification withRequest:(NSString *)request withHander:(HTTPHandler *)httpHandler
{
    // Wrapper for calls to xml Parser
    [[NSNotificationCenter defaultCenter] addObserver:self selector:NSSelectorFromString(notification) name:notification object:nil];
    [httpHandler setReponseString:notification];
    [httpHandler postRequest:[[@"https://" stringByAppendingString:_hostname] stringByAppendingString:_uri] request:request];
    NSLog(@"Registered %@", notification);
    [self wait];
}

-(HTTPHandler *)postRequest:(NSString *)request withMethod:(NSString *)method withURI:(NSString *)uri withNotification:(NSString *)notification
{
    if (_blocking) {
        isBusy=true;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:NSSelectorFromString(notification) name:notification object:nil];
    NSLog(@"Registered %@", notification);
    HTTPHandler *httpHandler = [[HTTPHandler alloc] init];
    httpHandler.method = method;
    httpHandler.headers = headers;
    [httpHandler setReponseString:notification];
    [httpHandler postRequest:[[@"https://" stringByAppendingString:_hostname] stringByAppendingString:uri] request:request];
    [self wait];
    return httpHandler;
}



-(void)login
{
    HTTPHandler *handler = [self postRequest:[HPOneviewJSONBuilder login:_username password:_password]
                                      withMethod:@"POST"
                                         withURI:@"/rest/login-sessions"
                                withNotification:@"blockingCallback"];
    NSError *error = nil;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:handler.responseData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
    NSString *sessionID = [jsonResponse objectForKey:@"sessionID"];
    if ([jsonResponse objectForKey:@"sessionID"]) { // Add the Session ID to the headers
        [headers addObject:@[@"auth",sessionID]];
        _auth=YES;
    }
}

-(void)logout{}

-(void)bladeList
{
    HTTPHandler *handler = [self postRequest:@""
                                  withMethod:@"GET"
                                     withURI:@"/rest/server-profiles"
                            withNotification:@"blockingCallback"];
    NSError *error = nil;
    serversData = [NSJSONSerialization JSONObjectWithData:handler.responseData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];

    //NSLog(@"Data: %@", serversData);
    
}

-(void)createBlank
{
    HTTPHandler *handler = [self postRequest:[HPOneviewJSONBuilder createBlankProfile]
                                  withMethod:@"POST"
                                     withURI:@"/rest/server-profiles"
                            withNotification:@"blockingCallback"];
    NSData *response = handler.responseData;
    NSLog(@"Data: %@", [NSString stringWithUTF8String:[response bytes]]);
}

-(void)createRandomSimpleProfile
{
    if ([[serverHardwareData objectForKey:@"members"] count] > 0 && [[enclosureGroupsData objectForKey:@"members"] count] > 0) {
        int num = arc4random() % 100; // Generate random number for profile name
        NSString *profileName = [NSString stringWithFormat:@"Profile%i", num];
        HTTPHandler *handler = [self postRequest:[HPOneviewJSONBuilder createSimpleProfileWithName:profileName
                                                                            withServerHardwareType:[[[serverHardwareData objectForKey:@"members"] objectAtIndex:0] objectForKey:@"uri"]
                                                                                 forEnclosureGroup:[[[enclosureGroupsData objectForKey:@"members"] objectAtIndex:0] objectForKey:@"uri"]]
                                      withMethod:@"POST"
                                         withURI:@"/rest/server-profiles"
                                withNotification:@"blockingCallback"];
        NSData *response = handler.responseData;
        NSLog(@"Data: %@", [NSString stringWithUTF8String:[response bytes]]);
    }
}

-(void)enclosureGroups
{
    HTTPHandler *handler = [self postRequest:@""
                                  withMethod:@"GET"
                                     withURI:@"/rest/enclosure-groups"
                            withNotification:@"blockingCallback"];
    NSError *error = nil;
    enclosureGroupsData = [NSJSONSerialization JSONObjectWithData:handler.responseData
                                                  options:NSJSONReadingMutableContainers
                                                    error:&error];
    //NSLog(@"Data: %@", enclosureGroupsData);

}

-(void)serverHardwareTypes
{
    HTTPHandler *handler = [self postRequest:@""
                                  withMethod:@"GET"
                                     withURI:@"/rest/server-hardware-types"
                            withNotification:@"blockingCallback"];
    NSError *error = nil;
    serverHardwareData = [NSJSONSerialization JSONObjectWithData:handler.responseData
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
    //NSLog(@"Data: %@", serverHardwareData);
}

-(void)networks
{
    HTTPHandler *handler = [self postRequest:@""
                                  withMethod:@"GET"
                                     withURI:@"/rest/ethernet-networks"
                            withNotification:@"blockingCallback"];
    NSError *error = nil;
    networkData = [NSJSONSerialization JSONObjectWithData:handler.responseData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    //NSLog(@"Data: %@", networkData);
}

-(void)networkSets
{
    HTTPHandler *handler = [self postRequest:@""
                                  withMethod:@"GET"
                                     withURI:@"/rest/network-sets"
                            withNotification:@"blockingCallback"];
    NSError *error = nil;
    networkSetsData = [NSJSONSerialization JSONObjectWithData:handler.responseData
                                                  options:NSJSONReadingMutableContainers
                                                    error:&error];
    //NSLog(@"Data: %@", networkSetsData);
}

-(void)fcNetworks
{
    HTTPHandler *handler = [self postRequest:@""
                                  withMethod:@"GET"
                                     withURI:@"/rest/fc-networks"
                            withNotification:@"blockingCallback"];
    NSError *error = nil;
    fcNetworksData = [NSJSONSerialization JSONObjectWithData:handler.responseData
                                                      options:NSJSONReadingMutableContainers
                                                        error:&error];
    //NSLog(@"Data: %@", fcNetworksData);
}

 /*
 */

#pragma Notification Center functions

/*  -----------------------------------------------
 Callbacks (delegate methods / NSNotifications )
 ----------------------------------------------- */

-(void)blockingCallback
{
    isBusy=false;
}

-(NSArray *)returnEnclosureURI
{
    NSMutableArray* uris = [NSMutableArray array];
    if (enclosureGroupsData) {
        for (NSDictionary *member in [enclosureGroupsData objectForKey:@"members"]) {
            [uris addObject:@[[member objectForKey:@"name"], [member objectForKey:@"uri"]]];
        }
    }
    return uris;
}

-(NSArray *)returnServerHardwareURI
{
    NSMutableArray* uris = [NSMutableArray array];
    if (serverHardwareData) {
        for (NSDictionary *member in [serverHardwareData objectForKey:@"members"]) {
            [uris addObject:@[[member objectForKey:@"model"], [member objectForKey:@"uri"]]];
        }
    }
    return uris;
}

-(NSArray *)returnNetworkURI
{
    NSMutableArray* uris = [NSMutableArray array];
    if (networkData) {
        for (NSDictionary *member in [networkData objectForKey:@"members"]) {
            [uris addObject:@[[member objectForKey:@"name"], [member objectForKey:@"uri"]]];
        }
    }
    return uris;
}

-(NSArray *)returnNetworkSetsURI
{
    NSMutableArray* uris = [NSMutableArray array];
    if (networkSetsData) {
        for (NSDictionary *member in [networkSetsData objectForKey:@"members"]) {
            [uris addObject:@[[member objectForKey:@"name"], [member objectForKey:@"uri"]]];
        }
    }
    return uris;
}

-(NSArray *)returnFCNetworkURI
{
    NSMutableArray* uris = [NSMutableArray array];
    if (fcNetworksData) {
        for (NSDictionary *member in [fcNetworksData objectForKey:@"members"]) {
            [uris addObject:@[[member objectForKey:@"name"], [member objectForKey:@"uri"]]];
        }
    }
    return uris;
}

/*
-(void)loginNotification
{
    NSError *error = nil;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:_http.responseData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
    NSString *sessionID = [jsonResponse objectForKey:@"sessionID"];
    if ([jsonResponse objectForKey:@"sessionID"]) { // Add the Session ID to the headers
        [_http.headers addObject:@[@"auth",sessionID]];
        _auth=YES;
    }
    _isBusy=false; // If blocking remove the block
}

-(void)logoutNotification
{
    
}

-(void)bladeListNotification
{
    NSLog(@"Data: %@", [NSString stringWithUTF8String:[_http.responseData bytes]]);
    _isBusy=false;
}

-(void)queryNotification
{
    
}

-(void)serverCreatedNotification
{
    NSLog(@"Data: %@", [NSString stringWithUTF8String:[_http.responseData bytes]]);
     _isBusy=false;
}

-(void)enclosureGroupsNotification
{
    NSError *error = nil;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:_http.responseData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
    _enclosureGroupArray = [jsonResponse objectForKey:@"members"];
    if (_enclosureGroupArray) {
        for (NSDictionary *enclosureGroup in _enclosureGroupArray) {
            NSLog(@"%@ %@", [enclosureGroup objectForKey:@"name"], [enclosureGroup objectForKey:@"uri"]);
        }
    }
    _isBusy=false;
}


-(void)serverHardwareNotification
{
    NSError *error = nil;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:_http.responseData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
    //NSLog(@"%@", jsonResponse);
    _serverHardwareArray = [jsonResponse objectForKey:@"members"];
    if (_serverHardwareArray) {
        for (NSDictionary *enclosureGroup in _serverHardwareArray) {
            NSLog(@"%@ %@", [enclosureGroup objectForKey:@"model"], [enclosureGroup objectForKey:@"uri"]);
        }
    }
    _isBusy=false;
}

-(void)networksNotification
{
    NSLog(@"Data: %@", [NSString stringWithUTF8String:[_http.responseData bytes]]);
    _isBusy=false;
}

-(void)networkSetsNotification
{
    NSLog(@"Data: %@", [NSString stringWithUTF8String:[_http.responseData bytes]]);
    _isBusy=false;
}

-(void)fcNetworksNotification
{
    NSLog(@"Data: %@", [NSString stringWithUTF8String:[_http.responseData bytes]]);
    _isBusy=false;
}
 */




@end
