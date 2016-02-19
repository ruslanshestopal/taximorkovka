#import "MorkovkaServiceProxy+Private.h"
#import <MMPReactiveCoreLocation/MMPReactiveCoreLocation.h>
#import "MorkovkaHTTPClient.h"
#import "ApplicationFacade.h"

NSString *const MorkovkaServiceErrorDomain = @"MorkovkaServiceErrorDomain";
NSString *const MorkovkaServicePostAuthEvent = @"MorkovkaServicePostAuthEvent";

@interface MorkovkaServiceProxy ()

@property(nonatomic, strong) MorkovkaHTTPClient *http;
@property(nonatomic, strong) CredentialsProxy *credentialsProxy;


@end


#pragma mark -
@implementation MorkovkaServiceProxy


typedef void(^CompletedResults)(NSString *searchResult, NSError *error);


- (void) initializeProxy {
    self.http = [MorkovkaHTTPClient new];
    self.destination = [DestinationVO new];
    self.ordersArr = [NSMutableArray new];
    self.streets = [NSArray new];
    self.credentialsProxy = [self.facade retrieveProxy:[CredentialsProxy name]];
    
    if (self.credentialsProxy.hasCredentials &&
        self.credentialsProxy.credentialsAreValid) {
        //[self.credentialsProxy clearCredentials];
        NSLog(@"self.credentialsProxy.username %@ %@ ", self.credentialsProxy.username, self.credentialsProxy.password);
        [self.http updateBasicAuthHeaderWith:self.credentialsProxy.username
                                 andPassword:self.credentialsProxy.password];
    }
    NSDictionary *streetsDic = [self readStringFromFile:@"streets"];
    NSDictionary *poiDic = [self readStringFromFile:@"poi"];
    
    self.streets = [streetsDic[@"geo_street"] map:^(NSDictionary *data) {
        RoutePoint *point = [RoutePoint new];
        point.name = data[@"name"];
        point.isPOI = NO;
        return  point;
    }];
    

    NSArray *poiArray =[poiDic[@"geo_object"] map:^(NSDictionary *data) {
        RoutePoint *point = [RoutePoint new];
        point.name = data[@"name"];
        point.isPOI = YES;
        return  point;
    }];
    self.streets = [self.streets arrayByAddingObjectsFromArray:poiArray];
    


    
    RunningOrderVO *order = [RunningOrderVO new];
    order.orderUID = @"7c2220e7de6342f0ab16862afaf7e4dc";
    order.driverPhone = @"+380938163336";
    order.foundCar = @"СВ4255АН, КРАСНЫЙ, NEXIA, +380938163336";
    order.orderCost = @"22";
    RoutePoint *p1 = [RoutePoint new];
    p1.name = @"ЧИГОРИНА УЛ.";
    p1.houseNum = @"12";

    RoutePoint *p2 = [RoutePoint new];
    p2.name = @"БУБНОВА АНДРЕЯ УЛ.";
    p2.houseNum = @"8";
    
    order.addressFrom = p1;
    order.addressTo = p2;
    
    DriverPosition *pos = [ DriverPosition new];
    pos.lat = [NSNumber numberWithFloat:50.419977];
    pos.lng = [NSNumber numberWithFloat:30.537664];
    pos.time = [NSDate date];
    order.gps = pos;
    
    [self.ordersArr addObject:order];


}

- (RACSignal *) startJSONRequest:(NSString *)requestStr {
    NSParameterAssert(requestStr != nil);
     /*
     NSURL *baseURL = [NSURL URLWithString:@"http://example.com/v1/"];
     [NSURL URLWithString:@"foo" relativeToURL:baseURL];                  // http://example.com/v1/foo
     [NSURL URLWithString:@"foo?bar=baz" relativeToURL:baseURL];          // http://example.com/v1/foo?bar=baz
     [NSURL URLWithString:@"/foo" relativeToURL:baseURL];                 // http://example.com/foo
     [NSURL URLWithString:@"foo/" relativeToURL:baseURL];                 // http://example.com/v1/foo
     [NSURL URLWithString:@"/foo/" relativeToURL:baseURL];                // http://example.com/foo/
     [NSURL URLWithString:@"http://example2.com/" relativeToURL:baseURL]; // http://example2.com/
     */
    
    @weakify(self);
    return [RACSignal createSignal:
            ^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self)
                NSURLSessionDataTask *dataTask =
                [self.http GET:[NSURL URLWithString:requestStr
                                      relativeToURL:self.http.baseURL].absoluteString
                    parameters:nil
                      progress:nil
                       success:^(NSURLSessionTask *task, id responseObject) {
                        [subscriber sendNext:responseObject];
                        [subscriber sendCompleted];
                    
                } failure:^(NSURLSessionTask *operation, NSError *error) {
                    [subscriber sendError:error];
                }];
                return [RACDisposable disposableWithBlock:^{
                    [dataTask cancel];
                }];
            }];
}
- (RACSignal *) startPOSTRequest:(NSString *)requestPath withParams:(NSDictionary *)params{

    NSParameterAssert(requestPath != nil);

    @weakify(self);
    return [RACSignal createSignal:
            ^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self)
                NSURLSessionDataTask *dataTask =
                [self.http POST:[NSURL URLWithString:requestPath
                                      relativeToURL:self.http.baseURL].absoluteString
                    parameters:params
                      progress:nil
                       success:^(NSURLSessionTask *task, id responseObject) {
                           [subscriber sendNext:responseObject];
                           [subscriber sendCompleted];
                           
                       } failure:^(NSURLSessionTask *operation, NSError *error) {
                          [subscriber sendError:error];
                       }];
                return [RACDisposable disposableWithBlock:^{
                    [dataTask cancel];
                }];
            }];
}

