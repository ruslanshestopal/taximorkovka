#import "AddRoutePointTableViewController.h"
#import "UITableView+VMStaticCells.h"
#import "KievOnMapViewController.h"
#import "HousesTableViewController.h"
#import "ListFavoritesTableViewController.h"


@interface AddRoutePointTableViewController ()

@property(nonatomic,weak) UITextField * streetField;
@property(nonatomic,weak) UITextField * houseField;
@property(nonatomic,weak) UITextField * entranceField;
@property(nonatomic,weak) UITextField * commentField;
@property(nonatomic,weak) UIButton *confirmButton;
@property(nonatomic, strong) UIView *overlayView;
@property(nonatomic,strong) UITableViewCell *headerCell;
@property(nonatomic,strong) NSArray *streets;
@end

@implementation AddRoutePointTableViewController
@synthesize delegate = _delegate;
- (void)viewDidLoad {
    [super viewDidLoad];

    self.destination = [self.delegate requestDestinationData];
    
    self.streets = [NSArray array];
    self.headerCell =[UITableViewCell
                            loadFromNib:@"BasicUIElements"
                            cellWithIdentifier:@"addresCell"];
    self.confirmButton = [self.headerCell viewWithTag:22];
    [self.confirmButton addTarget:self
                           action:@selector(confirmAdress:)
                 forControlEvents:UIControlEventTouchDown];
    
    self.streetField = [self.headerCell viewWithTag:11];
    self.houseField = [self.headerCell viewWithTag:12];
    self.commentField = [self.headerCell viewWithTag:14];

    RAC(self.confirmButton, enabled) = [RACSignal
                combineLatest:@[
                   [RACSignal merge:@[self.streetField.rac_textSignal,
                                      RACObserve(self.streetField, text)]],
                   [RACSignal merge:@[self.houseField.rac_textSignal,
                                      RACObserve(self.streetField, text)]]
                 ] reduce:^(NSString *streetName, NSString *houseNum) {
                     return @(streetName.length > 0 && houseNum.length > 0);
                 }];

    
        [[[[[[self.streetField.rac_textSignal
              filter:^BOOL(NSString *value) {
                return [value length] >= 1;
        }]
              throttle:0.1
        ] map:^id(NSString* searchText) {
            return [self.delegate listStreetsWithName:searchText];
        }]
              switchToLatest]
            deliverOn:RACScheduler.mainThreadScheduler]
            subscribeNext:^(NSArray *params) {
         
         if ([NSThread isMainThread]){
             self.streets = params;
             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                           withRowAnimation:UITableViewRowAnimationNone];
         }
         else{
             NSLog(@"is not MainThread");
         }
     }];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if(self.point) {
        self.streetField.text = self.point.name;
        self.houseField.text = self.point.houseNum;
        self.commentField.text = self.destination.userComment;
        self.navigationController.title =  NSLocalizedString(@"Изменить адрес",nil);
    }else{
        self.navigationController.title =  NSLocalizedString(@"Добавить адрес",nil);
    }
    [self.destination rac_liftSelector:@selector(setUserComment:)
                           withSignals:self.commentField.rac_textSignal, nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
                    numberOfRowsInSection:(NSInteger)section {
            if (section==0) {
                return 0;
            }else if(section == 1){
                return self.streets.count;

            }else{
                return [[self class] kMenuTitles].count;
            }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
                cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell =[UITableViewCell loadFromNib:@"BasicUIElements"
                                     cellWithIdentifier:@"streetCell"];
    UIImageView *imgView = [cell viewWithTag:10];
    UILabel *locLabel = [cell viewWithTag:11];
   


    if (indexPath.section==1) {
   
        
        RoutePoint *point = [self.streets objectAtIndex:indexPath.row];
        locLabel.text = point.name;
        
        if (!point.isPOI) {
            imgView.image = [UIImage imageNamed:@"cityIcon"];
        }
        NSMutableAttributedString *str=[[NSMutableAttributedString alloc]
                                        initWithString:point.name];
        

        
        NSRange range =  [point.name rangeOfString:self.streetField.text
                                           options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound ) {
            [str addAttribute:NSBackgroundColorAttributeName
                        value:[UIColor colorWithRed:0.945 green:0.518 blue:0.035 alpha:1.000]
                         range:range];
            [str addAttribute:NSForegroundColorAttributeName
                         value:[UIColor whiteColor]
                         range:range];

        }
         locLabel.attributedText = str;

    }else if (indexPath.section==2){
        NSArray  *menuArray = [[self class] kMenuTitles];
        locLabel.text = [NSString stringWithFormat:@"%@",menuArray[indexPath.row][@"txt"]];
        imgView.image = [UIImage imageNamed:
                         [NSString stringWithFormat:@"%@",menuArray[indexPath.row][@"ico"]]];
        
        
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView
                            viewForHeaderInSection:(NSInteger)section{
        if (section==0) {
            return [self.headerCell contentView];
        }
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        if (section==0) {
                return 120.0;
            }
        return 0.0;
}
-(void)confirmAdress:(UIButton*)sender{
    if(self.point) {
        self.point.name = self.streetField.text;
        self.point.houseNum = self.houseField.text;
        self.destination.preCheck = nil;
    }else{
        RoutePoint *point = [RoutePoint new];
        point.name = self.streetField.text;
        point.houseNum = self.houseField.text;
        [self.destination addRoutePoint:point];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];

    if (indexPath.section==1){
        RoutePoint *point = [self.streets objectAtIndex:indexPath.row];
        self.streetField.text = point.name;
        
        if(self.point) {
            self.point.name =  point.name;
            self.point.isPOI =  point.isPOI;
            self.destination.preCheck = nil;
            if (point.isPOI) {
                self.point.houseNum = @"";
                [self.navigationController popToRootViewControllerAnimated:YES];
                return;
            }
        }else{
            if (point.isPOI) {
                RoutePoint *newPoint = [RoutePoint new];
                newPoint.name =  point.name;
                newPoint.isPOI =  point.isPOI;
                [self.destination addRoutePoint:newPoint];
                [self.navigationController popToRootViewControllerAnimated:YES];
                return;
            }
            
        }
        [self fetchHousesForStreetWithName:point.name];

    }else if (indexPath.section==2){
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if (indexPath.row==0) {
            [self fetchCurrentLocation];
        }else if(indexPath.row==1){
            NSLog(@"POINT %@", self.point);
            UIViewController *vc = [storyboard
                  instantiateViewControllerWithIdentifier:@"mapServiceVC"];
            [(KievOnMapViewController*)vc setDelegate:self.delegate];
            [(KievOnMapViewController*)vc setPoint:self.point];
            [self.navigationController pushViewController:vc animated:YES];
        }else if(indexPath.row==2){
            //
            NSLog(@"POINT %@", self.point);
            UIViewController *vc = [storyboard
                    instantiateViewControllerWithIdentifier:@"FavListStoryboardVC"];
            [(ListFavoritesTableViewController*)vc setDelegate:self.delegate];
            [(ListFavoritesTableViewController*)vc setDestination:self.destination];
            [(ListFavoritesTableViewController*)vc setPoint:self.point];
            [self.navigationController pushViewController:vc animated:YES];
        }

    }
}
-(void) fetchCurrentLocation{
    [self addOverlayView];
    @weakify(self);
    [[_delegate curentLocationAdressForRadius:@"50"] subscribeNext:^(RACTuple *signalValues) {
        @strongify(self)
        NSDictionary *params = [signalValues last];
        NSDictionary *streetsDict =params[@"geo_streets"];
        if ([streetsDict[@"geo_street"] count]) {
            
            NSArray *adressComp = streetsDict[@"geo_street"];
            NSDictionary*housesDict = [adressComp objectAtIndex:0];
            NSString *adressStreet = housesDict[@"name"];
            NSArray *housesArr = housesDict[@"houses"];
            
            if (adressStreet && housesArr.count) {
                NSDictionary*houseDict = [housesArr objectAtIndex:0];
                self.streetField.text = adressStreet;
                self.houseField.text = houseDict[@"house"];

            }
         }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                 initWithTitle: NSLocalizedString(@"Ошибка",nil)
                 message:  NSLocalizedString(@"Ничего не найдено",nil)
                 delegate: nil
                 cancelButtonTitle: NSLocalizedString(@"OK",nil)
                 otherButtonTitles: nil];
                [alert show];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.overlayView removeFromSuperview];
        });
        
    }
   error:^(NSError *error) {
       @strongify(self)
       dispatch_async(dispatch_get_main_queue(), ^{
           UIAlertView *alert = [[UIAlertView alloc]
                 initWithTitle: NSLocalizedString(@"Ошибка",nil)
                 message: NSLocalizedString(@"Не удалось определить местоположение",nil)
                 delegate: nil
                 cancelButtonTitle: NSLocalizedString(@"OK",nil)
                 otherButtonTitles: nil];
           [alert show];
           [self.overlayView removeFromSuperview];
           [self.tableView reloadData];
       });
       
   }];
}

