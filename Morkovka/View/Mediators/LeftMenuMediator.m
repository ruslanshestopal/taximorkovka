#import "LeftMenuMediator.h"

@interface LeftMenuMediator () <IRootViewDelegate>
@property(nonatomic, strong) id<IRootViewComponent> viewComponent;
@end




#pragma mark -
@implementation LeftMenuMediator

@dynamic viewComponent;

-(void)onRegister {
    NSParameterAssert(self.viewComponent != nil);
    NSParameterAssert([self.viewComponent
            conformsToProtocol:(@protocol(IRootViewComponent))]);
    self.viewComponent.delegate = self;
}
-(void)onRemove {

}

-(NSArray *)listNotificationInterests {
    return @[onOrderDidSuccessfullyPlaced];
}

-(void)handleNotification:(id<INotification>)notification {

	if ([[notification name] isEqualToString:onOrderDidSuccessfullyPlaced]) {
        if ([self.viewComponent respondsToSelector:@selector(onOderPlacement)]) {
            [self.viewComponent onOderPlacement];
        }

	}

}
- (void) viewComponentDidTriggeredMenuAtIndex:(NSIndexPath *)index{
    [self.facade sendNotification:onMenuDidNavigateToSection
                             body:index];
}



@end