# HPOneView
This is a very simple wrapper around the RESTful API of HP Oneview and at this time offers only simplistic functionality, with the view that additions to this "skeleton" wont take much. 

It consists of three classes, two of which are for building JSON queries and directly speaking with OneView and the other a Delegate class for handling interactions with HTTP/HTTPS.

HTTPHandler.h/m - This is a simple wrapper around NSURLConnection and provides the delegate methods and the ability for managing request types (POST/GET) along with handling an array of headers

HPOneviewManager.h/m - This is the main class for interacting with HP OneView and as such requires the IP, Username and Password of HP and allows commands and data to be sent to Oneview. Currently it can do the following:
- Login
- Retrieval of Networks, Network Sets, FC Networks, Server Hardware Profiles, Enclosure Groups and a list of server profiles
- Creation of Server Profiles (only basic/random currently)

Code Example:
~~~objective-c

    HPOneviewManager *hpOneview = [[HPOneviewManager alloc] initWithUsername:@"Administrator" Password:@"password"];

    [hpOneview setDelegate:self]; // Required for future use
    [hpOneview setHostname:@"10.0.0.1"];
    [hpOneview setBlocking:YES]; // done execute on main thread otherwise UI will lag.
    [hpOneview login];
    
    // ... Execute further commands
    
~~~

The above example will Log you into HP OneView and from there further commands will allow reading and writing ..

Further Code Example:
~~~objective-c

    // Retrieve Server Hardware Types and available enclosure Groups
    [hpOneview serverHardwareTypes];
    [hpOneview enclosureGroups];
    
    // The above information is required before a profile can be created.
    // This creates a randomly named profile on the first enclosure group using the first server hardware type
    [hp createRandomSimpleProfile];
    
    // return an array of Network Names to their URIs
    NSLog(@"%@",[hpOneview returnNetworkURI]);
    
~~~

ToDo:
- a lot ..
- Name changes for classes Oneview -> OneView
- Additional functionality for creating server profiles (BIOS, Network, FC etc..)
- possible look at changing the HTTP interaction
