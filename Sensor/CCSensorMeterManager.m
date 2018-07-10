//
//  CCSensorMeterManager.m
//  CCSDK
//
//  Created by wangcong on 15/9/10.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCSensorMeterManager.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

#define kUpdateInterval (1 / 100.0f)

#define KG                                      9.88f           // 重力加速度

@interface CCSensorMeterManager ()

@property(nonatomic, strong) CMMotionManager *motionManager;

// 跳高
@property(nonatomic, strong) CMAccelerometerData *mUpAccelerometerData;             // 记录跳起点
@property(nonatomic, strong) CMAccelerometerData *mVertexAccelerometerData;         // 记录跳到最高点
@property(nonatomic, strong) CMAccelerometerData *mDownAccelerometerData;           // 记录落地点
@property(nonatomic, strong) NSMutableArray *mMutArrayAccelerometer;

// 挥拳
@property(nonatomic, strong) CCPunchMeterData *mPunchMeterData;                     // 挥拳数据记录
@property(nonatomic, strong) CMDeviceMotion *mPunchStartDeviceMotion;               // 开始挥拳的记录

@property(nonatomic, strong) CMDeviceMotion *mPunchMinDeviceMotion;                 // 用于记录正常或收拳时的数据
@property(nonatomic, strong) CMDeviceMotion *mPunchMaxDeviceMotion;                 // 用于记录出拳数据

@property(nonatomic, assign) NSInteger xMaxVectorCount;                             // 介于最大最小点之间 x 分向量最大点的个数
@property(nonatomic, assign) NSInteger yMaxVectorCount;                             // 介于最大最小点之间 y 分向量最大点的个数
@property(nonatomic, assign) NSInteger zMaxVectorCount;                             // 介于最大最小点之间 z 分向量最大点的个数

@end

@implementation CCSensorMeterManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onckToken;
    static CCSensorMeterManager *instance = nil;
    dispatch_once(&onckToken, ^{
        if (instance == nil) {
            instance = [[[self class] alloc] init];
        }
    });
    return instance;
}

+ (CGFloat)calculateCalorieWithStep:(NSInteger)numberOfSteps age:(NSInteger)age sex:(NSInteger)sex weight:(CGFloat)weight time:(NSTimeInterval)time
{
    //    另外的卡路里计算公式：
    //    英制
    //    距离：1mile=63360inch
    //    能量：每步能量=（体重(lb)-30)*0.000315+0.00495
    //    卡路里=每步能量*steps (kcal)
    //
    //    公制
    //    距离： 1KM=1000*100cm
    //    能量：每步能量=（体重（kg）-15）*0.000693+0.005895
    //    卡路里=每步能量*steps（kcal）
    
    //    基本热量 精确算法 单位（千卡路里）
    //    女子
    //    18- 30 岁 14.6 x 体重（公斤） + 450
    //    31- 60 岁 8.6 x 体重（公斤） + 830
    //    60岁以上 10.4 x 体重（公斤） + 600
    //
    //    男子
    //    18- 30 岁 15.2 x 体重（公斤）+ 680
    //    31- 60 岁 11.5 x 体重（公斤） + 830
    //    60岁以上 13.4 x 体重（公斤） + 490
    
    // 步行热量
    CGFloat stepKcal = numberOfSteps * ((weight - 15) * 0.000693 + 0.005895);
    
    // 基本热量
    CGFloat basicKcal = 0;
    if (age <= 30) {
        basicKcal = sex == 2 ? 14.6 * weight + 450 : 15.2 * weight + 680;
    } else if (age >= 31 && age <= 60) {
        basicKcal = sex == 2 ? 8.6 * weight + 830 : 11.5 * weight + 830;
    } else {
        basicKcal = sex == 2 ? 10.4 * weight + 600 : 13.4 * weight + 490;
    }
    basicKcal = basicKcal / (24 * 60 * 60) * time;
    return stepKcal + basicKcal;
}

+ (CGFloat)calculateDistanceWithStep:(NSInteger)numberOfSteps height:(CGFloat)height
{
    //    足迹长 = 身高 / 7
    //    复步长在166cm以上的一般为高个，身高＝复步长＋1/3足迹长；
    //    复步长在148cm--166cm以上的一般为中个，身高＝复步长＋1/2足迹长；
    //    复步长在140cm以下的一般为矮个，身高＝复步长＋2/3足迹长。
    //
    //    注释：这里的复步长就是左右脚各走两步所跨越的长度，即立正以后，一只脚先迈出一步，另外一只脚再迈出一步，这两次卖出的距离为一个复步长。过去用脚丈量土地，就是这样计算的，一般一个复步长为五尺。足迹长是指脚印的长度，男性平均足迹长为25cm； 女性平均足迹长为23cm。
    
    CGFloat distanceOfOneStep = 0;
    if (height > 166) {
        distanceOfOneStep = (height - height / 21.0) / 200.0;
    } else if (height > 148 && height <= 166) {
        distanceOfOneStep = (height - height / 14.0) / 200.0;
    } else {
        distanceOfOneStep = (height - 2 * height / 21.0) / 200.0;
    }
    return numberOfSteps * distanceOfOneStep;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.deviceMotionUpdateInterval = kUpdateInterval;
        self.motionManager.accelerometerUpdateInterval = kUpdateInterval;
        self.motionManager.gyroUpdateInterval = kUpdateInterval;
        self.motionManager.magnetometerUpdateInterval = kUpdateInterval;
        self.motionManager.showsDeviceMovementDisplay = YES;
    }
    return self;
}

