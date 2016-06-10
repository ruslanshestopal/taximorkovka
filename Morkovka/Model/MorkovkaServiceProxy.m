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


- (void) initializeProxy {
    self.http = [MorkovkaHTTPClient new];
    self.destination = [DestinationVO new];
    self.ordersArr = [NSMutableArray new];
    self.streets = [NSArray new];
    self.credentialsProxy = [self.facade
                             retrieveProxy:[CredentialsProxy name]];

    
    if (self.credentialsProxy.hasCredentials &&
        self.credentialsProxy.credentialsAreValid) {
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
}

- (RACSignal *) startJSONRequest:(NSString *)requestStr {
    NSParameterAssert(requestStr != nil);
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

- (RACSignal *) startPUTRequest:(NSString *)requestPath withParams:(NSDictionary *)params{
    NSParameterAssert(requestPath != nil);
    @weakify(self);
    return [RACSignal createSignal:
            ^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self)
                NSURLSessionDataTask *dataTask =
                [self.http PUT:[NSURL URLWithString:requestPath
                                      relativeToURL:self.http.baseURL].absoluteString
                    parameters:params
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
            [subscriber sendError:error];
        }];
        return nil;
    }] doCompleted:^{
        @strongify(self);
        self.credentialsProxy.username = name;
        self.credentialsProxy.password = pass;
        self.credentialsProxy.credentialsAreValid = YES;
        [self.http updateBasicAuthHeaderWith:name andPassword:pass];
    }];

}
 - (RACSignal *) startRouting{
    @weakify(self);
    return  [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSDictionary *routeJSON =
         [MTLJSONAdapter JSONDictionaryFromModel:self.destination error:nil] ;
        
        [[self startPOSTRequest:@"/api/weborders" withParams:routeJSON]
                                        subscribeNext:^(NSDictionary *val) {
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
        }error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] doCompleted:^{
        @strongify(self);
        self.destination.routePoints  = [NSArray new];

    }];
    
}


- (RACSignal *)updateRoutingWithSession:(RunningOrderVO *)order {
    //@"7c2220e7de6342f0ab16862afaf7e4dc"
    NSLog(@"updateRoutingWithSession %@", order.orderUID);
    NSString *url = NSStringWithFormat(@"/api/weborders/%@",
                                      order.orderUID);
    return [self startJSONRequest:url];
}

