//
//  Controller.h
//  CocoaAMF
//
//  Created by Marc Bauer on 27.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMF.h"
#import "AMFActionMessage.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "NSString+URLEncode.h"
#import "OutlineViewDataSource.h"
#import "CAMFFieldEditor.h"
#import "NSOutlineView+ContextMenu.h"
#import "AMFDebugUnarchiver.h"
#import "SCGenerator.h"
#import "SCActionscriptGenerator.h"
#import "SCObjCGenerator.h"


@interface Controller : NSObject 
{
	IBOutlet NSTextField *m_gatewayTextField;
	IBOutlet NSTextField *m_serviceTextField;
	IBOutlet NSTextView *m_dataTextView;
	IBOutlet NSTextView *m_resultTextView;
	IBOutlet NSPopUpButton *m_amfTypePopUpButton;
	IBOutlet NSButton *m_gzipCheckbox;
	IBOutlet NSOutlineView *m_objectOutlineView;
	IBOutlet NSPanel *m_detailViewHUDPanel;
	IBOutlet NSTextView *m_detailTextView;
	IBOutlet NSArrayController *m_sentHeadersArrayController;
	IBOutlet NSArrayController *m_receivedHeadersArrayController;
	IBOutlet NSTabView *m_tabView;
	IBOutlet NSProgressIndicator *m_progressIndicator;
	IBOutlet NSButton *m_executeButton;
	
	BOOL m_isLoading;
	NSMutableArray *m_sentHeaders;
	NSMutableArray *m_receivedHeaders;
	NSURLConnection *m_connection;
	NSMutableData *m_receivedData;
	OutlineViewDataSource *m_outlineViewDataSource;
	NSString *m_errorDescription;
	BOOL m_error;
	CAMFFieldEditor *m_fieldEditor;
}

- (IBAction)query:(id)sender;
- (IBAction)copyURL:(id)sender;
- (IBAction)focusGatewayTextField:(id)sender;
- (IBAction)focusServiceTextField:(id)sender;
- (IBAction)focusDataTextView:(id)sender;
- (IBAction)selectNextTab:(id)sender;
- (IBAction)selectPreviousTab:(id)sender;

- (BOOL)setURLString:(NSString *)urlString;

@end