-(void) fetchHousesForStreetWithName:(NSString *)street{
    [self addOverlayView];
    @weakify(self);
    [[_delegate listHousesForStreetWithName:street] subscribeNext:^(NSDictionary *params) {
        @strongify(self)

        if ([params isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{

                NSDictionary *dict = [params[@"geo_street"] objectAtIndex:0];
                NSString *streetName = dict[@"name"];
                NSArray *streetHousesArr = dict[@"houses"];
                
                NSArray *homes = [streetHousesArr map:^(NSDictionary *data) {
                    RoutePoint *point = [RoutePoint new];
                    point.name = streetName;
                    point.houseNum = data[@"house"];
                    point.isPOI = NO;
                    return  point;
                }];

                
                NSArray *homes_sorted  = [homes sortedArrayUsingDescriptors:@[[NSSortDescriptor
                                                sortDescriptorWithKey:@"houseNum" ascending:YES]]];
                

                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                HousesTableViewController *vc = [storyboard
                                        instantiateViewControllerWithIdentifier:@"HousesStoryboardVC"];
                [vc setDestination:self.destination];
                [vc setPoint:self.point];
                [vc setHousesArray:homes_sorted];
                [vc setDelegate:self.delegate];
                [self.navigationController pushViewController:vc animated:YES];
            });
        }
        
        [self.overlayView removeFromSuperview];
    }
     error:^(NSError *error) {
      @strongify(self)
      dispatch_async(dispatch_get_main_queue(), ^{
          [self.overlayView removeFromSuperview];
          
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

- (void) addOverlayView{
    
    UITableViewCell *cell =[UITableViewCell loadFromNib:@"BasicUIElements"
                                     cellWithIdentifier:@"overlayCell"];
    self.overlayView = [cell contentView];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    self.overlayView.tag = 55;
    [self.overlayView setFrame:
     [[UIApplication sharedApplication].keyWindow bounds]];
    [[UIApplication sharedApplication].keyWindow
     addSubview:self.overlayView];
    
}

+ (NSArray *)kMenuTitles{
    static NSArray *_kMenuTitles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kMenuTitles = @[ @{@"ico":@"timeIcon",
                            @"txt":NSLocalizedString(@"Определить автоматически",nil)},
                          @{@"ico":@"timeIcon",
                            @"txt":NSLocalizedString(@"Выбрать адрес на карте",nil)},
                          @{@"ico":@"timeIcon",
                            @"txt":NSLocalizedString(@"Избранные адреса",nil)
                            }];
    });
    return _kMenuTitles;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
