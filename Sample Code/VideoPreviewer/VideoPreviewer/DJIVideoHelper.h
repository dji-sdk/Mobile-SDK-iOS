//
//  DJIVideoHelper.h
//
//  Copyright (c) 2013 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIStreamCommon.h"

//For acquiring pre-construction I frame struct
typedef struct _DummyIframeInfo{
    int frame_width;
    int frame_height;
    int fps;
    int encoder_type; //H264EncoderType
}PrebuildIframeInfo;

typedef char* (*loadPrebuildIframePathPtr)(uint8_t* buffer, int in_buffer_size, PrebuildIframeInfo info);
typedef int (*loadPrebuildIframeOverridePtr)(uint8_t* buffer, int in_buffer_size, PrebuildIframeInfo info);;

extern loadPrebuildIframePathPtr g_loadPrebuildIframePathFunc;
extern loadPrebuildIframeOverridePtr g_loadPrebuildIframeOverrideFunc;

//tag for pps and sps
#define SEI_TAG (0x06)
#define SPS_TAG (0x07)
#define PPS_TAG (0x08)
//nalu_type of access_unit_delimiter
#define AUD_TAG (0x09)
#define IDR_TAG (0x05)
#define SLICE_TAG (0x01)
#define SLICE_A_TAG (0x02)
#define SLICE_B_TAG (0x03)
#define SLICE_C_TAG (0x04)

//sps
typedef struct SPS {
    unsigned int sps_id;
    int profile_idc;
    int level_idc;
    int chroma_format_idc;
    int transform_bypass;              ///< qpprime_y_zero_transform_bypass_flag
    int log2_max_frame_num;            ///< log2_max_frame_num_minus4 + 4
    int poc_type;                      ///< pic_order_cnt_type
    int log2_max_poc_lsb;              ///< log2_max_pic_order_cnt_lsb_minus4
    int delta_pic_order_always_zero_flag;
    int offset_for_non_ref_pic;
    int offset_for_top_to_bottom_field;
    int poc_cycle_length;              ///< num_ref_frames_in_pic_order_cnt_cycle
    int ref_frame_count;               ///< num_ref_frames
    int gaps_in_frame_num_allowed_flag;
    int mb_width;                      ///< pic_width_in_mbs_minus1 + 1
    int mb_height;                     ///< pic_height_in_map_units_minus1 + 1
    int frame_mbs_only_flag;
    int mb_aff;                        ///< mb_adaptive_frame_field_flag
    int direct_8x8_inference_flag;
    int crop;                          ///< frame_cropping_flag
    
    /* those 4 are already in luma samples */
    unsigned int crop_left;            ///< frame_cropping_rect_left_offset
    unsigned int crop_right;           ///< frame_cropping_rect_right_offset
    unsigned int crop_top;             ///< frame_cropping_rect_top_offset
    unsigned int crop_bottom;          ///< frame_cropping_rect_bottom_offset
    int vui_parameters_present_flag;
    struct{
        int num; ///< numerator
        int den; ///< denominator
    } sar;
    int video_signal_type_present_flag;
    int full_range;
    int colour_description_present_flag;
    int color_primaries;
    int color_trc;
    int colorspace;
    int timing_info_present_flag;
    unsigned long num_units_in_tick;
    unsigned long time_scale;
    int fixed_frame_rate_flag;
    short offset_for_ref_frame[256]; // FIXME dyn aloc?
    int bitstream_restriction_flag;
    int num_reorder_frames;
    int scaling_matrix_present;
    unsigned char scaling_matrix4[6][16];
    unsigned char scaling_matrix8[6][64];
    int nal_hrd_parameters_present_flag;
    int vcl_hrd_parameters_present_flag;
    int pic_struct_present_flag;
    int time_offset_length;
    int cpb_cnt;                          ///< See H.264 E.1.2
    int initial_cpb_removal_delay_length; ///< initial_cpb_removal_delay_length_minus1 + 1
    int cpb_removal_delay_length;         ///< cpb_removal_delay_length_minus1 + 1
    int dpb_output_delay_length;          ///< dpb_output_delay_length_minus1 + 1
    int bit_depth_luma;                   ///< bit_depth_luma_minus8 + 8
    int bit_depth_chroma;                 ///< bit_depth_chroma_minus8 + 8
    int residual_color_transform_flag;    ///< residual_colour_transform_flag
    int constraint_set_flags;             ///< constraint_set[0-3]_flag
    //int new;                              ///< flag to keep track if the decoder context needs re-init due to changed SPS
} SPS;

typedef struct{
    int first_mb_in_slice;
    int slice_type;
    //frame_num is an ID that used to distinguish different frames. It is not counter.
    int frame_num;
} H264SliceHeaderSimpleInfo;

/**
 *  Decode seq data.
 *
 *  @param buf In sps buffer.
 *  @param nLen Buffer size.
 *  @param Width mb width.
 *  @param Height mb hegiht.
 *  @param framerate The frame rate.
 *  @param decodeedSps Out sps data.
 *
 *  @return `0` if it is set successfully.
 */
int	h264_decode_seq_parameter_set_out(unsigned char * buf,unsigned int nLen,int *Width,int *Height, int *framerate, SPS* decodeedSps);

/**
 *  Decode a slice header.
 *
 *  @param buf In sps buffer.
 *  @param nLen Buffer size.
 *  @param sps Sps data.
 *  @param info Out the slice header info.
 *
 *  @return `0` if it is decode successfully.
 */
int h264_decode_slice_header(unsigned char * buf, unsigned int nLen, SPS* sps, H264SliceHeaderSimpleInfo* info);

/**
 *  Search the end position of nalu header.
 *  
 *  @param buffer Frame data.
 *  @param nLen Frame size.
 *
 *  @return The search position.
 */
int findNextNALStartCodeEndPos(uint8_t* buffer, int size);

/**
 *  Search the start position of nalu header.
 *
 *  @param buffer Frame data.
 *  @param nLen Frame size.
 *
 *  @return The search position.
 */
int findNextNALStartCodePos(uint8_t* buffer, int size);

/**
 *  Attempts to load pre-constructed i frame from disk
 *  
 *  @param buffer Out the i frame data.
 *  @param in_buffer_size In buffer size.
 *  @param info In the i frame info.
 *
 *  @return If less than `0` mean the buffer have no enough size, '0' No correspond i frame, more than `0` the size of get.
 */
int loadPrebuildIframe(uint8_t* buffer, int in_buffer_size, PrebuildIframeInfo info);