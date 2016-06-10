#import "UserProfileMediator.h"
#import "IUserProfileView.h"
#import "MorkovkaServiceFacade.h"

@interface UserProfileMediator () <IUserProfileViewDelegate>
@property(nonatomic, strong) id<IUserProfileViewComponent> viewComponent;
@end


@implementation UserProfileMediator

@dynamic viewComponent;

-(void)onRegister {
    NSParameterAssert(self.viewComponent != nil);
    NSParameterAssert([self.viewComponent conformsToProtocol:(
                            @protocol(IUserProfileViewComponent))]);
    self.viewComponent.delegate = self;
}
-(void)onRemove {

}
- (void) loggOutUser{

    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
     [proxy loggOutUser];
}
- (RACSignal *) requestUserProfile{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy requestUserProfile];

}

- (RACSignal *) changeMyPassword:(NSDictionary *)params{
    
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy changeMyPassword:params];
}

- (RACSignal *) saveUserProfile:(NSDictionary *)params{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    return [proxy saveUserProfile:params];

}

-(NSArray *)listNotificationInterests {
	return [NSArray new];
}

@end