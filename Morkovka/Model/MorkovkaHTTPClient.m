#import "MorkovkaHTTPClient.h"
#include <CommonCrypto/CommonDigest.h>

// Service host name.
static NSString *const MorkovkaAPIHostName = @"62.205.151.60:6969";
// Basic authentication credentials to access server.
static NSString *const MorkovkaBasicAuthUsername = @"guest";
static NSString *const MorkovkaBasicAuthPassword = @"guest";

@implementation MorkovkaHTTPClient

- (id) init {
    NSURL *baseURL =
    [NSURL URLWithString:
     [@"http://" stringByAppendingString:MorkovkaAPIHostName]];
    if (!(self = [super initWithBaseURL:baseURL])) return nil;

    AFJSONRequestSerializer *serializerRequest = [AFJSONRequestSerializer
                                                            serializer];
    [serializerRequest setValue:@"application/json"
             forHTTPHeaderField:@"Accept"];
    [serializerRequest setValue:@"application/json; charset=utf-8"
             forHTTPHeaderField:@"Content-Type"];


    
    self.requestSerializer = serializerRequest;
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    

    [self updateBasicAuthHeaderWith:MorkovkaBasicAuthUsername
                        andPassword:MorkovkaBasicAuthPassword];
    [self.requestSerializer setValue:@"Morkovaka-iOS"
                                    forHTTPHeaderField:@"X-WO-API-APP-ID"];
    
    return self;
}

-(void) updateBasicAuthHeaderWith:(NSString*)name andPassword:(NSString*)pass{
    NSString *passSHA512String =[[self class]
                                 SHA512StringFromString:pass];
    NSData *basicAuthCredentials = [[NSString stringWithFormat:@"%@:%@",
                                     name, passSHA512String]
                                    dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64AuthCredentials = [basicAuthCredentials
                                       base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", base64AuthCredentials]
                  forHTTPHeaderField:@"Authorization"];
}


+(NSString *) SHA512StringFromString:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes,(int) data.length, digest);
    NSMutableString* output = [NSMutableString
                    stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
