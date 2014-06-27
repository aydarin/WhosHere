//
//  ViewController.m
//  WhosHere
//
//  Created by Aydar Mukhametzyanov on 25/06/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import "ViewController.h"
#import "NotificationsManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL isLoading;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Who's here";
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:PERSONS_DATA_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTimeLabel) name:TIMER_TICK_NOTIFICATION object:nil];
    
    [self update];
    [self loadPersonsList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Data loading

- (void)loadPersonsList
{
    self.isLoading = YES;
    
    __weak ViewController* selfWeak = self;
    [PM loadOnlinePersonsListWithCompletion:^(BOOL success) {
    
        selfWeak.isLoading = NO;
    }];
}

- (void)changeStatus
{
    self.isLoading = YES;
    
    __weak ViewController* selfWeak = self;
    [PM setSelfOnlineStatus:!PM.selfPerson.isOnline completion:^(BOOL success) {
        
        if (success)
        {
            [selfWeak loadPersonsList];
        }
        else
        {
            selfWeak.isLoading = NO;
        }
    }];
}

#pragma mark - UI settings

- (void)update
{
    [_tableView reloadData];
    
    _statusLabel.text = PM.selfPerson.isOnline ? @"Online" : @"Offline";
    
    [self updateHiddenViews];
    [self updateTimeLabel];
    
    NSString* buttonTitle = PM.selfPerson.isOnline ? @"Go out" : @"I'm here";
    [_button setTitle:buttonTitle forState:UIControlStateNormal];
    [_button setTitle:buttonTitle forState:UIControlStateDisabled];
    
    [self updateTimeLabel];
}

- (void)updateTimeLabel
{
    NSString* text = @"";
    
    if (PM.selfPerson.isOnline && PM.selfPerson.onlineSinceDate && !PM.selfPerson.pfPerson.isDirty)
    {
        NSDate* date = [NSDate date];
        NSTimeInterval timeInterval = [date timeIntervalSinceDate:PM.selfPerson.onlineSinceDate];
        
        if (timeInterval > 0)
        {
            long long time = [[NSNumber numberWithDouble: floor(timeInterval)] longLongValue];
            long long s = time % 60;
            time = time / 60;
            long long m = time % 60;
            time = time / 60;
            long long h = time;
            
            text = [NSString stringWithFormat:@"%.2lld:%.2lld:%.2lld", h, m, s];
        }
    }
    
    _timeLabel.text = text;
}

- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    
    _button.enabled = !_isLoading;
    _activityIndicator.hidden = !_isLoading;
    _tableView.alpha = _isLoading ? 0.5 : 1;
    _tableView.userInteractionEnabled = !_isLoading;
    
    if (_activityIndicator.hidden)
    {
        [_activityIndicator stopAnimating];
    }
    else
    {
        [_activityIndicator startAnimating];
    }
}

- (void)updateHiddenViews
{
    _tableView.hidden = !PM.selfPerson.isOnline;
}

#pragma mark - Actions

- (IBAction)buttonClicked:(id)sender
{
    [self changeStatus];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return PM.onlinePersons.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (PM.onlinePersons.count > indexPath.row)
    {
        Person* person = PM.onlinePersons[indexPath.row];
        cell.textLabel.text = person.udid;
    }
    else
    {
        cell.textLabel.text = @"";
    }
    
    return cell;
}

@end







