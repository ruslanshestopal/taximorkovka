#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DestinationVO.h"
#import "IRootViewComponent.h"
@interface KievOnMapViewController : UIViewController <MKMapViewDelegate,
                                                        IRootViewComponent>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) RoutePoint *point;
@property (nonatomic, assign) RoutePoint *selectedPoint;

@end
