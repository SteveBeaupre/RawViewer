unit ChildUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TChildForm = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    bmp: TBitmap;
  public
    { Public declarations }
    function ReadRawFile(fname: String): Boolean;
  end;

var
  ChildForm: TChildForm;

implementation

uses SettingsUnit, MainUnit;

{$R *.dfm}

procedure TChildForm.FormCreate(Sender: TObject);
begin
AutoScroll := True;
bmp := TBitmap.Create;
end;

procedure TChildForm.FormActivate(Sender: TObject);
var
  i,t: Integer;
begin
for i := 0 to MainForm.WindowMenu.Count-1 do begin
  if(Self.Tag > 0) then begin
    t := MainForm.WindowMenu.Items[i].Tag;
    MainForm.WindowMenu.Items[i].Checked := t = Self.Tag;
  end;
end;
end;

procedure TChildForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
for i := 0 to MainForm.WindowMenu.Count-1 do begin
  if(Self.Tag > 0) then begin
    if(MainForm.WindowMenu.Items[i].Tag = Self.Tag) then begin
      MainForm.WindowMenu.Delete(i);
      break;
    end;
  end;
end;
bmp.Free;
Action := caFree;
end;

procedure TChildForm.FormPaint(Sender: TObject);
var
 TmpCol: TColor;
 DestRect, SourceRect: TRect;
begin
DestRect.Left   := 0;
DestRect.Top    := 0;
DestRect.Right  := ClientWidth;
DestRect.Bottom := ClientHeight;

if(not bmp.Empty) then begin
  SourceRect.Left := HorzScrollBar.Position;
  SourceRect.Top  := VertScrollBar.Position;
  SourceRect.Right  := SourceRect.Left + ClientWidth;
  SourceRect.Bottom := SourceRect.Top  + ClientHeight;

  Canvas.CopyRect(DestRect, bmp.Canvas, SourceRect);
end else begin
  TmpCol := Canvas.Brush.Color;
  Canvas.Brush.Color := clGray;
  Canvas.FillRect(DestRect);
  Canvas.Brush.Color := TmpCol;
end;
end;

function TChildForm.ReadRawFile(fname: String): Boolean;
var
 f: FILE;
 w,h, NumPixels, TargetSize: Integer;
 i,j,x,y, NumRead, NumLeftToRead: Integer;
 yStart, yStop, yStep: Integer;
 PixBuffer: Array [0..3] of BYTE;
 ReadBuffer: Array [0..2047] of BYTE;
 FileBuffer: Array of BYTE;
 w16bits: WORD;
 b8bits: WORD;
 col: TColor;
begin
Result := False;
w := SettingsForm.SpinEditWidth.Value;
h := SettingsForm.SpinEditHeight.Value;

NumPixels := w * h;
if(NumPixels = 0) then
  Exit;

AssignFile(f, fname);
Reset(f, 1);

TargetSize := -1;
if(SettingsForm.RadioButton32Bits.Checked) then begin
  TargetSize := NumPixels * 4;
end else if(SettingsForm.RadioButton24Bits.Checked) then begin
  TargetSize := NumPixels * 3;
end else if(SettingsForm.RadioButton16Bits.Checked) then begin
  TargetSize := NumPixels * 2;
end else if(SettingsForm.RadioButton8BitsRGB.Checked) then begin
  TargetSize := NumPixels;
end else if(SettingsForm.RadioButton8BitsGray.Checked) then begin
  TargetSize := NumPixels;
end else if(SettingsForm.RadioButton2BitsGray.Checked) then begin
  TargetSize := NumPixels div 4;
end;

if(FileSize(f) <> TargetSize) then begin
  ShowMessage('File size doesn''t match expected size!');
  Exit;
end;

NumLeftToRead := TargetSize;
SetLength(FileBuffer, NumLeftToRead);

while(NumLeftToRead > 0) do begin
  if(NumLeftToRead >= 2048) then begin
    BlockRead(f, ReadBuffer, 2048, NumRead);
  end else begin
    BlockRead(f, ReadBuffer, NumLeftToRead, NumRead);
  end;
  CopyMemory(@FileBuffer[TargetSize-NumLeftToRead], @ReadBuffer[0], NumRead);
  Dec(NumLeftToRead, NumRead);
end;
CloseFile(f);

bmp.Width  := w;
bmp.Height := h;

if(not SettingsForm.CheckBoxFlip.Checked) then begin
  yStart := 0;
  yStop  := h;
  yStep  := 1;
