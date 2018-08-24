//
//  djiffremux.c
//
//  Copyright (c) 2015 DJI. All rights reserved.
//
#ifndef _DJI_FFREMUX_H_
#define _DJI_FFREMUX_H_
#include <stdio.h>
#include <stdarg.h>

void DJIFF_LOGI(int i, const char* format, ...);

#define DJIFF_MODULE_FFREMUX 1
#define DJIFF_LOGE DJIFF_LOGI
#define DJIFF_ERR_PARAM -1
#define DJIFF_ERR_FAILURE -2
#define DJIFF_SUCCESS 0

#define MAX_NUM_STREAMS 4

typedef void* djiff_ffremux_handle_t;

//this file format applies to both input and output
typedef enum DJIFF_FILE_FORMAT{
    DJIFF_FILE_FORMAT_NULL,
    DJIFF_FILE_FORMAT_H264RAW,
    DJIFF_FILE_FORMAT_AACRAW,
    DJIFF_FILE_FORMAT_MJPGRAW,
    DJIFF_FILE_FORMAT_USERDATARAW,
    DJIFF_FILE_FORMAT_RAWMAX,
    DJIFF_FILE_FORMAT_MP4,
    DJIFF_FILE_FORMAT_MOV,
    DJIFF_FILE_FORMAT_MAX,
}DJIFF_FILE_FORMAT;

typedef enum DJIFF_STREAM_TYPE{
    DJIFF_STREAM_TYPE_H264,
    DJIFF_STREAM_TYPE_AAC,
    DJIFF_STREAM_TYPE_USERDATA,
}DJIFF_STREAM_TYPE;

typedef struct djiff_codecParam_t{
    //video codec parameter
    int width;//input picture width
    int height;//input picture height
    int fpsNum;// the nominator part of the frame rate
    int fpsDen;// the denominator part of the frame rate
    int bitrate;// this is not neccessary but providing it is better
    //audio codec parameter
    int bitPerSample;
    int sampleRate;
    int numChannels;
    int rotate; //the rotation of videostream, shouldbe 0, 90, 180, 270
}djiff_codecParam_t;

//this is the parameter to be passed to init function
typedef struct djiff_ffremux_config_t{
    int numInput;//Specify how many input streams can we have
    int numOutput;//Specify how many output streams can we have
    //Under any situaion, there can only be either one input stream or one output stream.
    char * in_filename[MAX_NUM_STREAMS ];// in the liveView mode, specify this as the input filename. in the storage mode, specify this as NULL
    char * out_filename[MAX_NUM_STREAMS ];// in the liveView mode, specify this as NULL. In the storage mode, specify this as the destination filename
    DJIFF_FILE_FORMAT in_format[MAX_NUM_STREAMS ];
    DJIFF_FILE_FORMAT out_format[MAX_NUM_STREAMS];
    djiff_codecParam_t enc_param;//specifying the parameters of the input encoder as this is already a prior knowledge to the muxer user
                                //this will save some time for the muxer to start up, 
                                //otherwise, it must probe a short section of data before starting
    int isFrag;//if output format is mp4, should it be fragmented mp4
    int min_frag_duration;// the minimum fragment size of the fMP4
}djiff_ffremux_config_t;

typedef int djiff_result_t;
/*****************************************************************************
remuxer init
*Input:
*input file and output file name should be full url like: 
*for raw h264 input or output to ringbuffer destimation: ringbuffer://recording123456.h264
*for mp4 input or output to file destimation: recording123456.mp4
* for the extradata, they are the sps: sequence parameter set
*Output:
* function returns the remux handle as djiff_ffremux_handle_t 
******************************************************************************/

djiff_result_t djiff_remux_init(djiff_ffremux_handle_t* pRemuxHandle,
                        djiff_ffremux_config_t * cfg, uint8_t * extradata, int extradata_size);

/*****************************************************************************
*remux frame:
*This function will drain all the frames in the input buffer and remux them to the output 
* Input:
* remux_handle returned from djiff_remux_init
* data is the data pointer of the h264 input
* size is also the data pointer of the h264 input
* Output:
* Remuxing status
******************************************************************************/

djiff_result_t djiff_remux_frame(djiff_ffremux_handle_t  remux_handle);

/*****************************************************************************
*mux header:
*This function will keep the header data inside the muxer and wait for the first data package to arrive
* Input:
* remux_handle returned from djiff_remux_init
* data is the data pointer of the h264 header
* size is also the data size of the h264 header
* Output:
* Remuxing status
******************************************************************************/

djiff_result_t djiff_mux_header(djiff_ffremux_handle_t  remux_handle, unsigned char * header, int size);

/*****************************************************************************
*mux frame:
*This function will mux the data in the input buffer to the output destination file
* Input:
* remux_handle returned from djiff_remux_init
* data is the data pointer of the h264 input
* size is also the data size of the h264 input
* frame_idx is used to compute the time_stamp. it should follows the frame's display order instead of encoding order
* these two values may be different when B frame is presented
* flag is set to 1 when it is a key frame, otherwise please set to 0
* Output:
* Remuxing status
******************************************************************************/

djiff_result_t djiff_mux_frame(djiff_ffremux_handle_t remux_handle, unsigned char * data, int size, int frame_idx,
                                                      DJIFF_FILE_FORMAT streamType, int flag);

/*****************************************************************************
 *mux frame:
 *This function for incoming frame rate from outside for dynamic calculation of PTS
 * Input:
 * remux_handle returned from djiff_remux_init
 * fps frame fps
 * data is the data pointer of the h264 input
 * data is also the data size of the h264 input
 * frame_idx is used to compute the time_stamp. it should follows the frame's display order instead of encoding order
 * these two values may be different when B frame is presented
 * flag is set to 1 when it is a key frame, otherwise please set to 0
 * Output:
 * Remuxing status
 ******************************************************************************/

djiff_result_t djiff_mux_frame2(djiff_ffremux_handle_t remux_handle, int fps, unsigned char * data, int size, int frame_idx,
							   DJIFF_FILE_FORMAT streamType, int flag);


/*****************************************************************************
*remux frame:
*This function will demux the data from the input file and put it in the output buffer
* Input:
* remux_handle returned from djiff_remux_init
* data is the data pointer of the h264 output buffer
* size is also the data size of the h264 output buffer
* Output:
* Remuxing status
******************************************************************************/

djiff_result_t djiff_demux_frame(djiff_ffremux_handle_t  remux_handle, unsigned char * data, int* size,
                                                                    DJIFF_FILE_FORMAT * streamType);


/*****************************************************************************
*remux seek
*seek to a special location in the input mp4 file and mux into h264
*Input:
*remux_handle returned from dji_remux_init
*time_offset: the time offset of the seek destinaation, in the unit of million seconds
*Output:
seek result
******************************************************************************/

djiff_result_t djiff_remux_seek(djiff_ffremux_handle_t  remux_handle, int time_offset);


/*****************************************************************************
*remux get duration
*probe the duration of the targeting file
*Input:
*filename to the file you are to get duration
*integer pointer to a predefined variable to store the duration
*Output:
******************************************************************************/

djiff_result_t djiff_remux_getDuration(char * filename, int *duration);

/*****************************************************************************
remux deinit
clear up everything and leave
******************************************************************************/
djiff_result_t djiff_remux_deinit(djiff_ffremux_handle_t  remux_handle);
#endif
