object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 545
  ClientWidth = 1096
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PopupMenu = PopupMenu1
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 1096
    Height = 504
    Align = alClient
    Visible = False
    ExplicitLeft = 272
    ExplicitTop = 24
    ExplicitWidth = 233
    ExplicitHeight = 241
  end
  object Panel1: TPanel
    Left = 0
    Top = 504
    Width = 1096
    Height = 41
    Align = alBottom
    TabOrder = 0
    object Button5: TButton
      Left = 5
      Top = 4
      Width = 99
      Height = 33
      Caption = 'Abrir Carpeta'
      TabOrder = 0
      OnClick = Button5Click
    end
    object Button1: TButton
      Left = 110
      Top = 4
      Width = 115
      Height = 33
      Caption = 'Ver imagenes nube'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Edit1: TEdit
      Left = 457
      Top = 9
      Width = 105
      Height = 23
      NumbersOnly = True
      TabOrder = 2
      Text = '45'
    end
    object Button2: TButton
      Left = 231
      Top = 4
      Width = 115
      Height = 33
      Caption = 'Subir imagen Nube'
      TabOrder = 3
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 416
      Top = 4
      Width = 34
      Height = 33
      Caption = '<--'
      TabOrder = 4
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 570
      Top = 4
      Width = 34
      Height = 33
      Caption = '-->'
      TabOrder = 5
      OnClick = Button4Click
    end
    object cbFav: TCheckBox
      Left = 615
      Top = 12
      Width = 57
      Height = 17
      Caption = 'Fav'
      TabOrder = 6
    end
    object Button6: TButton
      Left = 692
      Top = 4
      Width = 91
      Height = 33
      Caption = 'Cargar Comics'
      TabOrder = 7
      OnClick = Button6Click
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 1096
    Height = 504
    VertScrollBar.Smooth = True
    VertScrollBar.Tracking = True
    Align = alClient
    TabOrder = 1
    OnMouseWheel = ScrollBox1MouseWheel
  end
  object DataSource1: TDataSource
    DataSet = DBLinies
    Left = 304
    Top = 336
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'User_Name=root'
      'Password=123456'
      'Database=prova'
      'Server=127.0.0.1'
      'Port=3307'
      'DriverID=MySQL')
    Connected = True
    LoginPrompt = False
    Left = 368
    Top = 336
  end
  object DBLinies: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from imatges')
    Left = 424
    Top = 336
    object DBLiniesid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object DBLiniesnom: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'nom'
      Origin = 'nom'
      Size = 50
    end
    object DBLiniescontingut: TBlobField
      AutoGenerateValue = arDefault
      FieldName = 'contingut'
      Origin = 'contingut'
    end
    object DBLiniesurl: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'url'
      Origin = 'url'
      Size = 1000
    end
    object DBLiniesheight: TIntegerField
      AutoGenerateValue = arDefault
      FieldName = 'height'
      Origin = 'height'
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 376
    Top = 64
    object Eliminarnocargados1: TMenuItem
      Caption = 'Delete Unloaded'
      OnClick = Eliminarnocargados1Click
    end
    object RefreshF51: TMenuItem
      Caption = 'Refresh F5'
      ShortCut = 116
      OnClick = RefreshF51Click
    end
  end
  object DBLinies2: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from imatges')
    Left = 424
    Top = 280
    object FDAutoIncField1: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object StringField1: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'nom'
      Origin = 'nom'
      Size = 50
    end
    object DBLinies2contingut: TBlobField
      AutoGenerateValue = arDefault
      FieldName = 'contingut'
      Origin = 'contingut'
    end
    object StringField2: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'url'
      Origin = 'url'
      Size = 1000
    end
    object IntegerField1: TIntegerField
      AutoGenerateValue = arDefault
      FieldName = 'carregat'
      Origin = 'carregat'
    end
    object IntegerField2: TIntegerField
      AutoGenerateValue = arDefault
      FieldName = 'height'
      Origin = 'height'
    end
  end
  object DBComicsPortada: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from comic_portada')
    Left = 624
    Top = 344
    object DBComicsPortadaid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object DBComicsPortadanom: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'nom'
      Origin = 'nom'
      Size = 50
    end
    object DBComicsPortadacontingut: TBlobField
      AutoGenerateValue = arDefault
      FieldName = 'contingut'
      Origin = 'contingut'
    end
    object DBComicsPortadacodi_comic: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'codi_comic'
      Origin = 'codi_comic'
      Size = 500
    end
    object DBComicsPortadaheight: TIntegerField
      AutoGenerateValue = arDefault
      FieldName = 'height'
      Origin = 'height'
    end
  end
end
