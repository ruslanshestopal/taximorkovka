#import "PreOrderViewController.h"

@interface PreOrderViewController ()

@end

@implementation PreOrderViewController

@synthesize confirmationBlock = _confirmationBlock;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.phoneTextField.text = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"userPhone"];
    self.nameTextField.text = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"userName"];

    RAC(self.orderButton, enabled) = [RACSignal
                                        combineLatest:@[
           [RACSignal merge:@[self.nameTextField.rac_textSignal,
                              RACObserve(self.nameTextField, text)]],
           [RACSignal merge:@[self.phoneTextField.rac_textSignal,
                              RACObserve(self.phoneTextField, text)]]
           ] reduce:^(NSString *userName, NSString *userPhone) {
               return @(userName.length > 0 && [[NSPredicate
                     predicateWithFormat:@"SELF MATCHES %@", @"^\\+?[0-9]{10,12}$"]
                    evaluateWithObject:userPhone]);
           }];
  

}
-(IBAction)confirmOrder:(UIButton*)sender{
    if (self.confirmationBlock) {
        
        [[NSUserDefaults standardUserDefaults]
         setObject:self.phoneTextField.text
         forKey:@"userPhone"];
        [[NSUserDefaults standardUserDefaults]
         setObject:self.nameTextField.text
         forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController popToRootViewControllerAnimated:YES];
        self.confirmationBlock();
    }
}

@end
