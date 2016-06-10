#import "AppDelegate.h"
#import "Facade.h"
#import "ApplicationFacade.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application
                didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    Facade *facade = [Facade getInstance];
    [facade registerCommand:onAppStarted
            commandClassRef:[StartupCommand class]];
    [facade sendNotification:onAppStarted
                        body:self.window.rootViewController];
    [self.window makeKeyAndVisible]; 
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[Facade getInstance]
        sendNotification:onApplicationWillEnterForeground];
 
}

@end
