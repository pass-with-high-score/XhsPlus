#import <UIKit/UIKit.h>
#import "XhsSettingsViewController.h"

@interface XYSettingNavigationBar : UINavigationBar
@end

%hook XYSettingNavigationBar

- (void)layoutSubviews {
    %orig;

    NSLog(@"[XhsPlus] layoutSubviews in XYSettingNavigationBar");

    // Tránh thêm nhiều lần
    if ([self viewWithTag:9999]) return;

    UIButton *xhsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [xhsButton setTitle:@"⚙️" forState:UIControlStateNormal];
    xhsButton.frame = CGRectMake(self.bounds.size.width - 60, 40, 50, 36);
    xhsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    xhsButton.tag = 9999;

    [xhsButton addTarget:self action:@selector(xhs_openSettings) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:xhsButton];
}

%new
- (void)xhs_openSettings {
    NSLog(@"[XhsPlus] 点击导航栏按钮，打开设置");
    [XhsSettingsViewController showSettings];
}

%end



@interface XYTabBar : UIView
@property (nonatomic, copy) NSArray *tabs;
@end

%hook XYTabBar

- (void)layoutSubviews {
    %orig;
    
    if (self.subviews.count >= 3) {
        BOOL removeShoppingTab = [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_tab_shopping"];
        BOOL removePostTab = [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_tab_post"];
        
        if (removeShoppingTab && removePostTab) {
            [[self.subviews objectAtIndex:1] removeFromSuperview];
            [[self.subviews objectAtIndex:1] removeFromSuperview];
        } else {
            if (removeShoppingTab) {
                [[self.subviews objectAtIndex:1] removeFromSuperview];
            }
            if (removePostTab) {
                [[self.subviews objectAtIndex:2] removeFromSuperview];
            }
        }
    }

    CGFloat tabWidth = CGRectGetWidth(self.bounds) / self.subviews.count;
    CGFloat xPosition = 0;
    
    for (UIView *subview in self.subviews) {
        CGRect frame = subview.frame;
        frame.origin.x = xPosition;
        frame.size.width = tabWidth;
        subview.frame = frame;
        
        xPosition += tabWidth;
    }
}

%end

%hook XYPHMediaSaveConfig

- (void)setDisableWatermark:(_Bool)arg1 {
    BOOL removeWatermark = [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_save_watermark"];
    %orig(removeWatermark);
}

- (void)setDisableSave:(_Bool)arg1 {
    BOOL forceSaveMedia = [[NSUserDefaults standardUserDefaults] boolForKey:@"force_save_media"];
    if (forceSaveMedia) {
        %orig(NO);
    } else {
        %orig(arg1);
    }
}
%end