/*
 
 -Author: Krez
 -Organisation: Drona Aviation
 -Date: 01-09-2016
 *******************************************************
 
 Implementation of MultiWi Serial Protocol for drone flight control
 
 */


#include <Foundation/Foundation.h>

#import <math.h>
#import "MultiWi230.h"
#import "Communication.h"

const NSString* MSP_HEADER=@"$M<";

int8_t inputBuffer[1024];
uint8_t bufferIndex=0;
NSMutableArray* requests;

int roll=0;
int pitch=0;
int yaw=0;
float battery=0;

float accX=0;
float accY=0;
float accZ=0;

float gyroX=0;
float gyroY=0;
float gyroZ=0;

float magX=0;
float magY=0;
float magZ=0;
float alt=0;

int FC_versionMajor=0;
int FC_versionMinor=0;
int FC_versionPatchLevel=0;
int MSP_PROTOCOL_VERSION, API_VERSION_MAJOR, API_VERSION_MINOR;

NSMutableString *FLIGHT_CONTROLLER_ID = nil;
NSMutableString *BOARD_ID = nil;

int trim_roll=0;
int trim_pitch=0;

int flightIndicatorFlag = 10;

int byteP[PID_ITEMS], byteI[PID_ITEMS], byteD[PID_ITEMS];

int byteRC_RATE, byteRC_EXPO, byteRollPitchRate, byteYawRate, byteDynThrPID, byteThrottle_EXPO, byteThrottle_MID;

int maxAlt;
int current_command, command_status;

@interface MultiWi230()

@end


@implementation MultiWi230

static WiFiCommunication *MWiFiConnection;

-(id)init {
    
    self=[super init];
    
    if(self) {
        
    }
    
    return self;
}



+(void)setWiFiCommunication:(WiFiCommunication *)WiFiConnection {
    MWiFiConnection=WiFiConnection;
}


+(int)read32 {
    return (inputBuffer[bufferIndex++] & 0xff) + ((inputBuffer[bufferIndex++] & 0xff) << 8)
    + ((inputBuffer[bufferIndex++] & 0xff) << 16) + ((inputBuffer[bufferIndex++] & 0xff) << 24);
}

+(int)read16 {
    int add_1=(inputBuffer[bufferIndex++] & 0xff);
    int add_2=((inputBuffer[bufferIndex++]) << 8);
    
    return add_1+add_2;
}

+(int)read8 {
    return inputBuffer[bufferIndex++] & 0xff;
}

+(void)evaluateCommand:(int)command and:(int)dataSize{
    
    switch (command) {
            
        case MSP_API_VERSION:
            MSP_PROTOCOL_VERSION = [MultiWi230 read8];
            API_VERSION_MAJOR = [MultiWi230 read8];
            API_VERSION_MINOR = [MultiWi230 read8];
            
            break;
            
        case MSP_FC_VERSION:
            FC_versionMajor=[MultiWi230 read8];
            FC_versionMinor=[MultiWi230 read8];
            FC_versionPatchLevel=[MultiWi230 read8];
            break;
            
        case MSP_FC_VARIANT:
            FLIGHT_CONTROLLER_ID = [NSMutableString stringWithString:@""];
            while (dataSize-- > 0) {
                char c = (char) [MultiWi230 read8];
                if (c != 0) {
                    [FLIGHT_CONTROLLER_ID appendFormat:@"%c", c];
                }
            }
            
            break;
            
        case MSP_BOARD_INFO:
            dataSize = [MultiWi230 read16];
            BOARD_ID = [NSMutableString stringWithString:@""];
            
            if(dataSize < 256) {
                while (dataSize-- > 0) {
                    char c = (char) [MultiWi230 read8];
                    if (c != 0) {
                        [BOARD_ID appendFormat:@"%c", c];
                    }
                }
            }
            break;
            
        case MSP_RAW_IMU:
            accX=[MultiWi230 read16];
            accY=[MultiWi230 read16];
            accZ=[MultiWi230 read16];
            
            gyroX=[MultiWi230 read16]/8;
            gyroY=[MultiWi230 read16]/8;
            gyroZ=[MultiWi230 read16]/8;
            
            magX=[MultiWi230 read16]/3;
            magY=[MultiWi230 read16]/3;
            magZ=[MultiWi230 read16]/3;
            break;
            
        case MSP_ATTITUDE:
            roll=([MultiWi230 read16]/10);
            pitch=([MultiWi230 read16]/10);
            yaw=[MultiWi230 read16];
            break;
            
        case MSP_ALTITUDE:
            alt=([MultiWi230 read32]/10)-0;
            break;
            
        case MSP_ANALOG:
            battery=([MultiWi230 read8]/10.0);
            break;
            
        case MSP_ACC_TRIM:
            trim_pitch=[MultiWi230 read16];
            trim_roll=[MultiWi230 read16];
            break;
            
        case MSP_PID:
            for (int i = 0; i < PID_ITEMS; i++) {
                byteP[i] = [MultiWi230 read8];
                NSLog(@"byte p[i] %d", byteP[i]);
                byteI[i] = [MultiWi230 read8];
                NSLog(@"byte i[i] %d", byteI[i]);
                byteD[i] = [MultiWi230 read8];
                NSLog(@"byte d[i] %d", byteD[i]);
            }
            break;
            
        case MSP_RC_TUNING:
            byteRC_RATE = [MultiWi230 read8];
            byteRC_EXPO = [MultiWi230 read8];
            byteRollPitchRate = [MultiWi230 read8];
            byteYawRate = [MultiWi230 read8];
            byteDynThrPID = [MultiWi230 read8];
            byteThrottle_MID = [MultiWi230 read8];
            byteThrottle_EXPO = [MultiWi230 read8];
            break;
            
        case MSP_FLIGHT_STATUS:
            flightIndicatorFlag = [MultiWi230 read16];
            flightIndicatorFlag = (int) (log(flightIndicatorFlag & -flightIndicatorFlag) / log(2));
            
            break;
            
        case MSP_COMMAND:
            current_command = [MultiWi230 read16];
            command_status = [MultiWi230 read8];
            
            NSLog(@"command status read: %d", command_status);
            break;
            
        case MSP_MAX_ALT:
            maxAlt = [MultiWi230 read16];
            break;
            
        default:
            break;
    }
    
}


