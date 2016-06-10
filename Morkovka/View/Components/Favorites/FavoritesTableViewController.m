#import "FavoritesTableViewController.h"
#import <ObjectiveSugar/ObjectiveSugar.h>
#import "UITableView+VMStaticCells.h"
#import "AddToFavoritesTableViewController.h"
#import "DestinationVO.h"
@interface FavoritesTableViewController ()
@property(nonatomic, strong) NSArray *favArray;
@end

@implementation FavoritesTableViewController
@synthesize delegate = _delegate;
@synthesize favArray = _favArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.favArray = [NSArray new];
    /*
     FavAddStoryboardVC
     */
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.favArray = [_delegate fetchFavoritsAdresses];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _favArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =[UITableViewCell loadFromNib:@"BasicUIElements" cellWithIdentifier:@"buttonCell"];
    UILabel *locLabel = [cell viewWithTag:22];
    UILabel *infLabel = [cell viewWithTag:21];

    RoutePoint *point = [_favArray objectAtIndex:indexPath.row];
    locLabel.text = point.name;
    infLabel.text = point.houseNum;
    
    
    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{

        UITableViewCell *cell =[UITableViewCell loadFromNib:@"BasicUIElements"
                                         cellWithIdentifier:@"addFavCell"];
        UIButton *locButton = [cell viewWithTag:12];
        [locButton addTarget:self
                      action:@selector(searchFavorites:)
            forControlEvents:UIControlEventTouchDown];
        
        return cell.contentView;
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 44.0;
    return height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView
                                commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                 forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
 
       
        NSMutableArray *ids = [self.favArray mutableCopy];
        
        [_delegate removeFavoriteItemAtIndex:indexPath.row];
        [ids removeObjectAtIndex:indexPath.row];
        self.favArray = ids;
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

-(void)searchFavorites:(UIButton*)sender{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddToFavoritesTableViewController *vc = [storyboard
                                     instantiateViewControllerWithIdentifier:@"FavAddStoryboardVC"];
    [vc setDelegate:self.delegate];
    
    [self.navigationController pushViewController:vc animated:YES];
}
@end
