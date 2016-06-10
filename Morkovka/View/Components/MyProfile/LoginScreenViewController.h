#import "TopViewController.h"
#import "IUserProfileView.h"

@interface LoginScreenViewController : TopViewController <IUserProfileViewComponent>
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *getCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *renewPassButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@end
