{
    Copyright (C) 2023 VCC
    creation date: Aug 2023  (09 Aug 2023)
    initial release date: 25 Aug 2023

    author: VCC
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}


unit WinInterpEditorMainForm;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  DrawingBoardFrame, ClickerWinInterpFrame,
  DrawingBoardDataTypes;

type

  { TfrmWinInterpEditorMain }

  TfrmWinInterpEditorMain = class(TForm)
    pnlDrawingBoard: TPanel;
    pnlHorizSplitter: TPanel;
    pnlWinInterp: TPanel;
    tmrStartup: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure pnlHorizSplitterMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlHorizSplitterMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pnlHorizSplitterMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmrStartupTimer(Sender: TObject);
  private
    FWinInterpFrame: TfrClickerWinInterp;
    FfrDrawingBoard: TfrDrawingBoard;

    FHold: Boolean;
    FSplitterMouseDownGlobalPos: TPoint;
    FSplitterMouseDownImagePos: TPoint;

    procedure CreateRemainingComponents;
    procedure ResizeFrameSectionsBySplitter(NewLeft: Integer);

    procedure HandleOnDrawComponentOnPanel(APanel: TMountPanel; var AAllComponents: TDynTFTDesignAllComponentsArr; var AAllVisualComponents: TProjectVisualComponentArr);
    procedure HandleOnAddItemToSelCompListInOI(ACompName: string);
    procedure HandleOnCancelObjectInspectorEditing;
    procedure HandleOnClearObjectInspector;
    procedure HandleOnDrawingBoardModified;
    procedure HandleOnRefreshObjectInspector;
    procedure HandleOnGetDefaultScreenColor(var AColor: TColor; var AColorName: string);
    function HandleOnLookupColorConstantInBaseSchema(ConstName: string; DefaultValue: TColor): TColor;
    procedure HandleOnBeforeSelectAllPanels(AMsg, AHint: string);
    procedure HandleOnAfterSelectAllPanels(AMsg, AHint: string);
    procedure HandleOnDeleteComponentByPanel(APanel: TMountPanel);
    procedure HandleOnGetComponentIndexFromPlugin(ACompTypeIndex: Integer; var ACategoryIndex, AComponentIndex: Integer);
    procedure HandleOnUpdateSpecialProperty(APropertyIndex: Integer; var ADesignComponentInAll: TDynTFTDesignComponentOneKind; APropertyName, APropertyNewValue: string);
    procedure HandleOnAddNewHandlerToAllHandlersByHandlerType(ATypeName, AHandlerName: string);
    function HandleOnEditScreen(var AScreen: TScreenInfo): Boolean;
    procedure HandleOnDrawingBoardMouseMove(X, Y: Integer);
    function HandleOnDrawingBoardCanFocus: Boolean;
    procedure HandleOnDisplayScreenSize(AWidth, AHeight: Integer);
    procedure HandleOnDrawingBoardRemoveFocus;
    procedure HandleOnSetCustomPropertyValueOnLoading(APropertyName: string; ACompType: Integer; var APropertyValue: string);
    function HandleOnResolveColorConst(AColorName: string): TColor;
    procedure HandleOnAfterMovingMountPanel(APanel: TMountPanel);

    procedure HandleOnInsertTreeComponent(ACompData: PHighlightedCompRec);
    procedure HandleOnClearWinInterp;
  public

  end;

var
  frmWinInterpEditorMain: TfrmWinInterpEditorMain;

