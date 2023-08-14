//
//  LWManage.h
//  LW93Control
//
//  Created by mark on 16/10/4.
//  Copyright © 2016年 mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>





#define JPEG_TYPE 1
#define RAW_BITMAP_TYPE_480P 2
#define RAW_BITMAP_TYPE_576P 3
#define RAW_BITMAP_TYPE_720P 4

#define DOWNLOAD_START 1
#define DOWNLOAD_ERROR 2
#define DOWNLOAD_SUCCESS 3


#define LW63_LW_AESKEY      0x000001   //63乐为公版加密
#define LW63_LW_NO_AESKEY   0x000002   //63乐为公版不加密
#define LW63_HK_AESKEY      0x000004   //63辉科专用加密
#define LW63_UDIRC_AESKEY   0x000008   //63优迪专用加密
#define LW63_GX_NO_AESKEY   0x000010   //63冠旭公版不加密

#define LW23_XYZJ_AESKEY    0x000020
#define LW23_WL2_AESKEY     0x000040



#define LW93_LW_AESKEY      0x000100   //93乐为公版只加密
#define LW93_LW             0x000200   //93乐为公版兼容和不加密
#define LW93_HK_AESKEY      0x000400   //93辉科专用加密
#define LW93_YKQY_AESKEY    0x000800   //93遥控前沿专用加密


#define LW23_HK_AESKEY      0x001000   //23辉科专用加密
#define LW93_WL2_AESKEY     0x002000   //93伟力二厂专用加密
#define LW93_INDIA_AESKEY   0x004000   //印度客户专用加密

#define LW_YD_ANGBAO_LIANXIN_AESKEY      0x008000   //雅得 昂宝 联芯 雅联





#define LW63_BAUDRATE_9600  0x010000   //63波特率9600
#define LW63_BAUDRATE_19200 0x020000   //63波特率19200



#define USER_SDK_LEWEI_LW63_LW93                        (LW63_LW_AESKEY|LW63_LW_NO_AESKEY|LW93_LW|LW63_BAUDRATE_19200)
#define USER_SDK_LEWEI_LW63_AESKEY_LW93_AESKEY          (LW63_LW_AESKEY|LW93_LW_AESKEY|LW63_BAUDRATE_19200)
#define USER_SDK_LEWEI_LW63_LW93_AESKEY                 (LW63_LW_AESKEY|LW63_LW_NO_AESKEY|LW93_LW_AESKEY|LW63_BAUDRATE_19200)
#define USER_SDK_UDIRC                                  (LW63_LW_AESKEY|LW63_UDIRC_AESKEY|LW63_LW_NO_AESKEY|LW93_LW|LW63_BAUDRATE_19200)
#define USER_SDK_HK                                     (LW63_HK_AESKEY|LW93_HK_AESKEY|LW23_HK_AESKEY|LW63_BAUDRATE_19200)
#define USER_SDK_YKQY                                   (LW63_LW_AESKEY|LW63_GX_NO_AESKEY|LW93_LW|LW63_BAUDRATE_19200)
#define USER_SDK_YKQY_AESKEY                            (LW63_LW_AESKEY|LW63_GX_NO_AESKEY|LW93_YKQY_AESKEY|LW63_BAUDRATE_19200)
#define USER_SDK_ZC_LW63_AESKEY_LW93_AESKEY_9600        (LW63_LW_AESKEY|LW93_LW_AESKEY|LW63_BAUDRATE_9600)



#define USER_SDK_WL2_AESKEY                             (LW63_LW_AESKEY|LW93_WL2_AESKEY|LW63_BAUDRATE_19200)

#define USER_SDK_INDIA_AESKEY                           (LW93_INDIA_AESKEY|LW63_BAUDRATE_19200)

#define USER_SDK_YD_ANGBAO_LIANXIN_AESKEY               (LW_YD_ANGBAO_LIANXIN_AESKEY|LW63_BAUDRATE_19200)


#define LWALL_snapPhoto_default                         0x00000000
#define LW23_snapPhoto_640X480_amplifyTo_960_720        0x00000001
#define LW23_snapPhoto_640X480_amplifyTo_1280_960       0x00000002
#define LW23_snapPhoto_640X360_amplifyTo_1280_720       0x00000004
#define LW96_snapPhoto_1280X720_amplifyTo_1920X1080     0x00000010
#define LW96_snapPhoto_1280X720_amplifyTo_2389X1344     0x00000020
#define LW96_snapPhoto_1920X1080_amplifyTo_4096X2160    0x00000040
#define LW96_snapPhoto_1920X1080_amplifyTo_2592X1936    0x00000080


