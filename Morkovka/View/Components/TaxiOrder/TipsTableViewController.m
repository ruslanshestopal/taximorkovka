#import "TipsTableViewController.h"

@implementation TipsTableViewController


@synthesize destination = _destination;

- (UITableViewCell *)tableView:(UITableView *)tableView
                cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView
                        cellForRowAtIndexPath:indexPath];
    NSInteger value = [_destination.addCost integerValue];
    
    NSInteger mask = [_destination.extrasMask integerValue];
    BOOL isDriver = ((mask & (1 << 8)) >> 8);
    if (isDriver) {
        value = value - 100;
    }
    
    if (value == indexPath.row*5) {
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
                didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_destination triggerTipsSelectionatIndex:indexPath.row];
}

@end