{ ToDo
- Implement full schema loading for DrawingBoard. Define a few generic components, like Button, ComboBox, CheckBox, Panel etc.
- Integrate DrawingBoard schema editor into this application, so that users can define their own components (requires a new WinInterp-specific schema).
  The metaschema editor does not have to be here. It is fine to have it as a standalone app.
- bug - The DeletePanel procedure, from DrawingBoardUtils, has some disabled code for FPC. There is an AV when deleting panels.
  The AV still happens, but to a lower rate.
- bug - The selection rectagles should be orange. For some reason, their color is reset.
- bug - The aligning guide lines on DrawingBoard do not take into account that panels can be children of other panels
- there should be a vertical splitter on WinInterp frame
- there should be a vertical splitter between WinInterp frame and DrawingBoard frame
[in work] - when moving or resizing panels on DrawingBoard, they should be moved/resized the same on WinInterp  - see HandleOnAfterMovingMountPanel
- Implement remaining handlers
- bug - The Z order of created panels is set by the order they are found. This order does not always match the panel visibility.
}



implementation

{$R *.frm}

{ TfrmWinInterpEditorMain }

procedure TfrmWinInterpEditorMain.CreateRemainingComponents;
begin
  FfrDrawingBoard := TfrDrawingBoard.Create(Self);
  FfrDrawingBoard.Parent := pnlDrawingBoard;
  FfrDrawingBoard.Left := 0;
  FfrDrawingBoard.Top := 0;
  FfrDrawingBoard.Width := pnlDrawingBoard.Width;
  FfrDrawingBoard.Height := pnlDrawingBoard.Height;
  FfrDrawingBoard.Anchors := [akLeft, akTop, akRight, akBottom];
  FfrDrawingBoard.OnDrawComponentOnPanel := {$IFDEF FPC}@{$ENDIF}HandleOnDrawComponentOnPanel;
  FfrDrawingBoard.OnAddItemToSelCompListInOI := {$IFDEF FPC}@{$ENDIF}HandleOnAddItemToSelCompListInOI;
  FfrDrawingBoard.OnCancelObjectInspectorEditing := {$IFDEF FPC}@{$ENDIF}HandleOnCancelObjectInspectorEditing;
  FfrDrawingBoard.OnClearObjectInspector := {$IFDEF FPC}@{$ENDIF}HandleOnClearObjectInspector;
  FfrDrawingBoard.OnDrawingBoardModified := {$IFDEF FPC}@{$ENDIF}HandleOnDrawingBoardModified;
  FfrDrawingBoard.OnRefreshObjectInspector := {$IFDEF FPC}@{$ENDIF}HandleOnRefreshObjectInspector;
  FfrDrawingBoard.OnGetDefaultScreenColor := {$IFDEF FPC}@{$ENDIF}HandleOnGetDefaultScreenColor;
  FfrDrawingBoard.OnLookupColorConstantInBaseSchema := {$IFDEF FPC}@{$ENDIF}HandleOnLookupColorConstantInBaseSchema;
  FfrDrawingBoard.OnBeforeSelectAllPanels := {$IFDEF FPC}@{$ENDIF}HandleOnBeforeSelectAllPanels;
  FfrDrawingBoard.OnAfterSelectAllPanels := {$IFDEF FPC}@{$ENDIF}HandleOnAfterSelectAllPanels;
  FfrDrawingBoard.OnDeleteComponentByPanel := {$IFDEF FPC}@{$ENDIF}HandleOnDeleteComponentByPanel;
  FfrDrawingBoard.OnGetComponentIndexFromPlugin := {$IFDEF FPC}@{$ENDIF}HandleOnGetComponentIndexFromPlugin;
  FfrDrawingBoard.OnUpdateSpecialProperty := {$IFDEF FPC}@{$ENDIF}HandleOnUpdateSpecialProperty;
  FfrDrawingBoard.OnAddNewHandlerToAllHandlersByHandlerType := {$IFDEF FPC}@{$ENDIF}HandleOnAddNewHandlerToAllHandlersByHandlerType;
  FfrDrawingBoard.OnEditScreen := {$IFDEF FPC}@{$ENDIF}HandleOnEditScreen;
  FfrDrawingBoard.OnDrawingBoardMouseMove := {$IFDEF FPC}@{$ENDIF}HandleOnDrawingBoardMouseMove;
  FfrDrawingBoard.OnDrawingBoardCanFocus := {$IFDEF FPC}@{$ENDIF}HandleOnDrawingBoardCanFocus;
  FfrDrawingBoard.OnDisplayScreenSize := {$IFDEF FPC}@{$ENDIF}HandleOnDisplayScreenSize;
  FfrDrawingBoard.OnDrawingBoardRemoveFocus := {$IFDEF FPC}@{$ENDIF}HandleOnDrawingBoardRemoveFocus;
  FfrDrawingBoard.OnSetCustomPropertyValueOnLoading := {$IFDEF FPC}@{$ENDIF}HandleOnSetCustomPropertyValueOnLoading;
  FfrDrawingBoard.OnResolveColorConst := {$IFDEF FPC}@{$ENDIF}HandleOnResolveColorConst;
  FfrDrawingBoard.OnAfterMovingMountPanel := {$IFDEF FPC}@{$ENDIF}HandleOnAfterMovingMountPanel;

  FfrDrawingBoard.MinPxToUnlockDrag := 5;
  FfrDrawingBoard.ShouldFocusDrawingBoardOnMouseEnter := True;

  FWinInterpFrame := TfrClickerWinInterp.Create(Self);
  FWinInterpFrame.Left := 0;
  FWinInterpFrame.Top := 0;
  FWinInterpFrame.Width := pnlWinInterp.Width;
  FWinInterpFrame.Height := pnlWinInterp.Height;
  FWinInterpFrame.Parent := pnlWinInterp;
  FWinInterpFrame.Visible := True;
  FWinInterpFrame.Anchors := [akLeft, akTop, akRight, akBottom];
  //FWinInterpFrame.Visible := True;
  FWinInterpFrame.OnInsertTreeComponent := {$IFDEF FPC}@{$ENDIF}HandleOnInsertTreeComponent;
  FWinInterpFrame.OnClearWinInterp := {$IFDEF FPC}@{$ENDIF}HandleOnClearWinInterp;
