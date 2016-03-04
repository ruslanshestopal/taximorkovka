#import "UserProfileVO.h"

@implementation UserProfileVO

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userName": @"user_first_name",
             @"userLastName": @"user_last_name",
             @"userPhone": @"user_phone",
             @"userBalance": @"user_balance",
             @"addressFrom": @"route_address_from",
             @"addressNumber": @"route_address_number_from",
             @"addressEntrance": @"route_address_entrance_from",
             @"addressApartment": @"route_address_apartment_from",
             @"userDiscount": @"discount.value"
             };
    
}

@end
