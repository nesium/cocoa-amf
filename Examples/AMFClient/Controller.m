//
//  Controller.m
//  CocoaAMF
//
//  Created by Marc Bauer on 27.11.08.
//  Copyright 2008 nesiumdotcom. All rights reserved.
//

#import "Controller.h"

@interface Controller (Private)
- (void)setIsLoading:(BOOL)bFlag;
@end


@implementation Controller

+ (void)initialize
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:@"http://www.nesium.com/amfdemo/gateway.php" forKey:@"LastGateway"];
	[dict setObject:@"ExampleService.returnArrayCollection" forKey:@"LastService"];
	[dict setObject:@"[]" forKey:@"LastParams"];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:dict];
}

- (void)awakeFromNib
{
	m_isLoading = NO;
	m_fieldEditor = [[CAMFFieldEditor alloc] init];
	[m_fieldEditor setFieldEditor:YES];
	[m_gatewayTextField setDelegate:self];
	m_sentHeaders = nil;
	m_receivedHeaders = nil;
	m_outlineViewDataSource = [[OutlineViewDataSource alloc] init];
	[m_objectOutlineView setDataSource:m_outlineViewDataSource];
	[m_dataTextView setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
	[m_resultTextView setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
}

- (BOOL)setURLString:(NSString *)urlString
{
	NSURL *url = [NSURL URLWithString:urlString];
	
	if (url == nil)
	{
		return NO;
	}
	
	NSString *gatewayURL, *service, *args;
	
	NSArray *params = [[url query] componentsSeparatedByString:@"&"];
	NSMutableArray *unusedParams = [NSMutableArray array];
	for (NSString *param in params)
	{
		NSArray *kv = [param componentsSeparatedByString:@"="];
		NSString *key = [kv objectAtIndex:0];
		NSString *value = [kv objectAtIndex:1];
		if ([key isEqualToString:@"s"])
		{
			service = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		}
		else if ([key isEqualToString:@"d"])
		{
			args = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		}
		else
		{
			[unusedParams addObject:param];
		}
	}
	gatewayURL = [NSString stringWithFormat:@"http://%@%@", [url host], [url path]];
	if ([unusedParams count])
	{
		gatewayURL = [NSString stringWithFormat:@"%@?%@", gatewayURL, 
			[unusedParams componentsJoinedByString:@"&"]];
	}
	[m_gatewayTextField setStringValue:gatewayURL];
	[m_serviceTextField setStringValue:service];
	[m_dataTextView setString:args];
	return YES;
}

- (IBAction)query:(id)sender
{
	if (m_isLoading)
	{
		return;
	}
	
	NSURL *gatewayURL = [NSURL URLWithString:[m_gatewayTextField stringValue]];
	if (gatewayURL == nil)
	{
		NSBeginAlertSheet(@"Your URL is invalid", @"OK", nil, nil, [NSApp mainWindow], self, 
			NULL, NULL, nil, @"%@ is not a valid URL.", [m_gatewayTextField stringValue]);
	}
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:gatewayURL];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-amf" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"AMFClient" forHTTPHeaderField:@"User-Agent"];
	
	if ([m_gzipCheckbox state] == NSOffState)
	{
		[request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
	}
	
	NSError *error = nil;
	NSObject *obj;
	@try
	{
		obj = [[CJSONDeserializer deserializer] 
			deserialize:[[m_dataTextView string] dataUsingEncoding:NSUTF8StringEncoding] 
			error:&error];
	}
	@catch (NSException *e) 
	{
		obj = nil;
	}
	if (obj == nil)
	{
		NSBeginAlertSheet(@"Your JSON is invalid", @"OK", nil, nil, [NSApp mainWindow], self, 
			NULL, NULL, nil, [error localizedDescription]);
		return;
	}
	
	m_error = NO;
	m_errorDescription = nil;
	
	AMFActionMessage *message = [[AMFActionMessage alloc] init];
	AMFMessageBody *body = [[AMFMessageBody alloc] init];
	body.data = obj;
	body.responseURI = @"/1";
	body.targetURI = [m_serviceTextField stringValue];
	message.version = [m_amfTypePopUpButton selectedTag];
	message.bodies = [NSArray arrayWithObject:body];
	
	[request setHTTPBody:[message data]];
	m_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	m_receivedData = [[NSMutableData alloc] init];
	[body release];
	[message release];
	[self setIsLoading:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[m_receivedHeadersArrayController setContent:nil];
	[m_receivedHeaders release];
	m_receivedHeaders = [[NSMutableArray alloc] init];
	NSEnumerator *headerEnum = [[(NSHTTPURLResponse *)response allHeaderFields] keyEnumerator];
	NSString *headerName;
	while (headerName = [headerEnum nextObject])
	{
		[m_receivedHeaders addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			headerName, @"name", [[(NSHTTPURLResponse *)response allHeaderFields] 
			objectForKey:headerName], @"value", nil]];
	}
	[m_receivedHeadersArrayController setContent:m_receivedHeaders];
	
	if ([[[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Content-Type"] 
		rangeOfString:@"application/x-amf"].location == NSNotFound)
	{
		m_error = YES;
		m_errorDescription = [[NSString stringWithFormat:@"The server returned no application/x-amf data at URL %@.", 
			[[response URL] absoluteString]] retain];
		return;
	}
	
	if ([(NSHTTPURLResponse *)response statusCode] != 200)
	{
		m_error = YES;
		m_errorDescription = [[NSString stringWithFormat:@"The server returned status code %d at URL %@.", 
			[(NSHTTPURLResponse *)response statusCode], [[response URL] absoluteString]] retain];
	}
}

- (IBAction)copyURL:(id)sender
{
	NSURL *gatewayURL = [NSURL URLWithString:[m_gatewayTextField stringValue]];
	if (gatewayURL == nil)
	{
		NSBeginAlertSheet(@"Your URL is invalid", @"OK", nil, nil, [NSApp mainWindow], self, 
			NULL, NULL, nil, @"%@ is not a valid URL.", [m_gatewayTextField stringValue]);
	}
	NSMutableString *url = [NSMutableString stringWithString:[[gatewayURL absoluteString] 
		stringByReplacingCharactersInRange:(NSRange){0, [[gatewayURL scheme] length]} 
		withString:@"amfclient"]];
	[url appendFormat:@"?s=%@", [[m_serviceTextField stringValue] URLEncodedString]];
	[url appendFormat:@"&d=%@", [[m_dataTextView string] URLEncodedString]];
	[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:NSStringPboardType, 
		nil] owner:nil];
	[[NSPasteboard generalPasteboard] setString:url forType:NSStringPboardType];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[m_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	AMFActionMessage *message = nil;
	
	if (!m_error && [m_receivedData length] == 0)
	{
		m_error = YES;
		m_errorDescription = @"The server returned zero bytes of data";
	}
	
	if (m_error)
	{
		NSBeginAlertSheet(@"Error querying webservice", @"OK", nil, nil, [NSApp mainWindow], self, 
			NULL, NULL, nil, m_errorDescription);
		goto bailout;
	}
	
	message = [AMFActionMessage alloc];
	@try
	{
		message = [message initWithData:m_receivedData];
	}
	@catch (NSException *e) 
	{
		NSBeginAlertSheet(@"Could not deserialize response", @"OK", nil, nil, [NSApp mainWindow], 
			self, NULL, NULL, nil, [e reason]);
		goto bailout;
	}
	
	NSObject *data = [[message.bodies objectAtIndex:0] data];
	m_outlineViewDataSource.rootObject = data;
	[m_objectOutlineView reloadData];
	[m_objectOutlineView expandItem:[m_objectOutlineView itemAtRow:0]];
	[m_resultTextView setString:[[CJSONSerializer serializer] serializeObject:data]];
	[[NSApp mainWindow] makeFirstResponder:m_objectOutlineView];
	[m_objectOutlineView selectRow:0 byExtendingSelection:NO];
	
	bailout:
	[m_errorDescription release];
	[m_connection release];
	[message release];
	[self setIsLoading:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSBeginAlertSheet(@"Error querying webservice", @"OK", nil, nil, [NSApp mainWindow], self, 
		NULL, NULL, nil, [error localizedDescription]);
	[self setIsLoading:NO];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request 
	redirectResponse:(NSURLResponse *)redirectResponse
{
	[m_sentHeadersArrayController setContent:nil];
	[m_sentHeaders release];
	m_sentHeaders = [[NSMutableArray alloc] init];
	NSEnumerator *headerEnum = [[request allHTTPHeaderFields] keyEnumerator];
	NSString *headerName;
	while (headerName = [headerEnum nextObject])
	{
		[m_sentHeaders addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			headerName, @"name", [request valueForHTTPHeaderField:headerName], @"value", nil]];
	}
	[m_sentHeadersArrayController setContent:m_sentHeaders];
	return request;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldTypeSelectForEvent:(NSEvent *)event 
	withCurrentSearchString:(NSString *)searchString
{
	if ([[event charactersIgnoringModifiers] characterAtIndex:0] == ' ')
	{
		if ([m_objectOutlineView selectedRow] != -1)
		{
			if ([m_detailViewHUDPanel isVisible])
			{
				[m_detailViewHUDPanel orderOut:self];
			}
			else
			{
				NSString *value = [m_outlineViewDataSource 
					valueForObject:[m_objectOutlineView 
					itemAtRow:[m_objectOutlineView selectedRow]]];
				[m_detailTextView setString:(value == nil || [value length] == 0)
					? @"(empty)" : value];
				[m_detailViewHUDPanel orderFront:self];
			}
			return NO;
		}
	}
	return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	if ([m_detailViewHUDPanel isVisible])
	{
		NSString *value = [m_outlineViewDataSource 
			valueForObject:item];
		[m_detailTextView setString:(value == nil || [value length] == 0)
			? @"(empty)" : value];
	}
	return YES;
}

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject
{
	if (anObject == m_gatewayTextField)
	{
		return m_fieldEditor;
	}
	return nil;
}

- (BOOL)fieldEditor:(NSTextView *)fieldEditor willPasteText:(NSString *)text
{
	if ([[[text substringToIndex:[@"amfclient://" length]] lowercaseString] 
		isEqualToString:@"amfclient://"])
	{
		return [self setURLString:text];
	}
	return NO;
}

- (IBAction)focusGatewayTextField:(id)sender
{
	[[NSApp mainWindow] makeFirstResponder:m_gatewayTextField];
}

- (IBAction)focusServiceTextField:(id)sender
{
	[[NSApp mainWindow] makeFirstResponder:m_serviceTextField];
}

- (IBAction)focusDataTextView:(id)sender
{
	[[NSApp mainWindow] makeFirstResponder:m_dataTextView];
	[m_dataTextView setSelectedRange:(NSRange){0, [[m_dataTextView string] length]}];
}

- (IBAction)selectNextTab:(id)sender
{
	NSInteger index = [m_tabView indexOfTabViewItem:[m_tabView selectedTabViewItem]] + 1;
	if (index == [m_tabView numberOfTabViewItems])
	{
		index = 0;
	}
	[m_tabView selectTabViewItemAtIndex:index];
}

- (IBAction)selectPreviousTab:(id)sender
{
	NSInteger index = [m_tabView indexOfTabViewItem:[m_tabView selectedTabViewItem]] - 1;
	if (index == -1)
	{
		index = [m_tabView numberOfTabViewItems] - 1;
	}
	[m_tabView selectTabViewItemAtIndex:index];
}

- (void)setIsLoading:(BOOL)bFlag
{
	m_isLoading = bFlag;
	[m_executeButton setEnabled:!bFlag];
	if (bFlag)
	{
		[m_progressIndicator startAnimation:self];
	}
	else
	{
		[m_progressIndicator stopAnimation:self];
	}
}


@end