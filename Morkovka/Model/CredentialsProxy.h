
#import "Proxy.h"

/**
 The credential storage proxy.
 */
@interface CredentialsProxy : Proxy
/// A Boolean indicating that both username and password are available.
@property(nonatomic, readonly) BOOL hasCredentials;
@property(nonatomic) BOOL credentialsAreValid;
/// The username or nil.
@property(nonatomic, copy) NSString *username;
/// The password or nil.
@property(nonatomic, copy) NSString *password;


// Constructors.
+ (instancetype) proxyWithServiceName:(NSString *)serviceName;
+ (instancetype) withProxyName:(NSString *)name serviceName:(NSString *)sname;
/// Clears the credentials.
- (void) clearCredentials;


// Deprecations.
+ (instancetype) proxy __attribute__((
    unavailable("use -[CredentialsProxy proxyWithServiceName:] instead")));
+ (instancetype) withProxyName:(NSString *)proxyName __attribute__((
    unavailable("use -[CredentialsProxy withProxyName:serviceName:] instead")));
+ (instancetype) withProxyName:(NSString *)proxyName data:(id)data
    __attribute__((unavailable));
+ (instancetype) withData:(id)data __attribute__((unavailable));
@end
