#import <Mantle/Mantle.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import "TTTTimeIntervalFormatter.h"

@class RoutePrecalculation;
@class RoutePoint;
@interface DestinationVO : MTLModel <MTLJSONSerializing>

@property(nonatomic, copy) NSString *userName; //Полное имя пользователя
@property(nonatomic, copy) NSString *userPhone; //Телефон пользователя
@property(nonatomic) BOOL isReservation; //Признак предварительного заказа
@property(nonatomic, copy) NSDate *requiredTime;
@property(nonatomic, copy) NSString *userComment; //Комментарий к заказу

@property(nonatomic) BOOL isMinibus; //Микроавтобус
@property(nonatomic) BOOL isWagon; //Универсал
@property(nonatomic) BOOL isPremium; //Машина премиум-класса
@property(nonatomic) BOOL isBaggage; //Загрузка салона
@property(nonatomic) BOOL isAnimal; //Перевозка животного
@property(nonatomic) BOOL isConditioner; //Кондиционер
@property(nonatomic) BOOL isCourierDelivery; //Курьер
@property(nonatomic) BOOL isRouteUndefined; //По городу
@property(nonatomic) BOOL isTerminal; //Терминал
@property(nonatomic) BOOL isReceipt; //Требование чека за поездку
@property(nonatomic, copy) NSArray *routePoints;


@property(nonatomic, copy) NSString *fromEntrance; //Номер подъезда
@property(nonatomic, copy) NSString *clientCard; //Номер доп карточки
@property(nonatomic, strong) NSNumber *addCost; //Дополнительная стоимость к заказу
@property(nonatomic, copy) NSNumber *orderCost;
@property(nonatomic) NSInteger taxiColumnId; //Номер колоны, в которую будут приходить заказы
@property(nonatomic) NSInteger paymentType; //Тип оплаты заказа (нал, безнал) (см. Приложение 4)

@property(nonatomic, strong) NSNumber *extrasMask;
@property(nonatomic, strong) RoutePrecalculation *preCheck;

- (BOOL) startingPointIsReady;
- (BOOL) routeIsReady;
- (BOOL) isMarkedAsSelecteAtIndex:(NSInteger)index;
- (void) addRoutePoint:(RoutePoint *)point;
- (NSString *) extrasComponentsString;
- (NSString *) dateComponentsString;
- (NSString *) costComponentsString;
- (NSString *) tipComponentsString;
- (void) triggerExtrasSelectionState:(BOOL)selected
                             atIndex:(NSInteger)index;
- (void) triggerTipsSelectionatIndex:(NSInteger)index;
- (void) addStartPointWithStreetAddress:(NSString *)street
                        andStreetNumber:(NSString *)number;
+ (NSDateFormatter *)dateFormatter;
+ (UIImage *)imageForIndex:(NSInteger)index andCount:(NSInteger)count;
@end

@interface RoutePoint : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *houseNum;
@property (nonatomic ) BOOL isPOI;
@property(nonatomic, copy) NSNumber *latitude;
@property(nonatomic, copy) NSNumber *longitude;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@end

@interface RoutePrecalculation : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSString *currencyName;
@property (nonatomic, strong) NSString *orderUID;
@property (nonatomic, strong) NSString *orderCost;
@property (nonatomic) BOOL isDiscountTrip;
@property (nonatomic) BOOL isBonusesPayed;

- (NSString *) ordinaryPriceString;
- (NSString *) fastPriceString;

@end

