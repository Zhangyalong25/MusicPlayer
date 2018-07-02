//
//  PlayerViewController.m
//  MusicPlayer
//
//  Created by  liangzhun on 2018/6/28.
//  Copyright © 2018年  liangzhun. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MusicWordsTableViewCell.h"
#define kBaseSetColor_RGBA(rd, ge, be, al) ([UIColor colorWithRed:(rd/255.0f) green:(ge/255.0f) blue:(be/255.0f) alpha:al])

static NSString *const Cell =@"MusicWordsTableViewCell";
@interface PlayerViewController ()<AVAudioPlayerDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSArray *wordsArray;
    NSArray *arraySongs;
}

@property(nonatomic,assign)MusicplayerType playType;

@property(nonatomic,assign)BOOL play;

@property(nonatomic,strong)NSTimer *time;

@property(nonatomic,assign)int now;

@property(nonatomic,assign)int allTime;

@property(nonatomic,strong)AVAudioPlayer *player;

@property(nonatomic,assign)int nowPlaySong;

@property(nonatomic,strong)NSIndexPath *showIndexPath;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    //self.bottomViewHeight.constant = [UIApplication sharedApplication].statusBarFrame.size.height > 20? self.bottomViewHeight.constant + 34 : self.bottomViewHeight.constant;
    arraySongs = @[@"qing",@"quan",@"ai",@"tian",@"yun",@"zhuqiu",@"That+Girl+-+Olly+Murs"];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [self.progress setThumbImage:[UIImage imageNamed:@"jindu"] forState:UIControlStateNormal];

    [self.progress setMaximumTrackTintColor:[UIColor colorWithRed:0.1 green:0.31 blue:0.61 alpha:0.8]];
    [self.progress setMinimumTrackTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8]];
    [self.ModeBtn setTitle:@"循环" forState:UIControlStateNormal];

    [self.player addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil ];
    
    self.play = self.playbtn.selected = YES;
    [self.playbtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
   // [self.playbtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateHighlighted];
    [self.playbtn setImage:[UIImage imageNamed:@"bofang"] forState:UIControlStateSelected];
    self.playbtn.selected = self.play;
    self.time = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(seeTime) userInfo:nil repeats:YES];
    [self playMusic];
    
    [self.tab registerNib:[UINib nibWithNibName:Cell bundle:nil] forCellReuseIdentifier:Cell];
}
- (void)scr{
    
    for (int i = 0; i < wordsArray.count; i++) {
        
        NSString *timeStr = [wordsArray[i] componentsSeparatedByString:@"]"].firstObject;
        NSTimeInterval time  = [[timeStr componentsSeparatedByString:@":"].firstObject intValue] * 60 +[[timeStr componentsSeparatedByString:@":"].lastObject floatValue];
        
        if (time < self.player.currentTime) {
            
            self.showIndexPath = [NSIndexPath  indexPathForRow:i inSection:0];
            [self.tab scrollToRowAtIndexPath:self.showIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            [self.tab reloadData];
            
        }
        
    }
    
    
}
#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return wordsArray.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    MusicWordsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
    [cell.words setText:[wordsArray[indexPath.row] componentsSeparatedByString:@"]"].lastObject];
    NSInteger font = self.showIndexPath == indexPath? 19 : 16;
    UIColor *color = self.showIndexPath == indexPath? kBaseSetColor_RGBA(43, 206, 63, 0.8) : kBaseSetColor_RGBA(255, 255, 255, 0.7);
    [cell.words setFont:[UIFont systemFontOfSize:font]];
    [cell.words setTextColor:color];
    return cell;
    
}

//- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
//    UITableViewRowAction *ac = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//    }];
//    ac.backgroundColor = [UIColor blueColor];
//
//    UITableViewRowAction *ac2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//    }];
//
//    ac2.backgroundColor = [UIColor redColor];
//    UITableViewRowAction *ac3 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//    }];
//    ac3.backgroundColor = [UIColor greenColor];
//    return @[ac,ac2,ac3];
    
