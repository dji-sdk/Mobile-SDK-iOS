// djisymbols.h

#ifndef DJI_OBF_STRING
#define STR1(R)  #R
#define STR2(R)  STR1(R)
#define DJI_OBF_STRING(_ARG_) [NSString stringWithUTF8String:STR2(_ARG_)]
#endif
