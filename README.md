# bluetoothlaz

THIS IS AN INOFFITIAL FORK OF BLUETOOTHLAZ FROM <http://sourceforge.net/projects/lazarus-ccr/files/Bluetooth/>

The bluetoothlaz package provides bindings and functions to access bluetooth devices under various platforms.

## About
The bluetoothlaz package provides bindings and functions to access bluetooth devices under various platforms. It contains examples, like accessing the Wii Remote.
## Author
Mattias Gaertner
## License
LGPL (please contact the author if the LGPL doesn't work with your project licensing)
## Download
The latest stable release can be found on the <http://sourceforge.net/projects/lazarus-ccr/files/Bluetooth/> Lazarus CCR Files page.
## Status
### Alpha
At the moment the package only supports Linux. Eventually it will support Windows, Mac OS X and other platforms and will get some platform independent Wrapper functions/classes.
## Dependencies / System Requirements
### Linux
The BlueZ libraries plus their development files must be installed. 
#### Ubuntu/Debian/Raspbian
Install the libbluetooth-dev package:
__sudo apt-get install libbluetooth-dev__
#### Mandriva/Redhat
Install the libbluez-devel package.
## Installation
Download and unpack the package to a directory of your choice. In the Lazarus IDE use Package / Open package file. A file dialog will appear. Choose the __bluetooth/bluetoothlaz.lpk__ and open it. That's all. The IDE now knows the package.
## Examples
There are two examples for the Wii Remote. One that demonstrates how to connect to a Wii Remote and shows the infrared sensors and one that demonstrates VR headtracking with the Wii Remote and the 3D package Asmoday.
### Identifying reachable Bluetooth devices
This is a simple example that will identify one Bluetooth device in the vicinity.
The code uses the following modules:
`uses Bluetooth, ctypes, Sockets;`
This part can be called from a button click to write Bluetooth information to the console:
### Communicating using RFCOMM
RFCOMM is a simple set of transport protocols, made on top of the L2CAP protocol, providing emulated RS-232 serial ports .

RFCOMM is sometimes called serial port emulation and the Bluetooth serial port profile is based on this protocol. RFCOMM provides a simple reliable data stream to the user, similar to TCP. Many Bluetooth applications use RFCOMM because of its widespread support and publicly available API on most operating systems. Applications that use a serial port to communicate can often be quickly ported to use RFCOMM.

This example attempts to connect to a remote device identified by Bluetooth address 34:8A:7B:02:04:4D which is listening on channel 7 and sends a simple message if successful. It can be used with the Android example application [https://android.googlesource.com/platform/development/+/eclair-passion-release/samples/BluetoothChat BluetoothChat].


    procedure TForm1.ConnectRFCOMMClick(Sender: TObject);
    var
      loc_addr: sockaddr_rc;
      opt: longint;
      s, status: unixtype.cint;
      bd_addr: bdaddr_t;
      channel: byte;
      bt_addr: array[0..17] of char;
      bt_message: array[0..10] of char;
    begin
      opt := SizeOf(loc_addr);
    
      //remote device address
      bt_addr := '34:8A:7B:02:04:4D';
    
      //allocate socket
      s := fpsocket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
    
      //channel that destination device is listening on
      channel := 7;
    
      loc_addr.rc_family := AF_BLUETOOTH;
      loc_addr.rc_bdaddr := bd_addr;
      loc_addr.rc_channel := channel;
      str2ba(@bt_addr, @bd_addr);
      loc_addr.rc_bdaddr := bd_addr;
      writeln('Trying connection to ', bt_addr);
    
      status := fpconnect(s, @loc_addr, opt);
      writeln('channel: ', channel, '  result: ', status);
      if status = 0 then
      begin
        bt_message := 'Hello there';
        fpsend(s, @bt_message, 11, 0);
        // close socket after message is sent
        fpshutdown(s, 0);
      end;
    end; 


## ToDo: Usage/Tutorial/Reference

The package is quite new and not yet complete. Documentation will be written, when some more platforms are supported and the API has stabilized.

The HCI documentation for hci_* functions found in bluetooth.pas can be found in the BLUETOOTH SPECIFICATION PDF files linked at this <http://en.wikipedia.org/wiki/Bluetooth#Specifications_and_features>, specifically at this: <http://en.wikipedia.org/wiki/Bluetooth#cite_note-bluetooth_specs-31>.
