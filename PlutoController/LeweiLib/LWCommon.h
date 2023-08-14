//
//  LW93Control.h
//  WL
//
//  Created by mark on 16/3/22.
//  Copyright © 2016年 LEWEI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <string.h>
//#import <vector.h>
//#import <map.h>
//using namespace std;
//
//struct  FilePathInfo{
//    string m_strName;
//    string m_strFullPath;
//    bool   m_bFind;    //¥”…Ë±∏±Ì÷–’“µΩ¡À¬∑æ∂.
//};
//
//struct FolderInfo
//{
//    FilePathInfo m_path;
//    vector<FilePathInfo >m_filesPath;
//};



@protocol FuncDelegate <NSObject>
@optional
- (void) DidUdpToUartTimer;
- (void) DidUartToUdpBuf:(unsigned char*)buf :(long)length;
- (void) DidUartToTcpBuf:(unsigned char*)buf :(long)length;
@end

@interface LWCommon : NSObject

@property (assign, nonatomic)  id<FuncDelegate> g_Delegate;

+(long long) GetFileSize :(const char *)szFileName;
- (void) UdpToUartReconnect;
- (void) UdpToUartStart:(int)timeInterval;
- (void) UdpToUartStop;
- (void) UdpToUartSend:(unsigned char*)buf ServerIP:(const char *)ip length:(int)length timeoutms:(int)timeout;
- (void) UartToTcpStart;
- (void) UartToTcpStop;
- (void) TcpToUartSend:(unsigned char*)buf ServerIP:(const char *)ip length:(int)length timeoutms:(int)timeout;
+(NSString *)GetMp4VideoSavePath;
+(NSString *)GetVideoSavePath; 
+(NSString *)GetImageSavePath;
+(NSString *)GetVersion;
+(NSString *)documentsPath:(NSString *)fileName;
//+(NSString *)strToNsstr:(string)strName;
//+ (void) ListDirInPath :(const char *)path :(map<string ,FilePathInfo>&) mapDir;
//+ (void) ListFileInPath :(const char *)path :(map<string ,FilePathInfo> &)mapDir :(const char *)szExt;
+ (void) DeleteFile:(const char *)path :(bool) bDelEmptyFolder;
+(unsigned int) GetTickCount;
+(void) saveVideoToSystemGallery :(NSString *)filename;
- (void) StartRecoderMjpeg:(const char *)FileName :(int)framerate;
- (void) StopRecorderMjpeg;
- (void) InputMjpegVideoData :(void *)pData :(const int)nLength;
- (void) InputMjpegAudioData :(void *)pData :(const int)nLength;
@end
