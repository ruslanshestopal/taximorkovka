#import "ExtraServiceTableViewController.h"

@interface ExtraServiceTableViewController ()

@end

@implementation ExtraServiceTableViewController

@synthesize destination = _destination;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
                                cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView
                                cellForRowAtIndexPath:indexPath];

    if ([_destination isMarkedAsSelecteAtIndex:indexPath.row]) {
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
                        didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.destination triggerExtrasSelectionState:YES atIndex:indexPath.row];

    if (indexPath.row== 5) {
        [self.tableView
                deselectRowAtIndexPath:[NSIndexPath
                      indexPathForRow:6
                            inSection:0]
                              animated:YES];
        [self.tableView
                deselectRowAtIndexPath:[NSIndexPath
                       indexPathForRow:7
                             inSection:0]
                              animated:YES];
        [self.destination
            triggerExtrasSelectionState:NO
                                atIndex:6];
        [self.destination
            triggerExtrasSelectionState:NO
                                atIndex:7];
    }else if (indexPath.row== 6){
        [self.tableView
                deselectRowAtIndexPath:[NSIndexPath
                        indexPathForRow:5 inSection:0] animated:YES];
        [self.tableView
                deselectRowAtIndexPath:[NSIndexPath
                        indexPathForRow:7 inSection:0] animated:YES];
        [self.destination
                    triggerExtrasSelectionState:NO atIndex:5];
        [self.destination
                    triggerExtrasSelectionState:NO atIndex:7];
    }else if (indexPath.row== 7){
        [self.tableView
                deselectRowAtIndexPath:[NSIndexPath
                       indexPathForRow:5
                             inSection:0] animated:YES];
        [self.tableView
                deselectRowAtIndexPath:[NSIndexPath
                       indexPathForRow:6 inSection:0] animated:YES];
        [self.destination
                triggerExtrasSelectionState:NO atIndex:5];
        [self.destination
                triggerExtrasSelectionState:NO atIndex:6];
    }
}
- (void)tableView:(UITableView *)tableView
                        didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{

       [self.destination
        triggerExtrasSelectionState:NO
                            atIndex:indexPath.row];
}

@end
