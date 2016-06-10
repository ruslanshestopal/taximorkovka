#import "AddToFavoritesTableViewController.h"
#import "UITableView+VMStaticCells.h"
#import "FavHousesTableViewController.h"
#import <ReactiveCocoa.h>

@interface AddToFavoritesTableViewController ()
@property(nonatomic,strong) UITableViewCell *headerCell;
@property(nonatomic,weak) UITextField * streetField;
@property(nonatomic,strong) NSArray *streets;
@property(nonatomic, strong) UIView *overlayView;
@end

@implementation AddToFavoritesTableViewController
@synthesize delegate = _delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.streets = [NSArray array];
    self.headerCell =[UITableViewCell
                      loadFromNib:@"BasicUIElements"
                      cellWithIdentifier:@"findAdressCell"];
    self.streetField = [self.headerCell viewWithTag:10];

    
    [[[[[[self.streetField.rac_textSignal
          filter:^BOOL(NSString *value) {
              return [value length] >= 1;
          }]
         throttle:0.1
         ] map:^id(NSString* searchText) {
        return [self.delegate listStreetsWithName:searchText];
    }]
       switchToLatest]
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *params) {
         
         if ([NSThread isMainThread]){
             self.streets = params;
             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                           withRowAnimation:UITableViewRowAnimationNone];
         }
         else{
             NSLog(@"is not MainThread");
         }
     }];
    
}


#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView
                    viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return [self.headerCell contentView];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return 60.0;
    }
    return 0.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 0;
    }else {
        return self.streets.count;
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell =[UITableViewCell loadFromNib:@"BasicUIElements" cellWithIdentifier:@"streetCell"];
    UIImageView *imgView = [cell viewWithTag:10];
    UILabel *locLabel = [cell viewWithTag:11];
    
    if (indexPath.section==1) {
        
        
        RoutePoint *point = [self.streets objectAtIndex:indexPath.row];
        locLabel.text = point.name;
        
        if (!point.isPOI) {
            imgView.image = [UIImage imageNamed:@"cityIcon"];
        }
        NSMutableAttributedString *str=[[NSMutableAttributedString alloc] initWithString:point.name];
        
        NSRange range =  [point.name rangeOfString:self.streetField.text options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound ) {
            [str addAttribute:NSBackgroundColorAttributeName
                        value:[UIColor colorWithRed:0.945 green:0.518 blue:0.035 alpha:1.000]
                        range:range];
            [str addAttribute:NSForegroundColorAttributeName
                        value:[UIColor whiteColor]
                        range:range];
            
        }
        locLabel.attributedText = str;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    
    if (indexPath.section==1){
        RoutePoint *point = [self.streets objectAtIndex:indexPath.row];
        self.streetField.text = point.name;
        if (point.isPOI) {
            NSLog(@"POINT IS POI");
            [self.delegate addToFavorites:point];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [self fetchHousesForStreetWithName:point.name];
        }
        
    }
}

-(void) fetchHousesForStreetWithName:(NSString *)street{
    [self addOverlayView];
    @weakify(self);
    [[_delegate listHousesForStreetWithName:street] subscribeNext:^(NSDictionary *params) {
        @strongify(self)
        
        if ([params isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSDictionary *dict = [params[@"geo_street"] objectAtIndex:0];
                NSString *streetName = dict[@"name"];
                NSArray *streetHousesArr = dict[@"houses"];
                
                NSArray *homes = [streetHousesArr map:^(NSDictionary *data) {
                    RoutePoint *point = [RoutePoint new];
                    point.name = streetName;
                    point.houseNum = data[@"house"];
                    point.isPOI = NO;
                    return  point;
                }];
                
                NSArray *homes_sorted  = [homes sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"houseNum" ascending:YES]]];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FavHousesTableViewController *vc = [storyboard
                                                 instantiateViewControllerWithIdentifier:@"FavHousesStoryboardVC"];

                [vc setHousesArray:homes_sorted];
                [vc setDelegate:self.delegate];
                [self.navigationController pushViewController:vc animated:YES];
            });
        }
        
        [self.overlayView removeFromSuperview];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
