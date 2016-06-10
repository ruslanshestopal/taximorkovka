#import "IUserProfileView.h"
#import "MorkovkaServiceFacade.h"
#import "RunningOrdersMediator.h"
#import "RunningOrderVO.h"
#import <ObjectiveSugar/ObjectiveSugar.h>

@interface RunningOrdersMediator() <IUserProfileViewDelegate>
@property(nonatomic, strong) id<IUserProfileViewComponent> viewComponent;
@end

@implementation RunningOrdersMediator



@dynamic viewComponent;

-(void)onRegister {
    NSParameterAssert(self.viewComponent != nil);
    NSParameterAssert([self.viewComponent conformsToProtocol:(
                  @protocol(IUserProfileViewComponent))]);
    self.viewComponent.delegate = self;
}
-(void)onRemove {
    
}
- (NSArray *) showCurrentOrders{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];

    return [proxy.ordersArr reject:^BOOL(RunningOrderVO *order) {
        return (order.isCanceledByUser == YES);
    }];
}
- (void) cancelOrder:(RunningOrderVO *)order{
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    
    RunningOrderVO *orderObj = [proxy.ordersArr find:^BOOL(RunningOrderVO *obj) {
        return ([order.orderUID isEqualToString:obj.orderUID]);
    }];
    
    orderObj.isCanceledByUser = YES;
    
    if (orderObj) {
        if (!orderObj.isProcessed) {
            NSString *path = NSStringWithFormat(@"/api/weborders/cancel/%@", order.orderUID);
            [[proxy startPUTRequest:path withParams:nil] subscribeNext:^(id params) {
            }];
        }else{
            [proxy.ordersArr removeObject:orderObj];
        }
        
    }
    


}

-(RACSignal *)fetchDriverPosition:(RunningOrderVO *)order{

    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    NSString *path = NSStringWithFormat(@"/api/weborders/drivercarposition/%@", order.orderUID);
    return [proxy startPUTRequest:path withParams:nil];

}

-(NSArray *)listNotificationInterests {
    return @[onServiceDidFoundTaxi,
             onServiceDidNotFoundTaxi,
             onApplicationWillEnterForeground];
}

-(void)handleNotification:(id<INotification>)notification {
     if ([[notification name] isEqualToString:onServiceDidFoundTaxi] ||
         [[notification name] isEqualToString:onServiceDidNotFoundTaxi] ||
         [[notification name] isEqualToString:onApplicationWillEnterForeground] ) {
         if ([self.viewComponent respondsToSelector:@selector(onTaxiFound)]) {
             [self.viewComponent onTaxiFound];
         }
     }
  
}


@end