#import "Proxy.h"
#import <ReactiveCocoa.h>
#import "DestinationVO.h"
#import "UserProfileVO.h"
#import "RunningOrderVO.h"
#import "CredentialsProxy.h"

/// Morkovka service error domain.
extern NSString *const MorkovkaServiceErrorDomain;
extern NSString *const MorkovkaServicePostAuthEvent;

/// Service error codes.
typedef NS_ENUM (NSInteger, MorkovkaServiceErrorCodes) {
    /// Not authorized.
    kMorkovkaServiceNotAuthorized = 401,
    /// Invalid username or password.
    kMorkovkaServiceInvalidCredentials = 403,
    /// Invalid server response format error code.
    kMorkovkaServiceInvalidResponseFormat = 406,
    /// Location failed.
    kMorkovkaServiceLocationFailed = 402,
};


#pragma mark -
@interface MorkovkaServiceProxy : Proxy


@property(nonatomic, strong) DestinationVO *destination;
@property(nonatomic, copy) UserProfileVO *userProfile;
@property(nonatomic, strong) RACSignal *loginSignal;
@property(nonatomic, assign) NSIndexPath *menuPath;
@property(nonatomic, copy) NSArray *historyArr;
@property(nonatomic, strong) NSMutableArray *ordersArr;
@property(nonatomic, copy) NSArray *streets;

- (RACSignal *) startJSONRequest:(NSString *)requestStr;
- (RACSignal *) startPOSTRequest:(NSString *)requestPath
                      withParams:(NSDictionary *)params;
- (RACSignal *) startPUTRequest:(NSString *)requestPath;
- (RACSignal *) search:(NSString *)text;
- (RACSignal *) searchForStreet:(NSString *)street;
- (RACSignal *) logginWithName:(NSString *)name
                   andPassword:(NSString *)pass;
- (RACSignal *) requestUserProfile;
- (RACSignal *) registerWithPhone:(NSDictionary *)params;
- (RACSignal *) registerWithUserNameAndCode:(NSDictionary *)params;
- (void) loggOutUser;
- (RACSignal *) curentLocationAdressForRadius:(NSString *)rad;
- (RACSignal *) requestOrdersHistory;
- (RACSignal *) fetchTaxi;
@end

