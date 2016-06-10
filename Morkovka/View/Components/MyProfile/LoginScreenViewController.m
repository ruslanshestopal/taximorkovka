#import "LoginScreenViewController.h"
#import "VerifyPhoneViewController.h"
#import "VerifyCodeViewController.h"

@implementation LoginScreenViewController

@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    @weakify(self);
    
    self.loginTextField.text = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"userPhone"];
    
    RACSignal *formValid = [RACSignal
                            combineLatest:@[
                                            self.loginTextField.rac_textSignal,
                                            self.passwdTextField.rac_textSignal
                                            ]
                            reduce:^(NSString *login, NSString *password) {
                                return @(login.length >= 7
                                && password.length >=7
                               );
                            }];
    

    RACCommand *createAccountCommand = [[RACCommand alloc]
                                        initWithEnabled:formValid
                                            signalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [[self.delegate logginWithName:self.loginTextField.text
                                  andPassword:self.passwdTextField.text]
                materialize];
    }];
    RACSignal *networkResults = [[createAccountCommand.executionSignals flatten]
                                 deliverOn:[RACScheduler mainThreadScheduler]];

  


    self.loginButton.rac_command = createAccountCommand;
    UIColor *defaultButtonTitleColor = [UIColor colorWithRed:0.071
                                                       green:0.475
                                                        blue:0.996
                                                       alpha:1.000];
    RACSignal *buttonTextColor = [createAccountCommand.enabled map:^id(NSNumber *x) {
        return x.boolValue ? defaultButtonTitleColor : [UIColor lightGrayColor];
    }];
    
    [self.loginButton rac_liftSelector:@selector(setTitleColor:forState:)
                           withSignals:buttonTextColor,
                        [RACSignal return:@(UIControlStateNormal)], nil];
    
    
    RACSignal *executing = createAccountCommand.executing;
    
    RACSignal *fieldTextColor = [executing map:^id(NSNumber *x) {
        return x.boolValue ?
                    [UIColor lightGrayColor]
                    : [UIColor blackColor];
    }];
    
    RAC(self.loginTextField, textColor) = fieldTextColor;
    RAC(self.passwdTextField, textColor) = fieldTextColor;

    
    RACSignal *notExecuting = [executing not];
    
    RAC(self.loginTextField, enabled) = notExecuting;
    RAC(self.passwdTextField, enabled) = notExecuting;
    RAC(self.getCodeButton, enabled) = notExecuting;
    RAC(self.renewPassButton, enabled) = notExecuting;



    [executing subscribeNext:^(NSNumber *x) {
        x.boolValue ?
        [self.loadingIndicator startAnimating]
       :[self.loadingIndicator stopAnimating];
    }];
    
  

    RAC(self.statusLabel, text) = [networkResults map:^id(RACEvent *x) {
          @strongify(self)
           return x.eventType == RACEventTypeError ?
        
                 [self messageForEffor:x.error]
                 : NSLocalizedString(@"Вход выполнен", nil);
    }];

    RACSignal *statusResultColor = [[networkResults replayLast]
                                    map:^id(RACEvent *x) {
        return x.eventType == RACEventTypeError
                            ? UIColor.redColor
                            : UIColor.greenColor;
    }];
    
    RAC(self.statusLabel, textColor) = [RACSignal
                                        if:executing
                                        then:[RACSignal return:UIColor.lightGrayColor]
                                        else:statusResultColor];


    
}
-(NSString *)messageForEffor:(NSError *)error{
    NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
    
    
    NSDictionary *serializedData = [NSJSONSerialization
                                    JSONObjectWithData:errorData
                                    options:kNilOptions
                                    error:nil];
    NSString *errorStr = [error.userInfo
                          valueForKey:NSLocalizedDescriptionKey];
    
    NSString *mesageStr = serializedData[@"Message"];
    
    if (mesageStr) {
        return mesageStr;
    }
    
    return errorStr;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.statusLabel.text = @"";
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = [segue destinationViewController];
    if([segue.identifier isEqualToString:@"getSMS"]){
         [(VerifyPhoneViewController *)vc setDelegate:self.delegate];
    }else if([segue.identifier isEqualToString:@"getPASS"]){
        [(VerifyCodeViewController *)vc setDelegate:self.delegate];
    }
}

@end
