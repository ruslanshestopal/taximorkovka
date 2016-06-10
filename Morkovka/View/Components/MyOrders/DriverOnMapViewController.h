#import "IUserProfileView.h"
#import "RunningOrderVO.h"
@interface DriverOnMapViewController : UIViewController<MKMapViewDelegate, IUserProfileViewComponent>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *relocateButton;
@property (nonatomic, assign) RunningOrderVO *order;
@end
