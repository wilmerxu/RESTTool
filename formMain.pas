unit formMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, ScktComp, IdCookieManager, DateUtils,
  WinSkinData, SkinCaption, HttpApp, superobject, WiIniCom, ImgList, Menus,
  xDes, formRest, IdIPWatch, IdSSLOpenSSL, IdIOHandler, IdIOHandlerSocket, formInfo,
  WinINet, IDURI, IdIOHandlerStack, IdSSL, IdGlobal, formConfigServer, EncdDecd, jpeg;

const
    // REST�����ַ
    //REST_URL = '[%PROTOCOL_TYPE%]://[%HOST_ADDR%]:[%HOST_PORT%]/[%REST_PATH%]?t=[%TIME_VAL%]';
    REST_URL = '[%PROTOCOL_TYPE%]://[%HOST_ADDR%]:[%HOST_PORT%]/[%REST_PATH%]';

    // ������
    REST_REQ = 'POST /[%REST_PRE%]/[%REST_PATH%]?t=[%TIME_VAL%] HTTP/1.1' + #13#10 +
    'Host: [%HOST_ADDR%]:[%HOST_PORT%]' + #13#10 +
    'Connection: keep-alive' + #13#10 +
    'Content-Length: [%CONTENT_LENGTH%]' + #13#10 +
    'Pragma: no-cache' + #13#10 +
    'Cache-Control: no-cache' + #13#10 +
    'Accept: application/json, text/plain, */*' + #13#10 +
    'Origin: http://[%HOST_ADDR%]:[%HOST_PORT%]' + #13#10 +
    'X-Requested-With: XMLHttpRequest' + #13#10 +
    'User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113' + #13#10 +
    'Safari/537.36' + #13#10 +
    'Content-Type: application/ueefire' + #13#10 +
    'Referer: http://[%HOST_ADDR%]:[%HOST_PORT%]/[%HTML_PATH%]' + #13#10 +
    'Accept-Encoding: gzip, deflate, br' + #13#10 +
    'Accept-Language: zh-CN,zh;q=0.8' + #13#10 +
    'Cookie: bes_login_sid=ZJDS001-f87f72a5b3c74d669f57a28436ba90ee; access_time_cookie=1505814437291; bes-site-param=%' + #13#10 +
    '7B%22siteVersion%22%3A%22c10%22%2C%22skinPath%22%3A%22default%22%7D; com.huawei.boss.CURRENT_MENUID=360view;' + #13#10 +
    'com.huawei.boss.CURRENT_USER=13729009520; u-locale=zh_CN' + #13#10 +
    #13#10 +
    '[%ALL_REQ_PARAM%]';

    // �������
    REQ_PARAM = '{"model":null,"params":[%REQ_PARAM%]}';

    // ��¼�ɹ���ʾ
    LOGIN_SUCCESS_INFO = '"successLogin!"';

    // COOKIE��Ϣ
//    COOKIE_INFO = 'Cookie: bes_login_sid=ZJDS001-e255472bc30e4eccabcc204a89ae3323; access_time_cookie=1504839128732; bes-site-param=%' + #13#10 +
//    '7B%22siteVersion%22%3A%22c10%22%2C%22skinPath%22%3A%22default%22%7D; com.huawei.boss.CURRENT_MENUID=360view;' + #13#10 +
//    'com.huawei.boss.CURRENT_USER=13729009520; u-locale=zh_CN';

    COOKIE_INFO = 'bes_login_sid=ZJDS001-8f10e8f97ec44d0791d6eeb0fda129e8; ' + #13#10 +
    'access_time_cookie=1511235703916; bes-site-param=%7B%22siteVersion%22%3A%22c10%22%2C%22skinPath%22%3A%22default%22%7D; ' + #13#10 +
    'com.huawei.boss.CURRENT_MENUID=root_workbeach; com.huawei.gdbes.CURRENT_MENUID=root_workbeach; u-locale=zh_CN';

    // �����ļ�·��
    CONFIG_PATH = 'config';
    // �����ļ�
    CONFIG_FILE = 'config.ini';
    // �������б�
    SERVER_CONFIG_FILE = 'server_list.txt';

    // �ӿ��ļ�·��
    INTERFACE_PATH = 'interface';

    // �ļ�����
    FILE_TYPE_TEMP = 0;
    FILE_TYPE_DIR = 1;
    FILE_TYPE_FILE = 2;

    // REST�ļ���ʽ
    REST_FILE_FMT = '<FILE_VERSON>[%VERSION%]</FILE_VERSON>' + #13#10 +
    '<REST_PATH>[%REST_PATH%]</REST_PATH>' + #13#10 +
    '<REST_PARAM>[%REST_PARAM%]</REST_PARAM>';

    REG_FILE = 'restreg.w';

    LOGOUT_URL = '';

type
    PTreeFileData = ^TTreeFileData;
    TTreeFileData = record
        fileType: integer;
        filePath: string;
        fileVersion: string;
        restPath: string;
        restParam: string;
    end;

type TMsgType = (MSG_ACTIVE_REQ = 1001, MSG_ACTIVE_RESP = 2001);

type
    PMsgData = ^TMsgData;
    TMsgData = record
        msgType: TMsgType;
        msgLength: Integer;
        msgData: array[0..1024] of byte;
    end;

type
    TActiveThread = class(TThread)
        private
        public
            function SendActive: boolean;
            function ConnectServer: boolean;
            procedure Execute; override;
    end;

