program RESTTool;

uses
  Forms,
  formMain in 'formMain.pas' {frmMain},
  formRest in '..\RESTServer\formRest.pas' {frmRest},
  formInfo in '..\RESTServer\formInfo.pas' {frmInfo},
  formConfigServer in 'formConfigServer.pas' {frmConfigServer};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmRest, frmRest);
  Application.CreateForm(TfrmInfo, frmInfo);
  Application.CreateForm(TfrmConfigServer, frmConfigServer);
  Application.Run;
end.
