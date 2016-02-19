#import <Mantle/Mantle.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import "TTTTimeIntervalFormatter.h"
#import <Foundation/Foundation.h>
#import "DestinationVO.h"

@class DriverPosition;

@interface RunningOrderVO : MTLModel <MTLJSONSerializing>
@property(nonatomic, copy) NSString *orderUID;
@property(nonatomic, copy) NSString *currencyName;
@property(nonatomic) BOOL isDiscountTrip;
@property(nonatomic, copy) NSNumber *timeout;
@property(nonatomic, copy) NSString *orderCost;
@property(nonatomic, copy) NSString *foundCar;
@property(nonatomic, copy) NSString *driverPhone;
@property(nonatomic, copy) RoutePoint *addressFrom;
@property(nonatomic, copy) RoutePoint *addressTo;
@property(nonatomic, copy) DriverPosition *gps;
@property(nonatomic) BOOL isCanceledByUser;

@end

@interface DriverPosition : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lng;
@property (nonatomic, copy) NSDate *time;
@property (nonatomic, copy) NSNumber *speed;

- (NSString *) dateComponentsString;
@end

/*
 "drivercar_position": {
 "lat": 50.419977,
 "lng": 30.537664,
 "time_positioned_utc": "2016-02-12T15:53:50.603",
 "altitude": 218,
 "accuracy": 13,
 "bearing": null,
 "speed": 0,
 "status": "gpsOk"
 },
 */