#define LWALL_Video_default                             0x00000000
#define LW96_Video_640X368_amplifyTo_1920_1080          0x00000001
#define LW96_Video_1280X720_amplifyTo_1920X1080         0x00000002
#define LW23_Video_640X480_amplifyTo_1280X960           0x00000010





#define MediaPlayStyleDefault    0
#define MediaPlayStyleUdirc      1


typedef enum
{
    CONNECT_NONE = 0x0,
    CONNECT_LW63,
    CONNECT_LW93,
    CONNECT_LW23,
    CONNECT_DEVICE_CAMERA,
    CONNECT_LW72,
}Connect_e;


typedef enum
{
    DEVICE_CAMERA_NONE = 0x0,
    DEVICE_CAMERA_BACK,
    DEVICE_CAMERA_FRONT,
}Device_Camera_e;

typedef enum
{
    VIEW_State_Logo = 0x01,
    VIEW_State_RealPlay,
    VIEW_State_PlaybackSelect,
    VIEW_State_DevPlayback,
    VIEW_State_DevPlaybackList,
    VIEW_State_Download,
}VIEW_State_e;

#pragma pack(push, 1)
#pragma pack(1)
typedef struct _LW_INFO_T
{
    uint8_t ssid[32];
    uint8_t password[32];
    uint8_t channel;
    uint8_t cameraValue;
    uint8_t qbValue;
    uint8_t bandrate;
    uint8_t droneType;
    uint8_t resolution;
    uint8_t spare[29];
}lw_info_t;

typedef  struct _LEWEI_CAMERA_RESO {
    uint16_t  widht;
    uint16_t  height;
    uint8_t   fps;
}lewei_camera_resolution, *Plewei_camera_resolution;

typedef  struct _LEWEI_CAMERA_RESO_LIST
{
    lewei_camera_resolution resolution[20];
    uint16_t   resolution_cnt;
}lewei_camera_reso_list, *Plewei_camera_reso_list;
#pragma pack(pop)

typedef struct object_rect_t {
    float xScale[5];
    float yScale[5];
    float widthScale[5];
    float heightScale[5];
    float score[5];
} object_tracker_rect_t;

@protocol FuncManageDelegate <NSObject>
@optional
-(void)startCardRecord;
-(void)stopCardRecord;
-(void)startLocalRecord;
-(void)startLocalRecordAndFilename :(NSString*)filename;
-(void)stopLocalRecord;
-(void)recordVideoTime :(int)second;
-(void)playbackCardFileCurrentTime :(int)curTime TotalTime:(int)totalTime;
-(void)downloadStatus :(int)value;
-(void)downloadProgress :(float)value;
-(void)didFrameRate :(int)framerate KBps:(int)bps;
-(void)didWiFiSignal :(int)value;
-(void)didCardListReloadData;
-(void)didUserLogin:(char *)buf;
-(void)didLW23UartToUdp :(unsigned char*)buf Length:(long)length;
-(void)didLW23Info :(lw_info_t)info;
-(void)didUpdateImg;
-(void)didImageData :(char *)imgbuf Length:(int)length Type:(int)type;
-(void)didFinishSnap;
-(void)didLW23FrameIndex:(unsigned int)frameIndex;
-(void)didDeviceKey :(int)keyValue;
-(void)didAdc_status:(int)status;
-(void)didUvcCameraStatus:(unsigned char)status;

-(void)didWarnDiskNoFreeSpace:(int)freeSpaceMB;
-(void)didLW23ReceiveDeviceReply:(int)type;
-(void)didRoll:(int)roll Pitch:(int)pitch Yaw:(int)yaw;
-(void)didHandTrackType :(int) handType TypeName:(NSString *)handName Score:(float)scroe Xscale:(float)xScale Yscale:(float)yScale Widthscale:(float)widthScale Heightscale:(float)heightScale;
-(void)didObjectTrack :(int) track_flag Score:(float)score Xscale:(float)xScale Yscale:(float)yScale Widthscale:(float)widthScale Heightscale:(float)heightScale;
-(void)didObjectDetectResult :(int)value;


