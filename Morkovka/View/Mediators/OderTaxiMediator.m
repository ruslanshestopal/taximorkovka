#import "OderTaxiMediator.h"
#import "TaxiOrderViewController.h"
#import "KievOnMapViewController.h"
#import "MorkovkaServiceFacade.h"
#import "FavoritesProxy.h"
#import <MMPReactiveCoreLocation/MMPReactiveCoreLocation.h>

@interface OderTaxiMediator () <IRootViewDelegate>
@property(nonatomic, strong) id <IRootViewComponent> viewComponent;
@property(nonatomic, strong) NSString *searchString;
@end



#pragma mark -
@implementation OderTaxiMediator

@dynamic viewComponent;

-(void)onRegister {
    NSParameterAssert(self.viewComponent != nil);
    NSParameterAssert([self.viewComponent
                       conformsToProtocol:(@protocol(IRootViewComponent))]);
    self.viewComponent.delegate = self;
}
-(void)onRemove {
    
}

-(NSArray *)listNotificationInterests {
    return @[onOrderDidSuccessfullyPlaced,
             onLocationServiceDidUpdateToLocation];
}

-(void)handleNotification:(id<INotification>)notification {
     if ([[notification name]
          isEqualToString:onOrderDidSuccessfullyPlaced]) {
         if ([self.viewComponent respondsToSelector:@selector(onOderPlacement)]) {
             [self.viewComponent onOderPlacement];
         }
     }
}

- (RACSignal *) showOrdersHistory{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy requestOrdersHistory];

}
- (RACSignal *) curentLocationAdressForRadius:(NSString *)radius{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy curentLocationAdressForRadius:radius];
}

- (RACSignal *) calculatePreoderPrice{
    
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
   
    NSMutableDictionary *routeJSON =
    [ [MTLJSONAdapter JSONDictionaryFromModel:proxy.destination error:nil] mutableCopy];
    
    //NSLog(@"routeJSON %@", routeJSON);
    return [proxy startPOSTRequest:@"/api/weborders/cost" withParams:routeJSON];


}
- (RACSignal *) placeAnOrder{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [[UIApplication sharedApplication]
         registerUserNotificationSettings:[UIUserNotificationSettings
                         settingsForTypes:UIUserNotificationTypeAlert|
                                           UIUserNotificationTypeBadge|
                                           UIUserNotificationTypeSound
                               categories:nil]];
    }
    MorkovkaServiceProxy *proxy = [self.facade
           retrieveProxy:[MorkovkaServiceProxy name]];
        return [proxy fetchTaxi];

}
- (RACSignal *) listStreetsWithName:(NSString *)street{
    MorkovkaServiceProxy *proxy = [self.facade retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy searchForStreet:street];
}
- (RACSignal *) listHousesForStreetWithName:(NSString *)street{
    MorkovkaServiceProxy *proxy = [self.facade retrieveProxy:[MorkovkaServiceProxy name]];
    NSString *req= [NSString stringWithFormat:@"/api/geodata/streets/search?q=%@&fields=*",
                    [street stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return [proxy startJSONRequest:req];

}

-(NSArray *)fetchFavoritsAdresses{
    FavoritesProxy *proxy = [self.facade
                             retrieveProxy:[FavoritesProxy name]];
    return  proxy.myFavoritesArray;
    
}

- (void) addToFavorites:(RoutePoint *)point{
   FavoritesProxy *proxy = [self.facade retrieveProxy:[FavoritesProxy name]];
   [proxy addToFavorites:point];
}
- (DestinationVO *) requestDestinationData{
    MorkovkaServiceProxy *proxy = [self.facade
                    retrieveProxy:[MorkovkaServiceProxy name]];
    if (proxy) {
        return  proxy.destination;

    }else{
        return [DestinationVO new];
    }
}
@end

