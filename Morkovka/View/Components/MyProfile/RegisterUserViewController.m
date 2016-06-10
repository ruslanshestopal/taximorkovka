#import "RegisterUserViewController.h"

@interface RegisterUserViewController ()

@end

@implementation RegisterUserViewController

@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    
    NSString *phoneStr = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"userPhone"];
    
    RACSignal *formValid = [RACSignal
                     combineLatest:@[
                            self.nameTextField.rac_textSignal,
                            self.passwordTextField.rac_textSignal,
                            self.password2TextField.rac_textSignal,
                            self.codeTextField.rac_textSignal
                   ]
          reduce:^(NSString *name, NSString *password,
                   NSString *password2, NSString *code) {
              return @(
              name.length >= 2
              && password.length >=7
              && password2.length >=7
              && code.length ==4
              && [password isEqualToString:password2]
              && phoneStr.length >0
              );
          }];
    
    
    RACCommand *createAccountCommand = [[RACCommand alloc] initWithEnabled:formValid
                          signalBlock:^RACSignal *(id input) {
                              @strongify(self)
                              return [[self.delegate
                                       registerWithUserNameAndCode:@{
                                       @"phone":phoneStr,
                                       @"confirm_code":self.codeTextField.text,
                                       @"password":self.passwordTextField.text,
                                       @"confirm_password":self.password2TextField.text,
                                       @"user_first_name":self.nameTextField.text
                                       }]
                                      materialize];
                          }];
    RACSignal *networkResults = [[createAccountCommand.executionSignals flatten]
                                 deliverOn:[RACScheduler mainThreadScheduler]];

    

    
    self.registerButton.rac_command = createAccountCommand;
    UIColor *defaultButtonTitleColor = [UIColor colorWithRed:0.071
                                                       green:0.475
                                                        blue:0.996
                                                       alpha:1.000];

    RACSignal *buttonTextColor = [createAccountCommand.enabled map:^id(NSNumber *x) {
        return x.boolValue ? defaultButtonTitleColor : [UIColor lightGrayColor];
    }];
    
    [self.registerButton rac_liftSelector:@selector(setTitleColor:forState:)
                           withSignals:buttonTextColor,
     [RACSignal return:@(UIControlStateNormal)], nil];

    
    RACSignal *executing = createAccountCommand.executing;
    
    RACSignal *fieldTextColor = [executing map:^id(NSNumber *x) {
        return x.boolValue ?
        [UIColor lightGrayColor]
        : [UIColor blackColor];
    }];


    
    RAC(self.nameTextField, textColor) = fieldTextColor;
    RAC(self.passwordTextField, textColor) = fieldTextColor;
    RAC(self.password2TextField, textColor) = fieldTextColor;
    RAC(self.codeTextField, textColor) = fieldTextColor;
    
    RACSignal *notExecuting = [executing not];
    
    RAC(self.nameTextField, enabled) = notExecuting;
    RAC(self.passwordTextField, enabled) = notExecuting;
    RAC(self.password2TextField, enabled) = notExecuting;
    RAC(self.codeTextField, enabled) = notExecuting;
    
    [executing subscribeNext:^(NSNumber *x) {
        @strongify(self)
        x.boolValue ?
        
        [self.loadingIndicator startAnimating]
        :[self.loadingIndicator stopAnimating];
    }];
    
    
    RAC(self.statusLabel, text) = [networkResults map:^id(RACEvent *x) {
        @strongify(self)
        return x.eventType == RACEventTypeError ?
        [self messageForEffor:x.error]
        : NSLocalizedString(@"Регистрация прошла успешно", nil);
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
    NSInteger errorId = [serializedData[@"Id"] integerValue];
    NSString *errorStr = @"";
    if (errorId ==-31) {
        errorStr = NSLocalizedString(@"Регистрация запрещена настройками «Такси Навигатор».", nil);
    }else if (errorId ==-32){
        errorStr = NSLocalizedString(@"Пользователь с таким номером телефона уже зарегистрирован.", nil);
    }else if (errorId ==-34){
        errorStr = NSLocalizedString(@"Неверный формат номера телефона.", nil);
    }else if (errorId ==-35){
        errorStr = NSLocalizedString(@"Неверный код подтверждения.", nil);
    }else if (errorId ==-36){
        errorStr = NSLocalizedString(@"Не указан пароль, или пароль подтверждения не соответствует паролю.", nil);
    }
    return errorStr;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

@end
