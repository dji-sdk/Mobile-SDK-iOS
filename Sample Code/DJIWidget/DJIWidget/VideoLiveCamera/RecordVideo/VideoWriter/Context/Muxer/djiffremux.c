//
//  dji_ffremux.c
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#include "libavutil/avconfig.h"
#include "libavutil/timestamp.h"
#include "libavutil/avstring.h"
#include "libavutil/opt.h"
#include <unistd.h>
#include <getopt.h>
#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"

#include "djiffremux.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsometimes-uninitialized"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wshorten-64-to-32"
#pragma clang diagnostic ignored "-Wpointer-sign"
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wunused-function"


#define PIXEL_FORMAT DJI_PIXEL_FORMAT_YUV420

//#define FFDJI_LOG_PACKET
#define MAX_NUM_STREAMS 4

void DJIFF_LOGI(int i, const char* format, ...)
{
    va_list argptr;
    va_start(argptr, format);
    vfprintf(stderr, format, argptr);
    va_end(argptr);
    return;
}

typedef struct djiff_remux_context_t{
    djiff_ffremux_config_t cfg;
    AVFormatContext* ifmt_ctx[MAX_NUM_STREAMS];//input format
    AVFormatContext* ofmt_ctx[MAX_NUM_STREAMS];//output format
    int pktIdx[MAX_NUM_STREAMS];
    int numInputFmtCtx;
    int numOutputFmtCtx;
    int isMuxer;
    int isDemuxer;
    unsigned char * header;
    int headerSize;
    AVBitStreamFilterContext * bsf[MAX_NUM_STREAMS];
}djiff_remux_context_t;

int ff_alloc_extradata(AVCodecContext *avctx, int size);
enum AVPixelFormat avpriv_find_pix_fmt(const void *tags, unsigned int fourcc);
void* avpriv_get_raw_pix_fmt_tags(void);

#ifdef FFDJI_LOG_PACKET
static void log_packet(const AVFormatContext *fmt_ctx, const AVPacket *pkt, const char *tag)
{
    AVRational *time_base = &fmt_ctx->streams[pkt->stream_index]->time_base;
    
    DJIFF_LOGI(DJIFF_MODULE_FFREMUX, "%s: pts:%s pts_time:%s dts:%s dts_time:%s duration:%s duration_time:%s size:%x\n",
               tag,
               av_ts2str(pkt->pts), av_ts2timestr(pkt->pts, time_base),
               av_ts2str(pkt->dts), av_ts2timestr(pkt->dts, time_base),
               av_ts2str(pkt->duration), av_ts2timestr(pkt->duration, time_base),
               pkt->size);
}
#endif
/***********************************************************************************/

static int djiff_open_file_input(AVFormatContext **ps, const char *filename)
{
    AVFormatContext *s = *ps;
    int ret = 0;
    
    if (!s && !(s = avformat_alloc_context()))
        return AVERROR(ENOMEM);
    
    s->iformat = av_find_input_format(strrchr(filename, '.')+1);
    if(s->iformat == NULL)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "error input file\n");
        goto fail;
    }
    s->probe_score = 100;
    if ((ret = avio_open2(&s->pb, filename, AVIO_FLAG_READ, &s->interrupt_callback, NULL)) < 0)
        return ret;
    
    /* Check filename in case an image number is expected. */
    DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "open file success\n");
    
    s->duration = AV_NOPTS_VALUE;
    s->start_time = 0;
    
    av_strlcpy(s->filename, filename ? filename : "", sizeof(s->filename));
    
    /* Allocate private data. */
    if (s->iformat->priv_data_size > 0) {
        if (!(s->priv_data = av_mallocz(s->iformat->priv_data_size))) {
            ret = AVERROR(ENOMEM);
            goto fail;
        }
        if (s->iformat->priv_class) {
            *(const AVClass **) s->priv_data = s->iformat->priv_class;
            av_opt_set_defaults((void *)s->priv_data);
        }
    }
    DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "read header start: %s\n",s->iformat->name);
    
    //assign streams and the codec* within streams
    if (!(s->flags&AVFMT_FLAG_PRIV_OPT) && s->iformat->read_header)
        if ((ret = s->iformat->read_header(s)) < 0)
            goto fail;
    DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "read header success\n");
    
    s->raw_packet_buffer_remaining_size = RAW_PACKET_BUFFER_SIZE;
    
    *ps = s;
    avio_close(s->pb);
    return 0;
    
fail:
    if (s->pb && !(s->flags & AVFMT_FLAG_CUSTOM_IO))
        avio_close(s->pb);
    avformat_free_context(s);
    *ps = NULL;
    return ret;
}