type
  TfrmMain = class(TForm)
    pnlLog: TPanel;
    sbMain: TStatusBar;
    pnlLeft: TPanel;
    tvMain: TTreeView;
    Panel2: TPanel;
    pnlMain: TPanel;
    redResp: TRichEdit;
    Panel3: TPanel;
    lbedRestPath: TLabeledEdit;
    spMain: TSplitter;
    timerMain: TTimer;
    btnHit: TButton;
    lblInParam: TLabel;
    Panel5: TPanel;
    redReq: TRichEdit;
    Splitter1: TSplitter;
    lblOutParam: TLabel;
    csMain: TClientSocket;
    mmoLog: TMemo;
    pnlToolbar: TPanel;
    btnClose: TButton;
    lbedHost: TLabeledEdit;
    lbedPort: TLabeledEdit;
    btnLogin: TButton;
    btnLogout: TButton;
    idCookieManager: TIdCookieManager;
    lbedLoginId: TLabeledEdit;
    lbedPassword: TLabeledEdit;
    SkinData1: TSkinData;
    SkinCaption1: TSkinCaption;
    lblVer: TLabel;
    wiIniCom: TWiIniCom;
    imglistFile: TImageList;
    popMenuInterface: TPopupMenu;
    N1: TMenuItem;
    csActive: TClientSocket;
    lbedRegPassword: TLabeledEdit;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    lbedLoginUrl: TLabeledEdit;
    idpwtchMain: TIdIPWatch;
    btnReg: TButton;
    rbHttp: TRadioButton;
    rbHttps: TRadioButton;
    lblProtocolType: TLabel;
    lblInterface: TLabel;
    lblServer: TLabel;
    cmbServer: TComboBox;
    btnConfigServer: TButton;
    idslhndlrscktpnslMain: TIdSSLIOHandlerSocketOpenSSL;
    idhttpMain: TIdHTTP;
    pmReq: TPopupMenu;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    btnClean: TButton;
    chkBES: TCheckBox;
    btnToBase64: TButton;
    odPic: TOpenDialog;
    N15: TMenuItem;
    N16: TMenuItem;
    cmbContentType: TComboBox;
    lblContentType: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure timerMainTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHitClick(Sender: TObject);
    procedure csMainConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure csMainRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure csMainDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure csMainError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure btnLoginClick(Sender: TObject);
    procedure tvMainExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure tvMainDblClick(Sender: TObject);
    procedure tvMainClick(Sender: TObject);
    procedure csActiveConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure csActiveDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure csActiveError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure csActiveRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure btnRegClick(Sender: TObject);
    procedure Panel5DblClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure btnConfigServerClick(Sender: TObject);
    procedure cmbServerChange(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure btnCleanClick(Sender: TObject);
    procedure chkBESClick(Sender: TObject);
    procedure btnToBase64Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
  private
    { Private declarations }
    function ConnectHost : integer;
    // ���������ļ�
    procedure LoadConfig;
    // ���������ļ�
    procedure SaveConfig;
    // ��ȡ�ļ��б�
    procedure FindFileList(pParentNode: TTreeNode; strPath: string; strFileAttr: string);
    // ����rest����
    procedure HitRest(strSrcRestPath: string; strRestParam: string);
    // �����쳣
    procedure AppException (Sender: TObject; E: Exception);
    // ����Ŀ¼
    procedure AddDir;
    // ���Ӹ�Ŀ¼
    procedure AddRootDir;
    // �����ļ�
    procedure AddFile;
    // �޸��ļ�
    procedure ModifyFile;
    // �����ļ�
    procedure SaveFile(strFileName: string; strRestPath: string; strRestParam: string);
    // ɾ���ļ�
    procedure DelFile;
    // ˢ���ļ��б�
    procedure RefreshFileList;
    // ɾ��Ŀ¼
    function DelDir(const strDirName : string) : boolean;
    procedure CheckReg;
    procedure HttpPost(url, data, Len, Auth: string; res: TStream);
    // ��ʽ��json
    function FormatJson(strText: string; isExpand: boolean) : string;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  g_iConnectRet: integer;
  g_strCookie: string;
  g_strPath: string;
  g_bLogined: boolean;
  g_bReg: boolean;
  g_strVersion: string;
  g_activeThread: TActiveThread;
  g_strAOPENAccessToken: string;
  g_strIBHAccessToken: string;

implementation

{$R *.dfm}

// ���ݿ�ʼ�ͽ�����ȡ���м��ַ���
function CenterStr(const strSrc : String; const strBegin : String; const strEnd : String) : String;
var
    iPosBegin, iPosEnd: integer;
    strSrcLow, strBeginLow, strEndLow: String;
begin
    strSrcLow := LowerCase(strSrc);
    strBeginLow := LowerCase(strBegin);
    strEndLow := LowerCase(strEnd);

    iPosBegin := Pos(strBeginLow, strSrcLow) + Length(strBeginLow);
    iPosEnd := Pos(strEndLow, strSrcLow);

    result := Copy(strSrc, iPosBegin, iPosEnd - iPosBegin);
end;

// ��ȡ����ֵ
function GetConfigValue(const strSrc : string; strConfigName: string): string;
begin
    result := CenterStr(strSrc, '<' + strConfigName + '>', '</' + strConfigName + '>'); 
end;

{�½�һ��TXT�ĵ�}
Procedure NewTxt(FileName:String);
Var
    F : Textfile; {���� F Ϊ Textfile}
Begin
    AssignFile(F,FileName); {���ļ�������� F ����}
    ReWrite(F); {����Txt�ĵ�������Ϊ ��FileName �� }
    Closefile(F); {�ر��ļ� F}
End;

{�ȸ���ԭ������д��������}
Procedure AppendTxt(Str:String;FileName:String);
Var
    F:Textfile;
Begin
    AssignFile(F, FileName);
    Append(F); {����ԭ������������ԭ���ݱ����}
    Writeln(F, Str); {������ Ser д���ļ�F }
    Closefile(F);
End;

// ��¼��־
procedure WriteTxtLog(const strFileName, strContent: string);
var
    strDir: string;
begin
    try
        if (Trim(strFileName) = '') then
            exit;
        strDir := ExtractFileDir(strFileName);
        // ����ļ��в����ڣ��򴴽�
        if (not DirectoryExists(strDir)) then
        begin
            ForceDirectories(strDir);
            Application.ProcessMessages;
            Sleep(100);
            Application.ProcessMessages;
        end;
            
        // ����ļ������ڣ��򴴽�
        if (not FileExists(strFileName)) then
        begin
            NewTxt(strFileName);
            Application.ProcessMessages;
            Sleep(100);
            Application.ProcessMessages;
        end;

        AppendTxt(strContent, strFileName);
    except
        ;
    end;
end;

// ��ӡ��־
procedure WriteLog(const strText : string);
var
    dt: TDateTime;
    strLogText, strLogFileName: string;
begin
    dt := Now();
    strLogText := FormatDateTime('yyyy-mm-dd hh:mm:ss', dt);
    strLogText := strLogText + ' ' + strText;
    frmMain.mmoLog.Lines.Add(strLogText);
    strLogFileName := FormatDateTime('yyyymmdd', dt);
    strLogFileName := g_strPath + 'log\' + strLogFileName + '.txt';
    WriteTxtLog(strLogFileName, strLogText);
end;

procedure WriteStatus(strContent: string);
begin
    frmMain.sbMain.Panels.Items[0].Text := strContent;
end;

procedure WriteLine;
begin
    frmMain.mmoLog.Lines.Add('============================================================================================================');
end;

function TActiveThread.SendActive: boolean;
var
    msgData: TMsgData;
    strData: string;
    i, iRecLength: integer;
begin
    result := false;
    if not frmMain.csActive.Active then
        Exit;

    FillChar(msgData, sizeof(msgData), 0);
    msgData.msgType := MSG_ACTIVE_REQ;
    strData := frmMain.lbedRegPassword.Text + ':' + FormatDateTime('yyyy-mm-dd hh:mm:ss', Now);
    msgData.msgLength := Length(strData);
    strData := EncryStr(strData, 'wi!!RTool2017');

    CopyMemory(@msgData.msgData, PChar(strData), Length(strData));
    frmMain.csActive.Socket.SendBuf(msgData, sizeof(msgData));
    for i := 0 to 120 do
    begin
        Sleep(1000);
        if frmMain.csActive.Socket.RemoteAddress <> '10.40.16.193' then
        begin
            g_bReg := false;
            Exit;
        end;

        iRecLength := frmMain.csActive.Socket.ReceiveLength;
        if iRecLength > 0 then
        begin
            FillChar(msgData, sizeof(msgData), 0);
            frmMain.csActive.Socket.ReceiveBuf(msgData, iRecLength);
            if msgData.msgType = MSG_ACTIVE_RESP then
            begin
                SetLength(strData, 1024);
                Move(msgData.msgData[0], strData[1], 1024);
                strData := DecryStr(strData, 'wi!!RTool2017');
                strData := Copy(strData, 0, msgData.msgLength);
                if (strData <> 'ok') then
                begin
                    g_bReg := false;
                    WriteLog(strData);
                end
                else
                begin
                    WriteLog('���ӷ�����ע��ɹ�');
                end;
            end;
            break;
        end;
    end;
end;


function TActiveThread.ConnectServer : boolean;
var
    i: integer;
begin
    Result := false;
    if not frmMain.csActive.Active then
    begin
        frmMain.csActive.Host := '10.40.16.193';
        frmMain.csActive.Port := 39998;
        frmMain.csActive.Open;
        for i := 0 to 25 do
        begin
            Application.ProcessMessages;
            Sleep(1000);
            if frmMain.csActive.Active then
            begin
                result := true;
                Exit;
            end;
        end;
        Result := false;
    end
    else
    begin
        Result := true;
    end;
end;

procedure TActiveThread.Execute;
begin
    while True do
    begin
        try
            Sleep(3000);
            if not ConnectServer then
            begin
                Sleep(5*60*1000);
                Continue;
            end;

            SendActive;
        except
            on e: Exception do
            begin
                Sleep(5000);
            end;
        end;
        Sleep(5*60*1000);
    end;
end;


//��Java�е�����ת��ΪDelphi�е�����
function ConvertJavaDateTimeToDelphiDateTime(Value: Int64): TDateTime;
begin
   Result := IncMilliSecond(StrToDate('1970-01-01'), Value);
end;

//��Delphi�е�����ת��ΪJava�е�����
function ConvertDelphiDateTimeToJavaDateTime(ADateTime: TDateTime): Extended;
var
   dt: TDateTime;
   dtVal: double;
begin

    if not TryStrToDate('1970-01-01', dt) then
    begin
       dtVal := 25569;
       dt := dtVal;
    end;
    Result := MilliSecondSpan(ADateTime, dt);
end;

//ȡ�����ļ������
{ ComputerName }
function ComputerName: string;
var
    FStr: PChar;
    FSize: Cardinal;
begin
    FSize := 255;
    GetMem(FStr, FSize);
    Windows.GetComputerName(FStr, FSize);
    Result := FStr;
    FreeMem(FStr);
end;

//ȡWindows��¼�û���
{ WinUserName }
function WinUserName: string;
var
    FStr: PChar;
    FSize: Cardinal;
begin
    FSize := 255;
    GetMem(FStr, FSize);
    GetUserName(FStr, FSize);
    Result := FStr;
    FreeMem(FStr);
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmMain.timerMainTimer(Sender: TObject);
begin
    sbMain.Panels.Items[2].Text := FormatDateTime('yyyy-mm-dd hh:mm:ss', Now());
end;

//ȡ���ļ��汾
function GetFileVer(strFileName: String): String;
var
    n, Len: DWORD;
    Buf : PChar;
    Value: Pointer;
    szName: array [0..255] of Char;
    Transstring: String;
begin
    Len := GetFileVersionInfoSize(PChar(strFileName), n);
    if Len > 0 then
    begin
        Buf := AllocMem(Len);
        if GetFileVersionInfo(Pchar(strFileName), n, Len, Buf) then
        begin
            Value := nil;
            VerQueryValue(Buf, '\VarFileInfo\Translation', Value, Len);
            if Value <> nil then
            begin
                Transstring := IntToHex(MakeLong(HiWord(LongInt(Value^)), LoWord(LongInt(Value^))),8);
            end;
            StrPCopy(szName, '\stringFileInfo\' + Transstring + '\FileVersion');
            if VerQueryValue(Buf, szName, Value, Len) then
            begin
                Result := StrPas(Pchar(Value));
            end;
            FreeMem(Buf, n);
        end;
    end;
end;

// ���������ļ�
procedure TfrmMain.LoadConfig;
var
    i, iProtocolType, iServerIndex, iContentTypeIndex: Integer;
begin
    wiIniCom.Section := 'main';
    lbedLoginId.Text := wiIniCom.ReadSection('LOGIN_ID');
    lbedPassword.Text := wiIniCom.ReadSection('LOGIN_PASSWORD');
    lbedHost.Text := wiIniCom.ReadSection('HTTP_HOST');
    lbedPort.Text := wiIniCom.ReadSection('HTTP_PORT');
//    lbedRestPre.Text := wiIniCom.ReadSection('REST_PRE');
    lbedLoginUrl.Text := wiIniCom.ReadSection('LOGIN_URL');
    iProtocolType := 1;
    TryStrToInt(Trim(wiIniCom.ReadSection('PROTOCOL_TYPE')), iProtocolType);
    if 1 = iProtocolType then
        rbHttp.Checked := True
    else if 2 = iProtocolType then
        rbHttps.Checked := True;
        
    if (FileExists(g_strPath + CONFIG_PATH + '\' + SERVER_CONFIG_FILE)) then
    begin
        cmbServer.Items.LoadFromFile(g_strPath +  CONFIG_PATH + '\' + SERVER_CONFIG_FILE);
    end;
    iServerIndex := -1;
    TryStrToInt(wiIniCom.ReadSection('SERVER_INDEX'), iServerIndex);
    if cmbServer.Items.Count > iServerIndex then
        cmbServer.ItemIndex := iServerIndex;
    iContentTypeIndex := 1;
    TryStrToInt(Trim(wiIniCom.ReadSection('CONTENT_TYPE_INDEX')), iContentTypeIndex);
    cmbContentType.ItemIndex := iContentTypeIndex;
    chkBES.Checked := wiIniCom.ReadSection('IS_BES') = '1';
end;

// ���������ļ�
procedure TfrmMain.SaveConfig;
var
    iProtocolType: integer;
begin
    wiIniCom.Section := 'main';
    wiIniCom.WriteSection('LOGIN_ID', lbedLoginId.Text);
    wiIniCom.WriteSection('LOGIN_PASSWORD', lbedPassword.Text);
    wiIniCom.WriteSection('HTTP_HOST', lbedHost.Text);
    wiIniCom.WriteSection('HTTP_PORT', lbedPort.Text);
    wiIniCom.WriteSection('LOGIN_URL', lbedLoginUrl.Text);
    iProtocolType := 1;
    if rbHttps.Checked then
        iProtocolType := 2;
    wiIniCom.WriteSection('PROTOCOL_TYPE', IntToStr(iProtocolType));

    wiIniCom.WriteSection('SERVER_INDEX', IntToStr(cmbServer.ItemIndex));
    wiIniCom.WriteSection('CONTENT_TYPE_INDEX', IntToStr(cmbContentType.ItemIndex));
    if chkBES.Checked then
        wiIniCom.WriteSection('IS_BES', '1')
    else
        wiIniCom.WriteSection('IS_BES', '0');
end;

// ��ȡ�ļ��б�
procedure TfrmMain.FindFileList(pParentNode: TTreeNode; strPath: string; strFileAttr: string);
var
    sr: TSearchRec;
    fr: Integer;
    pNode: TTreeNode;
    pTreeData: PTreeFileData;
begin
    fr := FindFirst(strPath + '\' + strFileAttr, faAnyFile, sr);
    while fr = 0 do
    begin
        if(sr.Attr = faDirectory) and (sr.Name <> '.') and (sr.Name <> '..') then
        begin
            // Ŀ¼����
            if not Assigned(pParentNode) then
                pNode := tvMain.Items.Add(nil, sr.Name)
            else
                pNode := tvMain.Items.AddChild(pParentNode, sr.Name);

            new(pTreeData);
            pTreeData.fileType := FILE_TYPE_DIR;
            pTreeData.filePath := strPath + '\' + sr.Name;
            pNode.Data := pTreeData;
            pNode.ImageIndex := FILE_TYPE_DIR;
            tvMain.Items.AddChild(pNode, 'temp');
        end
        else if (sr.Name <> '.') and (sr.Name<>'..') and (sr.Name <> '.svn') and (ExtractFileExt(sr.Name) = '.txt') then
        begin
            // �ļ�����
            if not Assigned(pParentNode) then
                pNode := tvMain.Items.Add(nil, sr.Name)
            else
                pNode := tvMain.Items.AddChild(pParentNode, sr.Name);
            new(pTreeData);
            pTreeData.fileType := FILE_TYPE_FILE;
            pTreeData.filePath := strPath + '\' + sr.Name;
            pNode.Data := pTreeData;
            pNode.ImageIndex := FILE_TYPE_FILE;
        end;
        fr := FindNext(sr);
    end;
    
    FindClose(sr);
end;

procedure TfrmMain.CheckReg;
var
    strIp, strData, strRegKey, strRegFile: string;
    strlistFile: TStringList;
    pRegFile: PChar;
    i: integer;
begin
    g_bReg := true;
    // ��ʱ����Ҫע��
    {
    strIp := idpwtchMain.LocalIP;
    GetMem(pRegFile, MAX_PATH);
    GetSystemDirectory(pRegFile, MAX_PATH);
    strRegFile := pRegFile + '\' + REG_FILE;
    if FileExists(strRegFile) then
    begin
        strlistFile := TStringList.Create;
        strlistFile.LoadFromFile(strRegFile);
        strData := EncryStrHex(strIp, '2017RegRToolwi!!');
        for i := 0 to strlistFile.Count - 1 do
        begin
            if strlistFile.Strings[i] = strData then
            begin
                g_bReg := true;
                WriteStatus('��ע��');
                break;
            end;
        end;
        strlistFile.Free;
    end;

    if not g_bReg then
    begin
        strRegKey := EncryStrHex(strIp, 'wi!!RToolKey2017');
        WriteLog('�ͻ���δע��,�뽫ע��Key[' + strRegKey + ']���͸�xWX425108');
        btnReg.Enabled := true;
        WriteStatus('δע��');
    end
    else
    begin
        btnReg.Visible := false;
        lbedRegPassword.Visible := false;
    end;
    }
end;

// ���崴��
procedure TfrmMain.FormCreate(Sender: TObject);
begin
    Application.OnException := AppException;
    
    g_strPath := ExtractFilePath(Application.ExeName);
    WiIniCom.IniFile := g_strPath + CONFIG_PATH + '\' + CONFIG_FILE;
    // ��������
    LoadConfig;
    // ���ؽӿ��ļ���Ŀ¼
    tvMain.Items.Clear;
    FindFileList(nil, g_strPath + INTERFACE_PATH, '*.*');

    g_strVersion := GetFileVer(Application.ExeName);
    lblVer.Caption := lblVer.Caption + ',file version:' + g_strVersion;

    // ��ʱ����Ҫע��
//    g_activeThread := TActiveThread.Create(true);
//    g_activeThread.Resume;

    CheckReg;
end;

// ����rest����
procedure TfrmMain.HitRest(strSrcRestPath: string; strRestParam: string);
var  
    strURL, strAllReqParam, strProtocolType, strResult, strMsg: string;
    streamReq, streamResp: TStringStream;
    json, jsonBody : ISuperObject;
    iter, iterBody: TSuperObjectIter;
    iBegin, iEnd: integer;
    fTime: Extended;
    iTimeVal: double;
    strTimeUnit, strAccessToken, strRestPath: string;
begin
    // ��������
    SaveConfig;
    
    redResp.Text := '';
    
//    if not g_bLogined then
//    begin
//        WriteLog('δ��¼�����ȵ�¼��');
//        Exit;
//    end;

    if not g_bReg then
    begin
        WriteLog('δע�ᣬ����ע�ᣡ');
        Exit;
    end;

    try
        WriteLine;
        idHTTPMain.Request.UserAgent := '';
        idHTTPMain.Request.CustomHeaders.Add('Cookie: ' + g_strCookie);
        if g_strIBHAccessToken <> '' then
        begin
            idHTTPMain.Request.CustomHeaders.Add('Access-Token:' + g_strIBHAccessToken);
        end;
        idHTTPMain.AllowCookies := true;
        idHTTPMain.HandleRedirects := true;
        idHTTPMain.CookieManager := idCookieManager;
        idHTTPMain.ReadTimeout := 180000;

        idHTTPMain.Request.Accept := 'application/json, text/plain, */*';
        idHTTPMain.Request.AcceptEncoding := 'gzip, deflate, br';
        idHTTPMain.Request.AcceptLanguage := 'zh-CN,zh;q=0.8';
        idHTTPMain.Request.CacheControl := 'no-cache';
        idHTTPMain.Request.Connection := 'keep-alive';
        idHTTPMain.Request.ContentType := 'application/ueefire';
        idHTTPMain.Request.ContentType := cmbContentType.Text;

        if rbHttps.Checked then
        begin
            strProtocolType := 'https';
        end
        else
            strProtocolType := 'http';
        strURL := REST_URL;
        strUrl := StringReplace(strUrl, '[%PROTOCOL_TYPE%]', strProtocolType, [rfReplaceAll]);
        // REST_PATH
        strRestPath := Trim(lbedRestPath.Text);
        // �ж��Ƿ�restPath����accessToken
        if (Pos('[%ACCESS_TOKEN%]', strRestPath) > 0) and (g_strAOPENAccessToken <> '') then
        begin
            strRestPath := StringReplace(strRestPath, '[%ACCESS_TOKEN%]', g_strAOPENAccessToken, []);
        end;
        strUrl := StringReplace(strUrl, '[%REST_PATH%]', strRestPath, [rfReplaceAll]);
        iTimeVal := ConvertDelphiDateTimeToJavaDateTime(Now);
        strUrl := StringReplace(strUrl, '[%TIME_VAL%]', FloatToStr(iTimeVal), [rfReplaceAll]);
        strUrl := StringReplace(strUrl, '[%HOST_ADDR%]', lbedHost.Text, [rfReplaceAll]);
        strUrl := StringReplace(strUrl, '[%HOST_PORT%]', lbedPort.Text, [rfReplaceAll]);

        strRestParam := Trim(strRestParam);
        if cmbContentType.ItemIndex = 0 then
        begin
            if (Copy(strRestParam, 1, 1) <> '{') then
            begin
                strRestParam := '{' + strRestParam;
                strRestParam := strRestParam + '}';
            end;
        end;
        
        // ���滥��������model param...����
        if chkBES.Checked then
        begin
            strAllReqParam := REQ_PARAM;
            strAllReqParam := StringReplace(strAllReqParam, '[%REQ_PARAM%]', Trim(strRestParam), [rfReplaceAll]);
        end
        else
            strAllReqParam := strRestParam;

        try
            if cmbContentType.ItemIndex = 0 then
            begin
                json := SO(Trim(strAllReqParam));
                strAllReqParam := json.AsJSon(false, false);
            end;
        except
            on E: Exception do
            begin
                strMsg := 'json��ʽ����:' + strAllReqParam + '����,��ȷ����������Ƿ���ȷ!';
                WriteLog(strMsg);
//                MessageBox(frmMain.Handle, PChar(strMsg), '��ʾ', 64);
                exit;
            end;
        end;
        WriteLog('��ַ:' + strUrl);
        WriteLog('����:' + strRestPath);

        WriteLog('���:');
        WriteLog(strAllReqParam);

        streamReq := TStringStream.Create(strAllReqParam);
        iBegin := GetTickCount;
        streamResp := TStringStream.Create('');
        idHTTPMain.Post(strUrl, streamReq, streamResp);

        strResult := streamResp.DataString;
        strResult := UTF8Decode(HttpDecode(strResult));
        fTime := GetTickCount - iBegin;
        if (fTime >= 1000) then
        begin
            strTimeUnit := '��';
            fTime := fTime / 1000;
        end
        else
            strTimeUnit := '����';
        WriteLog('���ú�ʱ:' + FloatToStr(fTime) + '(' + strTimeUnit + ')');
        streamReq.Free;

        WriteLog('���ý��:');
        json := SO(strResult);
        // IBH token
        if (g_strIBHAccessToken = '') and (ObjectFindFirst(json, iter)) then
        begin
            repeat
                //ShowMessageFmt('%s - %s', [iter.key, iter.val.AsString]);
                if (iter.key = 'body') then
                begin
                    jsonBody := iter.val;
                    if (jsonBody.O['accessToken'] <> nil) then
                    begin
                        strAccessToken := jsonBody.O['accessToken'].AsString;
                        if strAccessToken <> '' then
                        begin
                            g_strIBHAccessToken := strAccessToken;
                            WriteLog('��ȡaccessToken:' + g_strIBHAccessToken);
                        end;
                    end;
                end;
            until not ObjectFindNext(iter);
        end;
        // aopen token
        if (g_strAOPENAccessToken = '') and (ObjectFindFirst(json, iter)) then
        begin
            repeat
                //ShowMessageFmt('%s - %s', [iter.key, iter.val.AsString]);
                if (iter.key = 'access_token') then
                begin
                    g_strAOPENAccessToken := iter.val.AsString;
                    WriteLog('��ȡ�ܿ�ƽ̨access_token:' + g_strAOPENAccessToken);
                end;
            until not ObjectFindNext(iter);
        end;

        ObjectFindClose(iter);

        WriteLog(json.AsString);

        strResult := json.AsJSon(true, false);

        redResp.Text := strResult;
        WriteStatus('������:' + IntToStr(idHttpMain.ResponseCode));

    except
        on e: Exception do
        begin
            WriteLog('����ʧ��:' + e.Message);
        end;
    end;
    WriteLine;
end;

procedure TfrmMain.btnHitClick(Sender: TObject);
begin
    HitRest(lbedRestPath.Text, redReq.Text);
end;

procedure TfrmMain.csMainConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
    g_iConnectRet := 1;
    WriteLine;
    sbMain.Panels.Items[0].Text := '������';
    WriteLog('socket������');
    WriteLine;
end;

function HexToInt(Str1: string): longInt;
var
    i: integer;
begin
    Result := 0;
    for i := 1 to length(Str1) do
    begin
        if (Str1[i] >= '0') and (Str1[i] <= '9') then
            Result := Result * 16 + StrToInt(Str1[i])
        else
        begin
            if (Str1[i] >= 'A') and (Str1[i] <= 'F') then
                result := Result * 16 + ord(Str1[i]) - 55
            else
            begin
                result := 0;
                exit;
            end;
        end;
    end;
end;

//ASCת����unicode
function EncodeUniCode(Str:WideString):string; //�ַ�����>PDU
var
   i, len:Integer;
   cur: Integer;
begin
   Result := '';
   len := Length(Str);
   i := 1;
   while i <= len do
   begin
      cur := ord(Str[i]);
      Result := Result+IntToHex(Cur,4);
      inc(i);
   end;
end;

procedure TfrmMain.csMainRead(Sender: TObject; Socket: TCustomWinSocket);
var
    strRecText: string;
begin
    strRecText := Socket.ReceiveText;
    WriteLine;
    WriteLog('socket���ձ���' + #10#13 + strRecText);
    if (Pos('HTTP/', strRecText) > 0) then
        redResp.Text := strRecText;
    WriteLine;
end;

procedure TfrmMain.csMainDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
    WriteLine;
    WriteLog('socket�Ͽ�����');
    g_iConnectRet := -1;
    WriteLine;
end;

procedure TfrmMain.csMainError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
    WriteLine;
    WriteLog('socket error:' + IntToStr(ErrorCode));
    g_iConnectRet := ErrorCode;
    WriteLine;
end;

function TfrmMain.ConnectHost : integer;
var
    i: integer;
begin
    g_iConnectRet := 0;
    csMain.Active := false;
    csMain.Host := lbedHost.Text;
    csMain.Port := StrToInt(lbedPort.Text);
    csMain.Active := true;
    for i := 0 to 1000 do
    begin
        Application.ProcessMessages;
        Sleep(10);
        Application.ProcessMessages;
        if g_iConnectRet <> 0 then
            break;
    end;
    result := g_iConnectRet;
end;

procedure Post(url, data:string;res:TStream);
var
  hInt,hConn,hreq:HINTERNET;
  buffer:PChar;
  dwRead, dwFlags:cardinal;
  port: Word;
  uri: TIdURI;
  proto, host, path: string;
  var value: DWORD;
begin
  uri := TIdURI.Create(url);
  host := uri.Host;
  path := uri.Path + uri.Document;
  proto := uri.Protocol;
  uri.Free;
  if UpperCase(proto) = 'HTTPS' then
  begin
    port := INTERNET_DEFAULT_HTTPS_PORT;
    dwFlags := INTERNET_FLAG_SECURE;
  end
  else
  begin
    port := INTERNET_INVALID_PORT_NUMBER;
    dwFlags := INTERNET_FLAG_RELOAD;
  end;
  value := SECURITY_FLAG_IGNORE_CERT_CN_INVALID or
        SECURITY_FLAG_IGNORE_CERT_DATE_INVALID or
        SECURITY_FLAG_IGNORE_UNKNOWN_CA;

  hInt := InternetOpen('Delphi',INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  hConn := InternetConnect(hInt,PChar(host),port,nil,nil,INTERNET_SERVICE_HTTP,0,0);
  hreq := HttpOpenRequest(hConn,'POST',PChar(Path),'HTTP/1.1',nil,nil,dwFlags,0);
  GetMem(buffer, 65536);
  if HttpSendRequest(hReq,nil,0,PChar(data),Length(data)) then
  begin
    dwRead:=0;
    repeat
      InternetReadFile(hreq,buffer,65536,dwRead);
      if dwRead<>0 then
        res.Write(buffer^, dwRead);
    until dwRead=0;
  end;
 InternetCloseHandle(hreq);
 InternetCloseHandle(hConn);
 InternetCloseHandle(hInt);
 FreeMem(buffer);
end;

procedure TfrmMain.btnLoginClick(Sender: TObject);
const
    LOGIN_PARAM = '{"loginid":"[%LOGIN_ID%]","password":"[%LOGIN_PASSWORD%]"}';    
var
    strUrl, strResult, strLoginParam, strParam, strProtocolType: string;
    i: integer;
    iTimeVal: double;
    streamReq, streamResp: TStringStream;
begin
    btnLogin.Enabled := false;
    try
        // ��������
        SaveConfig;
        
        WriteLine;

        if rbHttps.Checked then
        begin
            strProtocolType := 'https';
        end
        else
            strProtocolType := 'http';

        idHTTPMain.Request.UserAgent := '';
        // ����cookie��Ϣ
        idHTTPMain.Request.Accept := 'application/json, text/plain, */*';
        idHTTPMain.Request.AcceptEncoding := 'gzip, deflate, br';
        idHTTPMain.Request.AcceptLanguage := 'zh-CN,zh;q=0.8';
        idHTTPMain.Request.CacheControl := 'no-cache';
        idHTTPMain.Request.Connection := 'keep-alive';
        idHTTPMain.Request.ContentType := 'application/ueefire';
        idHTTPMain.Request.Host := lbedHost.Text;
        idHTTPMain.Request.Pragma := 'no-cache';
        idHTTPMain.Request.Referer := 'https://' + lbedHost.Text + '/gdbes/sm/login/mylogin.html';
        idHTTPMain.ReadTimeout := 5000;

        strUrl := REST_URL;
        strUrl := StringReplace(strUrl, '[%PROTOCOL_TYPE%]', strProtocolType, [rfReplaceAll]);
        strUrl := StringReplace(strUrl, '[%REST_PATH%]', lbedLoginUrl.Text, [rfReplaceAll]);
        iTimeVal := ConvertDelphiDateTimeToJavaDateTime(Now);
        strUrl := StringReplace(strUrl, '[%TIME_VAL%]', FloatToStr(iTimeVal), [rfReplaceAll]);
        strUrl := StringReplace(strUrl, '[%HOST_ADDR%]', lbedHost.Text, [rfReplaceAll]);
        strUrl := StringReplace(strUrl, '[%HOST_PORT%]', lbedPort.Text, [rfReplaceAll]);
        IF (lbedPort.Text = '80') then
        begin
            strUrl := StringReplace(strUrl, ':80/', '/', [rfReplaceAll]);
        end;

        strLoginParam := LOGIN_PARAM;
        strLoginParam := StringReplace(strLoginParam, '[%LOGIN_ID%]', lbedLoginId.Text, [rfReplaceAll]);
        strLoginParam := StringReplace(strLoginParam, '[%LOGIN_PASSWORD%]', lbedPassword.Text, [rfReplaceAll]);
        strParam := REQ_PARAM;
        strParam := StringReplace(strParam, '[%REQ_PARAM%]', strLoginParam, [rfReplaceAll]);
        WriteLog('��¼��ַ:' + strUrl);
        WriteLog('��¼���:' + strParam);
        streamReq := TStringStream.Create(strParam);
        strResult := idHTTPMain.Post(strUrl, streamReq);

        strResult := UTF8Decode(HttpDecode(strResult));
        streamReq.Free;

        for i := 0 to idCookieManager.CookieCollection.Count - 1 do
        begin
            g_strCookie := g_strCookie + idCookieManager.CookieCollection.Cookies[i].CookieName + '=' + idCookieManager.CookieCollection.Cookies[i].Value;
            if (i <> idCookieManager.CookieCollection.Count - 1) then
            begin
                g_strCookie := g_strCookie + '; ';
            end;
        end;
        //WriteLog(g_strCookie);
        WriteLine;
        WriteLog('��¼���:' + strResult);
        if (LOGIN_SUCCESS_INFO = strResult) then
        begin
            btnLogOut.Enabled := true;
            btnHit.Enabled := true;
            g_bLogined := true;
        end
        else
        begin
            btnLogin.Enabled := true;
        end;

        // doReg;
    except
        on e: Exception do
        begin
            WriteLog('��¼����:' + e.Message);
            btnLogin.Enabled := true;
        end;
    end;
    WriteLine;

end;

procedure TfrmMain.tvMainExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var
    pTreeData: PTreeFileData;
begin
    pTreeData := PTreeFileData(Node.Data);
    if Node.HasChildren then
    begin
        Node.DeleteChildren;
    end;
    FindFileList(Node, pTreeData.filePath, '*.*');
end;

procedure TfrmMain.tvMainDblClick(Sender: TObject);
var
    pTreeData: PTreeFileData;
    strVersion, strRestPath, strRestParam: string;
    pTreeNode: TTreeNode;
begin
    pTreeNode := tvMain.Selected;
    if not Assigned(pTreeNode) then
        exit;

    pTreeData := PTreeFileData(pTreeNode.Data);

    if pTreeData.fileType <> FILE_TYPE_FILE then
        Exit;

    if not (FileExists(pTreeData.filePath)) then
        Exit;

    strVersion := pTreeData.fileVersion;
    strRestPath := pTreeData.restPath;
    strRestParam := pTreeData.restParam;

    if ((Trim(strRestPath) = '') or (Trim(strRestParam) = '')) then
        Exit;

    HitRest(strRestPath, strRestParam);
end;

procedure TfrmMain.tvMainClick(Sender: TObject);
var
    pTreeData: PTreeFileData;
    strVersion, strRestPath, strRestParam: string;
    pTreeNode: TTreeNode;
    strlistText: TStringList;
begin
    pTreeNode := tvMain.Selected;
    if not Assigned(pTreeNode) then
        exit;

    pTreeData := PTreeFileData(pTreeNode.Data);

    if pTreeData.fileType <> FILE_TYPE_FILE then
        Exit;

    if not (FileExists(pTreeData.filePath)) then
        Exit;
    strlistText := TStringList.Create;
    strlistText.LoadFromFile(pTreeData.filePath);
    strVersion := GetConfigValue(strlistText.Text, 'FILE_VERSON');
    strRestPath := GetConfigValue(strlistText.Text, 'REST_PATH');
    strRestParam := GetConfigValue(strlistText.Text, 'REST_PARAM');
    strlistText.Free;
    strlistText := nil;

    lbedRestPath.Text := strRestPath;
    redReq.Text := strRestParam;

    pTreeData.fileVersion := strVersion;
    pTreeData.restPath := strRestPath;
    pTreeData.restParam := strRestParam;

    pTreeNode.Data := pTreeData;
end;

procedure TfrmMain.csActiveConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
    WriteLine;
    sbMain.Panels.Items[0].Text := '�����ӷ�����';
    WriteLog('�����ӷ�����');
    WriteLine;
end;

procedure TfrmMain.csActiveDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
    WriteLine;
    //WriteLog('ͬ�������Ͽ����ӣ����˳��������µ�¼��');
    WriteLog('ע��������ر�');
    WriteLine;
//    btnLogin.Enabled := true;
//    btnLogOut.Enabled := false;
//    g_bLogined := false;
//    g_bReg := false;
end;

procedure TfrmMain.csActiveError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
    WriteLine;
    WriteLog('ע�������socket error:' + IntToStr(ErrorCode));
    ErrorCode := 0;
    WriteLine;
end;

procedure TfrmMain.csActiveRead(Sender: TObject; Socket: TCustomWinSocket);
//var
//    strRecText: string;
begin
    {
    if Socket.RemoteAddress <> '10.40.16.193' then
    begin
        Exit;
    end;

    strRecText := Socket.ReceiveText;
    if ('ok' = strRecText) then
    begin
        g_bReg := true;
        WriteLog('�û�У��ɹ�');
    end
    else
    begin
        g_bReg := false;
        WriteLog(strRecText);
    end;
    }
end;

procedure TfrmMain.N1Click(Sender: TObject);
var
    pTreeNode: TTreeNode;
    pTreeData: PTreeFileData;
begin
    pTreeNode := tvMain.Selected;
    if not Assigned(pTreeNode) then
    begin
        MessageBox(Handle, '��ѡ���Ӧ�ķ����ļ���', '��ʾ', 64);
        exit;
    end;
//    pTreeData := PTreeFileData(pTreeNode.Data);
//    if pTreeData.fileType = FILE_TYPE_FILE then
//        HitRest(pTreeData.restPath, pTreeData.restParam);
    HitRest(lbedRestPath.Text, redReq.Text);
end;

// ˢ���б�
procedure TfrmMain.N3Click(Sender: TObject);
begin
    // ˢ���ļ��б�
    RefreshFileList;
end;

// �����쳣
procedure TfrmMain.AppException (Sender: TObject; E: Exception);
begin
    WriteLog('�����쳣[' + E.Message + ']');
end;

procedure TfrmMain.N5Click(Sender: TObject);
begin
    AddDir;
end;

procedure TfrmMain.N10Click(Sender: TObject);
begin
    AddRootDir;
end;

procedure TfrmMain.N6Click(Sender: TObject);
begin
    AddFile;
end;

procedure TfrmMain.N9Click(Sender: TObject);
begin
    DelFile;
end;

// �޸��ļ�
procedure TfrmMain.N7Click(Sender: TObject);
begin
    ModifyFile;
end;

// ����Ŀ¼
procedure TfrmMain.AddDir;
var
    pTreeNode: TTreeNode;
    pTreeData: PTreeFileData;
    strDir: string;
begin
    pTreeNode := tvMain.Selected;
    if not Assigned(pTreeNode) then
    begin
        exit;
    end;

    pTreeData := PTreeFileData(pTreeNode.Data);
    if pTreeData.fileType <> FILE_TYPE_DIR then
    begin
        MessageBox(Handle, '��ѡ���Ӧ���ϲ�Ŀ¼', '��ʾ', 64);
        exit;
    end;
    
    strDir := InputBox('������Ŀ¼����', 'Ŀ¼����:', '');
    if Trim(strDir) <> '' then
    begin
        strDir := pTreeData.filePath + '\' + strDir;
        if DirectoryExists(strDir) then
        begin
            MessageBox(Handle, PChar('Ŀ¼[' + strDir + ']�Ѵ���!'), '��ʾ', 64);
            exit;
        end;
        CreateDir(strDir);
        N3.Click;
    end;
end;

// ���Ӹ�Ŀ¼
procedure TfrmMain.AddRootDir;
var
    strDir: string;
begin
    strDir := InputBox('������Ŀ¼����', 'Ŀ¼����:', '');
    if Trim(strDir) <> '' then
    begin
        strDir := g_strPath + INTERFACE_PATH + '\' + strDir;
        if DirectoryExists(strDir) then
        begin
            MessageBox(Handle, PChar('Ŀ¼[' + strDir + ']�Ѵ���!'), '��ʾ', 64);
            exit;
        end;
        CreateDir(strDir);
        // ˢ���ļ��б�
        RefreshFileList;
    end;
end;

// �����ļ�
procedure TfrmMain.AddFile;
var
    frmRest: TfrmRest;
    pTreeNode: TTreeNode;
    pTreeData: PTreeFileData;
    strDir, strContent: string;
    strlistFile: TStringList;
begin
    pTreeNode := tvMain.Selected;
    if not Assigned(pTreeNode) then
    begin
        exit;
    end;

    pTreeData := PTreeFileData(pTreeNode.Data);
    if (pTreeData.fileType <> FILE_TYPE_DIR) then
    begin
        MessageBox(Handle, '��ѡ�������ļ���Ŀ¼!', '��ʾ', 64);
        exit;
    end;

    frmRest := TfrmRest.Create(Application);
    frmRest.g_operType := TOperType(OPER_TYPE_ADD);
    frmRest.g_strFilePath := pTreeData.filePath;
    frmRest.ShowModal;
    if frmRest.g_bResult then
    begin
        strlistFile := TStringList.Create;
        strContent := REST_FILE_FMT;
        strContent := StringReplace(strContent, '[%VERSION%]', g_strVersion, [rfReplaceAll]);
        strContent := StringReplace(strContent, '[%REST_PATH%]', frmRest.g_strRestPath, [rfReplaceAll]);
        strContent := StringReplace(strContent, '[%REST_PARAM%]', frmRest.g_strRestParam, [rfReplaceAll]);
        strlistFile.Text := strContent;
        strlistFile.SaveToFile(frmRest.g_strFilePath);
        strlistFile.Free;
        // ˢ���ļ��б�
        RefreshFileList;
    end;
    frmRest.Free;
end;

// �޸��ļ�
procedure TfrmMain.ModifyFile;
var
    frmRest: TfrmRest;
    pTreeNode: TTreeNode;
    pTreeData: PTreeFileData;
    strFileName, strContent: string;
    strlistFile: TStringList;
begin
    pTreeNode := tvMain.Selected;
    if not Assigned(pTreeNode) then
    begin
        exit;
    end;

    pTreeData := PTreeFileData(pTreeNode.Data);
    if (pTreeData.fileType <> FILE_TYPE_FILE) then
    begin
        MessageBox(Handle, '��ѡ��Ҫ�޸ĵ��ļ�!', '��ʾ', 64);
        exit;
    end;

    frmRest := TfrmRest.Create(Application);
    frmRest.g_operType := TOperType(OPER_TYPE_MODIFY);
    frmRest.g_strFilePath := ExtractFileDir(pTreeData.filePath);
    frmRest.lbedRestPath.Text := pTreeData.restPath;
    strFileName := ExtractFileName(pTreeData.filePath);
    frmRest.lbedRestName.Text := Copy(strFileName, 0, Length(strFileName) - Length(ExtractFileExt(strFileName)));
    frmRest.redtReq.Text := pTreeData.restParam;
    frmRest.ShowModal;
    if frmRest.g_bResult then
    begin
        // �����ļ�
        SaveFile(frmRest.g_strFilePath, frmRest.g_strRestPath, frmRest.g_strRestParam);
        // �ļ����޸�
        if ExtractFileName(frmRest.g_strFilePath) <> ExtractFileName(pTreeData.filePath) then
            DeleteFile(pTreeData.filePath);
        // ˢ���ļ��б�
        RefreshFileList;
    end;
    frmRest.Free;
end;

// �����ļ�
procedure TfrmMain.SaveFile(strFileName: string; strRestPath: string; strRestParam: string);
var
    strlistFile: TStringList;
    strContent: string;
begin
    strlistFile := TStringList.Create;
    strContent := REST_FILE_FMT;
    strContent := StringReplace(strContent, '[%VERSION%]', g_strVersion, [rfReplaceAll]);
    strContent := StringReplace(strContent, '[%REST_PATH%]', strRestPath, [rfReplaceAll]);
    strContent := StringReplace(strContent, '[%REST_PARAM%]', strRestParam, [rfReplaceAll]);
    strlistFile.Text := strContent;
    strlistFile.SaveToFile(strFileName);
    strlistFile.Free;
    
    WriteLog('�����ļ�[' + strFileName + ']�ɹ�');
end;


// ɾ��Ŀ¼
function TfrmMain.DelDir(const strDirName : string) : boolean;
var
	rs : TSearchRec;
	strPath : string;
begin
	result := true;
	try
        Application.ProcessMessages;
		strPath := strDirName;
		if strPath[Length(strPath)] <> '\' then
        begin
			strPath := strPath + '\';
        end;
		if FindFirst(strPath + '*.*', faAnyFile, rs) = 0 then
		begin
			repeat
                Application.ProcessMessages;
				if (rs.name = '.')or(rs.name = '..') then
                begin
					continue;
                end;
				if rs.attr or fadirectory = fadirectory then
				begin
					// �ȵݹ�������Ŀ¼ɾ��������ļ�,������findfirst��  findclose
					if DelDir(strPath + rs.name) then
                    begin
                        // �˳��ݹ����ɾ��Ŀ¼
                        WriteLog('����ɾ��Ŀ¼[' + strPath + rs.name + '].....');
						RMDir(strPath + rs.name);
                    end;
                end
                else
                begin
                    WriteLog('����ɾ���ļ�[' + strPath + rs.name + '].....');
                    DeleteFile(strPath + rs.name);
                end;
			until FindNext(rs)<>0;
		end;
		// �ر�
		FindClose(rs);
	except
        on e : Exception do
        begin
            WriteLog('ɾ���ļ�Ŀ¼ʧ��[' + e.Message + '].');
        end;
	end;
end;

// ɾ���ļ�
procedure TfrmMain.DelFile;
var
    pTreeNode: TTreeNode;
    pTreeData: PTreeFileData;
begin
    pTreeNode := tvMain.Selected;
    if not Assigned(pTreeNode) then
    begin
        exit;
    end;

    pTreeData := PTreeFileData(pTreeNode.Data);
    if (pTreeData.fileType = FILE_TYPE_FILE) then
    begin
        if FileExists(pTreeData.filePath) then
        begin
            DeleteFile(pTreeData.filePath);
        end;
    end
    else if (pTreeData.fileType = FILE_TYPE_DIR) then
    begin
        DelDir(pTreeData.filePath);
        RmDir(pTreeData.filePath);
    end;

    RefreshFileList;
end;

// ˢ���ļ��б�
procedure TfrmMain.RefreshFileList;
begin
    // ���ؽӿ��ļ���Ŀ¼
    tvMain.Items.Clear;
    FindFileList(nil, g_strPath + INTERFACE_PATH, '*.*');
end;

procedure TfrmMain.btnRegClick(Sender: TObject);
var
    strIp, strData, strRegIp, strRegFile: string;
    strlistFile: TStringList;
    pRegFile: PChar;
begin
    strIp := idpwtchMain.LocalIP;
    GetMem(pRegFile, MAX_PATH);
    GetSystemDirectory(pRegFile, MAX_PATH);

    strData := InputBox('ע����', '������ע����:', '');
    try
        strRegIp := DecryStrHex(strData, '2017RegRToolwi!!');
    except
        on e: Exception do
        begin
            MessageBox(Handle, 'ע����Ϣϵ����!', '��ʾ', 64);
            exit;
        end;
    end;
    
    if strIp <> strRegIp then
    begin
        MessageBox(Handle, 'ע����Ϣϵ����!', '��ʾ', 64);
        exit;
    end;

    strRegFile := pRegFile + '\' + REG_FILE;
    strlistFile := TStringList.Create;
    strlistFile.Text := strData; 
    strlistFile.SaveToFile(strRegFile);
    strlistFile.Free;
    
    WriteStatus('ע��ɹ�');
    g_bReg := true;
    btnReg.Enabled := false;
end;

procedure TfrmMain.Panel5DblClick(Sender: TObject);
var
    frmInfo: TfrmInfo;
begin
    frmInfo := TfrmInfo.Create(Application);
    frmInfo.redtInfo.Text := redResp.Text;
    frmInfo.ShowModal;
    frmInfo.Free;
end;

procedure TfrmMain.btnLogoutClick(Sender: TObject);
var
    strRestPath, strRestParam: string;
begin
    lbedRestPath.Text := 'soService/quit';
    redReq.Text := '"req":{}';
    HitRest(lbedRestPath.Text, redReq.Text);
    btnLogin.Enabled := True;
    btnLogout.Enabled := false;
end;

procedure TfrmMain.btnConfigServerClick(Sender: TObject);
var
    frmConfigServer: TfrmConfigServer;
begin
    frmConfigServer := TfrmConfigServer.Create(Application);
    frmConfigServer.g_strConfigFileName := g_strPath + CONFIG_PATH + '\' + SERVER_CONFIG_FILE;
    frmConfigServer.mmoServer.Text := cmbServer.Items.Text;
    frmConfigServer.ShowModal;
    if frmConfigServer.g_bSave then
    begin
        cmbServer.Items.Text := frmConfigServer.mmoServer.Text;
        if cmbServer.Items.Count > 0 then
        begin
            cmbServer.ItemIndex := 0;
            cmbServer.OnChange(nil);
        end;
    end;
    frmConfigServer.Free;
end;

procedure TfrmMain.cmbServerChange(Sender: TObject);
var
    strConfig, strServerAddr, strPort: string;
    iPort: integer;
begin
    strConfig := Trim(cmbServer.Text);
    if Pos(':', strConfig) < 0 then
    begin
        MessageBox(Handle, '��������', '��ʾ', 64);
        Exit;
    end;
    strServerAddr := Copy(strConfig, 0, Pos(':', strConfig) - 1);
    if Trim(strServerAddr) = '' then
    begin
        MessageBox(Handle, '��������', '��ʾ', 64);
        Exit;
    end;

    strPort := Copy(strConfig, Pos(':', strConfig) + 1, Length(strConfig));
    if not TryStrToInt(strPort, iPort) then
    begin
        MessageBox(Handle, '��������', '��ʾ', 64);
        Exit;
    end;
    lbedHost.Text := strServerAddr;
    lbedPort.Text := strPort;
end;

procedure TfrmMain.HttpPost(url, data, Len, Auth: string; res: TStream);
var
  hInt, hConn, hreq: HINTERNET;
  buffer: PChar;
  dwRead, dwFlags: cardinal;
  port: Word;
  uri: TIdURI;
  proto, host, path: string;
  header:string;
begin
  uri := TIdURI.Create(url);
  host := uri.Host;
  path := uri.Path + uri.Document + uri.Params;
  proto := uri.Protocol;
  uri.Free;
  if UpperCase(proto) = 'HTTPS' then
  begin
    port := INTERNET_DEFAULT_HTTPS_PORT;
    dwFlags := INTERNET_FLAG_SECURE;
  end
  else
  begin
    port := INTERNET_INVALID_PORT_NUMBER;
    dwFlags := INTERNET_FLAG_RELOAD;
  end;
  hInt := InternetOpen('Delphi', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  hConn := InternetConnect(hInt, PChar(host), 8883, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
  hreq := HttpOpenRequest(hConn, 'POST', PChar(Path), 'HTTP/1.1', nil, nil, dwFlags, 0);
  GetMem(buffer, 65536);
  header:='Content-Length:'+len+
    #13'Accept:application/json'+
    #13'Content-Type:application/json'+
    #13'Authorization:'+auth;
  if HttpSendRequest(hReq, PAnsiChar(header), Length(header), PChar(data), Length(data)) then
  begin
    dwRead := 0;
    repeat
      InternetReadFile(hreq, buffer, 65536, dwRead);
      if dwRead <> 0 then
        res.Write(buffer^, dwRead);
    until dwRead = 0;
  end;
  InternetCloseHandle(hreq);
  InternetCloseHandle(hConn);
  InternetCloseHandle(hInt);
  FreeMem(buffer);
end;

procedure TfrmMain.N12Click(Sender: TObject);
begin
    // ���÷���
    HitRest(lbedRestPath.Text, redReq.Text);
end;

procedure TfrmMain.N14Click(Sender: TObject);
var
    pTreeNode: TTreeNode;
    pTreeData: PTreeFileData;
begin
    pTreeNode := tvMain.Selected;
    if not Assigned(pTreeNode) then
    begin
        MessageBox(Handle, '��ѡ�����Ķ�Ӧ�ӿڱ��ģ�', '��ʾ', 64);
        exit;
    end;
    //redReq.Text := FormatJson(redReq.Text, true);
    pTreeData := PTreeFileData(pTreeNode.Data);
    // �����ļ�
    SaveFile(pTreeData.filePath, lbedRestPath.Text, redReq.Text);
end;

procedure TfrmMain.btnCleanClick(Sender: TObject);
begin
    mmoLog.Lines.Clear;    
end;

procedure TfrmMain.chkBESClick(Sender: TObject);
begin
end;

{**************************************************************************
  ���ƣ�   BaseImage
  ������   fn: TFilename
  ����ֵ�� string
  ���ܣ�   ��fn�ļ�ת����Base64���룬����ֵΪ����
 **************************************************************************}
function BaseImage(fn: string): string;
var
    m1: TMemoryStream;
    m2: TStringStream;
    str: string;
begin
    m1 := TMemoryStream.Create;
    m2 := TStringStream.Create('');
    m1.LoadFromFile(fn);
    EncdDecd.EncodeStream(m1, m2);                       // ��m1������Base64��m2��
    str := m2.DataString;
    str := StringReplace(str, #13, '', [rfReplaceAll]);  // ����m2�����ݻ��Զ���ӻس����У�������Ҫ���س������滻�ɿ��ַ�
    str := StringReplace(str, #10, '', [rfReplaceAll]);
    result := str;                                       // ����ֵΪBase64��Stream
    m1.Free;
    m2.Free;
end;

procedure TfrmMain.btnToBase64Click(Sender: TObject);
var
    m1: TMemoryStream;    // base64��ͼƬ
    m2: TStringStream;    // ѹ��֮���ͼƬ
    jpg: TJpegImage;      // jpgԭͼ
    bmp: TBitmap;         // bmpѹ��ת��
    strResult: string;
begin
    if not odPic.Execute then
        Exit;

    WriteLog('תbase64���:' + #13#10 + BaseImage(odPic.FileName));
//
//    jpg := TJpegImage.Create;
//    bmp := TBitmap.Create;
//    m1 := TMemoryStream.Create;
//    m2 := TStringStream.Create('');
//    jpg.LoadFromFile(odPic.FileName);
//    bmp.Width := jpg.Width div 2;
//    bmp.Height := jpg.Height div 2;
//    bmp.Canvas.StretchDraw(bmp.Canvas.ClipRect, jpg);
//    jpg.Assign(bmp);
//    jpg.Compress;
//    jpg.CompressionQuality := 70;
//    jpg.SaveToStream(m1);
//    m1.Position := 0;               // һ��Ҫ��ԭָ�룬����base64
//    EncdDecd.EncodeStream(m1, m2);
//    strResult := m2.DataString;
//    strResult := StringReplace(strResult, #13, '', [rfReplaceAll]);
//    strResult := StringReplace(strResult, #10, '', [rfReplaceAll]);
//    WriteLog('base64:' + strResult);
//    //m2.SaveToFile();
//    m1.SaveToFile('d:/base64-01.txt');
//    bmp.Free;
//    jpg.Free;
//    m1.Free;
//    m2.Free;

end;

// ��ʽ��json
function TfrmMain.FormatJson(strText: string; isExpand: boolean) : string;
var
    json : ISuperObject;
begin
    json := SO(Trim(strText));
    result := json.AsJSon(isExpand, false);
end;

procedure TfrmMain.N16Click(Sender: TObject);
begin
    redReq.Text := FormatJson(redReq.Text, true);
end;

end.

