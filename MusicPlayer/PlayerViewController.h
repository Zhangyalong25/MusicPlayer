//
//  PlayerViewController.h
//  MusicPlayer
//
//  Created by  liangzhun on 2018/6/28.
//  Copyright © 2018年  liangzhun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    
    MusicplayerTypeRound,
    MusicplayerTypeRandom,
    MusicplayerTypeSingleCircle,
    
} MusicplayerType;

@interface PlayerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *ModeBtn;
- (IBAction)changPlayMode:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *playbtn;

@property (weak, nonatomic) IBOutlet UISlider *progress;

@property (weak, nonatomic) IBOutlet UILabel *timeLab;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;

@property (weak, nonatomic) IBOutlet UITableView *tab;
- (IBAction)playLastSong:(UIButton *)sender;
- (IBAction)stopAndStart:(UIButton *)sender;
- (IBAction)playNextSong:(UIButton *)sender;
- (IBAction)valueChange:(UISlider *)sender;

@end
