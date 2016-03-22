object BatchAddForm: TBatchAddForm
  Left = 0
  Top = 0
  Caption = 'Batch add'
  ClientHeight = 300
  ClientWidth = 635
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    635
    300)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 302
    Height = 13
    Caption = 
      'One link per line (You can drag and drop links to the list below' +
      '):'
  end
  object LinksList: TMemo
    Left = 8
    Top = 27
    Width = 619
    Height = 234
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 471
    Top = 267
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = CancelBtnClick
  end
  object OkBtn: TButton
    Left = 552
    Top = 267
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 2
    OnClick = OkBtnClick
  end
  object DropURLTarget1: TDropURLTarget
    DragTypes = [dtCopy, dtLink]
    GetDataOnEnter = True
    OnDrop = DropURLTarget1Drop
    Target = LinksList
    WinTarget = 0
    Left = 408
    Top = 104
  end
end
