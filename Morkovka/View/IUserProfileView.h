#import "RunningOrderVO.h"

@protocol IUserProfileViewComponent;


@protocol IUserProfileViewDelegate <NSObject>

// Mediator
@optional

- (RACSignal *) sendVerificationSMS:(NSDictionary *)params;
- (RACSignal *) registerWithUserNameAndCode:(NSDictionary *)params;

- (RACSignal *) logginWithName:(NSString *)name andPassword:(NSString *)pass;
- (void) loggOutUser;
- (RACSignal *) requestUserProfile;
- (RACSignal *) saveUserProfile:(NSDictionary *)params;
- (RACSignal *) showOrdersHistory;
- (NSMutableArray *) showCurrentOrders;
- (void) cancelOrder:(RunningOrderVO *)order;
- (void) repeatOrderAtIndex:(NSInteger)index;
- (RACSignal *) fetchDriverPosition:(RunningOrderVO *)order;
- (NSArray *) fetchFavoritsAdresses;
- (void) removeFavoriteItemAtIndex:(NSInteger)index;
- (void) addToFavorites:(RoutePoint *)point;
- (RACSignal *) listStreetsWithName:(NSString *)street;
- (RACSignal *) listHousesForStreetWithName:(NSString *)street;


- (RACSignal *) sendRestorationSMS:(NSDictionary *)params;
- (RACSignal *) checkConfirmCode:(NSDictionary *)params;
- (RACSignal *) accountRestore:(NSDictionary *)params;

- (RACSignal *) changeMyPassword:(NSDictionary *)params;
@end


#pragma mark -
@protocol IUserProfileViewComponent <NSObject>
@property(nonatomic, weak) id<IUserProfileViewDelegate> delegate;
@optional
- (void) onTaxiFound;
@end
