
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
/*
 {
 "client_bonuses" = "<null>";
 discount =     {
 unit = "%";
 value = 5;
 };
 "orders_count" = 42;
 "payment_type" = 0;
 "route_address_apartment_from" = "<null>";
 "route_address_entrance_from" = "<null>";
 "route_address_from" = "\U0422 \U041e\U043f\U0435\U0440\U044b \U0438 \U0431\U0430\U043b\U0435\U0442\U0430  (\U0443\U043b.\U0412\U043b\U0430\U0434\U0438\U043c\U0438\U0440\U0441\U043a\U0430\U044f 50)";
 "route_address_number_from" = "<null>";
 "user_balance" = "-100";
 "user_first_name" = "\U0414\U043c\U0438\U0442\U0440\U0438\U0439";
 "user_last_name" = "";
 "user_login" = "093-816-33-36";
 "user_middle_name" = "";
 "user_phone" = "+380938163336";
 }
*/
