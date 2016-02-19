
#import <UIKit/UIKit.h>
#import "IUserProfileView.h"

@interface FavHousesTableViewController : UITableViewController<IUserProfileViewComponent>
@property(nonatomic, strong) NSArray *housesArray;
@end
