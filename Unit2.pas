unit Unit2;

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
  TImagenData = record
    Image: TImage;
    Row: Integer;
    Col: Integer;
    Width: Integer;
    Height: Integer;
  end;
type
  TForm2 = class(TForm)
    DataSource1: TDataSource;
    Image1: TImage;
    Panel1: TPanel;
    Button5: TButton;
    ScrollBox1: TScrollBox;
    Button1: TButton;
    Edit1: TEdit;
    FDConnection1: TFDConnection;
    DBLinies: TFDQuery;
    DBLiniesid: TFDAutoIncField;
    DBLiniesnom: TStringField;
    DBLiniescontingut: TBlobField;
    Button2: TButton;
    DBLiniesurl: TStringField;
    PopupMenu1: TPopupMenu;
    Eliminarnocargados1: TMenuItem;
    DBLiniesheight: TIntegerField;
    DBLinies2: TFDQuery;
    FDAutoIncField1: TFDAutoIncField;
    StringField1: TStringField;
    DBLinies2contingut: TBlobField;
    StringField2: TStringField;
    IntegerField1: TIntegerField;
    IntegerField2: TIntegerField;
    Button3: TButton;
    Button4: TButton;
    cbFav: TCheckBox;
    Button6: TButton;
    DBComicsPortada: TFDQuery;
    DBComicsPortadaid: TFDAutoIncField;
    DBComicsPortadanom: TStringField;
    DBComicsPortadacontingut: TBlobField;
    DBComicsPortadacodi_comic: TStringField;
    DBComicsPortadaheight: TIntegerField;
    RefreshF51: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ScrollBox1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ShowImageForm(const ImagePath: string);
    procedure ShowImageFormDB(const ImageFileName: string);
    procedure ImageClick(Sender: TObject);
    procedure ImageClickDB(Sender: TObject);
    procedure ComicImageClickDB(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Eliminarnocargados1Click(Sender: TObject);
    procedure CarregarImatgesDB;
    procedure CarregarComicsDB;
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure RefreshF51Click(Sender: TObject);
  private

  public
    ImageIndex,NumFiles,PageSize,OffSet: Integer;
    ID:Integer;
    ImageFiles: TArray<string>;
    local,nuvol:Boolean;
  end;
var
  Form2: TForm2;
implementation
uses FRM_Image1,Bases1,FRM_alta_imatge1,FRM_Imatge_Comic1;
{$R *.dfm}
function Min(A, B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;
function NaturalCompare(const A, B: string): Integer;
var
  RegExpr: TRegEx;
  AParts, BParts: TArray<string>;
  I, NumA, NumB: Integer;
begin
  RegExpr := TRegEx.Create('(\d+|\D+)', [roCompiled]);
  AParts := RegExpr.Split(A);
  BParts := RegExpr.Split(B);
  for I := 0 to Min(Length(AParts), Length(BParts)) - 1 do
  begin
    if TryStrToInt(AParts[I], NumA) and TryStrToInt(BParts[I], NumB) then
    begin
      Result := NumA - NumB;
      if Result <> 0 then
        Exit;
    end
    else
    begin
      Result := CompareStr(AParts[I], BParts[I]);
      if Result <> 0 then
        Exit;
    end;
  end;
  Result := Length(AParts) - Length(BParts);
end;
procedure SortFiles(var Files: TArray<string>);
var
  I, J: Integer;
  Temp: string;
begin
  for I := Low(Files) to High(Files) - 1 do
  begin
    for J := I + 1 to High(Files) do
    begin
      if NaturalCompare(Files[I], Files[J]) > 0 then
      begin
        Temp := Files[I];
        Files[I] := Files[J];
        Files[J] := Temp;
      end;
    end;
  end;
end;


procedure TForm2.Button1Click(Sender: TObject);
begin
  PageSize:=StrToInt(Edit1.Text);
  Offset:=0;
  CarregarImatgesDB;
end;

procedure TForm2.CarregarImatgesDB;
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
  Local := False;
  Nuvol := True;

  // Borrar imágenes anteriores
  for I := ScrollBox1.ControlCount - 1 downto 0 do
  begin
    Control := ScrollBox1.Controls[I];
    if Control is TImage then
    begin
      TImage(Control).Picture.Graphic := nil;
      TImage(Control).Picture := nil;
      Control.Free;
    end;
  end;

  DBComicsPortada.SQL.Clear;
  DBLinies.SQL.Clear;

  if PageSize <= 0 then
    DBLinies.SQL.Add('SELECT * FROM imatges ORDER BY id ASC ')
  else
  begin
    DBLinies.SQL.Add('SELECT * FROM ');
    if cbFav.Checked then
      DBLinies.SQL.Add('imatges2')
    else
      DBLinies.SQL.Add('imatges');
    DBLinies.SQL.Add(Format(' ORDER BY id DESC LIMIT %d OFFSET %d', [PageSize, Offset]));
  end;

  DBLinies.Open;
  DBLinies.First;

  SetLength(Imagenes, 0);
  SetLength(MaxHeightPorFila, 100);
  SetLength(PosYPorFila, 100);

  I := -1;

  // Primera pasada: crear imágenes y calcular alturas
  while not DBLinies.Eof do
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
          DBLiniescontingut.SaveToStream(contenidoStream);
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
        Img.Tag := DBLiniesid.AsInteger;
        Img.OnClick := ImageClickDB;

        DBLinies.Edit;
        DBLiniesHeight.AsInteger := Img.Height;

        Application.ProcessMessages;
      finally
        Picture.Free;
        contenidoStream.Free;
      end;

    except
    end;

    DBLinies.Next;
  end;

  // Segunda pasada: asignar posición y mostrar
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


procedure TForm2.Button2Click(Sender: TObject);
begin
  Application.CreateForm(TFRM_alta_imatge,FRM_alta_imatge);
  FRM_alta_imatge.ShowModal;
  FRM_alta_imatge.Free;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  if OffSet-PageSize<=0 then begin
    Offset := 0;
  end else begin
    OffSet:=Offset-PageSize;
  end;
  CarregarImatgesDB;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  OffSet:=Offset+PageSize;
  CarregarImatgesDB;
end;

procedure TForm2.Button5Click(Sender: TObject);
var
  FileOpenDialog: TFileOpenDialog;
  Files: TArray<string>;
  YourDirectoryPath: string;
  I, I2, tamanyImatgeAnterior, tamanyImatgeAnterior2, EntratMP, EntratExtensio: Integer;
  Image: TImage;
  YOffset: Integer;
  Control: TControl;
  Extension: string;
  Picture: TPicture;
  PNGImage: TPngImage;
  JPGImage: TJPEGImage;
begin
  Local:=True;
  Nuvol:=False;
  // Eliminar todos los TImage y TWindowsMediaPlayer existentes en ScrollBox1
  for I := ScrollBox1.ControlCount - 1 downto 0 do
  begin
    Control := ScrollBox1.Controls[I];
    if (Control is TImage) then
    begin
      Control.Free;
    end;
  end;
  I2 := -1;
  I:=-1;
  tamanyImatgeAnterior2 := 0;
  tamanyImatgeAnterior := 0;
  FileOpenDialog := TFileOpenDialog.Create(nil);
  try
    FileOpenDialog.Options := [fdoPickFolders, fdoPathMustExist, fdoFileMustExist];
    if FileOpenDialog.Execute then
    begin
      YourDirectoryPath := FileOpenDialog.FileName;
      // Obtener una lista de archivos PNG, JPG y MP4
      Files := TDirectory.GetFiles(YourDirectoryPath, '*.png');
      Files := Files + TDirectory.GetFiles(YourDirectoryPath, '*.jpg');
      Files := Files + TDirectory.GetFiles(YourDirectoryPath, '*.mp4');
      // Ordenar los archivos con comparación natural
      SortFiles(Files);
      // Asignar a las variables de la clase
      ImageFiles := Files;
      NumFiles:=Length(Files);
      ImageIndex := 0;
      YOffset := 0;
      ScrollBox1.DisableAlign;
      try
        for I := Low(Files) to High(Files) do
        begin
          I2 := I2 + 1;
          EntratMP := 0;
          EntratExtensio := 0;
          try
            // Obtener la extensión del archivo
            Extension := LowerCase(ExtractFileExt(Files[I]));
            if (Extension = '.png') or (Extension = '.jpg') then
            begin
              EntratExtensio := 1;
              Image := TImage.Create(ScrollBox1);
              Image.Parent := ScrollBox1;
              // Crear un objeto TPicture para manejar tanto PNG como JPG
              Picture := TPicture.Create;
              try
                if Extension = '.png' then
                begin
                  // Cargar archivo PNG
                  PNGImage := TPngImage.Create;
                  try
                    PNGImage.LoadFromFile(Files[I]);
                    Picture.Assign(PNGImage);
                  finally
                    PNGImage.Free;
                  end;
                end
                else
                begin
                  // Cargar archivo JPG
                  JPGImage := TJPEGImage.Create;
                  try
                    JPGImage.LoadFromFile(Files[I]);
                    Picture.Assign(JPGImage);
                  finally
                    JPGImage.Free;
                  end;
                end;

                Image.Picture.Assign(Picture);
                Image.Top := YOffset;
                if (I2 mod 3)  = 0 then
                begin
                  tamanyImatgeAnterior2 := tamanyImatgeAnterior2 + tamanyImatgeAnterior;
                  tamanyImatgeAnterior := 0;
                end;

                Image.Left := (I2 mod 3) * Image.Width * 6;
                Image.Top := Round(tamanyImatgeAnterior2/3);

                Image.Proportional := True; // Mantener la proporción de la imagen
                Image.Stretch := False;      // No estirar la imagen para mantener la calidad
                Image.Proportional := True; // Mantener la proporción de la imagen
                Image.Stretch := False;      // No estirar la imagen para mantener la calidad
                Image.Width := Round(ScrollBox1.ClientWidth / 3)-15;
                Image.Height := Round((Image.Picture.Height / Image.Picture.Width) * ScrollBox1.ClientWidth);
                YOffset := YOffset + Image.Height + 10; // Añadir un margen entre las imágenes
                Image.Tag := I; // Usar Tag para almacenar el índice de la imagen
                Image.OnClick := ImageClick;
                if Image.Height > tamanyImatgeAnterior then
                begin
                  tamanyImatgeAnterior := Image.Height;
                end;

              finally
                Picture.Free;
              end;
            
            end;
          except
            I2 := I2 - 1;
            if EntratExtensio = 1 then
              Image.Free; // Asegurarse de liberar el recurso en caso de excepción

          end;

          Application.ProcessMessages;
        end;
      finally
        ScrollBox1.EnableAlign;
      end;
    end;
    ScrollBox1.ClientHeight := YOffset;
  finally
    FileOpenDialog.Free;
  end;
end;

procedure TForm2.Button6Click(Sender: TObject);
begin
  PageSize:=StrToInt(Edit1.Text);
  Offset:=0;
  CarregarComicsDB;
end;

procedure TForm2.CarregarComicsDB;
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
  Local := False;
  Nuvol := True;

  // Borrar imágenes anteriores
  for I := ScrollBox1.ControlCount - 1 downto 0 do
  begin
    Control := ScrollBox1.Controls[I];
    if Control is TImage then
    begin
      TImage(Control).Picture.Graphic := nil;
      TImage(Control).Picture := nil;
      Control.Free;
    end;
  end;
  DBLinies.SQL.Clear;
  DBComicsPortada.SQL.Clear;
  if PageSize <= 0 then begin
    DBComicsPortada.SQL.Add('SELECT * FROM comic_portada ORDER BY id ASC ');
  end else begin
    DBComicsPortada.SQL.Add('SELECT * FROM comic_portada');
    DBComicsPortada.SQL.Add(Format('ORDER BY id DESC LIMIT %d OFFSET %d', [PageSize, Offset]));
  end;
  DBComicsPortada.Open;
  DBComicsPortada.First;

  SetLength(Imagenes, 0);
  SetLength(MaxHeightPorFila, 100);
  SetLength(PosYPorFila, 100);

  I := -1;

  // ?? Primera pasada: crear imágenes y calcular alturas
  while not DBComicsPortada.Eof do
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
          DBComicsPortadacontingut.SaveToStream(contenidoStream);
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
        Img.Tag := DBComicsPortadaid.AsInteger;
        Img.OnClick := ComicImageClickDB;

        DBComicsPortada.Edit;
        DBComicsPortadaHeight.AsInteger := Img.Height;

        Application.ProcessMessages;
      finally
        Picture.Free;
        contenidoStream.Free;
      end;

    except
      // nada
    end;

    DBComicsPortada.Next;
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

procedure TForm2.ComicImageClickDB(Sender: TObject);
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
  DBComicsPortada.First;

  while DBComicsPortadaid.AsInteger <> Image.Tag do begin
  DBComicsPortada.Next;
  end;


  Application.CreateForm(TFRM_Imatge_Comic, FRM_Imatge_Comic);
  FRM_Imatge_Comic.codi_comic:=DBComicsPortadacodi_comic.AsString;
  FRM_Imatge_Comic.ShowModal;
  FRM_Imatge_Comic.Free;
end;


procedure TForm2.Eliminarnocargados1Click(Sender: TObject);
begin
  DBLinies.SQL.Clear;
  DBLinies.SQL.Add('delete from imatges');
  DBLinies.SQL.Add('where height is NULL');
  DBLinies.ExecSQL;
end;

procedure TForm2.ShowImageForm(const ImagePath: string);
begin

  Application.CreateForm(TFRM_image, FRM_image);
  FRM_image.LoadImage(ImagePath);
  FRM_image.Show;

end;

procedure TForm2.ImageClick(Sender: TObject);
var
  Image: TImage;
begin
  Image := Sender as TImage;
  ImageIndex := Image.Tag; // Establecer ImageIndex basado en el Tag de la imagen
  ShowImageForm(ImageFiles[ImageIndex]);
end;

procedure TForm2.ShowImageFormDB(const ImageFileName: string);
var
  Picture: TPicture;
  MemoryStream: TMemoryStream;
  PNGImage: TPngImage;
  JPGImage: TJPEGImage;
begin
  Application.CreateForm(TFRM_image, FRM_image);
  Picture := TPicture.Create;
  MemoryStream := TMemoryStream.Create;
  try
    MemoryStream.LoadFromFile(ImageFileName);
    MemoryStream.Position := 0;
    // Intentar cargar como PNG
    try
      PNGImage := TPngImage.Create;
      try
        PNGImage.LoadFromStream(MemoryStream);
        Picture.Assign(PNGImage);
      except
        // Si falla, intentar cargar como JPG
        JPGImage := TJPEGImage.Create;
        try
          MemoryStream.Position := 0; // Resetear posición para intentar con JPG
          JPGImage.LoadFromStream(MemoryStream);
          Picture.Assign(JPGImage);
        finally
          JPGImage.Free;
        end;
      end;
    finally
      PNGImage.Free;
    end;
    FRM_image.Image1.Picture.Assign(Picture);
    FRM_image.Image1.Proportional := True; // Mantener la proporción de la imagen
    FRM_image.Image1.Stretch := False;      // No estirar la imagen para mantener la calidad
  finally
    Picture.Free;
    MemoryStream.Free;
  end;
  FRM_image.ShowModal;
  FRM_image.Free;
end;

procedure TForm2.ImageClickDB(Sender: TObject);
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
  DBLinies.First;

  while DBLiniesid.AsInteger <> Image.Tag do begin
  DBLinies.Next;
  end;


  Application.CreateForm(TFRM_image, FRM_image);
  FRM_Image.Query := DBLinies;
  contenidoStream := TMemoryStream.Create;
  PNGImage := TPngImage.Create;
  JPEGImage:=TJPEGImage.Create;
  Picture := TPicture.Create;
  DBLiniescontingut.SaveToStream(contenidoStream);
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

procedure TForm2.RefreshF51Click(Sender: TObject);
begin
CarregarImatgesDB;
end;

procedure TForm2.FormCreate(Sender: TObject);
var
SQLConnection: TSQLConnection;
begin
  ID:=0;
  ScrollBox1.OnMouseWheel := ScrollBox1MouseWheel;
  SQLConnection := TSQLConnection.Create(nil);
  SQLConnection.DriverName := 'MySQL';
  SQLConnection.Params.Values['Database'] := 'guardarimatges';
  SQLConnection.Params.Values['User_Name'] := 'avnadmin';
  SQLConnection.Params.Values['Password'] := 'AVNS_ZZhsXBUxSadki9ujweq';
  SQLConnection.Params.Values['Port'] := '25063'; // Puerto típico de MySQL, ajusta si es necesario
  SQLConnection.LibraryName := 'dbxmys.dll';
  SQLConnection.VendorLib := 'libmysql.dll';
  SQLConnection.GetDriverFunc := 'getSQLDriverMYSQL';
  SQLConnection.LoginPrompt := False;
;
end;
procedure TForm2.FormShow(Sender: TObject);
begin
  Image1.Proportional := True;
end;
procedure TForm2.ScrollBox1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if WheelDelta > 0 then
    ScrollBox1.VertScrollBar.Position := ScrollBox1.VertScrollBar.Position - ScrollBox1.VertScrollBar.Increment
  else
    ScrollBox1.VertScrollBar.Position := ScrollBox1.VertScrollBar.Position + ScrollBox1.VertScrollBar.Increment;
  Handled := True;
end;
end.