-(NSMutableData *)createPacketMSP:(int)msp withPayload:(NSMutableData *) payload {
    
    if(msp<0)
        return NULL;
    
    NSMutableData  *data=[[NSMutableData alloc] initWithLength:0];
    
    uint8_t *buf = (uint8_t *)[MSP_HEADER UTF8String];
    
    [data appendBytes:(const void *)buf length:strlen((char *)buf) ];
    
    uint8_t checksum=0;
    
    uint8_t payloadSize=(uint8_t)((payload!=nil?[payload length]:0)&0xFF);
    
    [data appendBytes:&payloadSize length:sizeof(payloadSize)];
    
    checksum^=(payloadSize&0xFF);
    
    msp=msp&0xFF;
    
    [data appendBytes:&msp length:sizeof(uint8_t)];
    
    checksum^=(msp&0xFF);
    
    
    if(payload!=nil) {
        uint8_t * tempPayload=(uint8_t *)[payload bytes];
        
        for(uint8_t i=0; i<[payload length];i++) {
            uint8_t k=tempPayload[i];
            
            [data appendBytes:&k length:sizeof(k)];
            checksum^=((tempPayload[i])&0xFF);
        }
        
    }
    
    [data appendBytes:&checksum  length:sizeof(checksum)];
    return data;
}

-(void) sendRequestMSP:(NSMutableData *) data {
    if(MWiFiConnection==nil) {
        NSLog(@"Wificonnection is null");
        return;
    }
    
    [MWiFiConnection write:data];
}

-(void) sendRequestMSP_RAW_RC:(int [])channels8 {
    
    NSMutableData  *rc_signal_array=[[NSMutableData alloc] initWithLength:0];
    uint8_t k, k1;
    
    for(int i=0;i<8;i++) {
        k=(channels8[i] & 0xFF);
        k1=((channels8[i] >> 8) & 0xFF);
        
        [rc_signal_array appendBytes:&k length:sizeof(uint8_t)];
        [rc_signal_array appendBytes:&k1 length:sizeof(uint8_t)];
    }
    
    if(self!=nil) {
        [self sendRequestMSP:[self createPacketMSP:MSP_SET_RAW_RC withPayload:rc_signal_array]];
        
        k=(channels8[2] & 0xFF);
        k1=((channels8[2] >> 8) & 0xFF);
        
        //NSLog(@"yaw 1: %d yaw 2: %d", k, k1);
    }
    
}

-(void) sendRequestMSP_DEBUG:(NSMutableArray *)debugRequests {
    
    if(debugRequests!=nil) {
        for(int i=0;i<[debugRequests count];i++) {
            [self sendRequestMSP:[self createPacketMSP:[[debugRequests objectAtIndex:i]integerValue] withPayload:NULL]];
        }
    }
    
}

