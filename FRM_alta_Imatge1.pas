unit FRM_alta_Imatge1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet,Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  IdHTTP, IdSSL, IdSSLOpenSSL, IdAuthentication,JPEG,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,Urlmon, Vcl.Menus;

type
  TFRM_alta_Imatge = class(TForm)
    DataSource1: TDataSource;
    DBLinies: TFDQuery;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    Image1: TImage;
    Panel1: TPanel;
    Edit1: TEdit;
    Button2: TButton;
    IdHTTP1: TIdHTTP;
    PopupMenu1: TPopupMenu;
    Guardar1: TMenuItem;
    cbFav: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Guardar1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FRM_alta_Imatge: TFRM_alta_Imatge;

implementation
  uses Unit2;

{$R *.dfm}

procedure TFRM_alta_Imatge.Button1Click(Sender: TObject);
var
  FileStream: TFileStream;
  Stream: TMemoryStream;
  PNGImage :TPngImage;
  JPGImage: TJPEGImage;
  Picture : TPicture;
  taula:String;
begin
  // Abre el cuadro de diálogo de selección de archivo
  if OpenDialog1.Execute then
  begin
    PNGImage := nil;
    FileStream := nil;
    try
      // Crear el flujo de archivo y el PNGImage
      FileStream := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
      try
        FileStream.Position:=0;
        PNGImage := TPngImage.Create;
        PNGImage.LoadFromStream(FileStream);
        Image1.Picture.Assign(PNGImage);
      except
        FileStream.Position:=0;
        JPGImage := TJPEGImage.Create;
        JPGImage.LoadFromStream(FileStream);
        Image1.Picture.Assign(JPGImage);
      end;
      Application.ProcessMessages;
      if cbFav.Checked then begin
        taula := 'imatges2'
      end else begin
        taula := 'imatges'
      end;
      DBLinies.SQL.Clear;
      DBLinies.SQL.Add('insert into '+taula+' (contingut,height)');
      DBLinies.SQL.Add('values (:contingut,:height)');
      DBLinies.ParamByName('contingut').LoadFromStream(FileStream,ftBlob);
      DBLinies.ParamByName('height').asInteger:=Image1.Height;
      DBLinies.ExecSQL;
      PNGImage.Free;
      FileStream.Free;
    except
      // Liberar recursos
      PNGImage.Free;
      FileStream.Free;
    end;




  end;
end;

procedure TFRM_alta_Imatge.Button2Click(Sender: TObject);
var
  Buff: array[0..2048-1] of Char;
  url,taula:String;
  posicio:integer;
begin
  Screen.Cursor := crHourGlass;
  try
  url:=Edit1.Text;
  posicio := Pos('&format', url);

  // Si la subcadena se encuentra, elimina desde allí hasta el final
  if posicio > 0 then
    Delete(url, posicio, Length(url) - posicio + 1);

  URLDownloadToCacheFile(nil, PChar(url), Buff, SizeOf(Buff),0,nil);
  Image1.Picture.LoadFromFile(Buff);
  DBLinies.SQL.Clear;
  if cbFav.Checked then begin
    taula := 'imatges2'
  end else begin
    taula := 'imatges'
  end;

  DBLinies.SQL.Add('insert into '+taula+' (contingut,url,height)');
  DBLinies.SQL.Add('values (:contingut,:url,:height)');
  DBLinies.ParamByName('contingut').LoadFromFile(Buff,ftBlob);
  DBLinies.ParamByName('url').asString:=url;
  DBLinies.ParamByName('height').asInteger:=Image1.Height;
  DBLinies.ExecSQL;


  except

  end;
  Edit1.Text:='';
  Screen.Cursor := crDefault;
end;

procedure TFRM_alta_Imatge.Guardar1Click(Sender: TObject);
var
Lineas: TStringList;
  I: Integer;
begin
  if OpenDialog1.Execute then
  begin
    Lineas := TStringList.Create;
      try
        Lineas.LoadFromFile(OpenDialog1.FileName);
        for I := 0 to Lineas.Count - 1 do
        begin
          if Lineas[i]<>'' then begin
            Edit1.Text := Lineas[i];
            Button2.Click;
            application.ProcessMessages;
          end;
        end;
      finally
        Lineas.Free;
      end;
    end;
end;

end.
