unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, ShellAPI, Vcl.Imaging.GIFImg;

type
  TForm1 = class(TForm)
    chkSom: TCheckBox;
    btnDesativar: TButton;
    lblIntervalo: TLabel;
    edtIntervalo: TEdit;
    lblContagem: TLabel;
    imgMascote: TImage;
    lblCiclos: TLabel;
    TimerContagem: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure btnDesativarClick(Sender: TObject);
    procedure TimerContagemTimer(Sender: TObject);
  private
    FRunning: Boolean;
    FInterval: Integer;
    FRemaining: Integer;
    FCycleCount: Integer;
    procedure MoveMouse;
    procedure PressKey;
    procedure ClickOnTeamsIcon;
    procedure KeepTeamsActive;
    procedure LogCycleCount;
    procedure ResetCycleCount;
    procedure AtualizarContagem;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FRunning := False;
  FCycleCount := 0;
  lblCiclos.Caption := 'Ciclos executados: 0';
  TimerContagem.Interval := 1000;
  imgMascote.Transparent := True;
  imgMascote.Picture.LoadFromFile('mascote.gif');

  if imgMascote.Picture.Graphic is TGIFImage then
    TGIFImage(imgMascote.Picture.Graphic).Animate := True;
end;

procedure TForm1.btnDesativarClick(Sender: TObject);
begin
  if FRunning then
  begin
    FRunning := False;
    TimerContagem.Enabled := False;
    btnDesativar.Caption := 'Ativar';
  end
  else
  begin
    try
      FInterval := StrToInt(edtIntervalo.Text);
    except
      FInterval := 5;
    end;

    if FInterval < 1 then FInterval := 5;

    FRemaining := FInterval;
    ResetCycleCount;
    FRunning := True;
    btnDesativar.Caption := 'Desativar';
    TimerContagem.Enabled := True;
    AtualizarContagem;
  end;
end;

procedure TForm1.TimerContagemTimer(Sender: TObject);
begin
  Dec(FRemaining);
  AtualizarContagem;

  if FRemaining <= 0 then
  begin
    MoveMouse;
    PressKey;
    ClickOnTeamsIcon;
    KeepTeamsActive;

    if chkSom.Checked then
      MessageBeep(MB_OK);

    Inc(FCycleCount);
    lblCiclos.Caption := Format('Ciclos executados: %d', [FCycleCount]);
    LogCycleCount;
    FRemaining := FInterval;
  end;
end;

procedure TForm1.AtualizarContagem;
begin
  lblContagem.Caption := Format('Proximo movimento em: %d', [FRemaining]);
end;

procedure TForm1.MoveMouse;
var
  Pos: TPoint;
begin
  GetCursorPos(Pos);
  if (Pos.X mod 2 = 0) then
    SetCursorPos(Pos.X + 50, Pos.Y + 50)
  else
    SetCursorPos(Pos.X - 50, Pos.Y - 50);
end;

procedure TForm1.PressKey;
begin
  keybd_event(VK_F15, 0, 0, 0);
  keybd_event(VK_F15, 0, KEYEVENTF_KEYUP, 0);
end;

procedure TForm1.ClickOnTeamsIcon;
begin
  SetCursorPos(50, 1050);
  mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
end;

procedure TForm1.KeepTeamsActive;
begin
  ShellExecute(0, 'open', 'powershell.exe',
    ' -command "[System.Windows.Forms.SendKeys]::SendWait(''{SCROLLLOCK}'')"',
    nil, SW_HIDE);
end;

procedure TForm1.ResetCycleCount;
begin
  FCycleCount := 0;
  lblCiclos.Caption := 'Ciclos executados: 0';
end;

procedure TForm1.LogCycleCount;
var
  LogFile: TextFile;
  LogLine: string;
begin
  AssignFile(LogFile, 'cycle_log.txt');
  if FileExists('cycle_log.txt') then
    Append(LogFile)
  else
    Rewrite(LogFile);

  LogLine := Format('%s - Total de ciclos: %d',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), FCycleCount]);

  Writeln(LogFile, LogLine);
  CloseFile(LogFile);
end;

end.