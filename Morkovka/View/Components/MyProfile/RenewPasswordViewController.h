#import <UIKit/UIKit.h>
#import "IUserProfileView.h"

@interface RenewPasswordViewController : UIViewController <IUserProfileViewComponent>
@property (weak, nonatomic) IBOutlet UITextField *passwdATextField;
@property (weak, nonatomic) IBOutlet UITextField *passwdBTextField;

@property (weak, nonatomic) IBOutlet UIButton *changePassButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@end
