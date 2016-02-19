
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
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RoutePoint class]];
}
+ (NSValueTransformer *)addressFromJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RoutePoint class]];
}
+ (NSValueTransformer *)gpsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[DriverPosition class]];
}

/*
 {
 "dispatching_order_uid": "5088d3414944476586430510f08adf95",
 "discount_trip": false,
 "find_car_timeout": 720,
 "find_car_delay": 0,
 "order_cost": "101",
 "currency": " грн.",
 "route_address_from": {
 "name": "ЧИГОРИНА УЛ.",
 "number": "12",
 "lat": 50.4199295043945,
 "lng": 30.5379524230957
 },
 "route_address_to": {
 "name": "ПУШКИНСКАЯ УЛ.",
 "number": "21",
 "lat": 50.4438972473144,
 "lng": 30.5179347991943
 }
 }

 */
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