#pragma mark - 跳高测试

#define kJumpMinTimeInterval                    0.26        // 滞空最小时长
#define kJumpMaxTimeInterval                    0.90        // 滞空最大时长
#define kJumpUpMinResultantVector               2.0f        // 起跳时的最小合向量
#define kJumpVertexMaxResultantVector           0.12f       // 跳高到顶点时合向量最大值
#define kJumpDownMinResultantVector             4.5f        // 跳高回落到地面产生的合向量需要达到的最小值

- (void)startHighMeterWithHandler:(CCHighMeterHandler)handler
{
    if (self.motionManager.isAccelerometerAvailable) {
        if (!self.motionManager.isAccelerometerActive) {
            @weakify(self);
            [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                
                if (error) return;
                
                @strongify(self);
                CGFloat vector = [self _calculateResultantVector:accelerometerData];
                
                // 合向量大于一定数值，并且不存在最小值视为起始点
                if (vector > kJumpUpMinResultantVector && vector < kJumpDownMinResultantVector) {
                    if (self.mVertexAccelerometerData == nil && (!self.mUpAccelerometerData ||
                        vector > [self _calculateResultantVector:self.mUpAccelerometerData])) {
                        self.mUpAccelerometerData = accelerometerData;
                    }
                } else if (vector > kJumpDownMinResultantVector) {
                    // 合向量大于一定的数值，并且存在最小合向量才表示跳高，规避打拳晃动等影响
                    if (self.mVertexAccelerometerData != nil && (!self.mDownAccelerometerData ||
                        vector > [self _calculateResultantVector:self.mDownAccelerometerData])) {
                        self.mDownAccelerometerData = accelerometerData;
                    }
                } else if (vector < kJumpVertexMaxResultantVector) {       // 得到第一个小于0.15的那个点
                    if (self.mVertexAccelerometerData == nil ||
                        vector < [self _calculateResultantVector:self.mVertexAccelerometerData]) {
                        self.mVertexAccelerometerData = accelerometerData;
                    }
                }
                
                // 过滤任意晃动产生的起始点
                if (accelerometerData.timestamp - self.mUpAccelerometerData.timestamp > kJumpMaxTimeInterval) {
                    self.mUpAccelerometerData = nil;
                    self.mVertexAccelerometerData = nil;
                    self.mDownAccelerometerData = nil;
                }
                
                // 符合波形
                if (self.mUpAccelerometerData != nil &&
                    self.mVertexAccelerometerData != nil &&
                    self.mDownAccelerometerData != nil) {
                    
                    __block NSTimeInterval timeInterval = self.mDownAccelerometerData.timestamp - self.mUpAccelerometerData.timestamp;
                    self.mUpAccelerometerData = nil;
                    self.mVertexAccelerometerData = nil;
                    self.mDownAccelerometerData = nil;
                    
                    // 过滤掉时间过长过段不符合规则的数据
                    if (timeInterval < kJumpMinTimeInterval || timeInterval > kJumpMaxTimeInterval) return;
                    
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        timeInterval = timeInterval / 2.0;
                        handler(KG * timeInterval * timeInterval / 4.0f, nil);
                    }];
                }
            }];
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"CCSensorMeterManager只能同时测试一种运动，请检查其他运动测试是否已关闭" code:0 userInfo:nil];
            handler(-1, error);
        }
    } else {
        NSError *error = [[NSError alloc] initWithDomain:@"你的设备太差了，不支持Accelerator" code:0 userInfo:nil];
        handler(-1, error);
    }
}

- (void)stopHighMeter
{
    if (self.motionManager.isAccelerometerActive) {
        [self.motionManager stopAccelerometerUpdates];
        self.mUpAccelerometerData = nil;
        self.mVertexAccelerometerData = nil;
        self.mDownAccelerometerData = nil;
    }
}

#pragma mark - 挥拳测试

#define kPunchOutMaxZVector                     4.5             // z 轴向量最大值
#define kPunchOutMaxYVector                     4.5             // y 轴向量最大值
#define kPunchOutMinFemaleVector                6.5             // 女出拳最小加速度
#define kPunchOutMinMaleVector                  7.5             // 男出拳最小加速度

#define kPunchNormalOrInMaxVector               1.30            // 用于判定必须存在最小值，过滤出拳后震动引起的两次计数