end else begin
  yStart := h-1;
  yStop  := 0;
  yStep  := -1;
end;

i := 0;
y := yStart;

while(y <> yStop) do begin
  x := 0;
  while(x < w) do begin

    if(SettingsForm.RadioButton32Bits.Checked) then begin

      CopyMemory(@PixBuffer[0], @FileBuffer[i], 4);
      Inc(i, 4);

      if(SettingsForm.RadioButtonRGB.Checked) then begin
        col := (PixBuffer[0]) or (PixBuffer[1] shl 8) or (PixBuffer[2] shl 16);
      end else begin
        col := (PixBuffer[2]) or (PixBuffer[1] shl 8) or (PixBuffer[0] shl 16);
      end;
      bmp.Canvas.Pixels[x,y] := col;

    end else if(SettingsForm.RadioButton24Bits.Checked) then begin

      CopyMemory(@PixBuffer[0], @FileBuffer[i], 3);
      Inc(i, 3);

      if(SettingsForm.RadioButtonRGB.Checked) then begin
        col := (PixBuffer[0]) or (PixBuffer[1] shl 8) or (PixBuffer[2] shl 16);
      end else begin
        col := (PixBuffer[2]) or (PixBuffer[1] shl 8) or (PixBuffer[0] shl 16);
      end;
      bmp.Canvas.Pixels[x,y] := col;

    end else if(SettingsForm.RadioButton16Bits.Checked) then begin

      CopyMemory(@PixBuffer[0], @FileBuffer[i], 2);
      Inc(i, 2);

      CopyMemory(@w16bits, @PixBuffer[0], sizeof(WORD));
      PixBuffer[0] := w16bits and $0000001F;
      PixBuffer[1] := (w16bits shr 5) and $0000003F;
      PixBuffer[2] := (w16bits shr 11) and $0000001F;

      PixBuffer[0] := Trunc((PixBuffer[0] / 31) * 255.0);
      PixBuffer[1] := Trunc((PixBuffer[1] / 63) * 255.0);
      PixBuffer[2] := Trunc((PixBuffer[2] / 31) * 255.0);

      col := (PixBuffer[0]) or (PixBuffer[1] shl 8) or (PixBuffer[2] shl 16);
      bmp.Canvas.Pixels[x,y] := col;

    end else if(SettingsForm.RadioButton8BitsRGB.Checked) then begin

      PixBuffer[0] := FileBuffer[i];
      Inc(i, 1);

      b8bits := PixBuffer[0];
      PixBuffer[0] := b8bits and $00000007;
      PixBuffer[1] := (b8bits shr 3) and $00000007;
      PixBuffer[2] := (b8bits shr 6) and $00000003;

      PixBuffer[0] := Trunc((PixBuffer[0] / 7) * 255.0);
      PixBuffer[1] := Trunc((PixBuffer[1] / 7) * 255.0);
      PixBuffer[2] := Trunc((PixBuffer[2] / 3) * 255.0);

      col := (PixBuffer[0]) or (PixBuffer[1] shl 8) or (PixBuffer[2] shl 16);
      bmp.Canvas.Pixels[x,y] := col;

    end else if(SettingsForm.RadioButton8BitsGray.Checked) then begin

      PixBuffer[0] := FileBuffer[i];
      Inc(i, 1);

      PixBuffer[1] := PixBuffer[0];
      PixBuffer[2] := PixBuffer[0];

      col := (PixBuffer[0]) or (PixBuffer[1] shl 8) or (PixBuffer[2] shl 16);
      bmp.Canvas.Pixels[x,y] := col;

    end else if(SettingsForm.RadioButton2BitsGray.Checked) then begin

      PixBuffer[0] := FileBuffer[i];
      Inc(i, 1);

      b8bits := PixBuffer[0];
      for j := 0 to 3 do begin
        PixBuffer[0] := Trunc(((b8bits and $00000003) / 3) * 255.0);
        PixBuffer[1] := PixBuffer[0];
        PixBuffer[2] := PixBuffer[0];

        col := (PixBuffer[0]) or (PixBuffer[1] shl 8) or (PixBuffer[2] shl 16);
        bmp.Canvas.Pixels[x+j,y] := col;

        b8bits := b8bits shr 2;
      end;

      Inc(x, 3);
    end;
    Inc(x);
  end;
  y := y + yStep;
end;

SetLength(FileBuffer, 0);

ClientWidth  := w;
ClientHeight := h;

HorzScrollBar.Range := w;
VertScrollBar.Range := h;
Result := True;
end;

end.
