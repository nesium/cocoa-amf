//
//  Controller.h
//  CocoaAMF
//
//  Created by Marc Bauer on 07.10.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMF3Deserializer.h"
#import "AMFInputStream.h"
#import "SODeserializer.h"
#import "OutlineViewDataSource.h"
#import "FileSystemRepNode.h"


@interface Controller : NSObject 
{
	IBOutlet NSOutlineView *m_outlineView;
	IBOutlet NSOutlineView *m_directoryOutlineView;
	OutlineViewDataSource *m_dataSource;
	IBOutlet FileSystemRepNode *m_SOFolderRep;
	IBOutlet NSTreeController *m_directoryTreeController;
}

@end