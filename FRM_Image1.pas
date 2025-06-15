unit FRM_Image1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, System.ImageList,
  Vcl.ImgList, Vcl.StdCtrls, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Data.DB,
  Vcl.Menus, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFRM_Image = class(TForm)
    Image1: TImage;
    PopupMenu1: TPopupMenu;
    DataSource1: TDataSource;
    DBGeneric: TFDQuery;
    Exit1: TMenuItem;
    Guardar1: TMenuItem;
    SaveDialog1: TSaveDialog;
    Delete1: TMenuItem;
    Comic1: TMenuItem;
    CreateNewComic1: TMenuItem;
    AddtoComic1: TMenuItem;
    AddtoFav1: TMenuItem;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Exit1Click(Sender: TObject);
    procedure Guardar1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure CreateNewComic1Click(Sender: TObject);
    procedure AddtoComic1Click(Sender: TObject);
    procedure AddtoFav1Click(Sender: TObject);
  private
    FQuery: TFDQuery;
  public
    Fav,NFav,Comic:Boolean;
    ImageIndex,IDNova:Integer;
    tag:integer;
    procedure LoadImage(const ImagePath: string);
    property Query: TFDQuery read FQuery write FQuery;
  end;

var
  FRM_Image: TFRM_Image;

implementation
Uses Bases1, Unit2,FRM_alta_Imatge1,FRM_Buscar_comic1;

{$R *.dfm}

procedure TFRM_Image.AddtoComic1Click(Sender: TObject);
var
id_comic,codi_comic:Integer;
BlobStream: TMemoryStream;
begin
  Application.CreateForm(TFRM_buscar_comic,FRM_Buscar_comic);

  if FRM_Buscar_comic.ShowModal = mrOk then begin
    BlobStream:=TMemoryStream.Create;
    id_comic:=FRM_Buscar_comic.id_comic;

    DBGeneric.SQL.Clear;
    DBGeneric.SQL.Add('select codi_comic from comic_portada');
    DBGeneric.SQL.Add('where id = '+QuotedStr(IntToStr(id_comic)));
    DBGeneric.Open;

    codi_comic:=DBGeneric.FieldByName('codi_comic').AsInteger;

    (FQuery.FieldByName('contingut') as TBlobField).SaveToStream(BlobStream);

    DBGeneric.SQL.Clear;
    DBGeneric.SQL.Add('insert into comic_imatges (codi_comic,contingut,height)');
    DBGeneric.SQL.Add('VALUES ('+QuotedStr(IntToStr(codi_comic))+',:contingut,:height) ');
    DBGeneric.ParamByName('contingut').LoadFromStream(BlobStream, ftBlob);
    DBGeneric.ParamByName('height').AsInteger := Image1.Height;
    DBGeneric.ExecSQL;

    BlobStream.Free;
  end;
end;

procedure TFRM_Image.AddtoFav1Click(Sender: TObject);
var
id_comic,codi_comic:Integer;
BlobStream: TMemoryStream;
url,height:String;
begin

    BlobStream:=TMemoryStream.Create;

    DBGeneric.SQL.Clear;
    DBGeneric.SQL.Add('SELECT * FROM ');
    if Form2.cbFav.Checked then
      DBGeneric.SQL.Add('imatges2')
    else
      DBGeneric.SQL.Add('imatges');

    DBGeneric.SQL.Add('Where id = '+IntToStr(FRM_Image.Image1.Tag));
    DBGeneric.Open;

    (FQuery.FieldByName('contingut') as TBlobField).SaveToStream(BlobStream);
    url := DBGeneric.FieldByName('url').AsString;
    height := DBGeneric.FieldByName('height').AsString;

    DBGeneric.SQL.Clear;
    DBGeneric.SQL.Add('insert into ');
    if Form2.cbFav.Checked then
      DBGeneric.SQL.Add('imatges')
    else
      DBGeneric.SQL.Add('imatges2');

    DBGeneric.SQL.Add('(contingut,url,height) VALUES (:contingut,:url,:height) ');
    DBGeneric.ParamByName('contingut').LoadFromStream(BlobStream, ftBlob);
    DBGeneric.ParamByName('url').AsString := url;
    DBGeneric.ParamByName('height').AsString:= height;
    DBGeneric.ExecSQL;

    BlobStream.Free;

end;

procedure TFRM_Image.CreateNewComic1Click(Sender: TObject);
var
id:Integer;
BlobStream: TMemoryStream;
begin
  id:=0;
  BlobStream:=TMemoryStream.Create;

  DBGeneric.SQL.Clear;
  DBGeneric.SQL.Add('select Max(codi_comic) as codi from comic_portada');
  DBGeneric.Open;

  id := DBGeneric.FieldByName('codi').AsInteger + 1;

  (FQuery.FieldByName('contingut') as TBlobField).SaveToStream(BlobStream);

  DBGeneric.SQL.Clear;
  DBGeneric.SQL.Add('insert into comic_portada (codi_comic,contingut)');
  DBGeneric.SQL.Add('VALUES ('+QuotedStr(IntToStr(Id))+',:contingut) ');
  DBGeneric.ParamByName('contingut').LoadFromStream(BlobStream, ftBlob);
  DBGeneric.ExecSQL;

  BlobStream.Free;
