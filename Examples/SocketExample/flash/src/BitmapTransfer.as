package
{
	import SimpleMessage;
	
	import com.adobe.images.PNGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.net.registerClassAlias;
	import flash.system.Security;
	import flash.utils.ByteArray;
	
	import skins.BitmapTransferSkin;
	
	public class BitmapTransfer extends Sprite 
	{

		/***************************************************************************
		*                           Protected properties                           *
		***************************************************************************/
		protected static const k_port:int = 1235;
		protected var m_socket:Socket;
		protected var m_state:int = 0;
		protected var m_nextObjectSize:int;
		protected var m_bitmap:Bitmap;
		

		public function BitmapTransfer() 
		{
			registerClassAlias('SimpleMessage', SimpleMessage);
			
			m_bitmap = new BitmapTransferSkin.ProjectSprouts();
			addChild(m_bitmap);
			init();
		}
		
		/***************************************************************************
		*                             Protected methods                            *
		***************************************************************************/
		protected function init():void
		{
			m_socket = new Socket();
			openSocket('localhost');
		}
		
		protected function sendBitmap():void
		{
			trace(m_bitmap.bitmapData);
			writeToSocket(PNGEncoder.encode(m_bitmap.bitmapData));
		}
		
		protected function openSocket(host:String):void
		{
			trace('connect to ' + host + ':' + k_port);
			Security.loadPolicyFile('xmlsocket://' + host + ':' + k_port);
			m_socket.addEventListener(Event.CONNECT, socket_didConnect);
			m_socket.addEventListener(Event.CLOSE, socket_didDisconnect);
			m_socket.addEventListener(IOErrorEvent.IO_ERROR, socket_ioError);
			m_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socket_securityError);
			m_socket.addEventListener(ProgressEvent.SOCKET_DATA, socket_data);
			m_socket.connect(host, k_port);
		}
		
		protected function socket_didConnect(e:Event):void
		{
			m_socket.writeUTFBytes('BIN-INIT');
			m_socket.writeByte(0);
			m_socket.flush();
			
			sendBitmap();
		}
		
		protected function socket_didDisconnect(e:Event):void
		{
			trace('Connection closed by remote.', 'Connection closed', true);
		}
		
		protected function socket_ioError(e:IOErrorEvent):void
		{
			trace('Could not connect to socket!', 'IO Error', true);
		}
		
		protected function socket_securityError(e:SecurityErrorEvent):void
		{
			trace('Encountered security error! ' + e.text, 'Security Error');
		}
		
		protected function readFromSocket():Boolean
		{
			if (m_state == 0 && m_socket.bytesAvailable >= 4)
			{
				m_nextObjectSize = m_socket.readUnsignedInt();
				m_state = 1;
				return m_socket.bytesAvailable > 0;
			}
			else if (m_state == 1 && m_socket.bytesAvailable >= m_nextObjectSize)
			{
				var obj:Object = m_socket.readObject();
				processReceivedData(obj);
				m_state = 0;
				return m_socket.bytesAvailable > 0;
			}
			return false;
		}
		
		protected function writeToSocket(data:Object):void
		{
			var ba:ByteArray = new ByteArray();
			ba.writeObject(data);
			m_socket.writeInt(ba.length);
			m_socket.writeBytes(ba);
			m_socket.flush();
		}
		
		protected function socket_data(e:Event):void
		{
			while (readFromSocket()) {}
		}
		
		protected function processReceivedData(data:Object):void
		{
			if (data is SimpleMessage)
			{
				trace('Received message: ' + SimpleMessage(data).message);
				writeToSocket(new SimpleMessage("You're welcome cocoa."));
			}
		}
	}
}
