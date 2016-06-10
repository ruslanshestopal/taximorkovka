#import "UITableView+VMStaticCells.h"
#import <ObjectiveSugar/ObjectiveSugar.h>
#import "TTTTimeIntervalFormatter.h"
#import "OrderHistoryTableViewController.h"
#import "DestinationVO.h"



@interface OrderHistoryTableViewController ()< UIGestureRecognizerDelegate, UIAlertViewDelegate>
@end

@implementation OrderHistoryTableViewController
@synthesize delegate = _delegate;
@synthesize history = _history;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.slidingViewController.panGesture.delegate = self;

    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.loadingIndicator startAnimating];
    @weakify(self);
    [[_delegate showOrdersHistory] subscribeNext:^(NSArray *params) {
        @strongify(self)
        self->_history = params;
        [self.tableView reloadData];
        [self.loadingIndicator stopAnimating];
    }
   error:^(NSError *error) {

       dispatch_async(dispatch_get_main_queue(), ^{
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _history.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    DestinationVO * destination = [_history objectAtIndex:section];
    return destination.routePoints.count;

}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *cell =[UITableViewCell loadFromNib:@"BasicUIElements" cellWithIdentifier:@"historyHeader"];
    UILabel *dateLabel = [cell viewWithTag:10];
   // UILabel *priceLabel = [cell viewWithTag:11];
    UIButton *locButton = [cell viewWithTag:12];
    [locButton addTarget:self
                  action:@selector(repeatRoute:)
        forControlEvents:UIControlEventTouchDown];
   
    DestinationVO * destination = [_history objectAtIndex:section];
   
    dateLabel.text = [destination dateComponentsString];
    //priceLabel.text = [destination costComponentsString];
    cell.contentView.tag = section;
    return cell.contentView;
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
    DestinationVO * destination = [_history objectAtIndex:indexPath.section];
    RoutePoint *point = [destination.routePoints objectAtIndex:indexPath.row];
    locLabel.text = NSStringWithFormat(@"%@ %@", point.name, point.houseNum);
    imgViewPoint.image = [DestinationVO imageForIndex:indexPath.row
                                             andCount:destination.routePoints.count+1];
    imgView.image = nil;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    

    return cell;
}

-(void)repeatRoute:(UIButton*)sender{

    [_delegate repeatOrderAtIndex:[sender superview].tag];
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer locationInView:gestureRecognizer.view].x < 270.0 &&
        [gestureRecognizer locationInView:gestureRecognizer.view].x > 50.0) {
        return YES;
    }
    return NO;
}

@end


