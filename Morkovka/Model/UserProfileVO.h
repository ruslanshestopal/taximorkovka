#import <Mantle/Mantle.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

@interface UserProfileVO : MTLModel<MTLJSONSerializing>
@property(nonatomic, copy) NSString *userName;
@property(nonatomic, copy) NSString *userLastName;
@property(nonatomic, copy) NSString *userPhone;
@property(nonatomic, copy) NSNumber *userBalance;
@property(nonatomic, copy) NSString *addressFrom;
@property(nonatomic, copy) NSString *addressNumber;
@property(nonatomic, copy) NSString *addressEntrance;
@property(nonatomic, copy) NSString *addressApartment;
@property(nonatomic, copy) NSNumber *userDiscount;


@end
