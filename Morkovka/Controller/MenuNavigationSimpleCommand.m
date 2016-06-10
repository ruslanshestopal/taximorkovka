#import "MenuNavigationSimpleCommand.h"
#import "MorkovkaServiceFacade.h"
#import "SlidingViewMediator.h"
#import "OderTaxiMediator.h"
#import "UserProfileMediator.h"
#import "LoginFacilityMediator.h"
#import "UIViewController+ECSlidingViewController.h"
#import "TaxiOrderViewController.h"
#import "TariffViewController.h"
#import "AboutUsViewController.h"
#import "LoginScreenViewController.h"
#import "UserProfileUIViewController.h"
#import "OrderHistoryTableViewController.h"
#import "OrderHistoryMediator.h"
#import "FavoritesTableViewController.h"
#import "FavoritesMediator.h"
#import "RunningOrdersTableViewController.h"
#import "RunningOrdersMediator.h"

@implementation MenuNavigationSimpleCommand


-(void)execute:(id<INotification>)notification {

    NSIndexPath *index = [notification body];
    
    
    SlidingViewMediator *mediator = [self.facade retrieveMediator:[SlidingViewMediator name]];
    ECSlidingViewController *vc = (ECSlidingViewController*)[mediator viewComponent];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *topVC;
    
    CredentialsProxy *credentials = [self.facade
                                     retrieveProxy:[CredentialsProxy name]];
    MorkovkaServiceProxy *proxy = [self.facade
                                   retrieveProxy:[MorkovkaServiceProxy name]];
    BOOL isPostAuthEvent = [[notification type]
                            isEqualToString:MorkovkaServicePostAuthEvent];
    proxy.menuPath = index;

    if (index.row==0) {
       
        OderTaxiMediator *taxiMediator = [self.facade
                                retrieveMediator:[OderTaxiMediator name]];
        topVC = (TaxiOrderViewController*)[taxiMediator viewComponent];
        vc.topViewController = topVC.navigationController;
        [vc resetTopViewAnimated:YES];
            return;

    }else if (index.row==1){
        LoginFacilityMediator *ordersMediator = [self.facade
                                retrieveMediator:[RunningOrdersMediator name]];
        topVC = (RunningOrdersTableViewController*)[ordersMediator viewComponent];
        
    }else if (index.row==2){
        if (credentials.credentialsAreValid || isPostAuthEvent) {
            OrderHistoryMediator *historyMediator = [self.facade
                                     retrieveMediator:[OrderHistoryMediator name]];
            topVC = (OrderHistoryTableViewController*)[historyMediator viewComponent];
        }else{
            LoginFacilityMediator *loginMediator = [self.facade
                                retrieveMediator:[LoginFacilityMediator name]];
            topVC = (LoginScreenViewController*)[loginMediator viewComponent];
        }
    }else if (index.row==3){
        // Favorites
        FavoritesMediator *favMediator = [self.facade
                                                retrieveMediator:[FavoritesMediator name]];
        topVC = (FavoritesTableViewController*)[favMediator viewComponent];
        
    }else if (index.row==4){
        topVC  = (TariffViewController*)[storyboard
                           instantiateViewControllerWithIdentifier:@"TariffStoryboardVC"];
        
    }else if (index.row==5){
        //
        topVC  = (AboutUsViewController*)[storyboard
                            instantiateViewControllerWithIdentifier:@"AboutStoryboardVC"];

    }else if (index.row==100){
        if (credentials.credentialsAreValid || isPostAuthEvent) {
            UserProfileMediator *profileMediator = [self.facade
                                    retrieveMediator:[UserProfileMediator name]];
            topVC = (UserProfileUIViewController*)[profileMediator viewComponent];

        }else{
            LoginFacilityMediator *loginMediator = [self.facade
                                  retrieveMediator:[LoginFacilityMediator name]];
            topVC = (LoginScreenViewController*)[loginMediator viewComponent];
        }
    }

    if (topVC!=nil) {
        vc.topViewController = [[UINavigationController alloc]
                                    initWithRootViewController:topVC];
        [vc resetTopViewAnimated:YES];

    }
   
}
@end