#import "LoginFacilityMediator.h"
#import "IUserProfileView.h"
#import "MorkovkaServiceFacade.h"

@interface LoginFacilityMediator() <IUserProfileViewDelegate>
@property(nonatomic, strong) id<IUserProfileViewComponent> viewComponent;
@end


@implementation LoginFacilityMediator

@dynamic viewComponent;

-(void)onRegister {
    NSParameterAssert(self.viewComponent != nil);
    NSParameterAssert([self.viewComponent conformsToProtocol:(
                            @protocol(IUserProfileViewComponent))]);
    self.viewComponent.delegate = self;
}

-(void)onRemove {
    
}

- (RACSignal *) logginWithName:(NSString *)name andPassword:(NSString *)pass{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy logginWithName:name andPassword:pass];
}
- (RACSignal *) sendVerificationSMS:(NSDictionary *)params{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy sendVerificationSMS:params];
}

- (RACSignal *) registerWithUserNameAndCode:(NSDictionary *)params{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy registerWithUserNameAndCode:params];

}

- (RACSignal *) sendRestorationSMS:(NSDictionary *)params{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy sendRestorationSMS:params];
}
- (RACSignal *) checkConfirmCode:(NSDictionary *)params{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy checkConfirmCode:params];
}

- (RACSignal *) accountRestore:(NSDictionary *)params{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy accountRestore:params];
}



-(NSArray *)listNotificationInterests {
	return [NSArray new];
}

-(void)handleNotification:(id<INotification>)notification {

}

@end