end;

procedure TFRM_Image.Delete1Click(Sender: TObject);
var
taula:String;
begin
  if Application.MessageBox('Are You Sure??','Delete File',MB_YESNO or MB_ICONQUESTION) = mrYes then begin
    FQuery.Delete;
    Self.Free;
  end;
end;

procedure TFRM_Image.Exit1Click(Sender: TObject);
begin

  self.Free;
end;

procedure TFRM_Image.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Success: Boolean;
  PNGImage:TPNGImage;
  JPGImage:TJPEGImage;
  MemoryStream:TMemoryStream;
  Picture:TPicture;
  Index,seguent,ID1,ID2:Integer;
  taula:String;
begin
  if Key = 27 then begin

    self.Free;
  end;

  if Key = VK_RIGHT then begin

    if Form2.local then begin

      repeat
      Success := True;
      try
        Inc(Form2.ImageIndex);
      if Form2.ImageIndex >= Length(Form2.ImageFiles) then
        Form2.ImageIndex := 0;  // Reiniciar al inicio si se pasa del último
      LoadImage(Form2.ImageFiles[Form2.ImageIndex]);
      except
        on E: Exception do
        begin
          Success := False;
          // Aquí puedes agregar un log, mostrar un mensaje, o esperar un tiempo antes de reintentar, si es necesario.
        end;
      end;
      until Success;

    end;

    if Form2.nuvol then begin

      if not FQuery.Eof then
        FQuery.Next
      else
        FQuery.First;

      Picture := TPicture.Create;
      PNGImage := TPngImage.Create;
      JPGImage := TJPEGImage.Create;
      MemoryStream := TMemoryStream.Create;
        try
          //Form2.DBLiniescontingut.SaveToStream(MemoryStream);
          (FQuery.FieldByName('contingut') as TBlobField).SaveToStream(MemoryStream);
          MemoryStream.Position := 0;
          try
            PNGImage.LoadFromStream(MemoryStream);
            Picture.Assign(PNGImage);
            Image1.Picture:=nil;
            Image1.Picture.Assign(Picture);
          except
            // Si falla, intentar cargar como JPG
            MemoryStream.Position := 0;
            JPGImage.LoadFromStream(MemoryStream);
            Picture.Assign(JPGImage);
            Image1.Picture:=nil;
            Image1.Picture.Assign(Picture);
          end;
        except

        end;

        PNGImage.Free;
        JPGImage.Free;
        MemoryStream.Free;
    end;

    Application.ProcessMessages;

  end;

  if Key = VK_LEFT then begin

    if Form2.local then begin

      repeat
      Success := True;
      try
        Form2.ImageIndex := Form2.ImageIndex-1;
      if Form2.ImageIndex < 0 then
        Form2.ImageIndex := Length(Form2.ImageFiles);  // Reiniciar al inicio si se pasa del último
        LoadImage(Form2.ImageFiles[Form2.ImageIndex]);
      except
        on E: Exception do
        begin
          Success := False;
          // Aquí puedes agregar un log, mostrar un mensaje, o esperar un tiempo antes de reintentar, si es necesario.
        end;
      end;
      until Success;

    end;

      if Form2.nuvol then begin

      if not FQuery.Bof then
        FQuery.Prior
      else
        FQuery.Last;

      Picture := TPicture.Create;

      Picture := TPicture.Create;
      PNGImage := TPngImage.Create;
      JPGImage := TJPEGImage.Create;
      MemoryStream := TMemoryStream.Create;
        try
          (FQuery.FieldByName('contingut') as TBlobField).SaveToStream(MemoryStream);
          MemoryStream.Position := 0;
          try
            PNGImage.LoadFromStream(MemoryStream);
            Picture.Assign(PNGImage);
            Image1.Picture:=nil;
            Image1.Picture.Assign(Picture);
          except
            // Si falla, intentar cargar como JPG
            MemoryStream.Position := 0;
            JPGImage.LoadFromStream(MemoryStream);
            Picture.Assign(JPGImage);
            Image1.Picture:=nil;
            Image1.Picture.Assign(Picture);
          end;
        except

        end;

        PNGImage.Free;
        JPGImage.Free;
        MemoryStream.Free;
      end;

  Application.ProcessMessages;
  end;

  if KEY = VK_UP then begin
    if Form2.nuvol then begin
      ID1:=FQuery.FieldByName('id').AsInteger;

      if IDNova<> 0 then begin
      ID1:=IDNova;
      end;

      if NFav then begin
        taula:='imatges';
      end else begin
        taula:='imatges2';
      end;

      DBGeneric.SQL.Clear;
      DBGeneric.SQL.Add('select * from '+taula+' where id > '+QuotedStr(IntToStr(ID1))+'order by id asc LIMIT 1');
      DBGeneric.Open;

      if DBGeneric.RecordCount>0 then begin

        ID2 := DBGeneric.FieldByName('id').AsInteger;

        DBGeneric.SQL.Clear;
        DBGeneric.SQL.Add('update '+taula+' SET id = -1 where id = '+QuotedStr(IntToStr(id2)));
        DBGeneric.ExecSQL;

        DBGeneric.SQL.Clear;
        DBGeneric.SQL.Add('update '+taula+' SET id = '+QuotedStr(IntToStr(id2))+' where id = '+QuotedStr(IntToStr(id1)));
        DBGeneric.ExecSQL;

        DBGeneric.SQL.Clear;
        DBGeneric.SQL.Add('update '+taula+' SET id = '+QuotedStr(IntToStr(id1))+' where id = -1');
        DBGeneric.ExecSQL;

        IDNova:=ID2
      end;
    end;
  end;

  if KEY = VK_DOWN then begin
    if Form2.nuvol then begin
      ID1:=FQuery.FieldByName('id').AsInteger;

      if IDNova<> 0 then begin
      ID1:=IDNova;
      end;

      if NFav then begin
        taula:='imatges';
      end else begin
        taula:='imatges2';
      end;

      DBGeneric.SQL.Clear;
      DBGeneric.SQL.Add('select * from '+taula+' where id < '+QuotedStr(IntToStr(ID1))+'order by id desc LIMIT 1');
      DBGeneric.Open;

      if DBGeneric.RecordCount>0 then begin

        ID2 := DBGeneric.FieldByName('id').AsInteger;

        DBGeneric.SQL.Clear;
        DBGeneric.SQL.Add('update '+taula+' SET id = -1 where id = '+QuotedStr(IntToStr(id2)));
        DBGeneric.ExecSQL;

        DBGeneric.SQL.Clear;
        DBGeneric.SQL.Add('update '+taula+' SET id = '+QuotedStr(IntToStr(id2))+' where id = '+QuotedStr(IntToStr(id1)));
        DBGeneric.ExecSQL;

        DBGeneric.SQL.Clear;
        DBGeneric.SQL.Add('update '+taula+' SET id = '+QuotedStr(IntToStr(id1))+' where id = -1');
        DBGeneric.ExecSQL;

        IDNova:=ID2
      end;
    end;
  end;


