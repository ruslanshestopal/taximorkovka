#import <UIKit/UIKit.h>
#import "IUserProfileView.h"
#import "TopViewController.h"
#import "UserProfileVO.h"

@interface UserProfileUIViewController : TopViewController <IUserProfileViewComponent>

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIButton *passButton;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(nonatomic, strong) IBOutletCollection(UIView) NSArray *uiItems;


@end
