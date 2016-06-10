#import "HousesTableViewController.h"
#import "SWTableViewCell.h"

@interface HousesTableViewController ()<SWTableViewCellDelegate>

@end

@implementation HousesTableViewController
@synthesize delegate = _delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
     self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.housesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
                    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"HouseCell";
   
    SWTableViewCell *cell = (SWTableViewCell *)[tableView
                            dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell) {
            
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:44.0f];
        cell.delegate = self;
        RoutePoint *point = [self.housesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = point.houseNum;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView
                        didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RoutePoint *point = [self.housesArray objectAtIndex:indexPath.row];
    if (self.point) {
        self.point.name = point.name;
        self.point.houseNum = point.houseNum;
        self.point.isPOI = NO;
        self.destination.preCheck = nil;
    }else{
        [self.destination addRoutePoint:point];
    
    }
    [self.navigationController popToRootViewControllerAnimated:YES];

}
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.945 green:0.518 blue:0.035 alpha:1.0]
                                                 icon:[UIImage imageNamed:@"heartIco"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.467 green:0.682 blue:0.110 alpha:1.000]
                                                 icon:[UIImage imageNamed:@"checkIco"]];

    
    return rightUtilityButtons;
}
#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell
              scrollingToState:(SWCellState)state{
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell
        didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{

}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell
                didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    RoutePoint *point  = [self.housesArray objectAtIndex:cellIndexPath.row];
    
    switch (index) {
        case 0:
        {
            [self.delegate addToFavorites:point];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            if (self.point) {
                self.point.name = point.name;
                self.point.houseNum = point.houseNum;
                self.point.isPOI = NO;
                self.destination.preCheck = nil;
            }else{
                [self.destination addRoutePoint:point];
                
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell
               canSwipeToState:(SWCellState)state{
    switch (state) {
        case 1:
            return NO;
            break;
        case 2:
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

@end
