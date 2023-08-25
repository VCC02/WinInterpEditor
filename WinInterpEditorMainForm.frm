object frmWinInterpEditorMain: TfrmWinInterpEditorMain
  Left = 358
  Height = 576
  Top = 71
  Width = 1470
  Caption = 'WinInterp Editor'
  ClientHeight = 576
  ClientWidth = 1470
  Constraints.MinHeight = 576
  Constraints.MinWidth = 948
  OnCreate = FormCreate
  OnResize = FormResize
  LCLVersion = '7.5'
  object pnlDrawingBoard: TPanel
    Left = 888
    Height = 544
    Top = 0
    Width = 576
    Alignment = taLeftJustify
    Anchors = [akTop, akLeft, akRight, akBottom]
    Caption = 'Drawing Board'
    Color = 14546431
    Constraints.MinHeight = 353
    Constraints.MinWidth = 520
    ParentColor = False
    TabOrder = 0
  end
  object pnlWinInterp: TPanel
    Left = 0
    Height = 544
    Top = 0
    Width = 872
    Anchors = [akTop, akLeft, akBottom]
    Caption = 'pnlWinInterp'
    Constraints.MinWidth = 872
    ParentColor = False
    TabOrder = 1
  end
  object pnlHorizSplitter: TPanel
    Cursor = crHSplit
    Left = 872
    Height = 544
    Top = 0
    Width = 11
    Anchors = [akTop, akLeft, akBottom]
    Color = 15400902
    ParentColor = False
    TabOrder = 2
    OnMouseDown = pnlHorizSplitterMouseDown
    OnMouseMove = pnlHorizSplitterMouseMove
    OnMouseUp = pnlHorizSplitterMouseUp
  end
  object tmrStartup: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrStartupTimer
    Left = 278
    Top = 137
  end
end
