#import "VerifyCodeViewController.h"
#import "RenewPasswordViewController.h"

@interface VerifyCodeViewController ()

@end

@implementation VerifyCodeViewController
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    @weakify(self);

    NSString *phoneStr = [[NSUserDefaults standardUserDefaults]
                          stringForKey:@"userPhone"];
    
    RACSignal *formValid = [RACSignal
                            combineLatest:@[self.codeTextField.rac_textSignal]
                            reduce:^(NSString *code) {
                                return @(code.length == 4
                                        && phoneStr.length >0
                                );
                            }];
    




    RACCommand *verifyCodeCommand = [[RACCommand alloc]
                                  initWithEnabled:formValid
                                  signalBlock:^RACSignal *(id input) {
                                      @strongify(self)
                                      return [[self.delegate
                                               checkConfirmCode:@{@"phone":phoneStr,
                                                                  @"confirm_code":self.codeTextField.text} ]
                                              materialize];
                                  }];
    
    RACSignal *networkResults = [[verifyCodeCommand.executionSignals flatten]
                                 deliverOn:[RACScheduler mainThreadScheduler]];
    
    
    self.verifyCodeButton.rac_command = verifyCodeCommand;
    
    UIColor *defaultButtonTitleColor = [UIColor colorWithRed:0.071 green:0.475 blue:0.996 alpha:1.000];
    
    RACSignal *buttonTextColor = [verifyCodeCommand.enabled map:^id(NSNumber *x) {
        return x.boolValue ? defaultButtonTitleColor : [UIColor lightGrayColor];
    }];
    
    [self.verifyCodeButton rac_liftSelector:@selector(setTitleColor:forState:)
                             withSignals:buttonTextColor,
     [RACSignal return:@(UIControlStateNormal)], nil];
    
    
    RACSignal *executing = verifyCodeCommand.executing;
    
    RACSignal *fieldTextColor = [executing map:^id(NSNumber *x) {
        return x.boolValue ?
        [UIColor lightGrayColor]
        : [UIColor blackColor];
    }];
    
    RAC(self.codeTextField, textColor) = fieldTextColor;
    
    //
    
    RACSignal *notExecuting = [executing not];
    
    RAC(self.codeTextField, enabled) = notExecuting;
    RAC(self.changePassButton, enabled) = notExecuting;
    
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
    
    [verifyCodeCommand.executionSignals subscribeNext:^(RACSignal *execution) {
        [[execution dematerialize] subscribeNext:^(id value) {
            @strongify(self)
            [self performSegueWithIdentifier:@"updPASS" sender:self];
        }];
    }];
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"VerifyCodeViewController segue.identifier %@", segue.identifier);
    
    UIViewController *vc = [segue destinationViewController];
    if([segue.identifier isEqualToString:@"updPASS"]){
        [(RenewPasswordViewController *)vc setDelegate:self.delegate];
    }
}

-(NSString *)messageForEffor:(NSError *)error{
    NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
    
    
    NSDictionary *serializedData = [NSJSONSerialization
                                    JSONObjectWithData:errorData
                                    options:kNilOptions
                                    error:nil];
    NSInteger errorId = [serializedData[@"Id"] integerValue];
    NSString *errorStr = @"";
    if (errorId ==-35) {
        errorStr = NSLocalizedString(@"Неверный код подтверждения.", nil);
    }else if (errorId ==-34){
        errorStr = NSLocalizedString(@"Неверный формат номера телефона.", nil);
    }
    return errorStr;
    
}

@end