-(void)didDetectObject :(object_tracker_rect_t) objectRect ObjectNum:(int)objectCount;
@end


@interface LWManage : NSObject
{
    
}

@property (assign, nonatomic)  id<FuncManageDelegate> delegate;



-(instancetype)initWithView :(UIImageView *)imgMainView SecondView:(UIImageView *)imgSecondView PlaylistTableView:(UITableView *)tableview User:(int)user;


-(void)StartManageServer;
-(void)StopManageServer;
-(Connect_e)getConnectType;
-(void)setConnectType :(Connect_e)type;
-(void)setViewStatus :(VIEW_State_e)status;
-(VIEW_State_e)getViewStatus;
-(void)snapPhoto;
-(void)snapPhoto:(NSString *)filename;

-(void)snapPhoto_23_1280_960_96_2389_1344;//23 1280X960  96 if 1920 =1920 if 1280  2389*1344
-(void)snapPhoto_new :(int)snapType :(NSString *)filename;
-(void)snapPhoto_new :(int)snapType :(NSString *)filename;
-(void)setSnapDefault :(int)snapType;
-(void)setVideoDefault :(int)videoType;


-(void)snapThreePhoto;//default 200ms
-(void)snapThreePhoto:(int)ms;
-(void)reconnect;
-(void)recordVideo;
-(void)recordVideo:(NSString *)filename;
-(void)recordVideoLocalAndCard;
-(void)recordVideoCard;
-(void)recordLocalVideo;
-(void)stopLocalRecordVideo;
-(void)deleteCardFile :(NSInteger)row;
-(void)playCardFile :(NSInteger)row;
-(void)cameraFlip;
-(int)getWiFiChannel;
-(void)wifiChannel :(unsigned char)channel;
-(void)wifiSsid :(char *)ssid;
-(void)uvcLedKey;
-(unsigned int)getCardStatus;
-(void)searchCardRecordList;
-(void)searchCardPicList;
-(NSInteger)cardRecordFileCount;
-(NSString *)cardRecordFileName :(NSInteger)row;
-(void)setPlaybackStatus :(bool)value;
-(void)setPreviewMode :(int)flag;
-(void)startDownload :(NSInteger)row;
-(void)stopDownload;
-(NSString *)downloadFilePath;
-(void)SendUartData: (unsigned char *)buf Length:(int)length;
-(void)ChangeDecodeImgView :(UIImageView *)imgMainView SecondView:(UIImageView *)imgSecondView;
-(bool)getPermission;
-(void)setArMode :(bool) flag;
-(void)supportAudioRecord :(bool) flag;
-(void)insertFrameEnable;
-(void)setSupportBitmap :(bool) flag;
-(void)deviceCameraType :(Device_Camera_e)type;
-(void)addExif :(bool)flag :(CLLocationCoordinate2D)coordinate;
-(void)addWaterLogo:(NSString *)imageName Xpost:(float)x Ypost:(float)y Enable:(bool)flag;
-(void)addWaterTimeXpost:(float)x Ypost:(float)y Enable:(bool)flag;
-(void)enterBackground;
-(unsigned char)getModule_type;
-(int)getCurLumFactor;




-(void)wifiPassword :(char *)pwd;
-(void)clearWiFiPassword;
-(void)deviceReboot;
-(void)setAutoRecordTimeInterVal:(int)second;
-(int)changeWiFiCountry :(int)countryCode;
-(int)bindMacControl :(int) flag;  //return -1 false  0 other device has bind 1 bind ok

-(void)supportPhotosAlbum :(bool) flag;
-(unsigned char)getFollowType;
-(int)initHandTrack;
-(void)beginHandTrack;
-(void)endHandTrack;

-(int)initObjectTrack;//init Object Track func
-(void)beginTrackObjectXscale :(float)xScale Yscale:(float)yScale WidthScale:(float)widthscale Heightscale:(float)heightscale :(bool)otherObject;


-(void)beginTrackObject;
-(void)endTrackObject;//end track Object
-(void)setPlayerStyle :(int)type;



-(void)getUvcCameraResolution :(lewei_camera_reso_list *) resolutionList;
-(int)setUvcCameraResolution :(lewei_camera_resolution) resolution;


@end
