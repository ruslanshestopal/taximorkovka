#import <UIKit/UIKit.h>
#import "IUserProfileView.h"

@interface VerifyCodeViewController : UIViewController <IUserProfileViewComponent>
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *verifyCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *changePassButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@end
