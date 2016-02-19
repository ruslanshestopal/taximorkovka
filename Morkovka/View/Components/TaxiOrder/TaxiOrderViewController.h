#import <UIKit/UIKit.h>
#import "TopTableViewController.h"
#import "DestinationVO.h"
#import "IRootViewComponent.h"
@interface TaxiOrderViewController : TopTableViewController <IRootViewComponent>
@property(nonatomic, assign) DestinationVO *destination;
@property(nonatomic, strong) UINavigationController *nav;
@end


