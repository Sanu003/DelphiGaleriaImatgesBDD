object FRM_Imatge_Comic: TFRM_Imatge_Comic
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 480
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PopupMenu = PopupMenu1
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 640
    Height = 480
    VertScrollBar.Smooth = True
    VertScrollBar.Tracking = True
    Align = alClient
    TabOrder = 0
    OnMouseWheel = ScrollBox1MouseWheel
  end
  object DBComicsImatges: TFDQuery
    Connection = Form2.FDConnection1
    SQL.Strings = (
      'select * from comic_imatges')
    Left = 388
    Top = 240
    object DBComicsImatgesid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object DBComicsImatgesnom: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'nom'
      Origin = 'nom'
      Size = 50
    end
    object DBComicsImatgescontingut: TBlobField
      AutoGenerateValue = arDefault
      FieldName = 'contingut'
      Origin = 'contingut'
    end
    object DBComicsImatgescodi_comic: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'codi_comic'
      Origin = 'codi_comic'
      Size = 500
    end
    object DBComicsImatgesheight: TIntegerField
      AutoGenerateValue = arDefault
      FieldName = 'height'
      Origin = 'height'
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 424
    Top = 40
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
  end
end
