//
//  HPOneviewManager.h
//  Identity Converter
//
//  Created by Daniel Finneran on 17/12/2014.
//  Copyright (c) 2014 Daniel Finneran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPHandler.h"

@protocol HPOneviewDelegate <NSObject>

@required
-(void)dataReturned;
-(void)ucsDataUpdate:(NSString *)data; // callback method with NSString Data
@end

@interface HPOneviewManager : NSObject

@property id delegate;

//@property UCSAuthorization *auth; Taken from UCS Manager interface
@property NSString *username;
@property NSString *password;
@property bool auth; // cookie used after authentication

@property NSString *hostname;

@property NSString *uri; // REST URL

@property BOOL blocking; // defines blocking on function call

@property HTTPHandler *http;

-(id)initWithUsername:(NSString *)username Password:(NSString *)password;


// Functions for interacting with HP OneView
-(void)login;
-(void)logout;
-(void)bladeList;
-(void)createBlank;
-(void)enclosureGroups;
-(void)serverHardwareTypes;
-(void)networks;
-(void)networkSets;
-(void)fcNetworks;

// Tester Function
-(void)createRandomSimpleProfile;


-(NSArray *)returnEnclosureURI;
-(NSArray *)returnServerHardwareURI;
-(NSArray *)returnNetworkURI;
-(NSArray *)returnNetworkSetsURI;
-(NSArray *)returnFCNetworkURI;



@end