/***********************************************************************************/
static int djiff_open_stream_input(AVFormatContext **ps, const char *streamType)
{
    AVFormatContext *s = *ps;
    int ret = 0;
    
    if (!s && !(s = avformat_alloc_context()))
        return AVERROR(ENOMEM);
    
    s->iformat = av_find_input_format(streamType);
    s->probe_score = 100;
    s->duration = AV_NOPTS_VALUE;
    s->start_time = 0;
    
    if ((ret = avio_open_stream(&s->pb)) < 0)
        return ret;
    
    /* Allocate private data. */
    if (s->iformat->priv_data_size > 0) {
        if (!(s->priv_data = av_mallocz(s->iformat->priv_data_size))) {
            ret = AVERROR(ENOMEM);
            goto fail;
        }
        if (s->iformat->priv_class) {
            *(const AVClass **) s->priv_data = s->iformat->priv_class;
            av_opt_set_defaults((void *)s->priv_data);
        }
    }
    //assign streams and the codec* within streams
    if (!(s->flags&AVFMT_FLAG_PRIV_OPT) && s->iformat->read_header)
        if ((ret = s->iformat->read_header(s)) < 0)
            goto fail;
    
    s->raw_packet_buffer_remaining_size = RAW_PACKET_BUFFER_SIZE;
    
    *ps = s;
    return 0;
    
fail:
    avformat_free_context(s);
    *ps = NULL;
    return ret;
}
static int djiff_close_file_input(AVFormatContext ** ps)
{
    avformat_close_input(ps);
    return 0;
}

static int djiff_close_stream_input(AVFormatContext ** ps)
{
    
    AVFormatContext *s;
    AVIOContext *pb;
    
    if (!ps || !*ps)
        return 0;
    
    s  = *ps;
    pb = s->pb;
    
    if (s->iformat)
        if (s->iformat->read_close)
            s->iformat->read_close(s);
    
    avformat_free_context(s);
    
    *ps = NULL;
    
    avio_close_stream(pb);
    return 0;
}

static int djiff_assign_stream_info(AVFormatContext *ic, djiff_codecParam_t param)
{
    int i, ret = 0;
    AVStream *st;
    // new streams might appear, no options for those
    
    for (i = 0; i < ic->nb_streams; i++) {
        st = ic->streams[i];
        DJIFF_LOGI(DJIFF_MODULE_FFREMUX, "tbc: %d/%d and tbn: %d/%d\n", st->codec->time_base.num, st->codec->time_base.den,
                   st->time_base.num, st->time_base.den);
        if (st->codec->codec_type == AVMEDIA_TYPE_VIDEO && st->codec->codec_id == AV_CODEC_ID_H264) {
            st->codec->width = param.width;
            st->codec->height = param.height;
            st->codec->pix_fmt = AV_PIX_FMT_YUV420P;
            
            if (!st->codec->codec_tag && !st->codec->bits_per_coded_sample) {
                uint32_t tag= avcodec_pix_fmt_to_codec_tag(st->codec->pix_fmt);
                if (avpriv_find_pix_fmt(avpriv_get_raw_pix_fmt_tags(), tag) == st->codec->pix_fmt)
                    st->codec->codec_tag= tag;
            }
            st->codec->bits_per_raw_sample = 8;
            st->codec->chroma_sample_location = AVCHROMA_LOC_LEFT;
            st->codec->ticks_per_frame = 2;
            st->info->fps_first_dts = AV_NOPTS_VALUE;
            st->info->fps_last_dts = AV_NOPTS_VALUE;
            st->avg_frame_rate.num = param.fpsNum*st->codec->ticks_per_frame;
            st->avg_frame_rate.den = param.fpsDen;
            st->r_frame_rate.num = param.fpsNum;
            st->r_frame_rate.den = param.fpsDen;
            
            //set the rotation of the video stream
            if (param.rotate != 0) {
                char rotation[10] = {0};
                sprintf(rotation, "%d", param.rotate);
                av_dict_set(&st->metadata, "rotate", rotation, 0);
            }
        }
        else if(st->codec->codec_type == AVMEDIA_TYPE_AUDIO && st->codec->codec_id == AV_CODEC_ID_AAC)
        {
            st->codec->sample_fmt = param.bitPerSample==16?AV_SAMPLE_FMT_S16:AV_SAMPLE_FMT_NONE;
            if(param.bitPerSample!=16)
            {
                DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Audio sample format other than 16bit per sample is currently not supported!\n");
                return DJIFF_ERR_PARAM;
            }
            
            st->codec->sample_rate = param.sampleRate;
            st->r_frame_rate.num = param.sampleRate;
            st->r_frame_rate.den=1024;
            st->codec->channels = param.numChannels;
            if (!st->codec->bits_per_coded_sample)
                st->codec->bits_per_coded_sample =
                av_get_bits_per_sample(st->codec->codec_id);
            
        }
        st->cur_dts = 0;
        
    }
    
    for (i = 0; i < ic->nb_streams; i++) {
        
        st = ic->streams[i];
        st->index      = i;
        st->start_time = AV_NOPTS_VALUE;
        st->duration   = AV_NOPTS_VALUE;
        /* we set the current DTS to 0 so that formats without any timestamps
         * but durations get some timestamps, formats with some unknown
         * timestamps have their first few packets buffered and the
         * timestamps corrected before they are returned to the user */
#if FF_API_R_FRAME_RATE
        ic->streams[i]->info->last_dts = AV_NOPTS_VALUE;
#endif
        ic->streams[i]->info->fps_first_dts = AV_NOPTS_VALUE;
        ic->streams[i]->info->fps_last_dts	= AV_NOPTS_VALUE;
    }
    ic->duration = AV_NOPTS_VALUE;
    //	    ic->bit_rate = param.bitrate;
    ic->bit_rate = 4*1000*1000;
    return ret;
}