end;

procedure TFRM_Image.FormShow(Sender: TObject);
begin
  if not Form2.nuvol then begin
    Delete1.Visible:=False;
    Comic1.Visible:=False
  end;

  if Form2.nuvol then begin
    Fav := Form2.cbFav.Checked;
    NFav := not Fav;
    IDNova:=0;
  end;
end;

procedure TFRM_Image.Guardar1Click(Sender: TObject);
var
path:String;
PngImage: TPngImage;
begin
    if SaveDialog1.Execute then
    begin
      path := SaveDialog1.FileName;
      PngImage := TPngImage.Create;

      PngImage.Assign(Image1.Picture.Graphic);

      PngImage.SaveToFile(path);
    end;
end;

procedure TFRM_Image.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    if X > Image1.Width div 2 then
    begin
      // Clic en la parte derecha de la imagen
      keybd_event(VK_RIGHT, 0, 0, 0);
      keybd_event(VK_RIGHT, 0, KEYEVENTF_KEYUP, 0);
    end
    else
    begin
      // Clic en la parte izquierda de la imagen
      keybd_event(VK_LEFT, 0, 0, 0);
      keybd_event(VK_LEFT, 0, KEYEVENTF_KEYUP, 0);
    end;
  end;
end;

procedure TFRM_image.LoadImage(const ImagePath: string);
var
  Picture: TPicture;
  Extension: string;
  PNGImage: TPngImage;
  JPGImage: TJPEGImage;
begin
  Picture := TPicture.Create;
  try
    Extension := LowerCase(ExtractFileExt(ImagePath));
    try
      PNGImage := TPngImage.Create;
      try
        PNGImage.LoadFromFile(ImagePath);
        Picture.Assign(PNGImage);
      finally
        PNGImage.Free;
      end;
    except
      try
        JPGImage := TJPEGImage.Create;
        try
          JPGImage.LoadFromFile(ImagePath);
          Picture.Assign(JPGImage);
        finally
          JPGImage.Free;
        end;
      except

      end;
    end;
    Image1.Picture.Assign(Picture);
    Image1.Proportional := True;
    Image1.Stretch := True;
  finally
    Picture.Free;
  end;
end;

end.