-(void) sendRequestMSP_ATTITUDE {
    [self sendRequestMSP:[self createPacketMSP:MSP_ATTITUDE withPayload:NULL]];
}

-(void) sendRequestMSP_SET_MOTOR:(int [])motors8 {
    
    NSMutableData  *rc_signal_array=[[NSMutableData alloc] initWithLength:0];
    uint8_t k, k1;
    
    
    for(int i=0;i<8;i++) {
        k=(motors8[i] & 0xFF);
        k1=((motors8[i] >> 8) & 0xFF);
        
        [rc_signal_array appendBytes:&k length:sizeof(uint8_t)];
        [rc_signal_array appendBytes:&k1 length:sizeof(uint8_t)];
    }
    
    [self sendRequestMSP:[self createPacketMSP:MSP_SET_MOTOR withPayload:rc_signal_array]];
}


-(void)sendRequestMSP_ACC_CALIBRATION {
    [self sendRequestMSP:[self createPacketMSP:MSP_ACC_CALIBRATION withPayload:NULL]];
}

-(void)sendRequestMSP_MAG_CALIBRATION {
    [self sendRequestMSP:[self createPacketMSP:MSP_MAG_CALIBRATION withPayload:NULL]];
}

-(void)sendRequestMSP_FC_VERSION {
    [self sendRequestMSP:[self createPacketMSP:MSP_FC_VERSION withPayload:NULL]];
}

-(void)sendRequestMSP_BOARD_INFO {
    [self sendRequestMSP:[self createPacketMSP:MSP_BOARD_INFO withPayload:NULL]];
}

-(void)sendRequest_Firmware_VERSION {
    NSMutableArray *debugRequests =[NSMutableArray array];
    [debugRequests addObject:[NSNumber numberWithInt:MSP_FC_VARIANT] ];
    [debugRequests addObject:[NSNumber numberWithInt:MSP_FC_VERSION] ];
    
    if(debugRequests!=nil) {
        for(int i=0;i<[debugRequests count];i++) {
            [self sendRequestMSP:[self createPacketMSP:[[debugRequests objectAtIndex:i]integerValue] withPayload:NULL]];
        }
    }
}

-(void) sendRequest_Software_Info {
    NSMutableArray *debugRequests =[NSMutableArray array];
    [debugRequests addObject:[NSNumber numberWithInt:MSP_API_VERSION]];
    [debugRequests addObject:[NSNumber numberWithInt:MSP_FC_VARIANT]];
    [debugRequests addObject:[NSNumber numberWithInt:MSP_FC_VERSION]];
    
    if(debugRequests!=nil) {
        for(int i=0;i<[debugRequests count];i++) {
            [self sendRequestMSP:[self createPacketMSP:[[debugRequests objectAtIndex:i]integerValue] withPayload:NULL]];
        }
    }
}

-(void)sendRequestAT_WIFI_SETTINGS:(NSString *)ssid withPassword:(NSString *)password withChannel: (int)channel {
    NSMutableData * wiFiSetting;
    
    NSString * requestString= [NSString stringWithFormat: @"+++AT AP %@ %@ 3 %d", ssid, password, channel];
    
    wiFiSetting = [[NSMutableData alloc] initWithData:[requestString dataUsingEncoding:NSASCIIStringEncoding]];
    [self sendRequestMSP:wiFiSetting];
}

-(void) sendRequestMSP_GET_MAX_ALT {
    [self sendRequestMSP:[self createPacketMSP:MSP_MAX_ALT withPayload:NULL]];
}

-(void) sendRequestMSP_SET_MAX_ALT: (int)alt {
    NSMutableData  *payload=[[NSMutableData alloc] initWithLength:0];
    
    uint8_t b1, b2;
    b1=(alt & 0xFF);
    b2=((alt >> 8) & 0xFF);
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    [payload appendBytes:&b2 length:sizeof(uint8_t)];
    
    [self sendRequestMSP:[self createPacketMSP:MSP_SET_MAX_ALT withPayload:payload]];
}

-(void) sendRequestMSP_ACC_TRIM {
    [self sendRequestMSP:[self createPacketMSP:MSP_ACC_TRIM withPayload:NULL]];
}

-(void) sendRequestMSP_PID {
    [self sendRequestMSP:[self createPacketMSP:MSP_PID withPayload:NULL]];
}

-(void) sendRequestMSP_RC_TUNING{
    [self sendRequestMSP:[self createPacketMSP:MSP_RC_TUNING withPayload:NULL]];
}