/***********************************************************************************/

static int djiff_eval_packet(djiff_remux_context_t *remux_ctx, AVPacket * pkt,
                             unsigned char * data, int size, unsigned long long timestamp, int stream_index, int flag)
{
    memset(pkt, 0, sizeof(AVPacket));
    if(pkt==NULL)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "ff_dji_read_h264_packet: error inputing: pkt\n");
        return -1;
    }
    //if there is header data available, packetize it together with the first data package
    if(remux_ctx->headerSize>0)
    {
        //memmove the current package and restore the header part to the front
        //This may cause a crash! ! Because the space of data is only the size of the size, memmove is out of bounds.
        DJIFF_LOGI(DJIFF_MODULE_FFREMUX, "memmove the current package and restore the header part to the front\n");
        memmove(data+remux_ctx->headerSize, data, size);
        size+=remux_ctx->headerSize;
        memcpy(data, remux_ctx->header, remux_ctx->headerSize);
        remux_ctx->headerSize = 0;
    }
    pkt->data = (uint8_t*)data;
    pkt->size = size;
    pkt->pts = pkt->dts = timestamp;
    pkt->stream_index= stream_index;
    if(flag!=0)
        pkt->flags |= AV_PKT_FLAG_KEY;
    return 0;
}

static djiff_result_t djiff_filter_packet(AVFormatContext *s, AVPacket *pkt, AVCodecContext *avctx, AVBitStreamFilterContext *bsfc){
    
    while(bsfc){
        AVPacket new_pkt= *pkt;
        int a= av_bitstream_filter_filter(bsfc, avctx, NULL,
                                          &new_pkt.data, &new_pkt.size,
                                          pkt->data, pkt->size,
                                          pkt->flags & AV_PKT_FLAG_KEY);
        if(a>0){
            av_free_packet(pkt);
        } else if(a<0){
            DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "%s failed for stream %d, codec %s\n",
                       bsfc->filter->name, pkt->stream_index,
                       avctx->codec ? avctx->codec->name : "copy");
            return DJIFF_ERR_FAILURE;
        }
        *pkt= new_pkt;
        
        bsfc= bsfc->next;
    }
    
    return DJIFF_SUCCESS;
}

/***********************************************************************************/
static const char * fileFormat2string(DJIFF_FILE_FORMAT fileFormat, int isInput)
{
    switch(fileFormat){
        case DJIFF_FILE_FORMAT_H264RAW:
            return "h264";
            break;
        case DJIFF_FILE_FORMAT_AACRAW:
            if(isInput)
                return "aac";
            else
                return "adts";
            break;
        case DJIFF_FILE_FORMAT_USERDATARAW:
            return "userdata";
            break;
        case DJIFF_FILE_FORMAT_MJPGRAW:
            return "image2";
            break;
            
        case DJIFF_FILE_FORMAT_MP4:
            return "mp4";
            break;
        case DJIFF_FILE_FORMAT_MOV:
            return "mov";
            break;
            
        default:
            return "";
            break;
    }
    return "";
}

static DJIFF_FILE_FORMAT avCodecId2DjiFileFormat(enum AVCodecID codecId)
{
    if(codecId==AV_CODEC_ID_H264)
        return DJIFF_FILE_FORMAT_H264RAW;
    if(codecId == AV_CODEC_ID_AAC)
        return DJIFF_FILE_FORMAT_AACRAW;
    if(codecId == AV_CODEC_ID_MJPEG)
        return DJIFF_FILE_FORMAT_MJPGRAW;
    
    return DJIFF_FILE_FORMAT_RAWMAX;
}

/***********************************************************************************/

