#import "IUserProfileView.h"
#import "MorkovkaServiceFacade.h"
#import "FavoritesMediator.h"
#import "MorkovkaServiceFacade.h"

@interface FavoritesMediator() <IUserProfileViewDelegate>
@property(nonatomic, strong) id<IUserProfileViewComponent> viewComponent;
@end

@implementation FavoritesMediator


@dynamic viewComponent;

-(void)onRegister {
    NSParameterAssert(self.viewComponent != nil);
    NSParameterAssert([self.viewComponent conformsToProtocol:(
                                @protocol(IUserProfileViewComponent))]);
    self.viewComponent.delegate = self;
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

- (void) removeFavoriteItemAtIndex:(NSInteger)index{
    FavoritesProxy *proxy = [self.facade
                                   retrieveProxy:[FavoritesProxy name]];
    [proxy removeFavoriteItemAtIndex:index];

}

- (void) addToFavorites:(RoutePoint *)point{
    FavoritesProxy *proxy = [self.facade retrieveProxy:[FavoritesProxy name]];
    [proxy addToFavorites:point];
}

-(NSArray *)listNotificationInterests {
    return [NSArray new];
}



@end