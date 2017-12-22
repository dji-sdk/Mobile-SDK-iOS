//
//  DJILiveViewRenderCommon.h
//

#import <UIKit/UIKit.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

static NSString *const passThroughVS = SHADER_STRING
(
 //input
 attribute vec4 position;
 attribute vec2 texcoord;
 
 //to fragment shader
 varying vec2 v_texcoord;
 varying vec4 v_overexp_texcoord;
 
 void main()
 {
     gl_Position = position;
     v_texcoord = texcoord.xy;
 }
 );

//passthrough FS
static NSString *const passthroughFS = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 varying highp vec4 v_overexp_texcoord;
 
 uniform sampler2D s_texture;
 
 void main()
 {
     //get rgb color
     highp vec4 rgb_color = texture2D(s_texture, v_texcoord);
     gl_FragColor = vec4(ret_color.xyz, 1.0);
 }
 );

static const GLfloat g_defaultVertexs[8] = {
    -1.0f,  // x0
    -1.0f,  // y0
    
    1.0f,  // ..
    -1.0f,
    
    -1.0f,
    1.0f,
    
    1.0f,  // x3
    1.0f,  // y3
};

static const GLfloat g_yuvQuadTexCoordsNormal[] = {
    0.0f, 0.0f,
    1.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 1.0f,
};

static const GLfloat g_yuvQuadTexCoords90CW[] = {
    0.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 1.0f,
    1.0f, 0.0f,
};

static const GLfloat g_yuvQuadTexCoords180CW[] = {
    1.0f, 1.0f,
    0.0f, 1.0f,
    1.0f, 0.0f,
    0.0f, 0.0f,
};

static const GLfloat g_yuvQuadTexCoords270CW[] = {
    1.0f, 0.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    0.0f, 1.0f,
    
};

@interface DJILiveViewRenderCommon : NSObject

@end
