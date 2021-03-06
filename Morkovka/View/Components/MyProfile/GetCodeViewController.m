
#import "GetCodeViewController.h"
#import "VerifyCodeViewController.h"

@interface GetCodeViewController ()

@end

@implementation GetCodeViewController
@synthesize delegate = _delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
     @weakify(self);

    self.phoneTextField.text = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"userPhone"];
    
    RACSignal *formValid = [RACSignal
                            combineLatest:@[self.phoneTextField.rac_textSignal]
                            reduce:^(NSString *phone) {
                                return @([[NSPredicate
                                           predicateWithFormat:@"SELF MATCHES %@", @"^\\+?[0-9]{10,12}$"]
                                          evaluateWithObject:phone]);
                            }];
    
    
    RACCommand *getCodeCommand = [[RACCommand alloc]
                                      initWithEnabled:formValid
                                      signalBlock:^RACSignal *(id input) {
                                          @strongify(self)
                                          return [[self.delegate
                                                   sendRestorationSMS:@{@"phone":self.phoneTextField.text} ]
                                                  materialize];
                                      }];
    
    RACSignal *networkResults = [[getCodeCommand.executionSignals flatten]
                                 deliverOn:[RACScheduler mainThreadScheduler]];
    
    
    self.getCodeButton.rac_command = getCodeCommand;
    
    UIColor *defaultButtonTitleColor = [UIColor colorWithRed:0.071 green:0.475 blue:0.996 alpha:1.000];
    
    RACSignal *buttonTextColor = [getCodeCommand.enabled map:^id(NSNumber *x) {
        return x.boolValue ? defaultButtonTitleColor : [UIColor lightGrayColor];
    }];
    
    [self.getCodeButton rac_liftSelector:@selector(setTitleColor:forState:)
                             withSignals:buttonTextColor,
     [RACSignal return:@(UIControlStateNormal)], nil];
    
    
    RACSignal *executing = getCodeCommand.executing;
    
    RACSignal *fieldTextColor = [executing map:^id(NSNumber *x) {
        return x.boolValue ?
        [UIColor lightGrayColor]
        : [UIColor blackColor];
    }];
    
    RAC(self.phoneTextField, textColor) = fieldTextColor;

    
    
    RACSignal *notExecuting = [executing not];
    
    RAC(self.phoneTextField, enabled) = notExecuting;
    RAC(self.verifyCodeButton, enabled) = notExecuting;
    
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
        : NSLocalizedString(@"Вам отправлено сообщение (SMS) с кодом.", nil);
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
    
    [getCodeCommand.executionSignals subscribeNext:^(RACSignal *execution) {
        [[execution dematerialize] subscribeNext:^(id value) {
            @strongify(self)
            [self performSegueWithIdentifier:@"verifyCODE" sender:self];
        }];
    }];
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UIViewController *vc = [segue destinationViewController];
    if([segue.identifier isEqualToString:@"verifyCODE"]){
          [(VerifyCodeViewController *)vc setDelegate:self.delegate];
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
    if (errorId ==-31) {
        errorStr = NSLocalizedString(@"Операция запрещена настройками «Такси Навигатор»", nil);
    }else if (errorId ==-3){
        errorStr = NSLocalizedString(@"Не удалось найти пользователя с таким номером телефона.", nil);
    }else if (errorId ==-4){
        errorStr = NSLocalizedString(@"В системе более одного пользователя с таким номером телефона.", nil);
    }else if (errorId ==-5){
        errorStr = NSLocalizedString(@"Слишком много запросов за короткое время.", nil);
    }else if (errorId ==-34){
        errorStr = NSLocalizedString(@"Неверный формат номера телефона.", nil);
    }
    return errorStr;
    
}
@end