- (RACSignal *) startPUTRequest:(NSString *)requestPath{
    NSParameterAssert(requestPath != nil);
    @weakify(self);
    return [RACSignal createSignal:
            ^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self)
                NSURLSessionDataTask *dataTask =
                [self.http PUT:[NSURL URLWithString:requestPath
                                      relativeToURL:self.http.baseURL].absoluteString
                    parameters:nil
                       success:^(NSURLSessionTask *task, id responseObject) {
                           [subscriber sendNext:responseObject];
                           [subscriber sendCompleted];
                           
                       } failure:^(NSURLSessionTask *operation, NSError *error) {
                           [subscriber sendError:error];
                       }];
                return [RACDisposable disposableWithBlock:^{
                    [dataTask cancel];
                }];
            }];


}

- (RACSignal *) startLocationRequest:(NSString *)requestStr {
    NSParameterAssert(requestStr != nil);
   
    @weakify(self);
    return [RACSignal createSignal:
            ^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self)
                NSURLSessionDataTask *dataTask =
                [self.http GET:requestStr
                    parameters:nil
                      progress:nil
                       success:^(NSURLSessionTask *task, id responseObject) {
                           [subscriber sendNext:responseObject];
                           [subscriber sendCompleted];
                           
                       } failure:^(NSURLSessionTask *operation, NSError *error) {
                            [subscriber sendError:error];
                       }];
                return [RACDisposable disposableWithBlock:^{
                    [dataTask cancel];
                }];
            }];
}

- (RACSignal *) searchForStreet:(NSString *)street{
    
    NSCharacterSet * set = [NSCharacterSet
        characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    if ([[street uppercaseString] rangeOfCharacterFromSet:set].location != NSNotFound) {
        NSMutableString *name = [street mutableCopy];
        CFMutableStringRef nameRef = (__bridge CFMutableStringRef)name;
        CFStringTransform(nameRef, NULL, kCFStringTransformLatinCyrillic, false);
        CFStringTransform(nameRef, NULL, kCFStringTransformStripCombiningMarks, false);
        street = [name copy];
    }

    NSArray *matchesArray =  [self.streets
                              select:^BOOL(RoutePoint *point) {
        return ([[point.name uppercaseString]
                 hasPrefix:[street uppercaseString]]);
    }];
    if ([matchesArray count]==0) {
        matchesArray =  [self.streets
                         select:^BOOL(RoutePoint *point) {
           return ([[point.name uppercaseString]
           localizedCaseInsensitiveContainsString:[street uppercaseString]]);
        }];
    }
    return [RACSignal return:matchesArray];
}
- (RACSignal *)search:(NSString *)text {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *req= [NSString stringWithFormat:@"/api/geodata/streets/search?q=%@&fields=*",
                        [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self search:req completed:^(NSString *searchResult, NSError *error) {
            [subscriber sendNext:searchResult];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}
- (void)search:(NSString *)text completed:(CompletedResults)handler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2.5];
        [[self startJSONRequest:text] subscribeNext:^(id x) {
            if (handler){
                handler(x, nil);
            }
        }];
    });
}
- (RACSignal *) logginWithName:(NSString *)name andPassword:(NSString *)pass{
    NSDictionary *params = @{@"login": name,
                             @"password": [MorkovkaHTTPClient
                                           SHA512StringFromString:pass]};

    @weakify(self);
    return  [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [[self startPOSTRequest:@"/api/account" withParams:params]
                                            subscribeNext:^(NSDictionary *val) {
            NSError *error = nil;
            self.userProfile = [MTLJSONAdapter modelOfClass:UserProfileVO.class
                                                      fromJSONDictionary:val
                                                                   error:&error];
            [subscriber sendNext:val];
            [subscriber sendCompleted];
            [self.facade sendNotification:onMenuDidNavigateToSection
                                     body:self.menuPath
                                     type:MorkovkaServicePostAuthEvent
             ];
        }error:^(NSError *error) {
            NSLog(@"Error logging in");
            [subscriber sendError:error];
        }];
        return nil;
    }] doCompleted:^{
        @strongify(self);
        self.credentialsProxy.username = name;
        self.credentialsProxy.password = pass;
        self.credentialsProxy.credentialsAreValid = YES;
        NSLog(@"doCompleted %@", params);
        [self.http updateBasicAuthHeaderWith:name andPassword:pass];
    }];

}
 - (RACSignal *) startRouting{
    @weakify(self);
    return  [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSDictionary *routeJSON =
         [MTLJSONAdapter JSONDictionaryFromModel:self.destination error:nil] ;
        
        [[self startPOSTRequest:@"/api/weborders" withParams:routeJSON] subscribeNext:^(NSDictionary *val) {
            NSError *error = nil;
            
            self.destination.routePoints  = [NSArray new];
            self.destination.preCheck = nil;
            
            RunningOrderVO *order = [MTLJSONAdapter modelOfClass:RunningOrderVO.class
                                         fromJSONDictionary:val
                                                      error:&error];
            [self.ordersArr addObject:order];
            [subscriber sendNext:order];
            [subscriber sendCompleted];

            
            [self.facade sendNotification:onMenuDidNavigateToSection
                                     body:[NSIndexPath indexPathForRow:1 inSection:0]
             ];
            [self.facade sendNotification:onOrderDidSuccessfullyPlaced];

              NSLog(@"RunningOrderVO %@",  self.destination);
        }error:^(NSError *error) {
            NSLog(@"Error making order");
            [subscriber sendError:error];
        }];
        return nil;
    }] doCompleted:^{
        @strongify(self);
        self.destination.routePoints  = [NSArray new];

    }];
    
}


