#import "MorkovkaServiceFacade.h"
#import "MorkovkaHTTPClient.h"
#import <ReactiveCocoa.h>

@interface MorkovkaServiceProxy (Private)
@property(nonatomic, readonly, strong) MorkovkaHTTPClient *http;



- (RACSignal *) startLocationRequest:(NSString *)requestStr;
- (NSError *) invalidReplyErrorWithReason:(NSString *)reason;
- (NSError *) invalidLocationErrorWithReason:(NSString *)reason;
@end


