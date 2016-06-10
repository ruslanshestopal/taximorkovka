
#import "RunningOrderVO.h"

@implementation RunningOrderVO

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"orderUID": @"dispatching_order_uid",
             @"currencyName": @"currency",
             @"isDiscountTrip": @"discount_trip",
             @"timeout": @"find_car_timeout",
             @"orderCost": @"order_cost",
             @"addressTo": @"route_address_to",
             @"addressFrom": @"route_address_from",
             @"gps" : @"drivercar_position"
             };
    
}
+ (NSValueTransformer *)addressToJSONTransformer {
    return [MTLJSONAdapter
            dictionaryTransformerWithModelClass:[RoutePoint class]];
}
+ (NSValueTransformer *)addressFromJSONTransformer {
    return [MTLJSONAdapter
            dictionaryTransformerWithModelClass:[RoutePoint class]];
}
+ (NSValueTransformer *)gpsJSONTransformer {
    return [MTLJSONAdapter
            dictionaryTransformerWithModelClass:[DriverPosition class]];
}
- (BOOL) isExpired{
    NSTimeInterval ti = [[NSDate date]
                         timeIntervalSinceDate:self.dispatchedAt];
    NSInteger minutes = (NSInteger) (ti / 60);
    return minutes>60;
}
- (BOOL) isProcessed{
    NSTimeInterval ti = [[NSDate date]
                         timeIntervalSinceDate:self.dispatchedAt];
    NSInteger minutes = (NSInteger) (ti / 60);
    return minutes>20 && self.isArchived;
}
@end

@implementation DriverPosition

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"time": @"time_positioned_utc",
             @"lat": @"lat",
             @"lng": @"lng",
             @"speed": @"speed",
             };
    
}
- (NSString *) dateComponentsString{
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    return  [timeIntervalFormatter
             stringForTimeInterval:
             [self.time timeIntervalSinceNow ]];
    
}
+ (NSValueTransformer *)timeJSONTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^(NSString *str, BOOL *success,
                                           NSError **error){
                return [ [DestinationVO dateFormatter] dateFromString:str];
            } reverseBlock:^(NSDate *date, BOOL *success, NSError **error) {
                return [ [DestinationVO dateFormatter] stringFromDate:date];
            }];
}

@end