- (RACSignal *)updateRoutingWithSession:(NSString *)session {

    NSLog(@"updateRoutingWithSession %@", session);
    NSString *url = NSStringWithFormat(@"/api/weborders/%@",
                                       @"7c2220e7de6342f0ab16862afaf7e4dc");
    return [self startJSONRequest:url];
}

- (RACSignal *)fetchTaxi {
    return [[self startRouting] flattenMap:^RACStream *(RunningOrderVO *order) {
        return [[[[self updateRoutingWithSession:order.orderUID]
                  delay:10.0f]
                 repeat]
                takeUntilBlock:^BOOL(NSDictionary *response) {
                    NSLog(@"takeUntilBlock %@ \n %@", response[@"order_car_info"], response);
               
                    
                    if ([response[@"order_is_archive"] boolValue]) {
                       NSLog(@"takeUntilBlock CANCEL");
                        return YES;
                    }
                    return order.isCanceledByUser;
                }];
    }];
}

- (RACSignal *) requestUserProfile{
    if (self.userProfile) {
       return [RACSignal return:self.userProfile];
    }else{
        @weakify(self);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self)
            [[self startJSONRequest:@"/api/clients/profile"] subscribeNext:^(NSDictionary *val) {
                NSError *error = nil;
                self.userProfile = [MTLJSONAdapter modelOfClass:UserProfileVO.class
                                             fromJSONDictionary:[val mutableCopy]
                                                          error:&error];
                [subscriber sendNext:self.userProfile];
                [subscriber sendCompleted];
            }error:^(NSError *error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }
}
- (RACSignal *) requestOrdersHistory{
    if (self.historyArr) {
        return [RACSignal return:self.historyArr];
    }else{
        @weakify(self);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self)
            [[self startJSONRequest:@"/api/clients/ordershistory?limit=50&offset=0&executionStatus="]
                      subscribeNext:^(NSArray *val) {
                self.historyArr = [NSArray new];
                
                NSValueTransformer *transformer =
                    [MTLJSONAdapter arrayTransformerWithModelClass:DestinationVO.class];
                NSArray *values = [transformer transformedValue:val];
                if (![values isKindOfClass:[NSArray class]]) {
                    return [subscriber sendError:
                            [self invalidReplyErrorWithReason:
                             [NSString stringWithFormat:@"Value of key  is not an array"]]];
                }
                self.historyArr = [self.historyArr arrayByAddingObjectsFromArray:values];
                [subscriber sendNext:self.historyArr];
                [subscriber sendCompleted];
            }error:^(NSError *error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }
}
- (RACSignal *) registerWithPhone:(NSDictionary *)params{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [[self startPOSTRequest:@"/api/account/register/sendConfirmCode" withParams:params]
         subscribeNext:^(id val) {
             
             [[NSUserDefaults standardUserDefaults]
                        setObject:params[@"phone"]
                           forKey:@"userPhone"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             [subscriber sendNext:val];
             [subscriber sendCompleted];
         }error:^(NSError *error) {
             [subscriber sendError:error];
         }];
        return nil;
    }];
    
}
- (RACSignal *) registerWithUserNameAndCode:(NSDictionary *)params{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [[self startPOSTRequest:@"/api/account/register" withParams:params]
         subscribeNext:^(id val) {
             
             [[NSUserDefaults standardUserDefaults]
                         setObject:params[@"user_first_name"]
                            forKey:@"userName"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             self.credentialsProxy.username = params[@"phone"];
             self.credentialsProxy.password = params[@"password"];
             self.credentialsProxy.credentialsAreValid = YES;
             
             [self.http updateBasicAuthHeaderWith:params[@"phone"]
                                      andPassword:params[@"password"]];
             
             
             [subscriber sendNext:val];
             [subscriber sendCompleted];
             
             [self.facade sendNotification:onMenuDidNavigateToSection
                                      body:self.menuPath
                                      type:MorkovkaServicePostAuthEvent
              ];
             
         }error:^(NSError *error) {
             [subscriber sendError:error];
         }];
        return nil;
    }];
}