end;


procedure TfrmWinInterpEditorMain.FormCreate(Sender: TObject);
begin
  CreateRemainingComponents;

  pnlWinInterp.Caption := ''; //the caption is useful at design-time only
  pnlDrawingBoard.Caption := ''; //the caption is useful at design-time only
  FHold := False;

  tmrStartup.Enabled := True;
end;


procedure TfrmWinInterpEditorMain.pnlHorizSplitterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Shift <> [ssLeft] then
    Exit;

  if not FHold then
  begin
    GetCursorPos(FSplitterMouseDownGlobalPos);

    FSplitterMouseDownImagePos.X := pnlHorizSplitter.Left;
    FHold := True;
  end;
end;


procedure TfrmWinInterpEditorMain.pnlHorizSplitterMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  tp: TPoint;
  NewLeft: Integer;
begin
  if Shift <> [ssLeft] then
    Exit;

  if not FHold then
    Exit;

  GetCursorPos(tp);
  NewLeft := FSplitterMouseDownImagePos.X + tp.X - FSplitterMouseDownGlobalPos.X;

  ResizeFrameSectionsBySplitter(NewLeft);
end;


procedure TfrmWinInterpEditorMain.pnlHorizSplitterMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHold := False;
end;


procedure TfrmWinInterpEditorMain.FormResize(Sender: TObject);
var
  NewLeft: Integer;
begin
  NewLeft := pnlHorizSplitter.Left;

  if NewLeft > Width - 260 then
    NewLeft := Width - 260;

  ResizeFrameSectionsBySplitter(NewLeft);
end;


procedure TfrmWinInterpEditorMain.ResizeFrameSectionsBySplitter(NewLeft: Integer);
begin
  if NewLeft < pnlWinInterp.Constraints.MinWidth then
    NewLeft := pnlWinInterp.Constraints.MinWidth;

  if NewLeft > Width - 260 then
    NewLeft := Width - 260;

  if NewLeft < 893 then
    NewLeft := 893;

  pnlHorizSplitter.Left := NewLeft;

  pnlDrawingBoard.Left := pnlHorizSplitter.Left + pnlHorizSplitter.Width;
  pnlDrawingBoard.Width := Width - pnlDrawingBoard.Left;
  pnlWinInterp.Width := pnlHorizSplitter.Left;
