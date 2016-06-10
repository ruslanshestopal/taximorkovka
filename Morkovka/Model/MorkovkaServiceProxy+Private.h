#import "MorkovkaServiceFacade.h"
#import "MorkovkaHTTPClient.h"

@interface MorkovkaServiceProxy (Private)

@property(nonatomic, readonly, strong) MorkovkaHTTPClient *http;

- (NSError *) invalidReplyErrorWithReason:(NSString *)reason;
- (NSError *) invalidLocationErrorWithReason:(NSString *)reason;

@end


