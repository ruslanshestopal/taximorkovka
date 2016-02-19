#import "CredentialsProxy.h"
#import <SSKeychain.h>

static NSString *const CredentialsProxyValidCredentialsKey =
                                    @"CredentialsProxyValidCredentialsKey";

@interface CredentialsProxy ()
@property(nonatomic, copy) NSString *serviceName;
@end


#pragma mark -
@implementation CredentialsProxy
+ (instancetype) proxyWithServiceName:(NSString *)serviceName {
    return [[self alloc] initWithProxyName:nil serviceName:serviceName];
}

+ (instancetype) withProxyName:(NSString *)name serviceName:(NSString *)sname {
    return [[self alloc] initWithProxyName:name serviceName:sname];
}

- (id) initWithProxyName:(NSString *)name serviceName:(NSString *)serviceName {
    NSParameterAssert(serviceName != nil);
    
    if (!(self = [super initWithProxyName:name data:nil])) return nil;
    self.serviceName = serviceName;
    return self;
}

- (void) onRegister {
    NSAssert(self.serviceName != nil, @"Service name is not set");
    
    NSArray *accounts = [SSKeychain accountsForService:self.serviceName];
    if (accounts.count > 0) {
        _username = accounts[0][kSSKeychainAccountKey];
        _credentialsAreValid =
            [[NSUserDefaults standardUserDefaults]
                    boolForKey:CredentialsProxyValidCredentialsKey];
    }
}

- (BOOL) hasCredentials {
    return self.username != nil;
}

- (void) setUsername:(NSString *)username {
    if (username.length == 0) return;
    
    if (![_username isEqualToString:username]) {
        self.credentialsAreValid = NO;
    }
    
    NSString *password = self.password;
    [SSKeychain deletePasswordForService:self.serviceName account:_username];
    [SSKeychain setPassword:(password ?: @"") forService:self.serviceName
                    account:username];
    _username = username;
}

- (NSString *) password {
    if (self.username == nil) return nil;
    
    NSString *password = [SSKeychain passwordForService:self.serviceName
                                                account:self.username];
    return (password.length > 0) ? password : nil;
}

- (void) setPassword:(NSString *)password {
    if (password.length == 0 || self.username == nil) return;
    
    if (![self.password isEqualToString:password]) {
        self.credentialsAreValid = NO;
    }
    [SSKeychain setPassword:password forService:self.serviceName
                    account:self.username];
}

- (void) clearCredentials {
    [SSKeychain deletePasswordForService:self.serviceName account:_username];
    _username = nil;
    self.credentialsAreValid = NO;
}

- (void) setCredentialsAreValid:(BOOL)credentialsAreValid {
    _credentialsAreValid = credentialsAreValid;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:credentialsAreValid
               forKey:CredentialsProxyValidCredentialsKey];
    [defaults synchronize];
}
@end
