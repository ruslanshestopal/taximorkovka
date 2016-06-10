#import "IUserProfileView.h"
#import "MorkovkaServiceFacade.h"
#import "OrderHistoryMediator.h"

@interface OrderHistoryMediator() <IUserProfileViewDelegate>
@property(nonatomic, strong) id<IUserProfileViewComponent> viewComponent;
@end


@implementation OrderHistoryMediator

@dynamic viewComponent;

-(void)onRegister {
    NSParameterAssert(self.viewComponent != nil);
    NSParameterAssert([self.viewComponent conformsToProtocol:(
                        @protocol(IUserProfileViewComponent))]);
    self.viewComponent.delegate = self;
}
-(void)onRemove {
    
}
- (RACSignal *) showOrdersHistory{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
     return [proxy requestOrdersHistory];
}
- (void) repeatOrderAtIndex:(NSInteger)index{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    DestinationVO *destenation = [proxy.historyArr objectAtIndex:index];

    proxy.destination.preCheck = nil;
    proxy.destination.routePoints = [destenation.routePoints copy];
    proxy.destination.requiredTime = [NSDate date];

    [self.facade sendNotification:onMenuDidNavigateToSection
                             body:[NSIndexPath indexPathForRow:0 inSection:0]];

}

-(NSArray *)listNotificationInterests {
    return [NSArray new];
}

@end