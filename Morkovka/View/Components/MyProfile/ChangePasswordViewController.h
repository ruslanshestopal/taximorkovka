#import <UIKit/UIKit.h>
#import "IUserProfileView.h"

@interface ChangePasswordViewController : UIViewController<IUserProfileViewComponent>
@property (weak, nonatomic) IBOutlet UITextField *passwdOldTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwdATextField;
@property (weak, nonatomic) IBOutlet UITextField *passwdBTextField;
@property (weak, nonatomic) IBOutlet UIButton *updatePassButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@end
