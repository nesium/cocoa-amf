//
//  SimpleMessage.as
//
//  Created by Marc Bauer on 2009-01-29.
//  Copyright (c) 2009 nesiumdotcom. All rights reserved.
//

package
{
	
	public class SimpleMessage
	{
		
		public var message:String;
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function SimpleMessage(aMessage:String=null)
		{
			message = aMessage;
		}
		
		public function toString():String
		{
			return '[SimpleMessage] message: ' + message;
		}
	}
}
