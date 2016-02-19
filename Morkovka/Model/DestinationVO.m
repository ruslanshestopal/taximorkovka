
#import "DestinationVO.h"

@implementation DestinationVO


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userName": @"user_full_name",
             @"userPhone": @"user_phone",
             @"isReservation": @"reservation",
             @"requiredTime": @"required_time",
             @"userComment": @"comment",
             @"isMinibus": @"minibus",
             @"isWagon": @"wagon",
             @"isPremium": @"premium",
             @"isBaggage": @"baggage",
             @"isAnimal": @"animal",
             @"isConditioner": @"conditioner",
             @"isCourierDelivery": @"courier_delivery",
             @"isRouteUndefined": @"route_undefined",
             @"isTerminal": @"terminal",
             @"isReceipt": @"receipt",
             @"routePoints": @"route",
             @"fromEntrance": @"route_address_entrance_from",
             @"clientCard": @"client_sub_card",
             @"addCost": @"add_cost",
             @"taxiColumnId": @"taxiColumnId",
             @"paymentType": @"payment_type",
             @"orderCost": @"order_cost"
             };
}

- (instancetype) init {
    if (!(self = [super init]))
        return nil;
    if (self.routePoints == nil)
        self.routePoints = @[];
    if (self.extrasMask == nil)
        self.extrasMask = [NSNumber numberWithInteger:0];
    if (self.addCost == nil)
        self.addCost = [NSNumber numberWithInteger:0];
    if (self.requiredTime == nil)
        self.requiredTime = [NSDate date];
    if (self.userComment == nil)
        self.userComment = @"";
    
    
    return self;
}
- (instancetype) initWithDictionary:(NSDictionary *)dictionary
                              error:(NSError **)error {
    if (!(self = [super initWithDictionary:dictionary
                                     error:error]))
        return nil;
    if (self.routePoints == nil)
        self.routePoints = @[];
    if (self.extrasMask == nil)
        self.extrasMask = [NSNumber numberWithInteger:0];
    if (self.addCost == nil)
        self.addCost = [NSNumber numberWithInteger:0];
    if (self.requiredTime == nil)
        self.requiredTime = [NSDate date];
    return self;
}

