
#import <ReactiveCocoa.h>
#import "DestinationVO.h"


@protocol IRootViewComponent;


@protocol IRootViewDelegate <NSObject>

// Mediator
@optional
// Taxi oder and it's navi stack
- (void) viewComponentDidTriggeredMenuAtIndex:(NSIndexPath*)index;

- (DestinationVO *) requestDestinationData;
- (RACSignal *) listStreetsWithName:(NSString *)street;
- (RACSignal *) listHousesForStreetWithName:(NSString *)street;
- (RACSignal *) calculatePreoderPrice;
- (RACSignal *) placeAnOrder;
- (RACSignal *) showOrdersHistory;
- (RACSignal *) curentLocationAdressForRadius:(NSString *)radius;
- (void) addToFavorites:(RoutePoint *)point;
- (NSArray *) fetchFavoritsAdresses;
@end


#pragma mark -
@protocol IRootViewComponent <NSObject>
@property(nonatomic, weak) id<IRootViewDelegate> delegate;

@optional
- (void) onOderPlacement;
@end