- (RACSignal *)fetchTaxi {

    return [[self startRouting] flattenMap:^RACStream *(RunningOrderVO *order) {
        UIBackgroundTaskIdentifier backgroundTask = [[UIApplication sharedApplication]
                                    beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"Ran out of time");
        }];
        
        RACSignal *taskSignal = [[[[self updateRoutingWithSession:order]
                  delay:10.0f]
                 repeat]
                takeUntilBlock:^BOOL(NSDictionary *response) {
                    NSLog(@"takeUntilBlock %@ \n %@", response[@"order_car_info"], response);
               

                    if(![response[@"order_car_info"] isKindOfClass:[NSNull class]]){
                        order.foundCar = response[@"order_car_info"];
                        order.dispatchedAt = [NSDate date];
                        order.isArchived = YES;
                        UILocalNotification *notification = [UILocalNotification new];
                        notification.timeZone  = [NSTimeZone systemTimeZone];
                        notification.fireDate  = [[NSDate date] dateByAddingTimeInterval:1.0f];
                        notification.alertAction = NSLocalizedString(@"Такси найдено", nil);
                        notification.alertBody = response[@"order_car_info"];
                        notification.soundName = UILocalNotificationDefaultSoundName;
                        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                        
                       
                        if (![response[@"drivercar_position"] isKindOfClass:[NSNull class]]) {
                             NSDictionary *posDict = response[@"drivercar_position"];
                             order.gps = [MTLJSONAdapter modelOfClass:DriverPosition.class
                             fromJSONDictionary:posDict
                             error:nil];
                        }
                        [self sendNotification:onServiceDidFoundTaxi];
                        return YES;
                    }else{
                        if ([response[@"order_is_archive"] boolValue]) {
                            NSLog(@"takeUntilBlock order_is_archive");
                            order.dispatchedAt = [NSDate date];
                            order.isArchived = YES;
                            if ([response[@"order_car_info"] isKindOfClass:[NSNull class]]) {
                                [self.ordersArr removeObject:order];
                                UILocalNotification *notification = [UILocalNotification new];
                                notification.timeZone  = [NSTimeZone systemTimeZone];
                                notification.fireDate  = [[NSDate date] dateByAddingTimeInterval:1.0f];
                                notification.alertAction = NSLocalizedString(@"Такси не найдено", nil);
                                notification.alertBody = NSLocalizedString(@"Извините, но ничего не получилось.", nil);
                                notification.soundName = UILocalNotificationDefaultSoundName;
                                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                                [self sendNotification:onServiceDidNotFoundTaxi];
                            }
                            return YES;
                        }
                    }

                    if (order.isCanceledByUser) {
                        [self.ordersArr removeObject:order];
                        return YES;
                    }
                    return order.isCanceledByUser;
                }];
        return [taskSignal finally:^{
              NSLog(@"taskSignal finally");
             [[UIApplication sharedApplication]
                        endBackgroundTask:backgroundTask];
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
                                             fromJSONDictionary:val
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

- (RACSignal *) saveUserProfile:(NSDictionary *)params{
    @weakify(self);
    return  [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [[self startPUTRequest:@"/api/clients/profile" withParams:params]
         subscribeNext:^(id val) {
             [subscriber sendNext:val];
             [subscriber sendCompleted];
         }error:^(NSError *error) {
             [subscriber sendError:error];
         }];
        return nil;
    }] doCompleted:^{
        @strongify(self);
        self.userProfile.userName = params[@"user_first_name"];
    }];
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

- (RACSignal *) sendVerificationSMS:(NSDictionary *)params{
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
             
             [[NSUserDefaults standardUserDefaults]
                         setObject:params[@"phone"]
                            forKey:@"userPhone"];
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

//


- (RACSignal *) sendRestorationSMS:(NSDictionary *)params{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [[self startPOSTRequest:@"/api/account/restore/sendConfirmCode" withParams:params]
         subscribeNext:^(id val) {
             [subscriber sendNext:val];
             [subscriber sendCompleted];
         }error:^(NSError *error) {
             [subscriber sendError:error];
         }];
        return nil;
    }];
    
}

- (RACSignal *) checkConfirmCode:(NSDictionary *)params{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [[self startPOSTRequest:@"/api/account/restore/checkConfirmCode" withParams:params]
         subscribeNext:^(id val) {
             [[NSUserDefaults standardUserDefaults]
                        setObject:params[@"confirm_code"]
                        forKey:@"confirmCode"];
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

- (RACSignal *) accountRestore:(NSDictionary *)params{
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [[self startPOSTRequest:@"/api/account/restore" withParams:params]
         subscribeNext:^(id val) {
             [subscriber sendNext:val];
             [subscriber sendCompleted];
         }error:^(NSError *error) {
             [subscriber sendError:error];
         }];
        return nil;
    }]doCompleted:^{
        @strongify(self);
        self.credentialsProxy.username = [[NSUserDefaults standardUserDefaults]
                                         stringForKey:@"userPhone"];

        self.credentialsProxy.password = params[@"password"];
        self.credentialsProxy.credentialsAreValid = YES;
        NSLog(@"doCompleted %@ %@", params[@"password"], self.credentialsProxy.username);
        [self.http updateBasicAuthHeaderWith:self.credentialsProxy.username
                                 andPassword:params[@"password"]];
        [self.facade sendNotification:onMenuDidNavigateToSection
                                 body:self.menuPath
                                 type:MorkovkaServicePostAuthEvent
         ];
    }];

    
}

- (RACSignal *) changeMyPassword:(NSDictionary *)params{

    @weakify(self);
    return  [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [[self startPUTRequest:@"/api/account/changepassword" withParams:params]
         subscribeNext:^(id val) {
             [subscriber sendNext:val];
             [subscriber sendCompleted];
         }error:^(NSError *error) {
             [subscriber sendError:error];
         }];
        return nil;
    }] doCompleted:^{
        @strongify(self);
        NSString *loginName = self.credentialsProxy.username;
        self.credentialsProxy.password = params[@"newPassword"];
        self.credentialsProxy.credentialsAreValid = YES;
        NSLog(@"doCompleted %@", params[@"newPassword"]);
        [self.http updateBasicAuthHeaderWith:loginName
                                 andPassword:params[@"newPassword"]];
        [self.facade sendNotification:onMenuDidNavigateToSection
                                 body:self.menuPath
                                 type:MorkovkaServicePostAuthEvent
         ];
    }];
    
}

- (void) loggOutUser{
    self.userProfile = nil;
    [self.credentialsProxy clearCredentials];
    [self.ordersArr removeAllObjects];
    [self.http updateBasicAuthHeaderWith:@"guest"
                             andPassword:@"guest"];
    [self.facade sendNotification:onMenuDidNavigateToSection
                             body:[NSIndexPath
                                   indexPathForRow:100 inSection:0]];
}

- (RACSignal *) curentLocationAdressForRadius:(NSString *)rad{
     @weakify(self);
    
    [[[[[MMPReactiveCoreLocation service]
                      authorizeWhenInUse]
                 authorize] replayLazily]
        subscribeNext:^(NSNumber *statusNumber) {
         CLAuthorizationStatus status = [statusNumber intValue];
         switch (status) {
             case kCLAuthorizationStatusAuthorizedAlways:
             case kCLAuthorizationStatusAuthorizedWhenInUse:
                 break;
             case kCLAuthorizationStatusDenied:
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
    NSDictionary *objDict;
    NSError *error;
    if (fileName) {
        NSData *objData = [[NSData alloc] initWithContentsOfFile:fileName];

        objDict = [NSJSONSerialization JSONObjectWithData:objData
                                                              options:0
                                                                error:&error];
    }
    if (error) {
       return nil;
    }
    
    return objDict;
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
