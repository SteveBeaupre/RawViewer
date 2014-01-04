unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus;

type
 TMenuActions = class
  public
    class procedure OnClick(Sender: TObject);
  end;

  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    ExitMenu: TMenuItem;
    OpenMenu: TMenuItem;
    CloseMenu: TMenuItem;
    CloseAllMenu: TMenuItem;
    N1: TMenuItem;
    WindowMenu: TMenuItem;
    CascadeMenu: TMenuItem;
    TileMenu: TMenuItem;
    ArrangeAllMenu: TMenuItem;
    N2: TMenuItem;
    procedure CloseAllMenuClick(Sender: TObject);
    procedure CascadeMenuClick(Sender: TObject);
    procedure TileMenuClick(Sender: TObject);
    procedure ArrangeAllMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ExitMenuClick(Sender: TObject);
    procedure OpenMenuClick(Sender: TObject);
    procedure CloseMenuClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    AppDir: String;
    
    procedure CreateChildForm(const childName: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses ChildUnit, SettingsUnit;

class procedure TMenuActions.OnClick(Sender: TObject);
var
  i,j: Integer;
begin
for i := 0 to MainForm.WindowMenu.Count-1 do begin
  if(TMenuItem(Sender).Tag > 0) then begin
    if(MainForm.WindowMenu.Items[i].Tag = TMenuItem(Sender).Tag) then begin
      for j := 0 to MainForm.MdiChildCount-1 do begin
        if(MainForm.MDIChildren[j].Tag = TMenuItem(Sender).Tag) then
          MainForm.MDIChildren[j].SetFocus;
      end;
      break;
    end;
  end;
end;

end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
Randomize;
GetDir(0, AppDir);
end;

procedure TMainForm.ExitMenuClick(Sender: TObject);
begin
CloseAllMenu.OnClick(Self);
Close;
end;

procedure TMainForm.CloseMenuClick(Sender: TObject);
var
  i: integer;
begin
for i := 0 to MdiChildCount-1 do begin
  if(MDIChildren[i].Active) then
    MDIChildren[i].Close;
end
end;

procedure TMainForm.CloseAllMenuClick(Sender: TObject);
var
  i: integer;
begin
for i := 0 to MdiChildCount-1 do
  MDIChildren[i].Close;
end;

procedure TMainForm.CascadeMenuClick(Sender: TObject);
begin
Cascade;
end;

procedure TMainForm.TileMenuClick(Sender: TObject);
begin
Tile;
end;

procedure TMainForm.ArrangeAllMenuClick(Sender: TObject);
begin
ArrangeIcons;
end;

procedure TMainForm.OpenMenuClick(Sender: TObject);
var
 OpnDlg: TOpenDialog;
begin
OpnDlg := TOpenDialog.Create(Self);
OpnDlg.Filter := 'Raw files (*.raw)|*.RAW';
if(OpnDlg.Execute) then begin
  SettingsForm.LoadSettings();
  if(SettingsForm.ShowModal = mrOk) then begin
    SettingsForm.SaveSettings();

    CreateChildForm(OpnDlg.FileName);
  end;
end;
OpnDlg.Free;
end;

procedure OnDynamicWindowMenuItemClick(Sender: TObject);
begin

end;

procedure TMainForm.CreateChildForm(const childName: string);
var
  Child: TChildForm;
  menuItem: TMenuItem;
begin
menuItem := TMenuItem.Create(Self);
menuItem.Tag := random(999999)+1;
WindowMenu.Insert(WindowMenu.Count, menuItem);

Child := TChildForm.Create(Application);
Child.Caption := childName;
Child.Tag := menuItem.Tag;
Child.OnActivate(Self);
menuItem.OnClick := TMenuActions.OnClick;

if(Child.ReadRawFile(childName)) then begin
  menuItem.Caption := childName;
  Child.Repaint;
end else begin
  Child.Close;
  ShowMessage('An error occured while parsing the file...');
end;
end;

end.
