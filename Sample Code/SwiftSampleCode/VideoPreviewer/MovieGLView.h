//
//  ESGLView.h
//  kxmovie
//
//  Created by Kolyvan on 22.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>
#include <sys/types.h>

#ifndef YUV_FRAME_
#define YUV_FRAME_

typedef struct
{
    uint8_t *luma;
    uint8_t *chromaB;
    uint8_t *chromaR;
    
    int lz, bz,rz;
    int width, height;
    
    int gray;
    
    pthread_rwlock_t mutex;
    
} VideoFrameYUV;

#endif

@protocol KxMovieGLRenderer
- (BOOL) isValid;
- (NSString *) fragmentShader;
- (void) resolveUniforms: (GLuint) program;
- (void) setFrame: (VideoFrameYUV *) frame;
- (BOOL) prepareRender;
@end


@interface MovieGLView : UIView
{
    EAGLContext     *_context;
    GLuint          _framebuffer;
    GLuint          _renderbuffer;
    GLint           _backingWidth;
    GLint           _backingHeight;
    GLuint          _program;
    GLint           _uniformMatrix;
    GLfloat         _vertices[8];
    
    float _width;
    float _height;
    int _flag;
    id<KxMovieGLRenderer> _renderer;
}

- (id)initWithFrame:(CGRect)frame;

- (void)render: (VideoFrameYUV *) frame;

- (void)finish;

- (void)adjustSize;

@end