end;


procedure TfrmWinInterpEditorMain.tmrStartupTimer(Sender: TObject);
begin
  tmrStartup.Enabled := False;

  FfrDrawingBoard.AllComponentsLength := 1;
  FfrDrawingBoard.AllComponents^[0].Schema.ComponentTypeName := 'GenericButton';
  SetLength(FfrDrawingBoard.AllComponents^[0].Schema.Properties, 5);
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[0].PropertyName := 'Locked';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[1].PropertyName := 'Left';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[2].PropertyName := 'Top';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[3].PropertyName := 'Width';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[4].PropertyName := 'Height';

  FfrDrawingBoard.AllComponents^[0].Schema.Properties[0].PropertyDataType := 'Boolean';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[1].PropertyDataType := 'Integer';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[2].PropertyDataType := 'Integer';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[3].PropertyDataType := 'Integer';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[4].PropertyDataType := 'Integer';

  SetLength(FfrDrawingBoard.AllComponents^[0].DesignComponentsOneKind, Length(FfrDrawingBoard.AllComponents^[0].DesignComponentsOneKind) + 1);
  FfrDrawingBoard.AllComponents^[0].DesignComponentsOneKind[0].ObjectName := 'First';
end;


procedure TfrmWinInterpEditorMain.HandleOnDrawComponentOnPanel(APanel: TMountPanel; var AAllComponents: TDynTFTDesignAllComponentsArr; var AAllVisualComponents: TProjectVisualComponentArr);
var
  TempCompData: PHighlightedCompRec;
begin
  //DrawPDynTFTComponentOnPanel(APanel, AAllComponents, AAllVisualComponents, FColorConsts, FProjectSettings.AllFontSettings);

  //Dummy drawing:
  TempCompData := PHighlightedCompRec(APanel.UserData);
  APanel.Image.Canvas.Pen.Color := clYellow;
  APanel.Image.Canvas.Brush.Color := TempCompData^.AssignedColor ;//clGreen + Length(AAllComponents) shl 4;
  APanel.Image.Canvas.Rectangle(0, 0, APanel.Width, APanel.Height);

  APanel.Image.Canvas.Font.Color := clWhite;
  APanel.Image.Canvas.TextOut(1, 1, IntToStr(TempCompData^.CompRec.Handle));
end;


procedure TfrmWinInterpEditorMain.HandleOnAddItemToSelCompListInOI(ACompName: string);
begin
  //cmbObjectInspector.Items.Add(ACompName);
  //cmbObjectInspector.ItemIndex := cmbObjectInspector.Items.Count - 1;
end;


procedure TfrmWinInterpEditorMain.HandleOnCancelObjectInspectorEditing;
begin
  //if FEditingTextProperty then
    //vstObjectInspectorProperties.EndEditNode;
end;


procedure TfrmWinInterpEditorMain.HandleOnClearObjectInspector;
begin
  //ClearObjectInspector;
end;


procedure TfrmWinInterpEditorMain.HandleOnDrawingBoardModified;
begin
  //Modified := True;
end;


procedure TfrmWinInterpEditorMain.HandleOnRefreshObjectInspector;
begin
  //vstObjectInspectorProperties.Repaint;
end;


procedure TfrmWinInterpEditorMain.HandleOnGetDefaultScreenColor(var AColor: TColor; var AColorName: string);
begin
  AColorName := 'CL_DynTFTScreen_Background';
  //AColor := ResolveColorConst(AColorName, FColorConsts, clWhite);
end;


