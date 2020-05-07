//
//  PipelineProtocol.h
//  DJISdkDemo
//
//  Copyright © 2020 DJI. All rights reserved.
//

#ifndef PipelineProtocol_h
#define PipelineProtocol_h

#pragma pack(1)

typedef NS_ENUM(uint8_t, PipelineCmdType) {
    /// Request
    PipelineCmdType_Request = 0x50,
    /// Response
    PipelineCmdType_Response = 0x51,
    /// Confirmation of transmission results
    PipelineCmdType_Result = 0x52,
    /// Document information
    PipelineCmdType_FileInformation = 0x60,
    /// Download file request
    PipelineCmdType_DownloadFile = 0x61,
    /// Document data
    PipelineCmdType_FileData = 0x62,
    /// interrupt a transmission
    PipelineCmdType_Terminate = 0x63,
};

typedef NS_ENUM(uint8_t, PipelineCmdTypeRequestSubcmd) {
    PipelineCmdTypeRequestSubcmd_Upload = 0x00,
    PipelineCmdTypeRequestSubcmd_Download = 0x01,
};

typedef NS_ENUM(uint8_t, PipelineCmdTypeResponseSubcmd) {
    PipelineCmdTypeResponseSubcmd_OK = 0x00,
    PipelineCmdTypeResponseSubcmd_Reject = 0x01,
};

typedef NS_ENUM(uint8_t, PipelineCmdTypeResultSubcmd) {
    PipelineCmdTypeResultSubcmd_Success = 0x00,
    PipelineCmdTypeResultSubcmd_Failure = 0x01,
};

typedef NS_ENUM(uint8_t, PipelineCmdTypeFileDataSubcmd) {
    PipelineCmdTypeFileDataSubcmd_Normal = 0x00,
    PipelineCmdTypeFileDataSubcmd_End = 0x01,
};
 
typedef struct {
    bool isExist;
    uint32_t fileLength;
    char fileName[32];
    uint8_t md5Buf[16];
} PipelineFileInfo;
 
typedef struct {
    char fileName[32];
} PipelineDownloadReq;
 
typedef struct  {
    uint8_t cmd;
    uint8_t subcmd;
    uint16_t seqNum;
    uint32_t dataLen;
    uint8_t data[0];
} PipelineReqType;
 
#pragma pack()

#endif /* PipelineProtocol_h */