-(BOOL)startingPointIsReady{
    return [self.routePoints count]>0;
}
-(BOOL)routeIsReady{
    return [self.routePoints count]>1;
}
- (BOOL) isMarkedAsSelecteAtIndex:(NSInteger)index{
    return (([self.extrasMask integerValue] & (1 << index)) >> index);
}
- (void) addRoutePoint:(RoutePoint *)point{
    self.routePoints = [self.routePoints arrayByAddingObject:point];
}
- (NSString*) extrasComponentsString{
    NSMutableArray *compAray = [NSMutableArray array];
    NSInteger value = [self.extrasMask integerValue];
    [[[self class] kExtrasTitles] eachWithIndex:^(id object, NSUInteger  index){
        if ((value & (1 << index)) >> index) {
            [compAray addObject:object];
        }
    }];
    NSString *str =[compAray componentsJoinedByString:@","];
    return str;
}
- (NSString *) dateComponentsString{
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
     return  [timeIntervalFormatter
                      stringForTimeInterval:
              [self.requiredTime timeIntervalSinceNow ]];

}
- (NSString *) costComponentsString{
    if (self.orderCost) {
            return NSStringWithFormat(@"%ld ₴",
                           (long)[self.orderCost integerValue]);
    }
    return @"бесплатно";
}
- (NSString *) tipComponentsString{
    NSString *str;
    NSInteger value = [self.addCost integerValue];
    if (value == 0 ) {
        str = @"Не добавлять";
    }else{
        str = NSStringWithFormat(@"%ld ₴ быстрее",value);
        if (value < 20) {
            str = NSStringWithFormat(@"%ld ₴ чаевые",value);
        }
        if (value ==100) {
            str = NSStringWithFormat(@"%ld ₴ драйвер",value);
        }
        if (value > 100) {
            str = NSStringWithFormat(@"%ld ₴ драйвер + быстрее",value);
        }
    }
    return  str;
}
- (void) addStartPointWithStreetAddress:(NSString *)street
                        andStreetNumber:(NSString *)number{
    RoutePoint *pt = [RoutePoint new];
    pt.name = street;
    pt.houseNum = number;

    if ([self.routePoints first]) {
        RoutePoint *old =[self.routePoints first];
        old.name = street;
        old.houseNum = number;
    }else{
        self.routePoints = [self.routePoints arrayByAddingObject:pt];
    }
}
+(UIImage *)imageForIndex:(NSInteger)index andCount:(NSInteger)count{
    UIImage *img = [UIImage imageNamed:@"point0"];
    if (index==0 && count>=3) {
        img  = [UIImage imageNamed:@"point3"];
    }else if (index>0 && index<count-2){
        img  = [UIImage imageNamed:@"point2"];
    }
    if (index>0 && index==count-2) {
        img  = [UIImage imageNamed:@"point1"];
    }
    return img;
}
+ (NSArray *)kExtrasTitles{
    static NSArray *_kExtrasTitles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kExtrasTitles = @[@"Чек",
                           @"Кондиционер",
                           @"Перевозка животного",
                           @"Загрузка салана",
                           @"Курьер",
                           @"Универсал",
                           @"Микроавтобус",
                           @"Комфорт",
                           @"Драйвер"
                           ];
    });
    return _kExtrasTitles;
}
- (void)triggerExtrasSelectionState:(BOOL)selected
                            atIndex:(NSInteger)index{
    NSInteger value = [self.extrasMask integerValue];
    value = (selected << index) | (value & ~(1 << index));
    self.extrasMask = [NSNumber numberWithInteger:value];
    self.isReceipt =  ((value & (1 << 0)) >> 0);
    self.isConditioner = ((value & (1 << 1)) >> 1);
    self.isAnimal = ((value & (1 << 2)) >> 2);
    self.isBaggage = ((value & (1 << 3)) >> 3);
    self.isCourierDelivery = ((value & (1 << 4)) >> 4);
    self.isWagon = ((value & (1 << 5)) >> 5);
    self.isMinibus = ((value & (1 << 6)) >> 6);
    self.isPremium = ((value & (1 << 7)) >> 7);
    BOOL isDriver = ((value & (1 << 8)) >> 8);
    if (isDriver && index == 8) {
        self.addCost = [NSNumber
            numberWithInteger:[self.addCost integerValue]+100];
        self.userComment = [self.userComment
                stringByAppendingString:@"[Услуга «Драйвер»] "];
    }
    if (!isDriver && index == 8) {
        self.userComment = [self.userComment
                stringByReplacingOccurrencesOfString:@"[Услуга «Драйвер»] "
                            withString:@""];
         self.addCost = [NSNumber
      numberWithInteger:MAX([self.addCost integerValue]-100, 0)];
    }
}
- (void) triggerTipsSelectionatIndex:(NSInteger)index{
    self.addCost = [NSNumber numberWithInteger:index*5];
    NSInteger value = [self.extrasMask integerValue];
    BOOL isDriver = ((value & (1 << 8)) >> 8);
    if (isDriver) {
        self.addCost = [NSNumber
        numberWithInteger:[self.addCost integerValue]+100];
    }
}
+ (NSValueTransformer *)routePointsJSONTransformer {
    return [MTLJSONAdapter
        arrayTransformerWithModelClass:[RoutePoint class]];
}

+ (NSValueTransformer *)requiredTimeJSONTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^(NSString *str, BOOL *success,
                                            NSError **error){
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date, BOOL *success, NSError **error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSDateFormatter *)dateFormatter {
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.locale =
        [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        dateFormatter.dateFormat = @"YYYY-MM-dd'T'HH:mm:ss'Z'";
    });
    return dateFormatter;
}