djiff_result_t djiff_remux_init(djiff_ffremux_handle_t * pRemuxHandle, 
                                djiff_ffremux_config_t * cfg, uint8_t * extradata, int extradata_size){
    AVFormatContext *ifmt_ctx = NULL, *ofmt_ctx = NULL;
    AVDictionary * dict = NULL;
    int ret, i, j;
    djiff_result_t err;
    char * in_filename;
    char * out_filename;
    
    DJIFF_FILE_FORMAT file_format;
    djiff_remux_context_t * remux_ctx = NULL;
    
    if((cfg->numInput==0 && cfg->numOutput==0 )||(cfg->numInput>1 && cfg->numOutput>1 ) )
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "error number of input(%d) and output(%d)\n", cfg->numInput, cfg->numOutput);
        err = DJIFF_ERR_PARAM;
        goto error;
    }
    
    av_register_all();
    remux_ctx = (djiff_remux_context_t *)malloc(sizeof(djiff_remux_context_t));
    memset(remux_ctx, 0, sizeof(*remux_ctx));
    
    memcpy(&(remux_ctx->cfg),cfg, sizeof(*cfg));
    //if there is filename specified
    DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Allocating intput context\n");
    for(i=0; i<cfg->numInput; i++)
    {
        in_filename = cfg->in_filename[i];
        file_format =cfg->in_format[i];
        ifmt_ctx = NULL;
        if(in_filename==NULL)
        {
            //this is the muxer case
            if ((ret = djiff_open_stream_input(&ifmt_ctx, fileFormat2string(file_format, 1))) < 0) {
                //by default, we will have to have one video stream inside
                DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "djiff: Could not open h264 stream input\n");
                err = DJIFF_ERR_FAILURE;
                goto error;
            }
            if ((ret = djiff_assign_stream_info(ifmt_ctx, cfg->enc_param)) < 0) {
                DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Failed to retrieve input stream information");
                err = DJIFF_ERR_FAILURE;
                goto error;
            }
        }
        else{
            ret = avformat_open_input(&ifmt_ctx, in_filename, 0, 0);
            if(ret < 0){
                DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Could not open input file '%s\n'", in_filename);
                err = DJIFF_ERR_FAILURE;
                goto error;
            }
            ifmt_ctx->probesize = 500*1000;//500k probe size
            ret = avformat_find_stream_info(ifmt_ctx, 0);
            if (ret < 0) {
                DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Failed to retrieve input stream information");
                err = DJIFF_ERR_FAILURE;
                goto error;
            }
        }
        remux_ctx->ifmt_ctx[i] = ifmt_ctx;
        //open bitstream filter for aac raw input
        if(file_format == DJIFF_FILE_FORMAT_AACRAW)
        {
            remux_ctx->bsf[i] = av_bitstream_filter_init("aac_adtstoasc");
            if(!remux_ctx->bsf[i])
            {
                DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "error openning aac_adtstoasc bitstream filter\n");
                goto error;
            }
        }
    }
    
    
    DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Allocating output context\n");
    for(i=0; i<cfg->numOutput; i++)
    {
        file_format =cfg->out_format[i];
        out_filename = cfg->out_filename[i];
        
        if(out_filename!=NULL)
        {
            if(file_format<DJIFF_FILE_FORMAT_MAX )
            {
                AVOutputFormat *tmp_ofmt = av_guess_format(fileFormat2string(file_format, 0), NULL, NULL);
                avformat_alloc_output_context2(&ofmt_ctx, tmp_ofmt, fileFormat2string(file_format, 0), out_filename);
            }
            else
            {
                DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Output file format error: %d\n", file_format);
                ret = AVERROR_UNKNOWN;
                err = DJIFF_ERR_FAILURE;
                goto error;
            }
            
            if (!ofmt_ctx) {
                DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Could not create output context\n");
                ret = AVERROR_UNKNOWN;
                err = DJIFF_ERR_FAILURE;
                goto error;
            }
        }
        
        
        if (out_filename!=NULL) {
            ret = avio_open(&ofmt_ctx->pb, out_filename, AVIO_FLAG_WRITE);
            if (ret < 0) {
                DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Could not open output file '%s'", out_filename);
                err = DJIFF_ERR_FAILURE;
                goto error;
            }
        }
        
        if(file_format == DJIFF_FILE_FORMAT_MP4 || file_format == DJIFF_FILE_FORMAT_MOV)
        {
            if(cfg->isFrag)
            {
                char frag_duration[10]={0};
                sprintf(frag_duration, "%d", cfg->min_frag_duration);
                av_dict_set(&dict, "movflags", "frag_keyframe", 0);
                av_dict_set(&dict, "min_frag_duration", frag_duration, 0);
            }
        }
        
        if(file_format == DJIFF_FILE_FORMAT_H264RAW && cfg->numInput == 1 &&
           (cfg->in_format[0] == DJIFF_FILE_FORMAT_MP4 || cfg->in_format[0] == DJIFF_FILE_FORMAT_MOV))
        {
            remux_ctx->bsf[i] = av_bitstream_filter_init("h264_mp4toannexb");
            
            if(!remux_ctx->bsf[i])
            {
                DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "error openning h264_mp4toannexb bitstream filter\n");
                goto error;
            }
        }
        remux_ctx->ofmt_ctx[i] = ofmt_ctx;
    }
    
    //connect the input and output together
    
    for(j=0; j<cfg->numInput; j++)
    {
        ifmt_ctx = remux_ctx->ifmt_ctx[j];
        for(i=0; i<(int)ifmt_ctx->nb_streams; i++)
        {
            AVStream *in_stream = ifmt_ctx->streams[i];
            AVStream *out_stream;
            
            ofmt_ctx = (cfg->numOutput>1)?remux_ctx->ofmt_ctx[i]:remux_ctx->ofmt_ctx[0];
            
            if(ofmt_ctx!=NULL)
            {
                out_stream = avformat_new_stream(ofmt_ctx, in_stream->codec->codec);
                if (!out_stream) {
                    DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Failed allocating output stream\n");
                    ret = AVERROR_UNKNOWN;
                    err = DJIFF_ERR_FAILURE;
                    goto error;
                }
                
                ret = avcodec_copy_context(out_stream->codec, in_stream->codec);
                if (ret < 0) {
                    DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Failed to copy context from input to output stream codec context\n");
                    err = DJIFF_ERR_FAILURE;
                    goto error;
                }
                
                //copy metadata
                av_dict_copy(&out_stream->metadata, in_stream->metadata, 0);
                
                if(in_stream->codec->codec_id == AV_CODEC_ID_H264)
                    //in current case, extradata is only for H264. Question: how about AAC?
                {
                    if(extradata_size!=0)
                    {
                        //ff_alloc_extradata(out_stream->codec, extradata_size);
                        out_stream->codec->extradata = av_mallocz(extradata_size);
                        memcpy(out_stream->codec->extradata, extradata, extradata_size);
                        out_stream->codec->extradata_size = extradata_size;
                    }
                }
                
                out_stream->codec->codec_tag = 0;
                if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER)
                    out_stream->codec->flags |= CODEC_FLAG_GLOBAL_HEADER;
            }
        }
    }
    
    remux_ctx->numInputFmtCtx = cfg->numInput;
    remux_ctx->numOutputFmtCtx = cfg->numOutput;
    if(remux_ctx->numInputFmtCtx == 1)
        remux_ctx->isDemuxer = 1;
    if(remux_ctx->numOutputFmtCtx == 1)
        remux_ctx->isMuxer = 1;
    
    for(i=0; i<cfg->numOutput; i++)
    {
        ofmt_ctx = remux_ctx->ofmt_ctx[i];
        if(ofmt_ctx!=NULL)
        {
            ret = avformat_write_header(ofmt_ctx,
                                        (cfg->numOutput==1 && cfg->out_format[0]>DJIFF_FILE_FORMAT_RAWMAX)? &dict: NULL);
            if (ret < 0) {
                DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Error occurred when opening output file\n");
                err = DJIFF_ERR_FAILURE;
                goto error;
            }
        }
    }
    
    av_dict_free(&dict);
    *pRemuxHandle = (void *)remux_ctx;
    return DJIFF_SUCCESS;
