#import "AppDelegate.h"
#import "Facade.h"
#import "ApplicationFacade.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Starting the application.
    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);

    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings
        settingsForTypes:UIUserNotificationTypeAlert|
                        UIUserNotificationTypeBadge|
            UIUserNotificationTypeSound categories:nil]];
    }
    Facade *facade = [Facade getInstance];
    [facade registerCommand:onAppStarted commandClassRef:[StartupCommand class]];
    [facade sendNotification:onAppStarted body:self.window.rootViewController];
    [self.window makeKeyAndVisible]; 
    return YES;
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([notification.alertBody isEqualToString:@"Application is timeout!"])
    {
        // show an alert regarding your notification
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
 
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
 
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
 
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
 
}

- (void)applicationWillTerminate:(UIApplication *)application {
 
}

@end
