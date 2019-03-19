object frmConfigServer: TfrmConfigServer
  Left = 672
  Top = 313
  BorderStyle = bsDialog
  Caption = #37197#32622#26381#21153#22120
  ClientHeight = 218
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  object lblHint: TLabel
    Left = 7
    Top = 192
    Width = 202
    Height = 13
    AutoSize = False
    Caption = #25552#31034':'#26684#24335#20026#8220#26381#21153#22120#22320#22336':'#31471#21475#8221
  end
  object mmoServer: TMemo
    Left = 6
    Top = 8
    Width = 365
    Height = 177
    TabOrder = 0
  end
  object btnSave: TButton
    Left = 216
    Top = 189
    Width = 75
    Height = 25
    Caption = #20445#23384
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object btnClose: TButton
    Left = 296
    Top = 189
    Width = 75
    Height = 25
    Caption = #20851#38381
    TabOrder = 2
    OnClick = btnCloseClick
  end
end
