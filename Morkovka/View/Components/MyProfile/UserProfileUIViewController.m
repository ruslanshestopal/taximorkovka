#import "UserProfileUIViewController.h"
#import "ChangePasswordViewController.h"
@implementation UserProfileUIViewController

@synthesize delegate = _delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.uiItems each:^(UIView *uiObj) {
        uiObj.hidden = YES;
    }];
    
    [self.loadingIndicator startAnimating];
    @weakify(self);
    [[_delegate requestUserProfile] subscribeNext:^(UserProfileVO *params) {
        @strongify(self);
        [self.uiItems each:^(UIView *uiObj) {
            uiObj.hidden = NO;
        }];
        
        [self.loadingIndicator stopAnimating];
        self.firstNameTextField.text = params.userName;
        self.phoneLabel.text = params.userPhone;
        self.discountLabel.text = NSStringWithFormat(@"Скидка %.02f %%",
                                           [params.userDiscount floatValue]);

        
    } error:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"Ошибка",nil)
                              message:NSStringWithFormat(@"%@", [error.userInfo
                                        valueForKey:NSLocalizedDescriptionKey])
                              delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];

    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = [segue destinationViewController];
    if([segue.identifier isEqualToString:@"changePASS"]){
        [(ChangePasswordViewController *)vc setDelegate:self.delegate];
    }
}
- (IBAction)saveProfile {
    [self.uiItems each:^(UIView *uiObj) {
        uiObj.hidden = YES;
    }];
    
    [self.loadingIndicator startAnimating];
    @weakify(self);
    [[_delegate saveUserProfile:@{@"user_first_name": self.firstNameTextField.text}]
                  subscribeNext:^(UserProfileVO *params) {
        @strongify(self);
        [self.uiItems each:^(UIView *uiObj) {
            uiObj.hidden = NO;
        }];
        [self.loadingIndicator stopAnimating];
        
    }];

}
- (IBAction)logOut {
    [_delegate loggOutUser];
}

@end
