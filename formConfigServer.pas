unit formConfigServer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmConfigServer = class(TForm)
    mmoServer: TMemo;
    btnSave: TButton;
    btnClose: TButton;
    lblHint: TLabel;
    procedure btnSaveClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    g_strConfigFileName: string;
    g_bSave: boolean;
  end;

var
  frmConfigServer: TfrmConfigServer;

implementation

{$R *.dfm}

procedure TfrmConfigServer.btnSaveClick(Sender: TObject);
var
    strFileName: string;
begin
    mmoServer.Lines.SaveToFile(g_strConfigFileName);
    g_bSave := true;
    Close;
end;

procedure TfrmConfigServer.btnCloseClick(Sender: TObject);
begin
    g_bSave := false;
    Close;
end;

end.
