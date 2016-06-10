
#import "StartupCommand.h"
#import "ApplicationFacade.h"
#import "MenuNavigationSimpleCommand.h"
#import "MorkovkaServiceFacade.h"
#import "FavoritesProxy.h"


#import "LeftMenuMediator.h"
#import "SlidingViewMediator.h"
#import "OderTaxiMediator.h"
#import "UserProfileMediator.h"
#import "LoginFacilityMediator.h"
#import "OrderHistoryMediator.h"
#import "FavoritesMediator.h"
#import "RunningOrdersMediator.h"

#import "LeftSideMenuViewController.h"
#import "TaxiOrderViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "LoginScreenViewController.h"
#import "UserProfileUIViewController.h"
#import "OrderHistoryTableViewController.h"
#import "FavoritesTableViewController.h"
#import "RunningOrdersTableViewController.h"

static NSString *const MorkovkaKeychainServiceName = @"com.morkovka";

@implementation StartupCommand


-(void)execute:(id<INotification>)notification {

    ECSlidingViewController *vc = (ECSlidingViewController*) [notification body];



    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LeftSideMenuViewController *underLeftViewController  = [storyboard
                instantiateViewControllerWithIdentifier:@"LeftMenuStoryboardVC"];

    TaxiOrderViewController *topViewController = [storyboard
                 instantiateViewControllerWithIdentifier:@"TaxiOrderStoryboardVC"];
    
    UINavigationController *navigationController = [[UINavigationController alloc]
                                    initWithRootViewController:topViewController];
    
    vc.anchorLeftRevealAmount = 210.0;
    vc.anchorRightRevealAmount = 250.0;
    vc.topViewController = navigationController;
    vc.underLeftViewController  = underLeftViewController;

    [self.facade registerProxy:
     [CredentialsProxy
        proxyWithServiceName:MorkovkaKeychainServiceName]];
    
    
    
    [self.facade registerProxy:[MorkovkaServiceProxy proxy]];
    
    [self.facade registerProxy:[FavoritesProxy proxy]];
    
    [self.facade registerCommand:onMenuDidNavigateToSection
                 commandClassRef:[MenuNavigationSimpleCommand class]];
    
    [self.facade registerMediator:
     [SlidingViewMediator withViewComponent:vc]];
    
    [self.facade registerMediator:
     [OderTaxiMediator withViewComponent:topViewController]];
    
    [self.facade registerMediator:
     [LeftMenuMediator withViewComponent:underLeftViewController]];
    //
    LoginScreenViewController *loginVC =  [storyboard
            instantiateViewControllerWithIdentifier:@"LoginStoryboardVC"];
    
    UserProfileUIViewController *profileVC =  [storyboard
            instantiateViewControllerWithIdentifier:@"UserProfileStoryboardVC"];
    
    OrderHistoryTableViewController *historyVC =  [storyboard
            instantiateViewControllerWithIdentifier:@"OrderHistoryStoryboardVC"];

    
    FavoritesTableViewController *favoritesVC =  [storyboard
             instantiateViewControllerWithIdentifier:@"FavoritesStoryboardVC"];

    
    RunningOrdersTableViewController *ordersVC =  [storyboard
             instantiateViewControllerWithIdentifier:@"MyOrdersStoryboardVC"];
    
    [self.facade registerMediator:
        [LoginFacilityMediator withViewComponent:loginVC]];
    [self.facade registerMediator:
        [UserProfileMediator withViewComponent:profileVC]];

    [self.facade registerMediator:
        [OrderHistoryMediator withViewComponent:historyVC]];

    [self.facade registerMediator:
        [FavoritesMediator withViewComponent:favoritesVC]];

    [self.facade registerMediator:
        [RunningOrdersMediator withViewComponent:ordersVC]];
    

}
@end