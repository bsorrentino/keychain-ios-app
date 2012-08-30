//
//  UIXML.h
//  UIXML
//
//  Created by softphone on 10/08/12.
//  Copyright (c) 2012 SOUL. All rights reserved.
//

#ifndef UIXML_UIXML_h
#define UIXML_UIXML_h

#ifndef UIXML_STRONG
#   if __has_feature(objc_arc)
#       define UIXML_STRONG strong
#   else
#       define UIXML_STRONG retain
#   endif
#   define __UIXML_STRONG
#endif

#ifndef UIXML_WEAK
#if __has_feature(objc_arc_weak)
#   define UIXML_WEAK weak
#   define __UIXML_WEAK __weak
#elif __has_feature(objc_arc)
#   define UIXML_WEAK unsafe_unretained
#   define __UIXML_WEAK __unsafe_unretained
#else
#   define UIXML_WEAK assign
#   define __UIXML_WEAK
#endif
#endif


#endif