-(void) sendRequestMSP_SET_ACC_TRIM:(int)roll and:(int)pitch {
    NSMutableData  *payload=[[NSMutableData alloc] initWithLength:0];
    
    uint8_t b1, b2;
    b1=(roll & 0xFF);
    b2=((roll >> 8) & 0xFF);
    
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    [payload appendBytes:&b2 length:sizeof(uint8_t)];
    
    b1=(pitch & 0xFF);
    b2=((pitch >> 8) & 0xFF);
    
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    [payload appendBytes:&b2 length:sizeof(uint8_t)];
    
    [self sendRequestMSP:[self createPacketMSP:MSP_SET_ACC_TRIM withPayload:payload]];
    
}

-(void) sendRequestMSP_SET_PID:(float)confRC_RATE and: (float)confRC_EXPO and
                              :(float) rollPitchRate and :(float) yawRate and :(float) dynamic_THR_PID and
                              :(float) throttle_MID and :(float) throttle_EXPO and :(float[]) confP and
                              :(float[]) confI and :(float[]) confD {
    
    NSMutableData  *payload=[[NSMutableData alloc] initWithLength:0];
    uint8_t b1;
    b1 = round(confRC_RATE * 100);
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    b1 = round(confRC_EXPO * 100);
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    b1 = round(rollPitchRate * 100);
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    b1 = round(yawRate * 100);
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    b1 = round(dynamic_THR_PID * 100);
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    b1 = round(throttle_MID * 100);
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    b1 = round(throttle_EXPO * 100);
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    
    [self sendRequestMSP:[self createPacketMSP:MSP_SET_RC_TUNING withPayload: payload]];
    
    [payload setLength:0];
    
    for (int i = 0; i < PID_ITEMS; i++) {
        byteP[i] = (int) (round(confP[i] * 10));
        byteI[i] = (int) (round(confI[i] * 1000));
        byteD[i] = (int) (round(confD[i]));
    }
    
    byteP[4] = (int) round(confP[4] * 100.0);
    byteI[4] = (int) round(confI[4] * 100.0);
    
    byteP[5] = (int) round(confP[5] * 10.0);
    byteI[5] = (int) round(confI[5] * 100.0);
    byteD[5] = (int) (round(confD[5] * 10000.0) / 10);
    
    byteP[6] = (int) round(confP[6] * 10.0);
    byteI[6] = (int) round(confI[6] * 100.0);
    byteD[6] = (int) (round(confD[6] * 10000.0) / 10);
    
    for (int i = 0; i < PID_ITEMS; i++) {
        [payload appendBytes:&byteP[i] length:sizeof(uint8_t)];
        [payload appendBytes:&byteI[i] length:sizeof(uint8_t)];
        [payload appendBytes:&byteD[i] length:sizeof(uint8_t)];
    }
    
    [self sendRequestMSP:[self createPacketMSP:MSP_SET_PID withPayload: payload]];
    
}

-(void)sendRequestMSP_GET_COMMAND {
    [self sendRequestMSP:[self createPacketMSP:MSP_COMMAND withPayload:NULL]];
}

-(void) sendRequest_Device_Heading: (int) heading {
    NSMutableData  *payload=[[NSMutableData alloc] initWithLength:0];
    
    uint8_t b1, b2;
    b1=(heading & 0xFF);
    b2=((heading >> 8) & 0xFF);
    
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    [payload appendBytes:&b2 length:sizeof(uint8_t)];
    
    [self sendRequestMSP:[self createPacketMSP:MSP_APP_HEADING withPayload:payload]];
}

-(void) sendReuestMSP_Analog {
    [self sendRequestMSP:[self createPacketMSP:MSP_ANALOG withPayload:NULL]];
}

-(void) sendRequestMSP_SET_GPS: (int) latitude and: (int) longitude {
    NSMutableData  *payload=[[NSMutableData alloc] initWithLength:0];
    
    uint8_t b1, b2, b3, b4;
    
    b1= (latitude & 0xFF);
    b2= ((latitude >> 8) & 0xFF);
    b3= ((latitude >> 16) & 0xFF);
    b4= ((latitude >> 24) & 0xFF);
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    [payload appendBytes:&b2 length:sizeof(uint8_t)];
    [payload appendBytes:&b3 length:sizeof(uint8_t)];
    [payload appendBytes:&b4 length:sizeof(uint8_t)];
    
    b1= (longitude & 0xFF);
    b2= ((longitude >> 8) & 0xFF);
    b3= ((longitude >> 16) & 0xFF);
    b4= ((longitude >> 24) & 0xFF);
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    [payload appendBytes:&b2 length:sizeof(uint8_t)];
    [payload appendBytes:&b3 length:sizeof(uint8_t)];
    [payload appendBytes:&b4 length:sizeof(uint8_t)];
    
    NSLog(@"lat: %d long: %d", latitude, longitude);
    
    [self sendRequestMSP:[self createPacketMSP:MSP_APP_GPS withPayload:payload]];
}

