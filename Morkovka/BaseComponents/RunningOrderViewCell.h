
#import <SWTableViewCell/SWTableViewCell.h>

@interface RunningOrderViewCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
