#import <UIKit/UIKit.h>
#import "DestinationVO.h"
#import "IRootViewComponent.h"

@interface ListFavoritesTableViewController : UITableViewController <IRootViewComponent>
@property(nonatomic, assign) DestinationVO *destination;
@property(nonatomic, strong) NSArray *favArray;
@property(nonatomic, assign) RoutePoint *point;
@end