error:
    if(remux_ctx)
    {
        free(remux_ctx);
        *pRemuxHandle = NULL;
    }
    return err;
}

/*****************************************************************************************************/
djiff_result_t djiff_mux_header(djiff_ffremux_handle_t  remux_handle, unsigned char * header, int headerSize)
{
    djiff_remux_context_t *remux_ctx = (djiff_remux_context_t *)remux_handle;
    if(headerSize==0 || header == NULL)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "error input parameter: size: %d, p:%p\n", headerSize, header);
        return DJIFF_ERR_PARAM;
    }
    DJIFF_LOGI(DJIFF_MODULE_FFREMUX, "muxer got header: %d bytes\n", headerSize);
    remux_ctx->header = (unsigned char *)malloc(sizeof(char)*headerSize);
    memcpy(remux_ctx->header, header, headerSize);
    remux_ctx->headerSize = headerSize;
    return DJIFF_SUCCESS;
}

#ifndef INT64_MAX
#define INT64_MAX   0x7fffffffffffffffLL
#endif

djiff_result_t djiff_mux_choose_output(djiff_ffremux_handle_t  remux_handle, int * index)
{
    int i;
    djiff_remux_context_t *remux_ctx = (djiff_remux_context_t *)remux_handle;
    AVFormatContext *ofmt_ctx;
    AVStream * strm;
    int64_t minPts=INT64_MAX, currentPts;
    if(!remux_ctx->isMuxer)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Error: only muxing case need to choose the next output stream\n");
        return DJIFF_ERR_PARAM;
    }
    
    for(i=0; i<remux_ctx->numInputFmtCtx; i++)
    {
        ofmt_ctx = remux_ctx->ofmt_ctx[0];
        strm = ofmt_ctx->streams[i];
        
        currentPts = av_rescale_q(strm->cur_dts, strm->time_base, AV_TIME_BASE_Q);//unify to nanoSeconds
        
        if(minPts > currentPts)
        {
            minPts = currentPts;
            *index = i;
        }
    }
    return DJIFF_SUCCESS;
}

