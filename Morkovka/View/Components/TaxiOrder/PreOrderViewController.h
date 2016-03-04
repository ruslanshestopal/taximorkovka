#import <UIKit/UIKit.h>

typedef void (^ConfirmationBlock)(void);

@interface PreOrderViewController : UIViewController
//{
//    ConfirmationBlock confirmationBlock;
//}
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (nonatomic, copy) ConfirmationBlock confirmationBlock;

@end