- (void)startPunchMeterWithTestingTime:(NSTimeInterval)testingTime sex:(CCSex)sex handler:(CCPunchMeterHandler)handler
{
    if (self.motionManager.isDeviceMotionAvailable) {
        if (!self.motionManager.isDeviceMotionActive) {
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = 1;
            @weakify(self);
            [self.motionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion *motion, NSError *error) {
                
                @strongify(self);
                if (self.mPunchStartDeviceMotion == nil) {
                    self.mPunchStartDeviceMotion = motion;
                    self.mPunchMeterData = [[CCPunchMeterData alloc] init];
                }
                
                // 达到最大testingTime 自动结束挥拳计算
                if (motion.timestamp - self.mPunchStartDeviceMotion.timestamp > testingTime) {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                    handler(self.mPunchMeterData, YES, nil);
                    [self stopPunchMeter];
                }
                
                // 出拳或者收拳时的角速度必须 gravity.y > gravity.x (45°) 视为有效，防止用户向下或向上出拳不规范
                if (fabs(motion.gravity.y) > fabs(motion.gravity.x)) {
                    
                    CGFloat vector = [self _calculateResultantVectorWithAcceleration:motion.userAcceleration];
                    CGFloat tmpMinVector = sex == CCSEX_MALE ? kPunchOutMinMaleVector : kPunchOutMinFemaleVector;
                    if (vector > tmpMinVector) {
                        if (self.mPunchMinDeviceMotion != nil && ( self.mPunchMaxDeviceMotion == nil || vector > [self _calculateResultantVectorWithAcceleration:self.mPunchMaxDeviceMotion.userAcceleration])) {
                            self.mPunchMaxDeviceMotion = motion;
                        }
                    } else if (vector < kPunchNormalOrInMaxVector) {
                        self.mPunchMinDeviceMotion = motion;
                    
                        self.xMaxVectorCount = 0;
                        self.yMaxVectorCount = 0;
                        self.zMaxVectorCount = 0;
                    }
                    
                    // 每次对各个方向计数
                    if (self.mPunchMinDeviceMotion != nil) {
                        CGFloat maxVector = MAX(MAX(fabs(motion.userAcceleration.x), fabs(motion.userAcceleration.y)), fabs(motion.userAcceleration.z));
                        if (maxVector == fabs(motion.userAcceleration.x)) {
                            self.xMaxVectorCount += 1;
                        } else if (maxVector == fabs(motion.userAcceleration.y)) {
                            self.yMaxVectorCount += 1;
                        } else {
                            self.zMaxVectorCount += 1;
                        }
                        
//                        NSLog(@"fuck     %f    %f     %f   %f   %f    %f   %f    %f", motion.userAcceleration.x, motion.userAcceleration.y, motion.userAcceleration.z, motion.gravity.x, motion.gravity.y, motion.gravity.z, vector, [self _calculateResultantVectorWithAcceleration:self.mPunchMinDeviceMotion.userAcceleration]);
                    }
                    
                    // 找到了最大与最小点
                    if (self.mPunchMinDeviceMotion != nil && self.mPunchMaxDeviceMotion != nil &&
                        vector < [self _calculateResultantVectorWithAcceleration:self.mPunchMaxDeviceMotion.userAcceleration]) {
                        
                        // 判定在x方向上的合向量个数大于 y 及 z 则视为打拳
                        if (self.xMaxVectorCount > self.yMaxVectorCount && self.xMaxVectorCount > self.zMaxVectorCount) {
                            
//                            NSLog(@"%lu    %lu    %lu", self.xMaxVectorCount, self.yMaxVectorCount, self.zMaxVectorCount);
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                            self.mPunchMeterData.puchTimes += 1;
                            self.mPunchMeterData.passedTime = motion.timestamp - self.mPunchStartDeviceMotion.timestamp;
                            self.mPunchMeterData.testingTime = testingTime;
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                handler(self.mPunchMeterData, NO, nil);
                            }];
                        }
                        
                        self.mPunchMinDeviceMotion = nil;
                        self.mPunchMaxDeviceMotion = nil;
                        self.xMaxVectorCount = 0;
                        self.yMaxVectorCount = 0;
                        self.zMaxVectorCount = 0;
                    }
                }
            }];
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"CCSensorMeterManager只能同时测试一种运动，请检查其他运动测试是否已关闭" code:0 userInfo:nil];
            handler(nil, YES,error);
        }
    } else {
        NSError *error = [[NSError alloc] initWithDomain:@"你的设备太差了，不支持Accelerator" code:0 userInfo:nil];
        handler(nil, YES,error);
    }
}

- (void)stopPunchMeter
{
    if (self.motionManager.isDeviceMotionActive) {
        [self.motionManager stopDeviceMotionUpdates];
        self.mPunchStartDeviceMotion = nil;
        self.mPunchMinDeviceMotion = nil;
        self.mPunchMaxDeviceMotion = nil;
        self.xMaxVectorCount = 0;
        self.yMaxVectorCount = 0;
        self.zMaxVectorCount = 0;
    }
}

#pragma mark - private

/**
 *  计算合向量
 *  @param acceleration
 *  @return
 */
- (CGFloat)_calculateResultantVector:(CMAccelerometerData *)accelerometerData
{
    CMAcceleration acceleration = accelerometerData.acceleration;
    return sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z);
}

/**
 *  计算合向量
 *  @param acceleration
 *  @return
 */
- (CGFloat)_calculateResultantVectorWithAcceleration:(CMAcceleration)acceleration
{
    return sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z);
}

@end
