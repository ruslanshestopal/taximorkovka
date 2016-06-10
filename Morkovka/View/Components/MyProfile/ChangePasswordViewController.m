
#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController
@synthesize delegate = _delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    
    RACSignal *formValid = [RACSignal
                            combineLatest:@[self.passwdOldTextField.rac_textSignal,
                                            self.passwdATextField.rac_textSignal,
                                            self.passwdBTextField.rac_textSignal
                                            
                                            ]
                            reduce:^(NSString *oldPass, NSString *aPass, NSString *bPass) {
                                return @(oldPass.length >= 7
                                && aPass.length >=7
                                && [aPass isEqualToString:bPass]
                                );
                            }];
   
    
    RACCommand *verifyCodeCommand = [[RACCommand alloc]
                                     initWithEnabled:formValid
                                     signalBlock:^RACSignal *(id input) {
                                         @strongify(self)
                                         return [[self.delegate
                                                  changeMyPassword:@{@"oldPassword": self.passwdOldTextField.text,
                                                                     @"newPassword": self.passwdATextField.text,
                                                                     @"repeatNewPassword": self.passwdBTextField.text
                                                                     }
                                                  
                                                  ]
                                                 materialize];
                                     }];
    
    RACSignal *networkResults = [[verifyCodeCommand.executionSignals flatten]
                                 deliverOn:[RACScheduler mainThreadScheduler]];
    
    
    self.updatePassButton.rac_command = verifyCodeCommand;
    
    UIColor *defaultButtonTitleColor = [UIColor colorWithRed:0.071
                                                       green:0.475
                                                        blue:0.996
                                                       alpha:1.000];
    
    RACSignal *buttonTextColor = [verifyCodeCommand.enabled map:^id(NSNumber *x) {
        return x.boolValue ? defaultButtonTitleColor : [UIColor lightGrayColor];
    }];
    
    [self.updatePassButton rac_liftSelector:@selector(setTitleColor:forState:)
                                withSignals:buttonTextColor,
     [RACSignal return:@(UIControlStateNormal)], nil];
    
    
    RACSignal *executing = verifyCodeCommand.executing;
    
    RACSignal *fieldTextColor = [executing map:^id(NSNumber *x) {
        return x.boolValue ?
        [UIColor lightGrayColor]
        : [UIColor blackColor];
    }];
    
    RAC(self.passwdOldTextField, textColor) = fieldTextColor;
    RAC(self.passwdATextField, textColor) = fieldTextColor;
    RAC(self.passwdBTextField, textColor) = fieldTextColor;
    //
    
    RACSignal *notExecuting = [executing not];
    
    RAC(self.passwdOldTextField, enabled) = notExecuting;
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
        : NSLocalizedString(@"Код успешно проверен.", nil);
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
    }
    return errorStr;
    
}

@end
