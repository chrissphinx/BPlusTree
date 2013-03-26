/*
 *  CMCodeIndex.h                           Colin MacCreery
 *
 *  Header for the Code Index. Originally used @properties
 *  but was unnessesary as TempUserApp.m does not need
 *  to access any of that information. 
 *  
 ************************************************************/


#import <Foundation/Foundation.h>

typedef struct {
    short m;
    short r;
    short e;
    short f;
    short k;
} header;

@interface CMCodeIndex : NSObject {
    header* h;
    char _type;
    short _next;
    NSMutableArray* _codes;
    NSMutableArray* _pointers;
    int headSize;
    int recSize;
    NSFileHandle* binHandle;
    int nodesRead;
    int comparisons;
}

-(id)initWithFile:(NSString*)f;
-(NSDictionary*)query:(NSString*)c;
-(NSString*)list;
-(void)close;

@end