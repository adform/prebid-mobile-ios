//
//  ViewController.m
//  PriceCheckTestApp
//
//  Created by Nicole Hedley on 24/08/2016.
//  Copyright © 2016 Nicole Hedley. All rights reserved.
//

#import "LineItemsViewController.h"
#import "LineItemsConstants.h"

#import "ActionSheetPicker.h"

#import "LineItemAdsViewController.h"

NSString *__nonnull const kNextButtonText = @"Click to see your line items";
NSString *__nonnull const kTitleText = @"AdServer Setup Validator";

NSString *__nonnull const kAdServerLabelText = @"Ad Server";
NSString *__nonnull const kAdFormatLabelText = @"Ad Format";
NSString *__nonnull const kAdSizeLabelText = @"Ad Size";
NSString *__nonnull const kAdUnitIdText = @"Ad Unit ID";
NSString *__nonnull const kBidPriceText = @"Bid Price(s)";

NSString *__nonnull const kErrorMessageTitle = @"Oops...";

CGFloat const kLabelHeight = 80.0f;

@interface StyledCell : UITableViewCell

@end

@implementation StyledCell

- (id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    return self;
}

@end

@interface LineItemsViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSArray *adServers;
@property NSArray *adFormats;
@property NSArray *adSizes;

@property (nonatomic, strong) UITableView *userInputTableView;
@property NSArray *tableViewItems;
@property NSArray *initialDetailTextValues;

@property NSString *adServer;
@property NSString *adFormat;
@property NSString *adSize;
@property NSString *adUnitId;
@property NSString *bidPrice;

@end

