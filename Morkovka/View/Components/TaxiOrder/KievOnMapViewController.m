
#import "KievOnMapViewController.h"
#import "MapViewAnnotation.h"
#import "MKMapView+ZoomLevel.h"
@interface KievOnMapViewController ()

@end

@implementation KievOnMapViewController


@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    
    @weakify(self);
    [[_delegate curentLocationAdressForRadius:@"200"] subscribeNext:^(RACTuple *signalValues) {
        @strongify(self)
        
        NSDictionary *params = [signalValues last];
        NSDictionary *streetsDict =params[@"geo_streets"];
        NSArray *streets = streetsDict[@"geo_street"];

        if ([streets count]) {
            
        [streets each:^(NSDictionary *data) {
            NSArray *houses = data[@"houses"];
            [houses each:^(NSDictionary *house) {
               
                RoutePoint *point = [RoutePoint new];
                point.name = data[@"name"];
                point.houseNum = house[@"house"];
                point.isPOI = NO;
                CLLocationDegrees latitude = [house[@"lat"] doubleValue];
                CLLocationDegrees longitude = [house[@"lng"] doubleValue];

                MapViewAnnotation *annotation = [[MapViewAnnotation alloc]
                                                 initWithTitle:data[@"name"]
                                                 andSubtitle:house[@"house"]
                                                 AndCoordinate:CLLocationCoordinate2DMake(latitude,
                                                                                        longitude)];
                annotation.point = point;
                
                [self.mapView addAnnotation:annotation];

            }];
         }];
        }
        NSDictionary *objectsDict =params[@"geo_objects"];
        NSArray *geoObjects = objectsDict[@"geo_object"];
        
        if ([geoObjects count]) {
            [geoObjects each:^(NSDictionary *geo) {
                RoutePoint *point = [RoutePoint new];
                point.name = geo[@"name"];
                point.houseNum = @"";
                point.isPOI = YES;
                CLLocationDegrees latitude = [geo[@"lat"] doubleValue];
                CLLocationDegrees longitude = [geo[@"lng"] doubleValue];
               
                MapViewAnnotation *annotation = [[MapViewAnnotation alloc]
                                                 initWithTitle:geo[@"name"]
                                                 andSubtitle:geo[@"house"]
                                                 AndCoordinate:CLLocationCoordinate2DMake(latitude,
                                                                                          longitude)];
                annotation.point = point;
                
                [self.mapView addAnnotation:annotation];

            
            }];
        }
        
        CLLocation *location = [signalValues first];
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(location.coordinate.latitude,
           location.coordinate.longitude) zoomLevel:16 animated:YES];

    }
     error:^(NSError *error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView *alert = [[UIAlertView alloc]
                                       initWithTitle: NSLocalizedString(@"Ошибка",nil)
                                       message: @"Не удалось определить местоположение"
                                       delegate: nil
                                       cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                       otherButtonTitles: nil];
                 [alert show];
             });
             
         }];

    
}
- (MKAnnotationView *)mapView:(MKMapView *)mV
                            viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = nil;
    if (annotation != self.mapView.userLocation) {
        static NSString *defaultPinID = @"aPin";
        pinView = (MKPinAnnotationView *)[self.mapView
                                        dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if (pinView == nil){
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:defaultPinID];
        }
        RoutePoint *point = [(MapViewAnnotation*) annotation point];
        
        if (point.isPOI) {
            pinView.pinColor = MKPinAnnotationColorRed;
        }else{
            pinView.pinColor = MKPinAnnotationColorGreen;
        }
    }

    pinView.canShowCallout = YES;
    pinView.animatesDrop = YES;
    pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
    return pinView;
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
                                    calloutAccessoryControlTapped:(UIControl *)control{
    
   [mapView deselectAnnotation:view.annotation animated:YES];
    self.selectedPoint = [(MapViewAnnotation*)view.annotation point];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: NSLocalizedString(@"Вы находитесь по адресу?",nil)
                          message:self.selectedPoint.name
                          delegate: self
                          cancelButtonTitle: NSLocalizedString(@"Нет",nil)
                          otherButtonTitles: NSLocalizedString(@"Да",nil), nil];
    [alert show];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        if (buttonIndex == 0) {

        }else{
            DestinationVO *destination = [self.delegate requestDestinationData];
            if (self.point) {
                // We are editing start point
                RoutePoint *point = [destination.routePoints firstObject];
                point.name = self.selectedPoint.name;
                point.houseNum = self.selectedPoint.houseNum;
                point.isPOI = self.selectedPoint.isPOI;

            }else{
                RoutePoint *point = [RoutePoint new];
                point.name = self.selectedPoint.name;
                point.houseNum = self.selectedPoint.houseNum;
                point.isPOI = self.selectedPoint.isPOI;
                [destination addRoutePoint:point];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    
}

@end