djiff_result_t djiff_remux_frame(djiff_ffremux_handle_t  remux_handle)
{
    AVStream *in_stream, *out_stream;
    djiff_remux_context_t *remux_ctx = (djiff_remux_context_t *)remux_handle;
    AVFormatContext *ifmt_ctx, *ofmt_ctx ;
    AVPacket pkt;
    int ret=0;
    int i=0,j;
    int inIdx, outIdx;
    if(remux_handle == NULL)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "wrong remux handle NULL!\n");
        return DJIFF_ERR_PARAM;
    }
    
    av_init_packet(&pkt);
    //choose which elementary stream to be output
    if(remux_ctx->isMuxer)
        djiff_mux_choose_output(remux_handle, &inIdx);
    else
        inIdx=0;
    
    //read frame from the es
    ifmt_ctx = remux_ctx->ifmt_ctx[inIdx];
    ret = av_read_frame(ifmt_ctx, &pkt);
    if (ret < 0)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "cannot read frame\n");
        goto EXIT_REMUXING;
    }
    in_stream  = ifmt_ctx->streams[pkt.stream_index];
    //you only have two choices, muxer every input file into one output file
    //otherwise you have to demuxer every stream in the input file to seperate outputs
    if(remux_ctx->isMuxer)
    {
        outIdx = inIdx;
        ofmt_ctx = remux_ctx->ofmt_ctx[0];
        out_stream = ofmt_ctx->streams[outIdx];
    }
    else{
        outIdx = pkt.stream_index;
        ofmt_ctx = remux_ctx->ofmt_ctx[outIdx];
        out_stream = ofmt_ctx->streams[0];
    }
#ifdef FFDJI_LOG_PACKET
    log_packet(ifmt_ctx, &pkt, "in");
#endif
    
    pkt.dts = pkt.pts = av_rescale_q_rnd(out_stream->cur_dts, out_stream->time_base,
                                         in_stream->time_base, AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX);
    pkt.dts += pkt.duration;
    pkt.pts += pkt.duration;
    
    pkt.stream_index = inIdx;//The logic here is kind of a coincident. How to make this pretty?
    
    /* copy packet */
    pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base,
                               out_stream->time_base, AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX);
    pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base,
                               out_stream->time_base, AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX);
    pkt.duration = av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
    pkt.pos = -1;
#ifdef FFDJI_LOG_PACKET
    log_packet(ofmt_ctx, &pkt, "out");
#endif
    ret = djiff_filter_packet(ofmt_ctx, &pkt, out_stream->codec, remux_ctx->bsf[inIdx]);
    
    if(remux_ctx->isDemuxer)
        ret = av_write_frame(ofmt_ctx, &pkt);
    else
        ret = av_interleaved_write_frame(ofmt_ctx, &pkt);
    if (ret < 0) {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Error muxing packet\n");
        goto EXIT_REMUXING;
    }
    
EXIT_REMUXING:
    //	    av_free_packet(&pkt);
    if(ret<0)
        return DJIFF_ERR_FAILURE;
    else
        return DJIFF_SUCCESS;
}



//when muxing, the source is in the buffer and the destimation is in the file system
djiff_result_t djiff_mux_frame(djiff_ffremux_handle_t remux_handle, unsigned char * data, int size, int frame_idx, 
                               DJIFF_FILE_FORMAT streamType, int flag)
{
    AVStream *in_stream = NULL, *out_stream = NULL;
    djiff_remux_context_t *remux_ctx = (djiff_remux_context_t *)remux_handle;
    AVFormatContext *ifmt_ctx, *ofmt_ctx ;
    AVPacket pkt;
    int ret=0, i;
    double timestamp = 0;
    AVRational timeBase, frameRate;
    
    if(remux_handle == NULL)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "wrong remux handle NULL!\n");
        return DJIFF_ERR_PARAM;
    }
    if(remux_ctx->numOutputFmtCtx>1)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "wrong scenario. Please use different API!\n");
        return DJIFF_ERR_PARAM;
    }
    
    ofmt_ctx = remux_ctx->ofmt_ctx[0];
    
    for(i=0; i<remux_ctx->numInputFmtCtx; i++)
    {
        ifmt_ctx = remux_ctx->ifmt_ctx[i];
        if(ifmt_ctx)
        {
            in_stream  = ifmt_ctx->streams[0];
            out_stream = ofmt_ctx->streams[i];
            if(streamType == avCodecId2DjiFileFormat(out_stream->codec->codec_id))
                break;
        }
    }
    
    timeBase = av_inv_q(in_stream->time_base);
    frameRate = in_stream->r_frame_rate;
    
    timestamp =frame_idx* ((double)timeBase.num*frameRate.den)/(double)(timeBase.den*frameRate.num);
    ret = djiff_eval_packet(remux_ctx, &pkt, data, size, timestamp, i, flag);
    
    if(ret<0)
        goto EXIT_MUXING;
    
    //	    compute_pkt_fields(&ifmt_ctx, in_stream, NULL, &pkt);