+ (NSValueTransformer *)isReservationJSONTransformer {
    return [NSValueTransformer
            valueTransformerForName:MTLBooleanValueTransformerName];
}
+ (NSValueTransformer *)isMinibusJSONTransformer {
    return [NSValueTransformer
            valueTransformerForName:MTLBooleanValueTransformerName];
}
+ (NSValueTransformer *)isWagonJSONTransformer {
    return [NSValueTransformer
            valueTransformerForName:MTLBooleanValueTransformerName];
}
+ (NSValueTransformer *)isPremiumJSONTransformer {
    return [NSValueTransformer
            valueTransformerForName:MTLBooleanValueTransformerName];
}
+ (NSValueTransformer *)isBaggageJSONTransformer {
    return [NSValueTransformer
            valueTransformerForName:MTLBooleanValueTransformerName];
}
+ (NSValueTransformer *)isAnimalJSONTransformer {
    return [NSValueTransformer
            valueTransformerForName:MTLBooleanValueTransformerName];
}
+ (NSValueTransformer *)isConditionerJSONTransformer {
    return [NSValueTransformer
            valueTransformerForName:MTLBooleanValueTransformerName];
}
+ (NSValueTransformer *)isCourierDeliveryJSONTransformer {
    return [NSValueTransformer
            valueTransformerForName:MTLBooleanValueTransformerName];
}
+ (NSValueTransformer *)isTerminalJSONTransformer {
    return [NSValueTransformer
            valueTransformerForName:MTLBooleanValueTransformerName];
}
+ (NSValueTransformer *)isReceiptJSONTransformer {
    return [NSValueTransformer
            valueTransformerForName:MTLBooleanValueTransformerName];
}

@end

@implementation RoutePoint
- (instancetype) init {
    if (!(self = [super init])) return nil;
    return self;
}
- (instancetype) initWithDictionary:(NSDictionary *)dictionary
                              error:(NSError **)error {
    if (!(self = [super initWithDictionary:dictionary error:error]))
        return nil;
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"houseNum": @"number"
             /*
             @"latitude": @"lat",
             @"longitude": @"lng"
              */
            };
    
    

}
/*
+ (NSValueTransformer *)coordinateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^(NSDictionary *coordinate, BOOL *success, NSError **error){
        CLLocationDegrees latitude = [coordinate[@"lat"] doubleValue];
        CLLocationDegrees longitude = [coordinate[@"lng"] doubleValue];
        return [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
    } reverseBlock:^(NSValue *coordinateValue, BOOL *success, NSError **error){
        CLLocationCoordinate2D coordinate = [coordinateValue MKCoordinateValue];
        return @{@"lat": @(coordinate.latitude), @"lng": @(coordinate.longitude)};
    }];
}

+ (NSValueTransformer * )coordinateJSONTransformer {

    return [MTLValueTransformer
                transformerUsingForwardBlock:^(NSDictionary *coordinate, BOOL *success, NSError **error) {
                    CLLocationCoordinate2D result = CLLocationCoordinate2DMake(
                                                                               [coordinate[@"lat"] doubleValue],
                                                                               [coordinate[@"lng"] doubleValue]
                                                                               );
                    
                return [NSValue valueWithMKCoordinate:result];
    }  reverseBlock:^(NSValue *coordinateValue, BOOL *success, NSError **error) {
        CLLocationCoordinate2D coordinate = [coordinateValue MKCoordinateValue];
        return @{@"lat": @(coordinate.latitude), @"lng": @(coordinate.longitude)};
    }];
    
}
*/

@end


@implementation RoutePrecalculation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"isBonusesPayed": @"can_pay_bonuses",
             @"currencyName": @"currency",
             @"isDiscountTrip": @"discount_trip",
             @"orderUID": @"dispatching_order_uid",
             @"orderCost": @"order_cost"
             };
    
}

- (NSString *) ordinaryPriceString{
    return NSStringWithFormat(@"%ld ₴", (long)[self.orderCost integerValue]);
}
- (NSString *) fastPriceString{
        return NSStringWithFormat(@"%ld ₴", (long)[self.orderCost integerValue]+20);
}


@end