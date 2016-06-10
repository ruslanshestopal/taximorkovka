#import "LeftSideMenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "UITableView+VMStaticCells.h"

@interface LeftSideMenuViewController ()

@end

@implementation LeftSideMenuViewController

@synthesize delegate = _delegate;



- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *defaultIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:defaultIndexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    });
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath  *path= [self.tableView indexPathForSelectedRow];
    if (indexPath ==path) {
            return nil;
    }
    
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_delegate viewComponentDidTriggeredMenuAtIndex:indexPath];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
     //   NSLog(@"didDeselectRowAtIndexPath %ld", (long)indexPath.row);

}
- (UIView *)tableView:(UITableView *)tableView
                    viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
    UITableViewCell *cell =[UITableViewCell
           loadFromNib:@"BasicUIElements"
           cellWithIdentifier:@"profileHeaderCell"];
    UIButton *locButton = [cell viewWithTag:11];
    [locButton addTarget:self
                  action:@selector(manageProfile:)
        forControlEvents:UIControlEventTouchDown];

    return [ cell contentView];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
            heightForHeaderInSection:(NSInteger)section {
    return 166.0;
}
-(void)manageProfile:(UIButton*)sender{
    NSIndexPath  *path= [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:path animated:YES];
    [_delegate viewComponentDidTriggeredMenuAtIndex:[NSIndexPath
                                    indexPathForRow:100 inSection:0]];
}
- (void) onOderPlacement{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath  *path= [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:path
                                    animated:NO
                             ];
        NSIndexPath *defaultIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView selectRowAtIndexPath:defaultIndexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];

    });
}
@end
