/*
 
 -Author: Krez
 -Organisation: Drona Aviation
 -Date: 01-09-2016
 *******************************************************
 
 Protocol and Interface for implementing MultiWi Serial Protocol for drone flight control
 
 
 
 */

#include <Foundation/Foundation.h>
#include "Communication.h"


#ifndef MultiWi230_h
#define MultiWi230_h


extern int8_t inputBuffer[1024];
extern uint8_t bufferIndex;
extern NSMutableArray* requests;

static const int MSP_API_VERSION = 1;
static const int MSP_FC_VARIANT=2;
static const int MSP_FC_VERSION=3;
static const int MSP_BOARD_INFO = 4;
static const int MSP_BUILD_INFO = 5;
static const int MSP_RAW_IMU=102;
static const int MSP_ATTITUDE=108;
static const int MSP_ALTITUDE=109;
static const int MSP_ANALOG=110;
static const int MSP_RC_TUNING = 111;
static const int MSP_PID = 112;
static const int MSP_MAX_ALT = 123;
static const int MSP_COMMAND = 124;
static const int MSP_SET_RAW_RC=200;
static const int MSP_SET_PID = 202;
static const int MSP_SET_RC_TUNING = 204;
static const int MSP_ACC_CALIBRATION=205;
static const int MSP_MAG_CALIBRATION=206;
static const int MSP_SET_MOTOR=214;
static const int MSP_SET_COMMAND = 217;
static const int MSP_SET_MAX_ALT = 218;
static const int MSP_APP_HEADING = 221;
static const int MSP_APP_GPS = 222;
static const int MSP_SET_ACC_TRIM=239;
static const int MSP_ACC_TRIM=240;
static const int MSP_EEPROM_WRITE = 250;
static const int MSP_FLIGHT_STATUS = 255;

extern int roll;
extern int pitch;
extern int yaw;
extern float battery;
extern int rssi;

extern float accX;
extern float accY;
extern float accZ;

extern float gyroX;
extern float gyroY;
extern float gyroZ;

extern float magX;
extern float magY;
extern float magZ;

extern float alt;

extern int FC_versionMajor;
extern int FC_versionMinor;
extern int FC_versionPatchLevel;
extern int MSP_PROTOCOL_VERSION, API_VERSION_MAJOR, API_VERSION_MINOR;
extern int trim_roll;
extern int trim_pitch;
extern int flightIndicatorFlag;

static const int PID_ITEMS = 10;
extern int byteP[], byteI[], byteD[];

extern int byteRC_RATE, byteRC_EXPO, byteRollPitchRate, byteYawRate, byteDynThrPID, byteThrottle_EXPO, byteThrottle_MID;

extern int maxAlt;
extern int current_command, command_status;

extern NSMutableString *FLIGHT_CONTROLLER_ID;

extern NSMutableString *BOARD_ID;

@protocol MultirotorProtocol <NSObject>

@required


-(void) sendRequestMSP:(NSMutableData*) data;
-(NSMutableData *) createPacketMSP:(int)msp withPayload:(NSMutableData * )payload;


-(void) sendRequestMSP_RAW_RC:(int [])channels8;

-(void) sendRequestMSP_DEBUG:(NSMutableArray *) requests;

-(void) sendRequestMSP_ATTITUDE;

-(void) sendRequestMSP_ACC_CALIBRATION;

-(void) sendRequestMSP_MAG_CALIBRATION;

-(void) sendRequestMSP_FC_VERSION;

-(void) sendRequest_Firmware_VERSION;

-(void) sendRequestMSP_BOARD_INFO;

-(void) sendRequest_Software_Info;

-(void) sendRequestMSP_SET_MOTOR:(int [])motors8;

-(void) sendRequestAT_WIFI_SETTINGS:(NSString *)ssid withPassword:(NSString *)password withChannel: (int)channel;

-(void) sendRequestMSP_ACC_TRIM;

-(void) sendRequestMSP_PID;

-(void) sendRequestMSP_RC_TUNING;

-(void) sendRequestMSP_GET_MAX_ALT;

-(void) sendRequestMSP_SET_MAX_ALT: (int)alt;

-(void) sendRequestMSP_SET_ACC_TRIM:(int)pitch and:(int)roll;

-(void) sendRequestMSP_SET_PID:(float)confRC_RATE and: (float)confRC_EXPO and
							  :(float) rollPitchRate and :(float) yawRate and :(float) dynamic_THR_PID and
							  :(float) throttle_MID and :(float) throttle_EXPO and :(float[]) confP and
							  :(float[]) confI and :(float[]) confD;

-(void) sendRequestMSP_GET_COMMAND;

-(void) sendRequestMSP_SET_COMMAND: (int)commandType;

-(void) sendRequest_Device_Heading: (int) heading;

-(void) sendReuestMSP_Analog;

-(void) sendRequestMSP_SET_GPS: (int) latitude and: (int) longitude;

-(void) sendRequestMSP_EEPROM_WRITE;

-(void) sendFlashCommands: (NSMutableArray *) command;

-(void) checkBootLoaderStatus;

-(void) EnableBootMode;

-(void) disableBootMode;

- (void) sendRequestParity : (NSString*) parity;

-(void) sendRequestFlushStream;

-(void) readDataDuringFlashMode;

-(void) removeInputStreamDelegate;

-(void) setInputStreamDelegate;

@end


@interface MultiWi230 : NSObject<MultirotorProtocol>{
	
}


+(int)read32;

+(int)read16;

+(int)read8;

+(void)evaluateCommand: (int)command and:(int)dataSize;

+(void)setWiFiCommunication:(WiFiCommunication *)WiFiConnection;

@end



#endif /* MultiWi230_h */