@implementation LineItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = kTitleText;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"ff8700"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    _userInputTableView = [[UITableView alloc] init];
    _userInputTableView.frame = self.view.frame;
    _userInputTableView.dataSource = self;
    _userInputTableView.delegate = self;

    _userInputTableView.backgroundColor = [UIColor whiteColor];
    [_userInputTableView setSeparatorColor:[UIColor darkGrayColor]];
    [_userInputTableView registerClass:[StyledCell class] forCellReuseIdentifier:@"Cell"];
    
    if ([_userInputTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        _userInputTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:_userInputTableView];
    
    _tableViewItems = @[kAdServerLabelText, kAdFormatLabelText, kAdSizeLabelText, kAdUnitIdText, kBidPriceText];
    _adServers = @[kMoPubString, kDFPString];
    _adFormats = @[kBannerString, kInterstitialString];
    _adSizes = @[kBannerSizeString, kMediumRectangleSizeString, kInterstitialSizeString];

    _adServer = [[NSUserDefaults standardUserDefaults] objectForKey:kAdServerNameKey] ? [[NSUserDefaults standardUserDefaults] objectForKey:kAdServerNameKey] : self.adServers[0];
    _adFormat = [[NSUserDefaults standardUserDefaults] objectForKey:kAdFormatNameKey] ? [[NSUserDefaults standardUserDefaults] objectForKey:kAdFormatNameKey] : self.adFormats[0];
    _adSize = [[NSUserDefaults standardUserDefaults] objectForKey:kAdSizeKey] ? [[NSUserDefaults standardUserDefaults] objectForKey:kAdSizeKey] : self.adSizes[0];
    _adUnitId = [[NSUserDefaults standardUserDefaults] objectForKey:kAdUnitIdKey] ? [[NSUserDefaults standardUserDefaults] objectForKey:kAdUnitIdKey] : @"";
    id bidPriceInitialArray = [[NSUserDefaults standardUserDefaults] objectForKey:kBidPriceKey];
    if ([bidPriceInitialArray isKindOfClass:[NSArray class]]) {
        _bidPrice = [bidPriceInitialArray componentsJoinedByString:@","];
    } else {
        _bidPrice = @"";
    }
    
    _initialDetailTextValues = @[_adServer, _adFormat, _adSize, _adUnitId, _bidPrice];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    StyledCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[StyledCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.tableViewItems objectAtIndex:indexPath.row];
    if (indexPath.row < [self.initialDetailTextValues count]) {
        cell.detailTextLabel.text = self.initialDetailTextValues[indexPath.row];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableViewItems count];
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;
    if ([cellText isEqualToString:kAdServerLabelText]) {
        
        
        
        
        [ActionSheetStringPicker showPickerWithTitle:@"Select an Ad Server"
                                                rows:self.adServers
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               cell.detailTextLabel.text = selectedValue;
                                               self.adServer = selectedValue;
                                               [cell setSelected:NO];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             [cell setSelected:NO];
                                         }
                                              origin:tableView];
    } else if ([cellText isEqualToString:kAdFormatLabelText]) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select an Ad Format"
                                                rows:self.adFormats
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               cell.detailTextLabel.text = selectedValue;
                                               self.adFormat = selectedValue;
                                               [cell setSelected:NO];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             [cell setSelected:NO];
                                         }
                                              origin:tableView];
    } else if ([cellText isEqualToString:kAdSizeLabelText]) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select an Ad Size"
                                                rows:self.adSizes
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               cell.detailTextLabel.text = selectedValue;
                                               self.adSize = selectedValue;
                                               [cell setSelected:NO];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             [cell setSelected:NO];
                                         }
                                              origin:tableView];
    } else if ([cellText isEqualToString:kAdUnitIdText]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enter your Ad Unit ID"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = self.adUnitId;
            textField.placeholder = @"Ad Unit ID";
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleNone;
            [textField addTarget:self
                          action:@selector(adUnitIdTextFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
        }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:^{
            [cell setSelected:NO];
        }];
    } else if ([cellText isEqualToString:kBidPriceText]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enter one or more bid price in dollars"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = self.bidPrice;
            textField.placeholder = @"ex. 0.50,1.00,2.50";
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleNone;
            [textField addTarget:self
                          action:@selector(bidPriceTextFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
        }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:^{
            [cell setSelected:NO];
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kLabelHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setTitle:kNextButtonText forState:UIControlStateNormal];
    nextButton.frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, kLabelHeight);
    [nextButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [nextButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [nextButton addTarget:self action:@selector(didPressNext:) forControlEvents:UIControlEventTouchUpInside];
    return nextButton;
}

// Responders to user actions - text input and button click
- (void)bidPriceTextFieldDidChange:(UITextField *)textField {
    UITableViewCell *cell = [self.userInputTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    cell.detailTextLabel.text = textField.text;
    self.bidPrice = textField.text;
}

- (void)adUnitIdTextFieldDidChange:(UITextField *)textField {
    UITableViewCell *cell = [self.userInputTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    cell.detailTextLabel.text = textField.text;
    self.adUnitId = textField.text;
}

- (void)didPressNext:(id)sender {
    [self verifyInput];
    
    LineItemAdsViewController *lineItemAdsViewController = [[LineItemAdsViewController alloc] init];
    [self.navigationController pushViewController:lineItemAdsViewController animated:YES];
}

- (void)verifyInput {
    UIAlertController *alertController = nil;
    if ([self.adServer isEqualToString:kDFPString] && [self.adFormat isEqualToString:kInterstitialString]) {
        alertController = [UIAlertController alertControllerWithTitle:kErrorMessageTitle message:@"We currently do not support DFP Interstitial on the Test App. Please choose a different ad server or format." preferredStyle:UIAlertControllerStyleAlert];
    }
    if ([self.adFormat isEqualToString:kInterstitialString] && ([self.adSize isEqualToString:kInterstitialSizeString] == NO)) {
        alertController = [UIAlertController alertControllerWithTitle:kErrorMessageTitle message:@"Interstitial must be of size 320x480. Please update ad size in the picker." preferredStyle:UIAlertControllerStyleAlert];
    }

    if (alertController) {
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:self.adServer forKey:kAdServerNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.adFormat forKey:kAdFormatNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.adSize forKey:kAdSizeKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.adUnitId forKey:kAdUnitIdKey];
    NSArray *bidPrices = [self.bidPrice componentsSeparatedByString:@","];
    [[NSUserDefaults standardUserDefaults] setObject:bidPrices forKey:kBidPriceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end