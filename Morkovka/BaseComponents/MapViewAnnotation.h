#import "DestinationVO.h"
@interface MapViewAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) RoutePoint *point;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithTitle:(NSString *) title
        andSubtitle:(NSString *)sub
      AndCoordinate:(CLLocationCoordinate2D)coordinate;

@end