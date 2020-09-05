unit mb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BuFindBluetooth: TButton;
    ConnectRF: TButton;
    procedure BuFindBluetoothClick(Sender: TObject);
    procedure ConnectRFClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses Bluetooth, unixtype, Sockets;

{ TForm1 }

procedure TForm1.BuFindBluetoothClick(Sender: TObject);
var
 device_id, device_sock: cint;
 scan_info: array[0..127] of inquiry_info;
 scan_info_ptr: Pinquiry_info;
 found_devices: cint;
 DevName: array[0..255] of Char;
 PDevName: PCChar;
 RemoteName: array[0..255] of Char;
 PRemoteName: PCChar;
 i: Integer;
 timeout1: Integer = 5;
 timeout2: Integer = 5000;
begin
 // get the id of the first bluetooth device.
 device_id := hci_get_route(nil);
 if (device_id < 0) then
   raise Exception.Create('FindBlueTooth: hci_get_route')
 else
   writeln('device_id = ',device_id);

 // create a socket to the device
 device_sock := hci_open_dev(device_id);
 if (device_sock < 0) then
   raise Exception.Create('FindBlueTooth: hci_open_dev')
 else
   writeln('device_sock = ',device_sock);

 // scan for bluetooth devices for 'timeout1' seconds
 scan_info_ptr:=@scan_info[0];
 FillByte(scan_info[0],SizeOf(inquiry_info)*128,0);
 found_devices := hci_inquiry_1(device_id, timeout1, 128, nil, @scan_info_ptr, IREQ_CACHE_FLUSH);

 writeln('found_devices (if any) = ',found_devices);

 if (found_devices < 0) then
   raise Exception.Create('FindBlueTooth: hci_inquiry')
 else
     begin
       PDevName:=@DevName[0];
       ba2str(@scan_info[0].bdaddr, PDevName);
       writeln('Bluetooth Device Address (bdaddr) DevName = ',PChar(PDevName));

       PRemoteName:=@RemoteName[0];
       // Read the remote name for 'timeout2' milliseconds
       if (hci_read_remote_name(device_sock,@scan_info[0].bdaddr,255,PRemoteName,timeout2) < 0) then
         writeln('No remote name found, check timeout.')
       else
         writeln('RemoteName = ',PChar(RemoteName));
     end;

 hci_close_dev(device_sock);
end;

procedure TForm1.ConnectRFClick(Sender: TObject);
var
  loc_addr: sockaddr_rc;
  opt: longint;
  s, status: unixtype.cint;
  bd_addr: bdaddr_t;
  channel: byte;
  bt_addr: array[0..17] of char;
  bt_message: array[0..1023] of char;
  cnt: ssize_t;
begin
  opt := SizeOf(loc_addr);

  //remote device address
  bt_addr := '00:07:80:66:0A:5E';

  //allocate socket
  s := fpsocket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);

  //channel that destination device is listening on
  channel := 1;

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
    cnt:=0;
    while cnt >= 0 do begin
      bt_message := '';
      cnt:= fprecv(s,@bt_message, 1024, 0);
      if cnt = 0 then begin
        writeln('leer');
      end
      else
        Write(bt_message);
    end;
    // close socket after message is sent
    fpshutdown(s, 0);
    writeln('end');
  end;
end;

end.

