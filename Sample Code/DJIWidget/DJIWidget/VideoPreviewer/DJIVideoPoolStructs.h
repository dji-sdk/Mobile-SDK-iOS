//  DJIVideoPoolStructs.h
//  DJIWidget
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#ifndef DJIWidget_DJIVideoPoolStructs_h
#define DJIWidget_DJIVideoPoolStructs_h

typedef struct _VideoCacheFrame{
    int size;
    uint32_t time_tag; //videoTimeCapsule internal relative time
    uint8_t* data;
    
} VideoCacheFrame;



typedef struct _DJIVideoPoolFrame{
    uint32_t file_offset;
    uint32_t frame_size;
    uint32_t time_tag; //videoPool internal relative time
    
    union{
        struct{
            int has_sps :1; // contains sps information
            int has_pps :1; // contains pps information
            int has_idr :1; //The frame with idr
        } flags;
        uint32_t value;
    };
} DJIVideoPoolFrame;

void ReleaseVideoCacheFrameList(int count, VideoCacheFrame* list);

#endif
