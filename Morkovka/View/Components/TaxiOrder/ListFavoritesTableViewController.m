
#import "ListFavoritesTableViewController.h"
#import "UITableView+VMStaticCells.h"

@interface ListFavoritesTableViewController ()

@end

@implementation ListFavoritesTableViewController
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.favArray = [_delegate fetchFavoritsAdresses];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _favArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =[UITableViewCell
                            loadFromNib:@"BasicUIElements"
                     cellWithIdentifier:@"buttonCell"];
    UILabel *locLabel = [cell viewWithTag:22];
    UILabel *infLabel = [cell viewWithTag:21];
    RoutePoint *point = [_favArray objectAtIndex:indexPath.row];
    locLabel.text = point.name;
    infLabel.text = point.houseNum;

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RoutePoint *newPoint = [self.favArray objectAtIndex:indexPath.row];

    if (self.point) {
        // We are editing start point
        RoutePoint *point = [self.destination.routePoints firstObject];
        point.name = newPoint.name;
        point.houseNum = newPoint.houseNum;
        point.isPOI = newPoint.isPOI;
        
    }else{
        [self.destination addRoutePoint:newPoint];
    }

    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

@end
