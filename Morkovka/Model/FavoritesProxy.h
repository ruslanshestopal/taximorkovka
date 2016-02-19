#import "Proxy.h"
#import "DestinationVO.h"

@interface FavoritesProxy : Proxy

@property(nonatomic, strong) NSMutableArray *myFavoritesArray;

- (void) addToFavorites:(RoutePoint *)point;
- (void) removeFavoriteItemAtIndex:(NSInteger)index;
@end
