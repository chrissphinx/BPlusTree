/*
 *  CMCodeIndex.m                           Colin MacCreery
 *
 *  Implementation for the Code Index. Stores a single node
 *  from the binary file at a time. Is able to search for a
 *  particular country code's DRP and list all codes
 *  alphabetically.
 *
 ************************************************************/


#import "CMCodeIndex.h"

@implementation CMCodeIndex

// ----- PUBLIC ---------------------------------------------/

//  initWithFile
//
//  constructor for the object, opens the file passed
//  to it and reads the header into a struct. Calculates
//  the record size and the header size

-(id)initWithFile:(NSString*)f {
    self = [super init];
    
    binHandle = [NSFileHandle fileHandleForReadingAtPath:f];
        
    header *head=(header*)malloc(sizeof(header));
    head->m = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->r = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->e = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->f = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    head->k = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    h = head;
    
    recSize = 1 + 2 + (h->m * 3) + (h->m * 2);
    headSize = sizeof(header);
    
    return self;
}

//  query
//
//  public query function. Begins the search
//  for a particular country code at the root.
//  Uses recursion

-(NSDictionary*)query:(NSString*)c {
    nodesRead = 0;
    comparisons = 0;
    NSNumber* ans = [self query:c AtNode:h->r];
    NSNumber* nR = [NSNumber numberWithInt:nodesRead];
    NSNumber* comp = [NSNumber numberWithInt:comparisons];

    NSDictionary* result;
    if([ans isNotEqualTo:nil]) {
        result = [NSDictionary dictionaryWithObjects:@[ans, nR, comp] forKeys:@[@"pointer", @"nodes", @"comparisons"]];
    } else {
        result = [NSDictionary dictionaryWithObjects:@[nR, comp] forKeys:@[@"nodes", @"comparisons"]];
    }
    return result;
}

//  list
//
//  aggregates a string containing the country
//  codes listed alphabetically

-(NSString*)list {
    NSMutableString* listing = [NSMutableString stringWithString:@""];
    
    [self readNode:h->f];
    while(_next != 0) {
        for(int i = 0; i < [_codes count]; i++) {
            if([[_codes objectAtIndex:i] isEqualToString:@"^^^"]) break;
            [listing appendFormat:@"%@ %3d\n", [_codes objectAtIndex:i], [[_pointers objectAtIndex:i] intValue]];
        }
        [self readNode:_next];
    }
    
    [listing appendFormat:@"+++++ END OF DATA +++++ (%d countries)\n\n", h->k];
    
    return listing;
}

//  close
//
//  closes the binary file

-(void)close {
    [binHandle closeFile];
}

// ----- PRIVATE --------------------------------------------/

//  queryAtNode
//
//  recursive method for searching for a country code. Fails
//  fast if it ever runs into an "^^^" entry and counts
//  the number of nodes read as well as number of comparisons
//  made

-(NSNumber*)query:(NSString*)c AtNode:(int)n {
    nodesRead++;
    [self readNode:n];
    
    if(_type != 'L') {
        for(int i = 0; i < [_codes count]; i++) {
            comparisons++;
            if([[_codes objectAtIndex:i] isEqualToString:@"^^^"]) return nil;
            if([c isLessThanOrEqualTo:[_codes objectAtIndex:i]]) return [self query:c AtNode:[[_pointers objectAtIndex:i] intValue]];
        }
    } else {
        for(int i = 0; i < [_codes count]; i++) {
            comparisons++;
            if([[_codes objectAtIndex:i] isEqualToString:@"^^^"]) return nil;
            if([c isEqualTo:[_codes objectAtIndex:i]]) return [_pointers objectAtIndex:i];
        }
    }
    return nil;
}

//  readNode
//
//  reads in a single node from the file specified
//  by the record number

-(void)readNode:(int)record {
    [binHandle seekToFileOffset:(headSize + (record - 1) * recSize)];
    _type = *(char*)[[binHandle readDataOfLength:1] bytes];
    _next = CFSwapInt16BigToHost( *(short*)[[binHandle readDataOfLength:2] bytes] );
    
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