- (void) loggOutUser{
    self.userProfile = nil;
    [self.credentialsProxy clearCredentials];
    [self.http updateBasicAuthHeaderWith:@"guest"
                             andPassword:@"guest"];
    [self.facade sendNotification:onMenuDidNavigateToSection
                             body:[NSIndexPath
                                   indexPathForRow:100 inSection:0]];
}

- (RACSignal *) curentLocationAdressForRadius:(NSString *)rad{
    NSLog(@"curentLocationAdressEvos");
     @weakify(self);
    
    [[[[MMPReactiveCoreLocation service]
       authorizeWhenInUse]
        authorize]
        subscribeNext:^(NSNumber *statusNumber) {
         CLAuthorizationStatus status = [statusNumber intValue];
             NSLog(@"[INFO] : %d", status);
         switch (status) {
             case kCLAuthorizationStatusAuthorizedAlways:
             case kCLAuthorizationStatusAuthorizedWhenInUse:
                 break;
             case kCLAuthorizationStatusDenied:
                // @strongify(self)
                 break;
             default:
                 break;
         }
     }];
    
  
    return [
             [[[MMPReactiveCoreLocation service] timeout:30.0] location]
       
     flattenMap:^RACStream*(CLLocation *location) {
       @strongify(self)
       [self sendNotification:onLocationServiceDidUpdateToLocation body:location];
        NSString *locString = [NSString stringWithFormat:@"(%f, %f, %f)",
                               location.coordinate.latitude,
                               location.coordinate.longitude,
                               location.horizontalAccuracy];
        NSLog(@"[INFO] received single location: %@", locString);
        NSString *url = NSStringWithFormat(@"/api/geodata/search?lat=%f1&lng=%f&r=%@&fields=*",
                                           location.coordinate.latitude,
                                           location.coordinate.longitude,
                                           rad
                                           );
       
        return [RACSignal combineLatest:@[
                                          [RACSignal return:location],
                                          [self startJSONRequest:url]
                                          ]];
        
       
        }
    ];
    
}


- (NSDictionary*)readStringFromFile:(NSString *)filename {
    NSString *fileName = [[NSBundle mainBundle] pathForResource:filename
                                                         ofType:@"json"
                                                ];
    NSDictionary *party;

    if (fileName) {
        NSData *partyData = [[NSData alloc] initWithContentsOfFile:fileName];
        NSError *error;
        party = [NSJSONSerialization JSONObjectWithData:partyData
                                                              options:0
                                                                error:&error];
        
        if (error) {
            NSLog(@"Something went wrong! %@", error.localizedDescription);
           return nil;
        }
    } else {
        NSLog(@"Couldn't find file!");
        return nil;
    }
    return party;
}


- (NSError *) invalidReplyErrorWithReason:(NSString *)reason {
    
    NSParameterAssert(reason);
    
    return [NSError errorWithDomain:MorkovkaServiceErrorDomain
                               code:kMorkovkaServiceInvalidResponseFormat
                           userInfo:@{
          NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid server reply", nil),
   NSLocalizedFailureReasonErrorKey:reason,
                                    }];
}
- (NSError *) invalidLocationErrorWithReason:(NSString *)reason{
    NSParameterAssert(reason);
    return [NSError errorWithDomain:MorkovkaServiceErrorDomain
                               code:kMorkovkaServiceLocationFailed
                           userInfo:@{
          NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid location service reply", nil),
          NSLocalizedFailureReasonErrorKey:reason,
    }];

}
@end
