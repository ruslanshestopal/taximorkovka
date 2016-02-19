
#import <ReactiveCocoa.h>
#import "RunningOrderVO.h"

@protocol IUserProfileViewComponent;


@protocol IUserProfileViewDelegate <NSObject>

// Mediator
@optional

- (RACSignal *) registerWithPhone:(NSDictionary *)params;
- (RACSignal *) registerWithUserNameAndCode:(NSDictionary *)params;

- (RACSignal *) logginWithName:(NSString *)name andPassword:(NSString *)pass;
- (void) loggOutUser;
- (RACSignal *) requestUserProfile;
- (RACSignal *) showOrdersHistory;
- (NSMutableArray *) showCurrentOrders;
- (void) cancelOrderAtIndex:(NSInteger)index;
- (void) repeatOrderAtIndex:(NSInteger)index;
- (RACSignal *) fetchDriverPosition:(RunningOrderVO *)order;
- (NSArray *) fetchFavoritsAdresses;
- (void) removeFavoriteItemAtIndex:(NSInteger)index;
- (void) addToFavorites:(RoutePoint *)point;
- (RACSignal *) listStreetsWithName:(NSString *)street;
- (RACSignal *) listHousesForStreetWithName:(NSString *)street;

@end


#pragma mark -
@protocol IUserProfileViewComponent <NSObject>
@property(nonatomic, weak) id<IUserProfileViewDelegate> delegate;
@end