function TfrmWinInterpEditorMain.HandleOnLookupColorConstantInBaseSchema(ConstName: string; DefaultValue: TColor): TColor;
begin
  Result := clWhite;
  //Result := LookupColorConstantInBaseSchema(ConstName, DefaultValue);
end;


procedure TfrmWinInterpEditorMain.HandleOnBeforeSelectAllPanels(AMsg, AHint: string);
begin
  //StatusBar1.Panels.Items[1].Text := AMsg;
  //StatusBar1.Hint := AHint;
  //StatusBar1.Font.Style := StatusBar1.Font.Style + [fsBold];
  //StatusBar1.Repaint;
end;


procedure TfrmWinInterpEditorMain.HandleOnAfterSelectAllPanels(AMsg, AHint: string);
begin
  //StatusBar1.Panels.Items[1].Text := AMsg;
  //StatusBar1.Hint := AHint;
  //StatusBar1.Font.Style := StatusBar1.Font.Style - [fsBold];
  //StatusBar1.Repaint;
end;


procedure TfrmWinInterpEditorMain.HandleOnDeleteComponentByPanel(APanel: TMountPanel);
begin
  //cmbObjectInspector.Items.Delete(APanel.IndexInTProjectVisualComponentArr);
end;


procedure TfrmWinInterpEditorMain.HandleOnGetComponentIndexFromPlugin(ACompTypeIndex: Integer; var ACategoryIndex, AComponentIndex: Integer);
begin
  //ACategoryIndex := FCompPluginIndexArr[ACompTypeIndex].CategoryIndex;
  //AComponentIndex := FCompPluginIndexArr[ACompTypeIndex].IndexInCategory;
end;


procedure TfrmWinInterpEditorMain.HandleOnUpdateSpecialProperty(APropertyIndex: Integer; var ADesignComponentInAll: TDynTFTDesignComponentOneKind; APropertyName, APropertyNewValue: string);
begin
  if APropertyName = 'CreatedAtStartup' then
    ADesignComponentInAll.CreatedAtStartup := (UpperCase(APropertyNewValue) = 'TRUE') or (StrToIntDef(APropertyNewValue, -1) = 1);

  if APropertyName = 'HasVariableInGUIObjects' then
    ADesignComponentInAll.HasVariableInGUIObjects := (UpperCase(APropertyNewValue) = 'TRUE') or (StrToIntDef(APropertyNewValue, -1) = 1);
end;


procedure TfrmWinInterpEditorMain.HandleOnAddNewHandlerToAllHandlersByHandlerType(ATypeName, AHandlerName: string);
begin
  //AddNewHandlerToAllHandlersByHandlerType(FAllHandlers, ATypeName, AHandlerName);
end;


function TfrmWinInterpEditorMain.HandleOnEditScreen(var AScreen: TScreenInfo): Boolean;
begin
  Result := False;
  //Result := EditScreen(AScreen, FColorConsts);
end;


procedure TfrmWinInterpEditorMain.HandleOnDrawingBoardMouseMove(X, Y: Integer);
begin
  //StatusBar1.Panels.Items[0].Text := 'Mouse:  ' + IntToStr(X) + ' : ' + IntToStr(Y);
end;


function TfrmWinInterpEditorMain.HandleOnDrawingBoardCanFocus: Boolean;
begin
  Result := True;
  //Result := vstObjectInspectorProperties.Focused or vstObjectInspectorEvents.Focused;
end;


procedure TfrmWinInterpEditorMain.HandleOnDisplayScreenSize(AWidth, AHeight: Integer);
begin
  //StatusBar1.Panels.Items[3].Text := 'Screen size: ' + IntToStr(AWidth) + ' : ' + IntToStr(AHeight);
end;


procedure TfrmWinInterpEditorMain.HandleOnDrawingBoardRemoveFocus;
begin
  //memObjectInspectorDescription.SetFocus;  //set focus to another control
end;


