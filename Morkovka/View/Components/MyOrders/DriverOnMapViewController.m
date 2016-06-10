
#import "DriverOnMapViewController.h"
#import "MapViewAnnotation.h"
#import "MKMapView+ZoomLevel.h"

@interface DriverOnMapViewController ()

@end

@implementation DriverOnMapViewController
@synthesize delegate = _delegate;
- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.order != nil) {
        self.mapView.delegate = self;

        if (self.order.gps) {
            [self annotateMapWithDriverPosition:self.order.gps];
        }
    }
}

-(void)annotateMapWithDriverPosition:(DriverPosition *)gps{

    NSNumber *latitude = gps.lat;
    NSNumber *longitude = gps.lng;
    NSString *title = [gps dateComponentsString];
    NSString *sub = self.order.foundCar;
    
    CLLocationCoordinate2D coord;
    coord.latitude = latitude.doubleValue;
    coord.longitude = longitude.doubleValue;
    
    
    [self.mapView setCenterCoordinate:coord zoomLevel:15 animated:YES];
    
    
    MapViewAnnotation *annotation = [[MapViewAnnotation alloc]
                                     initWithTitle:title
                                    andSubtitle:sub
                                     AndCoordinate:coord];
    
    [self.mapView addAnnotation:annotation];


}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = nil;
    if (annotation != self.mapView.userLocation) {
        static NSString *defaultPinID = @"aPin";
        pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if (pinView == nil)
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    } else {
    }
    pinView.pinColor = MKPinAnnotationColorGreen;
    pinView.canShowCallout = YES;
    pinView.animatesDrop = YES;
    return pinView;
}
-(IBAction)updateDriverPosition:(UIButton*)sender{
     self.relocateButton.enabled = NO;
    @weakify(self);
    [[_delegate fetchDriverPosition:self.order] subscribeNext:^(NSDictionary *params) {
        @strongify(self)
        self.relocateButton.enabled = YES;
        if ([params isKindOfClass:[NSDictionary class]]) {
                NSLog(@"proceedWithTaxiOder %@", params);
            if (params[@"lat"] && params[@"lng"]) {
                NSError *error = nil;
                DriverPosition *pos= [MTLJSONAdapter modelOfClass:DriverPosition.class
                                             fromJSONDictionary:params
                                                          error:&error];
                [self annotateMapWithDriverPosition:pos];
            }
            }
        }
              error:^(NSError *error) {
           @strongify(self)
            self.relocateButton.enabled = YES;
           dispatch_async(dispatch_get_main_queue(), ^{
          
            UIAlertView *alert = [[UIAlertView alloc]
              initWithTitle: NSLocalizedString(@"Ошибка",nil)
              message:NSStringWithFormat(@"%@", [error.userInfo
                                                 valueForKey:NSLocalizedDescriptionKey])
              delegate: nil
              cancelButtonTitle: NSLocalizedString(@"OK",nil)
              otherButtonTitles: nil];
             [alert show];
                    });
        }];
}
@end
