#import "FavHousesTableViewController.h"

@interface FavHousesTableViewController ()

@end

@implementation FavHousesTableViewController
@synthesize delegate = _delegate;
- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView
                        cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favHouseCell"];
    RoutePoint *point = [self.housesArray objectAtIndex:indexPath.row];

    cell.textLabel.text = point.houseNum;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.housesArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RoutePoint *point = [self.housesArray objectAtIndex:indexPath.row];
    [self.delegate addToFavorites:point];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

@end
