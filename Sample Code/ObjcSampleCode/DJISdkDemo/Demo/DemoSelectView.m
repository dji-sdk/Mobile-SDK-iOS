//
//  DemoUtilityMethod.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import "DemoSelectView.h"
static NSString *cellID = @"interface-name";
@interface DemoSelectView()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *innerTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *innerSearchBar;

@property (strong, nonatomic) NSMutableArray* afterSearchTableList;
@property (nonatomic , strong) UIView *backView;
@end
@implementation DemoSelectView

-(instancetype)init {
    return [super init];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupUI];
    _afterSearchTableList = [NSMutableArray new];
    self.innerTableView.delegate = self;
    self.innerTableView.dataSource = self;
    self.innerSearchBar.delegate = self;
    [self.innerTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
}

- (void)setupUI{
    self.alpha = 0;
    UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backView.backgroundColor  = [UIColor colorWithWhite:0 alpha:0.3];
    [self insertSubview:backView atIndex:0];
    [backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    UIView* mainView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    [self addSubview:mainView];
    mainView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:mainView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.6
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:mainView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.7
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:mainView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:mainView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];

}

- (void)setDelegate:(id<DemoSelectViewDelegate>)delegate{
    _delegate = delegate;
    if (_delegate && [_delegate respondsToSelector:@selector(selectTableList)]) {
       _afterSearchTableList = [NSMutableArray arrayWithArray:[_delegate selectTableList]];
    }
    if (_afterSearchTableList.count > 0) {
        dispatch_after(DISPATCH_TIME_NOW + 0.2 * NSEC_PER_SEC, dispatch_get_main_queue(), ^{
            [self.innerTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:false scrollPosition:UITableViewScrollPositionNone];
        });
    }

}

- (void)refresh {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(selectTableList)]) {
        return;
    }
    _afterSearchTableList = [NSMutableArray arrayWithArray:self.delegate.selectTableList];
    [self.innerTableView reloadData];
    if (_afterSearchTableList.count > 0) {
        dispatch_after(DISPATCH_TIME_NOW + 0.2 * NSEC_PER_SEC, dispatch_get_main_queue(), ^{
            [self.innerTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:false scrollPosition:UITableViewScrollPositionNone];
        });
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectTableList)]) {
        return _afterSearchTableList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    NSString* cellText = self.afterSearchTableList[indexPath.row];
    cell.textLabel.text = cellText;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectView:selectIndex:)]) {
        [self.delegate selectView:self selectIndex:[self covertIndex2Delegate:indexPath.row]];
    }
    [self hide];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length <= 0) {
        self.afterSearchTableList = [NSMutableArray arrayWithArray: self.delegate.selectTableList];
    } else {
        [self.afterSearchTableList removeAllObjects];
        NSArray* searchTableList = self.delegate.selectTableList;
        for (NSString* text in searchTableList) {
                NSRange titleResult=[text rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [self.afterSearchTableList addObject:text];
                }
        }
    }
    [self.innerTableView reloadData];
}

- (NSInteger)covertIndex2Delegate:(NSInteger)innerIndex{
    NSString *item = self.afterSearchTableList[innerIndex];
    if (self.delegate.selectTableList && [self.delegate.selectTableList containsObject:item]) {
        return [self.delegate.selectTableList indexOfObject:item];
    }
    return -1;
}

- (void)hide{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    }];
}

- (void)show{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
    }];
}
@end
