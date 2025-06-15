object FRM_buscar_comic: TFRM_buscar_comic
  Left = 0
  Top = 0
  Caption = 'Comic Search'
  ClientHeight = 505
  ClientWidth = 727
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnKeyDown = FormKeyDown
  TextHeight = 15
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 727
    Height = 464
    VertScrollBar.Smooth = True
    VertScrollBar.Tracking = True
    Align = alClient
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 464
    Width = 727
    Height = 41
    Align = alBottom
    TabOrder = 1
    object Edit1: TEdit
      Left = 49
      Top = 8
      Width = 105
      Height = 23
      NumbersOnly = True
      TabOrder = 0
      Text = '30'
    end
    object Button3: TButton
      Left = 8
      Top = 3
      Width = 34
      Height = 33
      Caption = '<--'
      TabOrder = 1
    end
    object Button4: TButton
      Left = 162
      Top = 3
      Width = 34
      Height = 33
      Caption = '-->'
      TabOrder = 2
    end
  end
  object DBComicsPortada: TFDQuery
    Connection = Form2.FDConnection1
    SQL.Strings = (
      'select * from comic_portada')
    Left = 432
    Top = 272
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
