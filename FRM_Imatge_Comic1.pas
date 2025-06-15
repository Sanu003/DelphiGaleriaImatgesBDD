unit FRM_Imatge_Comic1;

interface

uses
  Winapi.Windows, Winapi.Messages, SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.FMTBcd, Data.DB, Data.SqlExpr,
  Data.DBXMySQL, Data.DbxSqlite,Vcl.StdCtrls,JPEG,
  Vcl.ExtCtrls, FileCtrl,System.Types, System.ImageList, Vcl.ImgList,
  System.IOUtils, System.Generics.Collections,System.RegularExpressions,Vcl.Imaging.pngimage,
  Vcl.MPlayer, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, Vcl.Menus;

type
  TFRM_Imatge_Comic = class(TForm)
    ScrollBox1: TScrollBox;
    DBComicsImatges: TFDQuery;
    DBComicsImatgesid: TFDAutoIncField;
    DBComicsImatgesnom: TStringField;
    DBComicsImatgescontingut: TBlobField;
    DBComicsImatgescodi_comic: TStringField;
    PopupMenu1: TPopupMenu;
    Exit1: TMenuItem;
    DBComicsImatgesheight: TIntegerField;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CarregarComicsDB;
    procedure ImageClickDB(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ScrollBox1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private
    PageSize,Offset:Integer;
  public
    codi_comic:String;
  end;

var
  FRM_Imatge_Comic: TFRM_Imatge_Comic;

implementation
uses Unit2,FRM_image1;

{$R *.dfm}

procedure TFRM_Imatge_Comic.Exit1Click(Sender: TObject);
begin
  ModalResult:=MrOk;
end;

procedure TFRM_Imatge_Comic.FormActivate(Sender: TObject);
begin
  if DBComicsImatges.RecordCount = 0 then begin
    CarregarComicsDB;
  end;
end;

procedure TFRM_Imatge_Comic.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_ESCAPE then begin
    ModalResult:=MrOk;
  end;

end;

procedure TFRM_Imatge_Comic.FormShow(Sender: TObject);
begin
  Application.ProcessMessages;

end;

procedure TFRM_Imatge_Comic.CarregarComicsDB;
const
  NumCols = 3;
var
  I, Row, Col: Integer;
  Control: TControl;
  Picture: TPicture;
  PNGImage: TPngImage;
  JPGImage: TJPEGImage;
  contenidoStream: TMemoryStream;
  Imagenes: array of TImagenData;
  MaxHeightPorFila: array of Integer;
  PosYPorFila: array of Integer;
  Data: TImagenData;

begin
  Screen.Cursor := crHourGlass;

  // Eliminar todos los TImage y TWindowsMediaPlayer existentes en ScrollBox1
  for I := ScrollBox1.ControlCount - 1 downto 0 do
  begin
    Control := ScrollBox1.Controls[I];
    if Control is TImage then
    begin
      TImage(Control).Picture := nil; // Libera los recursos de la imagen
      Control.Free;
    end;
  end;


  // Realizar la consulta a la base de datos para obtener las imágenes

  DBComicsImatges.SQL.Clear;
  if PageSize <= 0 then begin
    DBComicsImatges.SQL.Add('SELECT * FROM comic_imatges where codi_comic = '+QuotedStr(codi_comic)+'ORDER BY id ASC ');
  end else begin
    DBComicsImatges.SQL.Add('SELECT * FROM comic_imatges where codi_comic = '+QuotedStr(codi_comic));
    DBComicsImatges.SQL.Add(Format('ORDER BY id DESC LIMIT %d OFFSET %d', [PageSize, Offset]));
  end;
  DBComicsImatges.Open;
  DBComicsImatges.First;

  SetLength(Imagenes, 0);
  SetLength(MaxHeightPorFila, 100);
  SetLength(PosYPorFila, 100);

  I := -1;

  // ?? Primera pasada: crear imágenes y calcular alturas
  while not DBComicsImatges.Eof do
  begin
    I := I + 1;
    Col := I mod NumCols;
    Row := I div NumCols;

    try
      var Img := TImage.Create(ScrollBox1);
      Img.Parent := ScrollBox1;

      Picture := TPicture.Create;
      contenidoStream := TMemoryStream.Create;

      try
        try
          PNGImage := TPngImage.Create;
          DBComicsImatgescontingut.SaveToStream(contenidoStream);
          contenidoStream.Position := 0;
          PNGImage.LoadFromStream(contenidoStream);
          Picture.Assign(PNGImage);
          PNGImage.Free;
        except
          PNGImage.Free;
          try
            JPGImage := TJPEGImage.Create;
            contenidoStream.Position := 0;
            JPGImage.LoadFromStream(contenidoStream);
            Picture.Assign(JPGImage);
            JPGImage.Free;
          except
            JPGImage.Free;
          end;
        end;

        Img.Picture.Assign(Picture);
        Img.Proportional := True;
        Img.Stretch := True;
        Img.Width := Round(ScrollBox1.ClientWidth / NumCols) - 15;
        Img.Height := Round((Img.Picture.Height / Img.Picture.Width) * Img.Width);

        if Img.Height > MaxHeightPorFila[Row] then
          MaxHeightPorFila[Row] := Img.Height;

        SetLength(Imagenes, Length(Imagenes) + 1);
        Imagenes[High(Imagenes)].Image := Img;
        Imagenes[High(Imagenes)].Row := Row;
        Imagenes[High(Imagenes)].Col := Col;
        Imagenes[High(Imagenes)].Width := Img.Width;
        Imagenes[High(Imagenes)].Height := Img.Height;

        Img.Visible := False; // Ocultar hasta ubicar bien
        Img.Tag := DBComicsImatgesid.AsInteger;
        Img.OnClick := ImageClickDB;

        DBComicsImatges.Edit;
        DBComicsImatgesHeight.AsInteger := Img.Height;

        Application.ProcessMessages;
      finally
        Picture.Free;
        contenidoStream.Free;
      end;

    except

    end;

    DBComicsImatges.Next;
  end;

  // ?? Segunda pasada: asignar posición y mostrar
  for I := 0 to High(Imagenes) do
  begin
    Row := Imagenes[I].Row;
    Col := Imagenes[I].Col;

    if Row = 0 then
      PosYPorFila[Row] := 0
    else if PosYPorFila[Row] = 0 then
      PosYPorFila[Row] := PosYPorFila[Row - 1] + MaxHeightPorFila[Row - 1] + 10;

    with Imagenes[I].Image do
    begin
      Left := Col * Round(ScrollBox1.ClientWidth / NumCols);
      Top := PosYPorFila[Row];
      Visible := True;
    end;

  end;

  Screen.Cursor := crDefault;

end;

procedure TFRM_Imatge_Comic.ImageClickDB(Sender: TObject);
var
  Image: TImage;
  ImageIndex: Integer;
  PNGImage : TPngImage;
  JPEGImage : TJPEGImage;
  Picture : TPicture;
  contenidoStream : TMemoryStream;
begin
  Image := Sender as TImage;
  ImageIndex := Image.Tag; // Establecer ImageIndex basado en el Tag de la imagen
  DBComicsImatges.First;
  while DBComicsImatgesid.AsInteger <> Image.Tag do begin
  DBComicsImatges.Next;
  end;


  Application.CreateForm(TFRM_image, FRM_image);
  FRM_Image.Query := DBComicsImatges;
  contenidoStream := TMemoryStream.Create;
  PNGImage := TPngImage.Create;
  JPEGImage:=TJPEGImage.Create;
  Picture := TPicture.Create;
  DBComicsImatgescontingut.SaveToStream(contenidoStream);
  contenidoStream.Position := 0;  // Asegurarse de que el stream comience desde el principio
  // Si el contenido es una imagen PNG
  try
  PNGImage.LoadFromStream(contenidoStream);
  Picture.Assign(PNGImage);
  FRM_Image.Image1.Picture.Assign(Picture);
  FRM_Image.Image1.Tag := Image.Tag;
  FRM_Image.tag:=Image.Tag;
  FRM_Image.Image1.Proportional := True;
  FRM_Image.Image1.Stretch := False;
  FRM_Image.Show;

  except

    try
      contenidoStream.Position := 0;
      JPEGImage.LoadFromStream(contenidoStream);
      Picture.Assign(JPEGImage);
      FRM_Image.Image1.Picture.Assign(Picture);
      FRM_Image.Image1.Tag := Image.Tag;
      FRM_Image.tag:=Image.Tag;
      FRM_Image.Image1.Proportional := True;
      FRM_Image.Image1.Stretch := False;
      FRM_Image.Show;
    except

    end;
  end;


  PNGImage.Free;
  Picture.Free;
  JPEGImage.Free;
end;
procedure TFRM_Imatge_Comic.ScrollBox1MouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
if WheelDelta > 0 then
    ScrollBox1.VertScrollBar.Position := ScrollBox1.VertScrollBar.Position - ScrollBox1.VertScrollBar.Increment
  else
    ScrollBox1.VertScrollBar.Position := ScrollBox1.VertScrollBar.Position + ScrollBox1.VertScrollBar.Increment;
  Handled := True;
end;

end.
