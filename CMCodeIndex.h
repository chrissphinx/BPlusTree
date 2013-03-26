/*
 *  CMCodeIndex.h                           Colin MacCreery
 *
 *  Header for the Code Index.
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
    NSFileHandle* binHandle;
    NSDictionary* result;
}

@property char type;
@property short next;
@property (retain, nonatomic) NSMutableArray* codes;
@property NSMutableArray* pointers;

-(id)initWithFile:(NSString*)f;
-(NSDictionary*)query:(NSString*)c;
-(NSString*)list;
-(void)close;

@end