//
//  HPOneviewJSONBuilder.m
//  Identity Converter
//
//  Created by Daniel Finneran on 17/12/2014.
//  Copyright (c) 2014 Daniel Finneran. All rights reserved.
//

#import "HPOneviewJSONBuilder.h"

@implementation HPOneviewJSONBuilder

+(NSString *)login:(NSString *)username password:(NSString *)password
{
    NSDictionary *httpDictionary = @{@"userName" : username, @"password" : password };
    NSError *error = nil;
    return [[NSString alloc] initWithData: [NSJSONSerialization dataWithJSONObject:httpDictionary options:0 error:&error]
                                 encoding:NSUTF8StringEncoding];
}

+(NSString *)logoutWithID:(NSString *)cookie
{
    return @"";
}

+(NSString *)listBladesWithID:(NSString *)cookie
{
    return @"";
}

+(NSString *)createBlankProfile
{
    NSDictionary *httpDictionary = @{@"type" : @"ServerProfileV4",
                                     @"name" : @"TestProfile02",
                                     @"serverHardwareTypeUri" : @"/rest/server-hardware-types/4BECD816-3A55-4C10-B550-588E81DE49D3",
                                     @"enclosureGroupUri": @"/rest/enclosure-groups/5e6b367f-c1f7-43e7-a77d-22d8bcedfd93"
                                     };
                                     
    NSError *error = nil;
    return [[NSString alloc] initWithData: [NSJSONSerialization dataWithJSONObject:httpDictionary options:0 error:&error]
                                 encoding:NSUTF8StringEncoding];
}

+(NSString *)createSimpleProfileWithName:(NSString *)name withServerHardwareType:(NSString *)hardwareType forEnclosureGroup:(NSString *)enclosureGroup
{
    NSDictionary *httpDictionary = @{@"type" : @"ServerProfileV4",
                                     @"name" : name,
                                     @"serverHardwareTypeUri" : hardwareType,
                                     @"enclosureGroupUri": enclosureGroup
                                     };
    
    NSError *error = nil;
    return [[NSString alloc] initWithData: [NSJSONSerialization dataWithJSONObject:httpDictionary options:0 error:&error]
                                 encoding:NSUTF8StringEncoding];
}

@end
