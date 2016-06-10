#import "TTTTimeIntervalFormatter.h"
#import "DateSelectionViewController.h"

@interface DateSelectionViewController ()
@property(nonatomic,weak) IBOutlet UIDatePicker *picker;
@property(nonatomic,weak) IBOutlet UILabel *label;
@end

@implementation DateSelectionViewController

@synthesize destination = _destination;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.picker.date =
    [[ NSDate date ] initWithTimeIntervalSinceNow: (NSTimeInterval) 0 ];
    self.picker.minimumDate =
    [[ NSDate date ] initWithTimeIntervalSinceNow: (NSTimeInterval) 0 ];
    self.picker.maximumDate = [[NSDate date] dateByAddingTimeInterval:60*60*24];
    
     self.label.text = [_destination dateComponentsString];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     self.label.text = [_destination dateComponentsString];
}
- (IBAction)datePickerChanged: (id)sender{
    _destination.requiredTime = self.picker.date;
    self.label.text = [_destination dateComponentsString];
}
@end