//}
- (void)playMusic{
    
    self.now = 0;
    
    if (self.player)self.player = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:arraySongs[self.nowPlaySong] ofType:@".mp3"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
   
    self.player.delegate = self;
    [self.player play];
    self.player.volume = 0.5;
    self.progress.minimumValue = 0;
    self.allTime = self.player.duration;
    self.progress.maximumValue = self.allTime;
    NSString *min = [[NSString stringWithFormat:@"%.2f",self.allTime/60/100.0] componentsSeparatedByString:@"."].lastObject;
    NSString *sec = [[NSString stringWithFormat:@"%.2f",self.allTime%60/100.0] componentsSeparatedByString:@"."].lastObject;
    self.timeLab.text = [NSString stringWithFormat:@"00:00/%@:%@",min,sec];
    
    NSString *pathWord = [[NSBundle mainBundle] pathForResource:arraySongs[self.nowPlaySong] ofType:@"txt"];
    NSString *word = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:pathWord] encoding:NSUTF8StringEncoding];
    
    wordsArray = [word componentsSeparatedByString:@"["];
    [self.tab reloadData];
    [self configNowPlayingInfoCenter];
    
}
- (void)seeTime{
    
    self.now += 1;
    [self setTime];
    self.progress.value = self.now;
    
    if(self.player){
                //当前播放时间
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
        [dict setObject:[NSNumber numberWithDouble:self.player.currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经过时间
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        
        }
    
    [self scr];
    
    if (self.now >= self.allTime) {
        
        self.now = 0;
        return;
        
    }

}
- (void)setTime{
    
    NSString *min = [[NSString stringWithFormat:@"%.2f",self.now/60/100.0] componentsSeparatedByString:@"."].lastObject;
    NSString *sec = [[NSString stringWithFormat:@"%.2f",self.now%60/100.0] componentsSeparatedByString:@"."].lastObject;
    
    NSString *remindmin = [[NSString stringWithFormat:@"%.2f",(self.allTime-self.now)/60/100.0] componentsSeparatedByString:@"."].lastObject;
    NSString *remindsec = [[NSString stringWithFormat:@"%.2f",(self.allTime-self.now)%60/100.0] componentsSeparatedByString:@"."].lastObject;
    
    self.timeLab.text = [NSString stringWithFormat:@"%@:%@/%@:%@",min,sec,remindmin,remindsec];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)changPlayMode:(UIButton *)sender {
    
    _playType = _playType == MusicplayerTypeRound ? MusicplayerTypeRandom:_playType == MusicplayerTypeRandom ? MusicplayerTypeSingleCircle:MusicplayerTypeRound;
    NSString *str = _playType == MusicplayerTypeRound? @"循环":_playType == MusicplayerTypeRandom ? @"随机":@"单曲";
    
    [self.ModeBtn setTitle:str forState:UIControlStateNormal];
    
}
- (IBAction)playLastSong:(UIButton *)sender {
    
    self.nowPlaySong -= 1;
    if (self.nowPlaySong < 0) self.nowPlaySong = (int)arraySongs.count - 1;
    
    [self playMusic];
    //deviceCurrentTime
}

- (IBAction)stopAndStart:(UIButton *)sender {
    
    self.play = !self.play;
    sender.selected = self.play;
    
    //self.play ?[] :[self.player playAtTime:<#(NSTimeInterval)#>];
    if (self.play) {
        
        [self.player play];
        [self.time setFireDate:[NSDate distantPast]];
        
        
    }else{
        
        [self.player stop];
        [self.time setFireDate:[NSDate distantFuture]];
        
    }
    
}
- (IBAction)playNextSong:(UIButton *)sender {
    
    self.nowPlaySong+=1;
    if (self.nowPlaySong > arraySongs.count - 1) self.nowPlaySong = 0;
    [self playMusic];
    
}

- (IBAction)valueChange:(UISlider *)sender {

    self.now = sender.value;
    [self.player setCurrentTime:sender.value];
    [self setTime];
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    self.nowPlaySong = self.playType == MusicplayerTypeRound ? self.nowPlaySong+=1 :self.playType == MusicplayerTypeRandom ? (int)random()%(arraySongs.count - 1):self.nowPlaySong;
    if (self.nowPlaySong > arraySongs.count - 1) self.nowPlaySong = 0;
    [self playMusic];
    
}
- (void)dealloc{
   
    [self.time invalidate];
    self.time = nil;

    //self.player.numberOfLoops = 0;
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    
    if (self.player){
        [self.player stop];
        self.player.delegate = nil;
        self.player = nil;
    }
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
}
- (BOOL)becomeFirstResponder{
  return YES;
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    
    switch (event.subtype) {
            
                       case UIEventSubtypeRemoteControlTogglePlayPause:
                           //[self stopAndStart:nil];
                           break;
            
                        case UIEventSubtypeRemoteControlPreviousTrack:
                            [self playLastSong:nil];
                            break;
            
                        case UIEventSubtypeRemoteControlNextTrack:
                            [self playNextSong:nil];
                            break;
            
                        case UIEventSubtypeRemoteControlPlay:
                           // [self stopAndStart:nil];
                            break;
            
                        case UIEventSubtypeRemoteControlPause:
                            //[self stopAndStart:nil];
                            break;
            
                        default:
                            break;
              }
    
}
-(void)configNowPlayingInfoCenter{
    
         if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
             
             MPRemoteCommandCenter  *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
              //NSDictionary *info = [self.musicList objectAtIndex:_playIndex];
              NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
       
              //歌曲名称
              [dict setObject:@"name" forKey:MPMediaItemPropertyTitle];
       
               //演唱者
               [dict setObject:@"singer" forKey:MPMediaItemPropertyArtist];
       
               //专辑名
               [dict setObject:@"album" forKey:MPMediaItemPropertyAlbumTitle];
       
               //专辑缩略图
               UIImage *image = [UIImage imageNamed:@"image"];
               MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
               [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
       
             
               [dict setObject:[NSNumber numberWithDouble:self.player.duration] forKey:MPMediaItemPropertyPlaybackDuration];
       
               //音乐当前播放时间 在计时器中修改
               [dict setObject:[NSNumber numberWithDouble:self.now] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
       
               //设置锁屏状态下屏幕显示播放音乐信息
             if (@available(iOS 9.1, *)) {
                 [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                     
                     MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
                     self.progress.value = playbackPositionEvent.positionTime;
                     [self valueChange:self.progress];
                     return MPRemoteCommandHandlerStatusSuccess;
                 }];
                 
                 [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                     [self playNextSong:nil];
                     return MPRemoteCommandHandlerStatusSuccess;
                 }];
                 
                 [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                     [self playLastSong:nil];
                     return MPRemoteCommandHandlerStatusSuccess;
                 }];
                 
                 [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                     [self stopAndStart:nil];
                     return MPRemoteCommandHandlerStatusSuccess;
                 }];
                 
                 [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                     [self stopAndStart:nil];
                     return MPRemoteCommandHandlerStatusSuccess;
                 }];
                 
                 
             } else {
                 // Fallback on earlier versions
             }
             
               [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
             
           }
    }
@end
