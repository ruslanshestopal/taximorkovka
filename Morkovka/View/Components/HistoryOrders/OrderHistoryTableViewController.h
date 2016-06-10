#import "TopTableViewController.h"
#import "IUserProfileView.h"
@interface OrderHistoryTableViewController : TopTableViewController<IUserProfileViewComponent>
@property(nonatomic, assign) NSArray *history;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@end
