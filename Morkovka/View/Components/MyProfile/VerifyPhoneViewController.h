#import <UIKit/UIKit.h>
#import "IUserProfileView.h"

@interface VerifyPhoneViewController : UIViewController <IUserProfileViewComponent>

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;



@end
