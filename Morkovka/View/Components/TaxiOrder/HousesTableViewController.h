#import <UIKit/UIKit.h>
#import "DestinationVO.h"
#import "IRootViewComponent.h"
@interface HousesTableViewController : UITableViewController <IRootViewComponent>
@property(nonatomic, assign) DestinationVO *destination;
@property(nonatomic, assign) RoutePoint *point;
@property(nonatomic, strong) NSArray *housesArray;
@end