#ifdef FFDJI_LOG_PACKET
    //log_packet(ifmt_ctx, &pkt, "in");
#endif
    /* copy packet */
    pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base,
                               out_stream->time_base, AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX);
    pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base,
                               out_stream->time_base, AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX);
    pkt.duration = av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
    //	    pkt.pos = -1;
#ifdef FFDJI_LOG_PACKET
    log_packet(ofmt_ctx, &pkt, "out");
#endif
    
    ret = djiff_filter_packet(ofmt_ctx, &pkt, out_stream->codec, remux_ctx->bsf[i]);
    if (ret < 0) {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Error filtering packet\n");
        goto EXIT_MUXING;
    }
    
#if 0
    ret = av_interleaved_write_frame(ofmt_ctx, &pkt);
#else
    ret = av_write_frame(ofmt_ctx, &pkt);
#endif
    if (ret < 0) {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Error write frame\n");
        goto EXIT_MUXING;
    }
EXIT_MUXING:
    av_free_packet(&pkt);
    if(ret<0)
        return DJIFF_ERR_FAILURE;
    else
        return DJIFF_SUCCESS;
}

djiff_result_t djiff_mux_frame2(djiff_ffremux_handle_t remux_handle,int fps,unsigned char * data,int size,int frame_idx,
                                DJIFF_FILE_FORMAT streamType, int flag) {
    AVStream *in_stream = NULL, *out_stream = NULL;
    djiff_remux_context_t *remux_ctx = (djiff_remux_context_t *)remux_handle;
    AVFormatContext *ifmt_ctx, *ofmt_ctx ;
    AVPacket pkt;
    int ret=0, i;
    double timestamp = 0;
    AVRational timeBase, frameRate;
    
    if(remux_handle == NULL)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "wrong remux handle NULL!\n");
        return DJIFF_ERR_PARAM;
    }
    if(remux_ctx->numOutputFmtCtx>1)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "wrong scenario. Please use different API!\n");
        return DJIFF_ERR_PARAM;
    }
    
    ofmt_ctx = remux_ctx->ofmt_ctx[0];
    
    for(i=0; i<remux_ctx->numInputFmtCtx; i++)
    {
        ifmt_ctx = remux_ctx->ifmt_ctx[i];
        if(ifmt_ctx)
        {
            in_stream  = ifmt_ctx->streams[0];
            out_stream = ofmt_ctx->streams[i];
            if(streamType == avCodecId2DjiFileFormat(out_stream->codec->codec_id))
                break;
        }
    }
    
    timeBase = av_inv_q(in_stream->time_base);
    in_stream->r_frame_rate.num = fps;
    frameRate = in_stream->r_frame_rate;
    timestamp =frame_idx* ((double)timeBase.num*frameRate.den)/(double)(timeBase.den*frameRate.num);
    
    ret = djiff_eval_packet(remux_ctx, &pkt, data, size, timestamp, i, flag);
    
    if(ret<0)
        goto EXIT_MUXING;
    
    //        compute_pkt_fields(&ifmt_ctx, in_stream, NULL, &pkt);
#ifdef FFDJI_LOG_PACKET
    //log_packet(ifmt_ctx, &pkt, "in");
#endif
    /* copy packet */
    pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base,
                               out_stream->time_base, AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX);
    pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base,
                               out_stream->time_base, AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX);
    pkt.duration = av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
    //        pkt.pos = -1;
#ifdef FFDJI_LOG_PACKET
    log_packet(ofmt_ctx, &pkt, "out");
#endif
    
    ret = djiff_filter_packet(ofmt_ctx, &pkt, out_stream->codec, remux_ctx->bsf[i]);
    if (ret < 0) {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Error filtering packet\n");
        goto EXIT_MUXING;
    }
    
#if 0
    ret = av_interleaved_write_frame(ofmt_ctx, &pkt);
#else
    ret = av_write_frame(ofmt_ctx, &pkt);
#endif
    if (ret < 0) {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Error write frame\n");
        goto EXIT_MUXING;
    }
EXIT_MUXING:
    av_free_packet(&pkt);
    if(ret<0)
        return DJIFF_ERR_FAILURE;
    else
        return DJIFF_SUCCESS;
    
}




