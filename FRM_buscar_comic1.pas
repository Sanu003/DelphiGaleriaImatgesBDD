unit FRM_buscar_comic1;

interface

uses
  Winapi.Windows, Winapi.Messages, SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.FMTBcd, Data.DB, Data.SqlExpr,
  Data.DBXMySQL, Data.DbxSqlite,Vcl.StdCtrls,JPEG,
  Vcl.ExtCtrls, FileCtrl,System.Types, System.ImageList, Vcl.ImgList,
  System.IOUtils, System.Generics.Collections,System.RegularExpressions,Vcl.Imaging.pngimage,
  Vcl.MPlayer,FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, Vcl.Menus;

type
  TFRM_buscar_comic = class(TForm)
    ScrollBox1: TScrollBox;
    Panel1: TPanel;
    Edit1: TEdit;
    Button3: TButton;
    Button4: TButton;
    DBComicsPortada: TFDQuery;
    DBComicsPortadaid: TFDAutoIncField;
    DBComicsPortadanom: TStringField;
    DBComicsPortadacontingut: TBlobField;
    DBComicsPortadacodi_comic: TStringField;
    DBComicsPortadaheight: TIntegerField;
    procedure FormActivate(Sender: TObject);
    procedure CarregarComicsDB;
    procedure ImageClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    PageSize,Offset:Integer;
    id_comic:Integer;
  end;

var
  FRM_buscar_comic: TFRM_buscar_comic;

implementation
  uses Unit2;

{$R *.dfm}

procedure TFRM_buscar_comic.FormActivate(Sender: TObject);
begin
  PageSize:=StrToInt(Edit1.Text);
  Offset:=0;
  CarregarComicsDB;
end;

procedure TFRM_buscar_comic.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 27 then begin
    ModalResult:=MrCancel;
  end;
end;

procedure TFRM_buscar_comic.CarregarComicsDB;
var
  I, I2, tamanyImatgeAnterior, tamanyImatgeAnterior2: Integer;
  Image: TImage;
  YOffset: Integer;
  Control: TControl;
  Picture: TPicture;
  PNGImage: TPngImage;
  JPGImage: TJPEGImage;
  contenidoStream: TMemoryStream;
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
  I2 := -1;
  I:=-1;
  tamanyImatgeAnterior2 := 0;
  tamanyImatgeAnterior := 0;

  // Realizar la consulta a la base de datos para obtener las imágenes
  DBComicsPortada.SQL.Clear;
  if PageSize <= 0 then begin
    DBComicsPortada.SQL.Add('SELECT * FROM comic_portada ORDER BY id ASC ');
  end else begin
    DBComicsPortada.SQL.Add('SELECT * FROM comic_portada');
    DBComicsPortada.SQL.Add(Format('ORDER BY id DESC LIMIT %d OFFSET %d', [PageSize, Offset]));
  end;
  DBComicsPortada.Open;
  DBComicsPortada.First;
  while not DBComicsPortada.Eof do begin

    I := I+1;
    I2 := I2 + 1;
    try
        Image := TImage.Create(ScrollBox1);
        Image.Parent := ScrollBox1;
        // Crear un objeto TPicture para manejar tanto PNG como JPG
        Picture := TPicture.Create;
        try

          // Cargar archivo PNG
          PNGImage := TPngImage.Create;
          try
            contenidoStream := TMemoryStream.Create;
            DBComicsPortadacontingut.SaveToStream(contenidoStream);
            contenidoStream.Position := 0;
            PNGImage.LoadFromStream(contenidoStream);
            Picture.Assign(PNGImage);
            PNGImage.Free;
            DBComicsPortada.Edit;
            DBComicsPortadaheight.AsInteger:=Picture.Height;
            DBComicsPortada.Post;
          except
            PNGImage.Free;
            try
              JPGImage := TJPEGImage.Create;
              DBComicsPortadacontingut.SaveToStream(contenidoStream);
              contenidoStream.Position := 0;
              JPGImage.LoadFromStream(contenidoStream);
              Picture.Assign(JPGImage);
              JPGImage.Free;
              DBComicsPortada.Edit;
              DBComicsPortadaheight.AsInteger:=Picture.Height;
              DBComicsPortada.Post;
            except
              DBComicsPortada.Edit;
              DBComicsPortadaheight.AsInteger:=0;
              DBComicsPortada.Post;
              JPGImage.Free;
            end;
          end;

          Image.Picture.Assign(Picture);
          Image.Top := YOffset;
          if (I mod 3)  = 0 then
          begin
            tamanyImatgeAnterior2 := tamanyImatgeAnterior2 + tamanyImatgeAnterior;
            tamanyImatgeAnterior := 0;
          end;

          Image.Left := (I2 mod 3) * Image.Width * 6;
          Image.Top := Round(tamanyImatgeAnterior2/3);
          Image.Proportional := True; // Mantener la proporción de la imagen
          Image.Stretch := False;      // No estirar la imagen para mantener la calidad
          Image.Width := Round(ScrollBox1.ClientWidth / 3)-15;
          Image.Height := Round((Image.Picture.Height / Image.Picture.Width) * ScrollBox1.ClientWidth);
          YOffset := YOffset + Image.Height + 10; // Añadir un margen entre las imágenes
          Image.Tag := DBComicsPortadaid.AsInteger; // Usar Tag para almacenar el índice de la imagen
          Image.OnClick := ImageClick;
          if Image.Height > tamanyImatgeAnterior then
          begin
            tamanyImatgeAnterior := Image.Height;
          end;
          DBComicsPortada.Edit;
          DBComicsPortadaheight.AsInteger:=Image.Height;
        finally
          Picture.Free;
        end;
    except
      I2 := I2 - 1;

    end;

    Application.ProcessMessages;
    DBComicsPortada.Next;
  end;
  Screen.Cursor := crDefault;

end;

procedure TFRM_buscar_comic.ImageClick(Sender: TObject);
var
Image : TImage;
begin
  Image := Sender as TImage;
  id_comic:= Image.Tag;
  ModalResult:=MrOk;
end;

end.
