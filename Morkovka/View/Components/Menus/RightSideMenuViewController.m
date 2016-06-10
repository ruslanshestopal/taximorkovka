
#import "RightSideMenuViewController.h"

@interface RightSideMenuViewController ()

@end

@implementation RightSideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row==0) {
        [[UIApplication sharedApplication]
            openURL:[NSURL URLWithString:@"tel://0443539955"]];
    }else if (indexPath.row == 1){
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:@"tel://0932449955"]];
    }else if (indexPath.row == 2){
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:@"tel://0951329955"]];
    }else if (indexPath.row == 3){
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:@"tel://0971959955"]];
    }
}
@end