procedure TfrmWinInterpEditorMain.HandleOnSetCustomPropertyValueOnLoading(APropertyName: string; ACompType: Integer; var APropertyValue: string);
var
  PluginIndex: Integer;
  //Plugin: PCompPlugin;
begin
  //if APropertyName = 'Plugin' then
  //begin
  //  PluginIndex := FCompPluginIndexArr[ACompType].CategoryIndex;
  //  Plugin := GetPluginByIndex(PluginIndex);
  //  try
  //    APropertyValue := Plugin^.GetPluginName + '  at idx: ' + IntToStr(PluginIndex) + '  (' + Plugin^.LibPath + ')';
  //  except
  //    on E: Exception do
  //      APropertyValue := E.Message + '  ' + Plugin^.LoadingError;
  //  end;
  //end;
end;


function TfrmWinInterpEditorMain.HandleOnResolveColorConst(AColorName: string): TColor;
begin
  Result := clWhite;
  //Result := ResolveColorConst(AColorName, FColorConsts, clFuchsia);
end;


procedure TfrmWinInterpEditorMain.HandleOnAfterMovingMountPanel(APanel: TMountPanel);     ///////////// in work
var
  TempCompData: PHighlightedCompRec;
begin
  ////////////////////////////////////   update WinInterp component and images
  TempCompData := PHighlightedCompRec(APanel.UserData);
  if TempCompData^.ParentCtrl is TMountPanel then
  begin
    TempCompData^.LocalX_FromParent := APanel.Left;
    TempCompData^.LocalY_FromParent := APanel.Top;
  end;

  TempCompData^.CompRec.ComponentRectangle.Width := APanel.Width;
  TempCompData^.CompRec.ComponentRectangle.Height := APanel.Height;
end;

////////////////////

procedure TfrmWinInterpEditorMain.HandleOnInsertTreeComponent(ACompData: PHighlightedCompRec);
begin
  try
    ACompData^.Ctrl := FfrDrawingBoard.AddComponentToDrawingBoard(0, //component type index
                                                                 ACompData^.LocalX_FromParent,
                                                                 ACompData^.LocalY_FromParent,
                                                                 0, //plugin index
                                                                 0, //component index in plugin
                                                                 ACompData^.ParentCtrl,
                                                                 ACompData);

    ACompData^.Ctrl.Width := ACompData^.CompRec.ComponentRectangle.Width;    //update width and height of the mount panel
    ACompData^.Ctrl.Height := ACompData^.CompRec.ComponentRectangle.Height;
  except
    on E: Exception do
      FWinInterpFrame.memCompInfo.Lines.Add('Ex on adding component: "' + E.Message);
  end;
end;


procedure TfrmWinInterpEditorMain.HandleOnClearWinInterp;
begin
  FfrDrawingBoard.ClearDrawingBoard;

  FfrDrawingBoard.AllComponentsLength := 1;
  FfrDrawingBoard.AllComponents^[0].Schema.ComponentTypeName := 'GenericButton';
  SetLength(FfrDrawingBoard.AllComponents^[0].Schema.Properties, 5);
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[0].PropertyName := 'Locked';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[1].PropertyName := 'Left';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[2].PropertyName := 'Top';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[3].PropertyName := 'Width';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[4].PropertyName := 'Height';

  FfrDrawingBoard.AllComponents^[0].Schema.Properties[0].PropertyDataType := 'Boolean';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[1].PropertyDataType := 'Integer';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[2].PropertyDataType := 'Integer';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[3].PropertyDataType := 'Integer';
  FfrDrawingBoard.AllComponents^[0].Schema.Properties[4].PropertyDataType := 'Integer';

  SetLength(FfrDrawingBoard.AllComponents^[0].DesignComponentsOneKind, Length(FfrDrawingBoard.AllComponents^[0].DesignComponentsOneKind) + 1);
  FfrDrawingBoard.AllComponents^[0].DesignComponentsOneKind[0].ObjectName := 'First';
end;

end.

