#import "RunningOrdersTableViewController.h"
#import <ObjectiveSugar/ObjectiveSugar.h>
#import "UITableView+VMStaticCells.h"
#import "RunningOrderVO.h"
#import "RunningOrderViewCell.h"
#import "DriverOnMapViewController.h"
@interface RunningOrdersTableViewController ()<UIGestureRecognizerDelegate, SWTableViewCellDelegate>
@property(nonatomic, strong) NSArray *ordersArray;
@end

@implementation RunningOrdersTableViewController
@synthesize delegate = _delegate;
@synthesize ordersArray = _ordersArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.slidingViewController.panGesture.delegate = self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.ordersArray = [_delegate showCurrentOrders];
    [self.tableView reloadData];
}

-(void)onTaxiFound{
    NSLog(@"onTaxiFound");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ordersArray = [self->_delegate showCurrentOrders];
        [self.tableView reloadData];
    });
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return _ordersArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"historyCell";
    
    RunningOrderViewCell *cell = (RunningOrderViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                                           forIndexPath:indexPath];
    

    
        RunningOrderVO *item = [_ordersArray objectAtIndex:indexPath.row];
        [cell setRightUtilityButtons:[self rightButtonsForOrder:item] WithButtonWidth:64.0f];
        cell.delegate = self;
        cell.fromLabel.text = NSStringWithFormat(@"%@ %@",item.addressFrom.name, item.addressFrom.houseNum);
        cell.toLabel.text = NSStringWithFormat(@"%@ %@",item.addressTo.name, item.addressTo.houseNum);
        cell.priceLabel.text = NSStringWithFormat(@"%@ ₴",item.orderCost);
        if (item.foundCar!=nil) {
            cell.infoLabel.text = item.foundCar;
            cell.statusImageView.image = [UIImage imageNamed:@"checkIcon"];
            cell.activityIndicator.hidden = YES;
            [cell.activityIndicator stopAnimating];
        }else{
            cell.activityIndicator.hidden = NO;
            [cell.activityIndicator startAnimating];
            cell.statusImageView.image = nil;
             cell.infoLabel.text = @"";
        }
    

    return cell;
    
}
- (NSArray *)rightButtonsForOrder:(RunningOrderVO*)item
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                icon:[UIImage imageNamed:@"cancelIcon"]];
    
    //
    
    if (item.driverPhone) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.467 green:0.682 blue:0.110 alpha:1.000]
                                                     icon:[UIImage imageNamed:@"driverPhoneIcon"]];
   }
    if (item.gps) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.945 green:0.518 blue:0.035 alpha:1.0]
                                                     icon:[UIImage imageNamed:@"driveLocIcon"]];
    }
    
    return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
     NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
     RunningOrderVO *item = [_ordersArray objectAtIndex:cellIndexPath.row];
    
    switch (index) {
        case 0: {
            NSMutableArray *ids = [self.ordersArray mutableCopy];
            
            [_delegate cancelOrder:item];
            [ids removeObjectAtIndex:cellIndexPath.row];
            self.ordersArray = ids;
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case 1:{

           [cell hideUtilityButtonsAnimated:YES];
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:NSStringWithFormat(@"tel://%@",  item.driverPhone)]];
            break;
        }  case 2:{
            [cell hideUtilityButtonsAnimated:YES];
            UIStoryboard *storyboard = [UIStoryboard
                                        storyboardWithName:@"Main" bundle:nil];
            
            DriverOnMapViewController *vc = (DriverOnMapViewController*)[storyboard
                             instantiateViewControllerWithIdentifier:@"DriverStoryboardVC"];
            vc.order = item;
            vc.delegate = self.delegate;
           [self.navigationController pushViewController:vc animated:YES];
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer locationInView:gestureRecognizer.view].x < 270.0) {
        return YES;
    }
    return NO;
}
@end