-(void) sendRequestMSP_SET_COMMAND: (int)commandType{
    NSMutableData  *payload=[[NSMutableData alloc] initWithLength:0];
    
    uint8_t b1;
    
    b1=(commandType & 0xFF);
    
    [payload appendBytes:&b1 length:sizeof(uint8_t)];
    
    [self sendRequestMSP:[self createPacketMSP:MSP_SET_COMMAND withPayload:payload]];
}

-(NSMutableData *) requestCommand: (NSMutableArray *) command {
    NSMutableData  *data=[[NSMutableData alloc] initWithLength:0];
    
    if (NULL != command) {
        for(int index = 0; index < [command count]; index++){
            uint8_t b1 = ([[command objectAtIndex:index]longValue] & 0xFF);
            [data appendBytes:&b1 length:sizeof(uint8_t)];
        }
    }
    
    return (data);
}

-(void) sendFlashCommands: (NSMutableArray *) command{
    [self sendRequestMSP:[self requestCommand:command]];
}

-(void) EnableBootMode{
    NSMutableData * wiFiSetting;
    wiFiSetting = [[NSMutableData alloc] initWithData:[@"+++AT GPIO13 1\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [self sendRequestMSP: wiFiSetting];
    
    usleep(1000000);
    
    wiFiSetting = [[NSMutableData alloc] initWithData:[@"+++AT GPIO12 0\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [self sendRequestMSP: wiFiSetting];
    
    usleep(500000);
    
    wiFiSetting = [[NSMutableData alloc] initWithData:[@"+++AT GPIO12 1\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [self sendRequestMSP: wiFiSetting];
    
    usleep(500000);
    
    wiFiSetting = [[NSMutableData alloc] initWithData:[@"+++AT GPIO13 0\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [self sendRequestMSP: wiFiSetting];
    
    usleep(500000);
}

-(void) disableBootMode{
    NSMutableData * wiFiSetting;
    wiFiSetting = [[NSMutableData alloc] initWithData:[@"+++AT GPIO12 1" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [self sendRequestMSP: wiFiSetting];
    
    wiFiSetting = [[NSMutableData alloc] initWithData:[@"+++AT GPIO13 0" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [self sendRequestMSP: wiFiSetting];
}

-(void) checkBootLoaderStatus{
    NSMutableArray *command = [NSMutableArray array];
    [command addObject: [NSNumber numberWithLong:0x7F]];
    [self sendRequestMSP:[self requestCommand:command]];
}

-(void) sendRequestMSP_EEPROM_WRITE {
    [self sendRequestMSP:[self createPacketMSP:MSP_EEPROM_WRITE withPayload:NULL]];
}

- (void) sendRequestParity : (NSString*) parity{
    NSMutableData * wiFiSetting;
    NSMutableString * requestString=[NSMutableString string];
    
    [requestString appendString:@"+++AT BAUD 115200 8 "];
    
    [requestString appendString:parity];
    
    [requestString appendString:@" 1\r\n"];
    
    wiFiSetting = [[NSMutableData alloc] initWithData:[requestString dataUsingEncoding:NSASCIIStringEncoding]];
    
    [self sendRequestMSP: wiFiSetting];
}

-(void) sendRequestFlushStream {
    NSMutableData *stringToFlush;
    stringToFlush = [[NSMutableData alloc] initWithData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [self sendRequestMSP: stringToFlush];
}

-(void) readDataDuringFlashMode {
    if(MWiFiConnection==nil) {
        NSLog(@"Wificonnection is null");
        return;
    }
    
    [MWiFiConnection read];
}

-(void) removeInputStreamDelegate {
    if(MWiFiConnection==nil) {
        NSLog(@"Wificonnection is null");
        return;
    }
    
    [MWiFiConnection removeInputStreamDelegate];
}

-(void) setInputStreamDelegate {
    if(MWiFiConnection==nil) {
        NSLog(@"Wificonnection is null");
        return;
    }
    
    [MWiFiConnection setInputStreamDelegate];
}

@end
