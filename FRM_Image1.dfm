object FRM_Image: TFRM_Image
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
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 640
    Height = 480
    Align = alClient
    Center = True
    Proportional = True
    Stretch = True
    OnMouseDown = Image1MouseDown
    ExplicitLeft = 472
    ExplicitTop = 48
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object PopupMenu1: TPopupMenu
    Left = 368
    Top = 144
    object AddtoFav1: TMenuItem
      Caption = 'Add to Fav/No Fav'
      OnClick = AddtoFav1Click
    end
    object Guardar1: TMenuItem
      Caption = 'Save File'
      OnClick = Guardar1Click
    end
    object Delete1: TMenuItem
      Caption = 'Delete File'
      OnClick = Delete1Click
    end
    object Comic1: TMenuItem
      Caption = 'Comic'
      object CreateNewComic1: TMenuItem
        Caption = 'Create New Comic'
        OnClick = CreateNewComic1Click
      end
      object AddtoComic1: TMenuItem
        Caption = 'Add to Comic'
        OnClick = AddtoComic1Click
      end
    end
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
  end
  object DataSource1: TDataSource
    DataSet = DBGeneric
    Left = 304
    Top = 336
  end
  object DBGeneric: TFDQuery
    Connection = Form2.FDConnection1
    SQL.Strings = (
      'select * from imatges')
    Left = 424
    Top = 336
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'png'
    Left = 480
    Top = 144
  end
end
