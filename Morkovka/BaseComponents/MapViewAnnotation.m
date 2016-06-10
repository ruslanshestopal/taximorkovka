#import "MapViewAnnotation.h"

@implementation MapViewAnnotation
-(id) initWithTitle:(NSString *) title andSubtitle:(NSString *)sub
      AndCoordinate:(CLLocationCoordinate2D)coordinate

{
    
    self = [super init];
    
    _title = title;
    _subtitle = sub;
    _coordinate = coordinate;
    
    return self;
    
}
@end



