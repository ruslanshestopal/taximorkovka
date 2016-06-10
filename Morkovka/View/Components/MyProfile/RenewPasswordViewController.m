#import "RenewPasswordViewController.h"

@interface RenewPasswordViewController ()

@end

@implementation RenewPasswordViewController
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    @weakify(self);
    
    NSString *phoneStr = [[NSUserDefaults standardUserDefaults]
                          stringForKey:@"userPhone"];
    NSString *confirmStr = [[NSUserDefaults standardUserDefaults]
                          stringForKey:@"confirmCode"];
    
    RACSignal *formValid = [RACSignal
                            combineLatest:@[
                                            self.passwdATextField.rac_textSignal,
                                            self.passwdBTextField.rac_textSignal
                                            ]
                            reduce:^(NSString *password,
                                     NSString *password2) {
                                return @(
                                password.length >=7
                                && password2.length >=7
                                && [password isEqualToString:password2]
                                && phoneStr.length >0
                                && confirmStr.length >0
                                );
                            }];


    RACCommand *changePasswordCommand = [[RACCommand alloc]
                                     initWithEnabled:formValid
                                     signalBlock:^RACSignal *(id input) {
                                         @strongify(self)
                                         return [[self.delegate
                                                  accountRestore:@{@"phone":phoneStr,
                      @"confirm_code":confirmStr,
                      @"password":self.passwdATextField.text,
                       @"confirm_password":self.passwdBTextField.text
                      } ]
                                                 materialize];
                                     }];
    
    RACSignal *networkResults = [[changePasswordCommand.executionSignals flatten]
                                 deliverOn:[RACScheduler mainThreadScheduler]];
    
    
    self.changePassButton.rac_command = changePasswordCommand;
    
    UIColor *defaultButtonTitleColor = [UIColor colorWithRed:0.071
                                                       green:0.475
                                                        blue:0.996
                                                       alpha:1.000];
    
    RACSignal *buttonTextColor = [changePasswordCommand.enabled map:^id(NSNumber *x) {
        return x.boolValue ? defaultButtonTitleColor : [UIColor lightGrayColor];
    }];
    
    [self.changePassButton rac_liftSelector:@selector(setTitleColor:forState:)
                                withSignals:buttonTextColor,
     [RACSignal return:@(UIControlStateNormal)], nil];
    
    
    RACSignal *executing = changePasswordCommand.executing;
    
    RACSignal *fieldTextColor = [executing map:^id(NSNumber *x) {
        return x.boolValue ?
        [UIColor lightGrayColor]
        : [UIColor blackColor];
    }];
    
    RAC(self.passwdATextField, textColor) = fieldTextColor;
    RAC(self.passwdBTextField, textColor) = fieldTextColor;
    //
    
    RACSignal *notExecuting = [executing not];
    
    RAC(self.passwdATextField, enabled) = notExecuting;
    RAC(self.passwdBTextField, enabled) = notExecuting;

    
    [executing subscribeNext:^(NSNumber *x) {
        @strongify(self)
        x.boolValue ?
        [self.loadingIndicator startAnimating]
        :[self.loadingIndicator stopAnimating];
    }];
    RAC(self.statusLabel, text) = [networkResults map:^id(RACEvent *x) {
        return x.eventType == RACEventTypeError ?
        [self messageForEffor:x.error]
        : NSLocalizedString(@"Пароль изменен.", nil);
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
    NSString *errorStr = @"Неизвестная ошибка";
    if (errorId ==-3) {
        errorStr = NSLocalizedString(@"Не удалось найти пользователя с таким номером телефона.", nil);
    }else if (errorId ==-4){
        errorStr = NSLocalizedString(@"В системе более одного пользователя с таким номером телефона.", nil);
    }else if (errorId ==-5){
        errorStr = NSLocalizedString(@"Слишком много запросов за короткое время.", nil);
    }else if (errorId ==-31){
        errorStr = NSLocalizedString(@"Операция запрещена настройками «Такси Навигатор» ", nil);
    }
    return errorStr;
    
}
@end
