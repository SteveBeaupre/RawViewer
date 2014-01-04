unit SettingsUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin;

type
  TSettingsForm = class(TForm)
    GroupBox1: TGroupBox;
    GroupBoxImageSize: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    SpinEditWidth: TSpinEdit;
    SpinEditHeight: TSpinEdit;
    GroupBox3: TGroupBox;
    RadioButton16Bits: TRadioButton;
    RadioButton32Bits: TRadioButton;
    RadioButton24Bits: TRadioButton;
    RadioButton8BitsRGB: TRadioButton;
    RadioButton8BitsGray: TRadioButton;
    RadioButton2BitsGray: TRadioButton;
    GroupBox5: TGroupBox;
    CheckBoxFlip: TCheckBox;
    Panel2: TPanel;
    RadioButtonRGB: TRadioButton;
    RadioButtonBGR: TRadioButton;
    Button1: TButton;
    Button2: TButton;
    procedure RadioButton32BitsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadSettings();
    procedure SaveSettings();
  end;

var
  SettingsForm: TSettingsForm;

implementation

uses MainUnit;

{$R *.dfm}

procedure TSettingsForm.SaveSettings();
var
  Lst: TStringList;
begin
Lst := TStringList.Create;

Lst.Add(IntToStr(SpinEditWidth.Value));
Lst.Add(IntToStr(SpinEditHeight.Value));

if(RadioButton32Bits.Checked) then begin
  Lst.Add('32 bits');
end else if(RadioButton24Bits.Checked) then begin
  Lst.Add('24 bits');
end else if(RadioButton16Bits.Checked) then begin
  Lst.Add('16 bits');
end else if(RadioButton8BitsRGB.Checked) then begin
  Lst.Add('8 bits RGB');
end else if(RadioButton8BitsGray.Checked) then begin
  Lst.Add('8 bits Gray');
end else if(RadioButton2BitsGray.Checked) then begin
  Lst.Add('2 bits Gray');
end;

if(RadioButtonRGB.Checked) then begin
  Lst.Add('RGB');
end else begin
  Lst.Add('BGR');
end;

if(CheckBoxFlip.Checked) then begin
  Lst.Add('TRUE');
end else begin
  Lst.Add('FALSE');
end;

RadioButton32Bits.OnClick(Self);

Lst.SaveToFile(MainForm.AppDIr + '\Settings.set');
Lst.Free;
end;

procedure TSettingsForm.LoadSettings();
var
  Lst: TStringList;
begin
Lst := TStringList.Create;

if(FileExists(MainForm.AppDIr + '\Settings.set')) then begin
  Lst.LoadFromFile(MainForm.AppDIr + '\Settings.set');

  SpinEditWidth.Value  := StrToInt(Lst[0]);
  SpinEditHeight.Value := StrToInt(Lst[1]);

  if(Lst[2] = '32 bits') then begin
    RadioButton32Bits.Checked := True;
  end else if(Lst[2] = '24 bits') then begin
    RadioButton24Bits.Checked := True;
  end else if(Lst[2] = '16 bits') then begin
    RadioButton16Bits.Checked := True;
  end else if(Lst[2] = '8 bits RGB') then begin
    RadioButton8BitsRGB.Checked := True;
  end else if(Lst[2] = '8 bits Gray') then begin
    RadioButton8BitsGray.Checked := True;
  end else if(Lst[2] = '2 bits Gray') then begin
    RadioButton2BitsGray.Checked := True;
  end;

  if(Lst[3] = 'RGB') then begin
    RadioButtonRGB.Checked := True;
  end else begin
    RadioButtonBGR.Checked := True;
  end;

  CheckBoxFlip.Checked := Lst[4] = 'TRUE';
end;

Lst.Free;
end;

procedure TSettingsForm.RadioButton32BitsClick(Sender: TObject);
var
  HiColor: Boolean;
begin
HiColor := RadioButton32Bits.Checked or RadioButton24Bits.Checked;
RadioButtonRGB.Enabled := HiColor;
RadioButtonBGR.Enabled := HiColor;
end;

end.
