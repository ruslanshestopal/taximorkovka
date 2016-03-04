#import "TTTTimeIntervalFormatter.h"
#import "DestinationVO.h"

@class DriverPosition;

@interface RunningOrderVO : MTLModel <MTLJSONSerializing>
@property(nonatomic, copy) NSString *orderUID;
@property(nonatomic, copy) NSString *currencyName;
@property(nonatomic) BOOL isDiscountTrip;
@property(nonatomic) BOOL isArchived;
@property(nonatomic, copy) NSNumber *timeout;
@property(nonatomic, copy) NSString *orderCost;
@property(nonatomic, copy) NSString *foundCar;
@property(nonatomic, copy) NSString *driverPhone;
@property(nonatomic, copy) RoutePoint *addressFrom;
@property(nonatomic, copy) RoutePoint *addressTo;
@property(nonatomic, copy) DriverPosition *gps;
@property(nonatomic) BOOL isCanceledByUser;
@property(nonatomic, strong) NSDate *dispatchedAt;

- (BOOL) isExpired;
- (BOOL) isProcessed;

@end

@interface DriverPosition : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lng;
@property (nonatomic, copy) NSDate *time;
@property (nonatomic, copy) NSNumber *speed;

- (NSString *) dateComponentsString;
@end

