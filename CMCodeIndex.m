/*
 *  CMCodeIndex.m                           Colin MacCreery
 *
 *  Implementation for the Code Index.
 *
 ************************************************************/


#import "CMCodeIndex.h"

@implementation CMCodeIndex
@synthesize type = _type;
@synthesize next = _next;
@synthesize codes = _codes;
@synthesize pointers = _pointers;

// ----- PUBLIC ---------------------------------------------/
-(id)initWithFile:(NSString*)f {
    self = [super init];
    
    binHandle = [NSFileHandle fileHandleForReadingAtPath:f];
        
    header head = {
        CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] ),
        CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] ),
        CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] ),
        CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] ),
        CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] )
    };
    h = &head;
    
    return self;
}

-(NSDictionary*)query:(NSString*)c {
    result = [NSDictionary dictionaryWithObjects:@[@3, @5, @13] forKeys:@[@"pointer", @"nodes", @"comparisons"]];
    
    return nil;
}

-(NSString*)list {
    return @"LISTING ALL CODES\n\n";
}

-(void)close {
    [binHandle closeFile];
}

// ----- PRIVATE --------------------------------------------/
-(void)readNode:(int)offset {
    [binHandle seekToFileOffset:offset];
    _type = *(char*)[[binHandle readDataOfLength:1] bytes];
    if(_type == 'L') _next = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    
    _codes = [[NSMutableArray alloc] initWithCapacity:h->m];
    for (int i = 0; i < h->m; i++) {
        [_codes addObject: [
            [NSString alloc]
            initWithBytes:[[binHandle readDataOfLength:3] bytes]
            length:3 encoding:NSASCIIStringEncoding]
        ];
    }
    
    _pointers = [[NSMutableArray alloc] initWithCapacity:h->m];
    for (int i = 0; i < h->m; i++) {
        [_pointers addObject: [
            NSNumber numberWithShort:
            CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] )]
        ];
    }
}

@end
