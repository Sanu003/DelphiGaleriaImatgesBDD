object FRM_alta_Imatge: TFRM_alta_Imatge
  Left = 0
  Top = 0
  ClientHeight = 441
  ClientWidth = 817
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PopupMenu = PopupMenu1
  Position = poScreenCenter
  WindowState = wsMaximized
  TextHeight = 15
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 817
    Height = 400
    Align = alClient
    Center = True
    Proportional = True
    Stretch = True
    ExplicitLeft = -4
    ExplicitWidth = 628
    ExplicitHeight = 401
  end
  object Panel1: TPanel
    Left = 0
    Top = 400
    Width = 817
    Height = 41
    Align = alBottom
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 6
      Width = 129
      Height = 28
      Caption = 'Seleccionar imagen'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Edit1: TEdit
      Left = 223
      Top = 8
      Width = 386
      Height = 23
      TabOrder = 1
      TextHint = 'URL...'
    end
    object Button2: TButton
      Left = 152
      Top = 6
      Width = 65
      Height = 28
      Caption = 'URL'
      TabOrder = 2
      OnClick = Button2Click
    end
    object cbFav: TCheckBox
      Left = 624
      Top = 9
      Width = 57
      Height = 17
      Caption = 'Fav'
      TabOrder = 3
    end
  end
  object DataSource1: TDataSource
    DataSet = DBLinies
    Left = 168
    Top = 152
  end
  object DBLinies: TFDQuery
    Connection = Form2.FDConnection1
    SQL.Strings = (
      '           select * from imatges')
    Left = 376
    Top = 192
  end
  object OpenDialog1: TOpenDialog
    Left = 328
    Top = 80
  end
  object IdHTTP1: TIdHTTP
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 80
    Top = 56
  end
  object PopupMenu1: TPopupMenu
    Left = 424
    Top = 40
    object Guardar1: TMenuItem
      Caption = 'Load From TXT'
      OnClick = Guardar1Click
    end
  end
end