//when demuxing, the source is in the file system and the destimation is in the buffer(which means there is no output context)
djiff_result_t djiff_demux_frame(djiff_ffremux_handle_t  remux_handle, 
                                 unsigned char * data, int* size, DJIFF_FILE_FORMAT * streamType)
{
    AVStream *in_stream, *out_stream;
    djiff_remux_context_t *remux_ctx = (djiff_remux_context_t *)remux_handle;
    AVFormatContext *ifmt_ctx = NULL;
    AVFormatContext *ofmt_ctx = NULL;
    AVPacket pkt;
    
    int ret=0, strmIdx;
    
    * size = 0;
    if(remux_handle == NULL)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "wrong remux handle NULL!\n");
        return DJIFF_ERR_PARAM;
    }
    
    ifmt_ctx = remux_ctx->ifmt_ctx[0];
    
    ret = av_read_frame(ifmt_ctx, &pkt);
    if(ret<0)
    {
        DJIFF_LOGI(DJIFF_MODULE_FFREMUX, "No more data\n");
        goto EXIT_DEMUXING;
    }
    
    strmIdx = pkt.stream_index;
    
    in_stream = ifmt_ctx->streams[strmIdx];
    *streamType = avCodecId2DjiFileFormat(in_stream->codec->codec_id);
    
    ret = djiff_filter_packet(ofmt_ctx, &pkt, in_stream->codec, remux_ctx->bsf[strmIdx]);
    if (ret < 0) {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "Error filtering packet\n");
        goto EXIT_DEMUXING;
    }
    
    
    memcpy(data, pkt.data, pkt.size);
    * size = pkt.size;
    
EXIT_DEMUXING:
    if(ret<0)
        return DJIFF_ERR_FAILURE;
    else
        return DJIFF_SUCCESS;
}

//seek only support for mp4 to h264 remuxing
djiff_result_t djiff_remux_seek(djiff_ffremux_handle_t  remux_handle, int time_offset)
{
    AVFormatContext *ifmt_ctx;
    
    int ret = 0, i;
    int timestamp;
    if(remux_handle==NULL || time_offset<0)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "invalid input field\n");
        return DJIFF_ERR_PARAM;
    }
    for(i=0; i<((djiff_remux_context_t *)remux_handle)->numInputFmtCtx; i++)
    {
        ifmt_ctx = ((djiff_remux_context_t *)remux_handle)->ifmt_ctx[i];
        timestamp = av_rescale_q(time_offset*1000, AV_TIME_BASE_Q, ifmt_ctx->streams[0]->time_base);
        ret = av_seek_frame(ifmt_ctx, 0, timestamp, 0);
        if(ret<0)
        {
            DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "stream[%d] cannot seek to time: %d\n", i, time_offset);
            continue;
        }
    }
    return DJIFF_SUCCESS;
    
}

djiff_result_t djiff_remux_getDuration(char * filename, int *duration)
{
    AVFormatContext *s=NULL;
    int ret;
    if(duration ==NULL || filename==NULL)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "invalid input field\n");
        return DJIFF_ERR_PARAM;
    }
    
    av_register_all();
    DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "finished av register all\n");
    ret = djiff_open_file_input(&s, filename);
    if(ret<0)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "error openning the file: %s\n", filename);
        return DJIFF_ERR_PARAM;
    }
    
    *duration = s->duration;
    return DJIFF_SUCCESS;
}

djiff_result_t djiff_remux_deinit(djiff_ffremux_handle_t  remux_handle)
{
    djiff_remux_context_t *remux_ctx = (djiff_remux_context_t *)remux_handle;
    AVFormatContext *ifmt_ctx = NULL, *ofmt_ctx = NULL ;
    int i,j;
    
    if(remux_handle == NULL)
    {
        DJIFF_LOGE(DJIFF_MODULE_FFREMUX, "wrong remux handle NULL!\n");
        return DJIFF_ERR_PARAM;
    }
    
    for(i=0; i<remux_ctx->numInputFmtCtx; i++ )
    {
        ifmt_ctx = remux_ctx->ifmt_ctx[i];
        if(ifmt_ctx!=NULL)
        {
            if(remux_ctx->cfg.in_filename[i])
                djiff_close_file_input(&ifmt_ctx);
            else
                djiff_close_stream_input(&ifmt_ctx);
        }
        if(remux_ctx->bsf[i]!=NULL)
            av_bitstream_filter_close(remux_ctx->bsf[i]);
        remux_ctx->bsf[i]=NULL;
    }
    
    for(j=0; j<remux_ctx->numOutputFmtCtx; j++)
    {
        ofmt_ctx = remux_ctx->ofmt_ctx[j];
        if(ofmt_ctx)
        {
            av_write_trailer(ofmt_ctx);
            if(ofmt_ctx->streams[0]->codec->extradata)
            {
                av_free(ofmt_ctx->streams[0]->codec->extradata);
                ofmt_ctx->streams[0]->codec->extradata = NULL;
            }
            /* close output */
            if (ofmt_ctx)
                avio_close(ofmt_ctx->pb);
            avformat_free_context(ofmt_ctx);
        }
        if(remux_ctx->bsf[i]!=NULL)
            av_bitstream_filter_close(remux_ctx->bsf[i]);
        remux_ctx->bsf[i]=NULL;
    }
    
    if(remux_ctx->header!=NULL)
        free(remux_ctx->header);
    
    if(remux_ctx!=NULL)
    {
        free(remux_ctx);
    }
    return DJIFF_SUCCESS;
}

#pragma clang diagnostic pop
