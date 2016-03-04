#import "TaxiOrderViewController.h"
#import "DateSelectionViewController.h"
#import "AddRoutePointTableViewController.h"
#import "KievOnMapViewController.h"
#import "ExtraServiceTableViewController.h"
#import "TipsTableViewController.h"
#import "PreOrderViewController.h"


@interface TaxiOrderViewController ()<UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIView *overlayView;
@property(nonatomic, strong) UIView *priceView;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end

@implementation TaxiOrderViewController

@synthesize delegate = _delegate;
@synthesize destination = _destination;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.slidingViewController.panGesture.delegate = self;
    self.navigationController.title =  NSLocalizedString(@"Заказ машины",nil);
    
    self.destination = [self.delegate requestDestinationData];
    
    UITableViewCell *cell =[UITableViewCell loadFromNib:@"BasicUIElements"
                                     cellWithIdentifier:@"preoderCell"];
    UIButton *nButton = [cell viewWithTag:11];
    [nButton addTarget:self
                action:@selector(proceedWithTaxiPreOder:)
      forControlEvents:UIControlEventTouchDown];
    UIButton *fButton = [cell viewWithTag:22];
    [fButton addTarget:self
                action:@selector(proceedWithTaxiPreOder:)
      forControlEvents:UIControlEventTouchDown];
    
    
    self.priceView = cell.contentView;
    /*
     RACSignal *changeSignal = [self.destination
                        rac_valuesAndChangesForKeyPath:@keypath(self.destination, routePoints)
     options: NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld observer:nil];
     [changeSignal subscribeNext:^(RACTuple *x){
         UILabel *nLabel = [self.priceView viewWithTag:10];
         nLabel.text = @"";
         UILabel *fLabel = [self.priceView viewWithTag:20];
         fLabel.text = @"";

         [self autoCalculatePrice];
     }];
     
    
    
    
    NSArray *arrNums = @[ @"12", @"35", @"21", @"1/28", @"4"];
    NSArray *arr = @[ @"ЧИГОРИНА УЛ.", @"ПОЛЕВАЯ УЛ.", @"ПУШКИНСКАЯ УЛ.", @"ВАСИЛЕВСКОЙ ВАНДЫ УЛ.", @"САГАЙДАЧНОГО УЛ. (БОРИСПОЛЬ)"];
   
    [@2 timesWithIndex:^(NSUInteger index) {
        RoutePoint *point = [RoutePoint new];
        point.name = [arr objectAtIndex:index];
        point.houseNum =[arrNums objectAtIndex:index];
        self->_destination.routePoints = [self->_destination.routePoints arrayByAddingObject:point] ;
    }];
    */
    self.nav = self.navigationController;
    

}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    self.destination = [self.delegate
                        requestDestinationData];
    
    if([self.destination startingPointIsReady]){
        [self.tableView reloadData];
    }

    if ([_destination routeIsReady]
              && _destination.preCheck ==nil){
        [self autoCalculatePrice];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if(![_destination startingPointIsReady]){
        return 1;
    }
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return _destination.routePoints.count-1;
    }else if(section == 1){
        return 3;
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView
                    viewForHeaderInSection:(NSInteger)section{
    UITableViewCell *cell;
    if(section == 0){
    
        if([self.destination startingPointIsReady]){
            cell =[UITableViewCell
                   loadFromNib:@"BasicUIElements"
                   cellWithIdentifier:@"startCell"];
            UIButton *locButton = [cell viewWithTag:11];
            [locButton addTarget:self
                          action:@selector(changeStartAdress:)
                forControlEvents:UIControlEventTouchDown];
            UILabel *adressLabel = [cell viewWithTag:33];
            RoutePoint *pt = [self.destination.routePoints objectAtIndex:0];
            adressLabel.text = NSStringWithFormat(@"%@ %@", pt.name, pt.houseNum);

        }else{
                cell =[UITableViewCell
                                loadFromNib:@"BasicUIElements"
                                cellWithIdentifier:@"headerCell"];
        UIButton *locButton = [cell viewWithTag:10];
        [locButton addTarget:self
                               action:@selector(addStartAdress:)
                     forControlEvents:UIControlEventTouchDown];
            
        UIButton *autoButton = [cell viewWithTag:11];
          [autoButton addTarget:self
                          action:@selector(locateAutomaticly:)
                forControlEvents:UIControlEventTouchDown];
        }

    }else if(section == 1){
        cell=  [UITableViewCell
                loadFromNib:@"BasicUIElements"
                cellWithIdentifier:@"paramsCell"];
     }else{
        return nil;
    }
            return cell.contentView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(![_destination startingPointIsReady]){
        return nil;
    }
    if(section == 0){
        UITableViewCell *cell =[UITableViewCell loadFromNib:@"BasicUIElements"
                                         cellWithIdentifier:@"footerCell"];
        UIButton *locButton = [cell viewWithTag:12];
        [locButton addTarget:self
                      action:@selector(addRouteAdress:)
            forControlEvents:UIControlEventTouchDown];

        return cell.contentView;
    }else if (section==1 && [_destination routeIsReady]){
        
        if (_destination.preCheck != nil) {
            
            UILabel *nLabel = [self.priceView viewWithTag:10];
            nLabel.text = [_destination.preCheck ordinaryPriceString];
            UILabel *fLabel = [self.priceView viewWithTag:20];
            fLabel.text = [_destination.preCheck fastPriceString];
        }
        return self.priceView;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0 && [_destination startingPointIsReady]) {
        height = 44;
    }else if (section==1 && [_destination routeIsReady]){
        height = 88;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
      UITableViewCell *cell =[UITableViewCell loadFromNib:@"BasicUIElements" cellWithIdentifier:@"buttonCell"];
      UILabel *locLabel = [cell viewWithTag:22];
      UILabel *infLabel = [cell viewWithTag:21];
      UIImageView *imgView = [cell viewWithTag:20];
      UIImageView *imgViewPoint = [cell viewWithTag:25];
      locLabel.text = @"";
      infLabel.text = @"";
  
    if (indexPath.section ==0) {
        RoutePoint *point = [_destination.routePoints objectAtIndex:(indexPath.row+1)];
        locLabel.text = NSStringWithFormat(@"%@ %@", point.name, point.houseNum);
        imgViewPoint.image = [DestinationVO imageForIndex:indexPath.row
                                        andCount:_destination.routePoints.count];
        imgView.image = nil;
        
    }else if (indexPath.section==1){
         NSArray  *menuArray = [[self class] kMenuTitles];
         locLabel.text = [NSString stringWithFormat:@"%@",menuArray[indexPath.row][@"txt"]];
         imgView.image = [UIImage imageNamed:
                         [NSString stringWithFormat:@"%@",menuArray[indexPath.row][@"ico"]]];
        if (indexPath.row == 0) {
              infLabel.text = [_destination dateComponentsString];
        }else if (indexPath.row == 1){
            infLabel.text = [_destination extrasComponentsString];
        }else if (indexPath.row == 2){
              infLabel.text = [_destination tipComponentsString];
        }
    }
    
      return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 44;
    if (section == 0) {
        return [self.destination startingPointIsReady] ? 100 : 320;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1){
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if (indexPath.row==0) {
            UIViewController *vc = [storyboard
                         instantiateViewControllerWithIdentifier:@"timeServiceVC"];
            [(DateSelectionViewController *)vc setDestination:_destination];
            [self.navigationController pushViewController:vc animated:YES];

        }else if(indexPath.row==1){
            UIViewController *vc = [storyboard
                         instantiateViewControllerWithIdentifier:@"extraServiceVC"];
            [(ExtraServiceTableViewController *)vc  setDestination:_destination];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            UIViewController *vc = [storyboard
                          instantiateViewControllerWithIdentifier:@"tipsServiceVC"];
            [(TipsTableViewController *)vc  setDestination:_destination];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
        return YES;
}

- (void)tableView:(UITableView *)tableView
                    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                     forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *arr = [_destination.routePoints mutableCopy];
        [arr removeObjectAtIndex:indexPath.row+1];
        self.destination.routePoints = arr;
        self.destination.preCheck = nil;
        [self autoCalculatePrice];
        [self.tableView reloadData];
    }
    
}
- (void)addStartAdress:(UIButton*)sender{
    UIStoryboard *storyboard = [UIStoryboard
                                storyboardWithName:@"Main" bundle:nil];
    
    AddRoutePointTableViewController *vc = (AddRoutePointTableViewController*)[storyboard
                    instantiateViewControllerWithIdentifier:@"AddAdressStoryboardVC"];
    [vc setDelegate:self.delegate];
    [vc setDestination:self.destination];
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)changeStartAdress:(UIButton*)sender{
    UIStoryboard *storyboard = [UIStoryboard
                                storyboardWithName:@"Main" bundle:nil];
    
    AddRoutePointTableViewController *vc = (AddRoutePointTableViewController*)[storyboard
                        instantiateViewControllerWithIdentifier:@"AddAdressStoryboardVC"];
    [vc setDelegate:self.delegate];
    [vc setDestination:self.destination];
    [vc setPoint:[self.destination.routePoints objectAtIndex:0]];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)addRouteAdress:(UIButton*)sender{
    UIStoryboard *storyboard = [UIStoryboard
                                storyboardWithName:@"Main" bundle:nil];
    
    AddRoutePointTableViewController *vc = (AddRoutePointTableViewController*)[storyboard
                        instantiateViewControllerWithIdentifier:@"AddAdressStoryboardVC"];
    [vc setDelegate:self.delegate];
    [vc setDestination:self.destination];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)manageAdress:(UIButton*)sender{

    UIStoryboard *storyboard = [UIStoryboard
                                storyboardWithName:@"Main" bundle:nil];

    AddRoutePointTableViewController *vc = (AddRoutePointTableViewController*)[storyboard
                        instantiateViewControllerWithIdentifier:@"AddAdressStoryboardVC"];
    [vc setDelegate:_delegate];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)proceedWithTaxiPreOder:(UIButton*)sender{
    
    if (sender.tag ==22) {
        _destination.addCost = [NSNumber numberWithInt:20];
    }
    
    UIStoryboard *storyboard = [UIStoryboard
                                storyboardWithName:@"Main" bundle:nil];
    
    PreOrderViewController *vc = (PreOrderViewController*)[storyboard
                            instantiateViewControllerWithIdentifier:@"PreOrderStoryboardVC"];
    @weakify(self);
    [vc setConfirmationBlock:^{
        @strongify(self)
        [self proceedWithTaxiOder];
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)proceedWithTaxiOder{
    NSLog(@"proceedWithTaxiOder");

    [self addOverlayView];
    /*
    _destination.userName = @"Morkovka iOS Test";
    _destination.userComment = @"разработка приложения";
    _destination.userPhone = @"+38(000)-000-00-00";
    */
    
    _destination.userPhone = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"userPhone"];
    _destination.userName = [[NSUserDefaults standardUserDefaults]
                               stringForKey:@"userName"];
    @weakify(self);
    [[_delegate placeAnOrder] subscribeNext:^(NSDictionary *params) {
        NSLog(@"placeAnOrder subscribeNext!");

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
       

       NSLog(@"serializedData %@", error);
        }
        completed:^{
            NSLog(@"placeAnOrder completed!");
        }
     ];
}
-(void)locateAutomaticly:(UIButton*)sender{
    
    NSLog(@"locateAutomaticly");
    
    sender.enabled = NO;
    UIButton* button = [[sender superview] viewWithTag:10];
    UIActivityIndicatorView *loadingIndicator =[[sender superview] viewWithTag:12];
    [loadingIndicator startAnimating];
    button.enabled = NO;
    
      @weakify(self);
    [[_delegate curentLocationAdressForRadius:@"50"] subscribeNext:^(RACTuple *signalValues) {
        @strongify(self)

        NSDictionary *params = [signalValues last];
        NSLog(@"curentLocationAdress %@", params);
        NSDictionary *streetsDict =params[@"geo_streets"];
        if ([streetsDict[@"geo_street"] count]) {
           
            NSArray *adressComp = streetsDict[@"geo_street"];
            NSDictionary*housesDict = [adressComp objectAtIndex:0];
            NSString *adressStreet = housesDict[@"name"];
            NSArray *housesArr = housesDict[@"houses"];
            
            if (adressStreet && housesArr.count) {
                NSDictionary*houseDict = [housesArr objectAtIndex:0];
                [self.destination addStartPointWithStreetAddress:adressStreet
                                                 andStreetNumber:houseDict[@"house"] ];
            }


        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"Ошибка",nil)
                                  message: NSLocalizedString(@"Ничего не найдено",nil)
                                  delegate: nil
                                  cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                  otherButtonTitles: nil];
            [alert show];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });

    }
    error:^(NSError *error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc]
                 initWithTitle: NSLocalizedString(@"Ошибка",nil)
                 message:  NSLocalizedString(@"Не удалось определить местоположение",nil)
                 delegate: nil
                 cancelButtonTitle: NSLocalizedString(@"OK",nil)
                 otherButtonTitles: nil];
            [alert show];
            [self.tableView reloadData];
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

-(void) autoCalculatePrice{
    if ([_destination routeIsReady]) {
        NSLog(@"SOULD UPDATE PRICE");

        UILabel *nLabel = [self.priceView viewWithTag:10];
        nLabel.text = @"";
        UILabel *fLabel = [self.priceView viewWithTag:20];
        fLabel.text = @"";
        
        @weakify(self);
        [[_delegate calculatePreoderPrice] subscribeNext:^(NSDictionary *params) {
            @strongify(self)
            if ([params isKindOfClass:[NSDictionary class]]) {
                NSError *error = nil;
                RoutePrecalculation *precheck = [MTLJSONAdapter modelOfClass:RoutePrecalculation.class
                                                          fromJSONDictionary:params
                                                                       error:&error];
                NSLog(@"calculatePreoderPrice %@", precheck);
            
                dispatch_async(dispatch_get_main_queue(), ^{
                     self->_destination.preCheck = precheck;
                    [self.tableView reloadData];
                });
            }
            

        }
           error:^(NSError *error) {
               NSLog(@"Enjoy the silence");

           }];

    }


}
- (void) onOderPlacement{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.overlayView removeFromSuperview];
    });
}

+ (NSArray *)kMenuTitles{
    static NSArray *_kMenuTitles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kMenuTitles = @[ @{@"ico":@"timeIcon",
                            @"txt":NSLocalizedString(@"Время подачи",nil)},
                          @{@"ico":@"vipIcon",
                            @"txt":NSLocalizedString(@"Дополнительные услуги",nil)},
                          @{@"ico":@"cashIcon",
                            @"txt":NSLocalizedString(@"Добавить к стоимости",nil)
                            }];
    });
    return _kMenuTitles;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer locationInView:gestureRecognizer.view].x < 270.0) {
        return YES;
    }
    return NO;
}

@end
