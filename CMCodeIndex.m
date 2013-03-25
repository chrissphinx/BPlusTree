/*
 *  CMCodeIndex.m                           Colin MacCreery
 *
 *  Implementation for the Code Index.
 *
 ************************************************************/


#import "CMCodeIndex.h"

@implementation CMCodeIndex
@synthesize header = _header;
@synthesize type = _type;
@synthesize next = _next;
@synthesize codes = _codes;
@synthesize pointers = _pointers;

// ----- PUBLIC ---------------------------------------------/
-(id)initWithFile:(NSString*)f {
    self = [super init];
    
    binHandle = [NSFileHandle fileHandleForReadingAtPath:f];
        
    header* head = malloc(sizeof(header));
    head->m = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->r = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->e = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->f = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->k = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    _header = head;
    
    return self;
}

-(NSDictionary*)query:(NSString*)c {
    result = [NSDictionary dictionaryWithObjects:@[@3, @5, @13] forKeys:@[@"pointer", @"nodes", @"comparisons"]];
    
    return result;
}

-(void)close {
    free(_header);
}

// ----- PRIVATE --------------------------------------------/
-(void)readNode:(int)offset {
    [binHandle seekToFileOffset:offset];
    _type = *(char*)[[binHandle readDataOfLength:1] bytes];
    if(_type == 'L') _next = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    
    _codes = [[NSMutableArray alloc] initWithCapacity:_header->m];
    for (int i = 0; i < _header->m; i++) {
        [_codes addObject: [
            [NSString alloc]
            initWithBytes:[[binHandle readDataOfLength:3] bytes]
            length:3 encoding:NSASCIIStringEncoding]
        ];
    }
    
    _pointers = [[NSMutableArray alloc] initWithCapacity:_header->m];
    for (int i = 0; i < _header->m; i++) {
        [_pointers addObject: [
            NSNumber numberWithShort:
            CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] )]
        ];
    }
}

@end
