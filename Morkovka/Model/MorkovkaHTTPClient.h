@interface MorkovkaHTTPClient : AFHTTPSessionManager

+(NSString *) SHA512StringFromString:(NSString*)input;
-(void) updateBasicAuthHeaderWith:(NSString*)name
                      andPassword:(NSString*)pass;

@end
