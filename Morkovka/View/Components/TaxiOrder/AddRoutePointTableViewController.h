#import <UIKit/UIKit.h>
#import "IRootViewComponent.h"
@interface AddRoutePointTableViewController : UITableViewController<IRootViewComponent>
@property(nonatomic, assign) DestinationVO *destination;
@property(nonatomic, assign) RoutePoint *point;
@end
