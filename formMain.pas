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
    // REST请求地址
    //REST_URL = '[%PROTOCOL_TYPE%]://[%HOST_ADDR%]:[%HOST_PORT%]/[%REST_PATH%]?t=[%TIME_VAL%]';
    REST_URL = '[%PROTOCOL_TYPE%]://[%HOST_ADDR%]:[%HOST_PORT%]/[%REST_PATH%]';

    // 请求报文
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

    // 请求入参
    REQ_PARAM = '{"model":null,"params":[%REQ_PARAM%]}';

    // 登录成功标示
    LOGIN_SUCCESS_INFO = '"successLogin!"';

    // COOKIE信息
//    COOKIE_INFO = 'Cookie: bes_login_sid=ZJDS001-e255472bc30e4eccabcc204a89ae3323; access_time_cookie=1504839128732; bes-site-param=%' + #13#10 +
//    '7B%22siteVersion%22%3A%22c10%22%2C%22skinPath%22%3A%22default%22%7D; com.huawei.boss.CURRENT_MENUID=360view;' + #13#10 +
//    'com.huawei.boss.CURRENT_USER=13729009520; u-locale=zh_CN';

    COOKIE_INFO = 'bes_login_sid=ZJDS001-8f10e8f97ec44d0791d6eeb0fda129e8; ' + #13#10 +
    'access_time_cookie=1511235703916; bes-site-param=%7B%22siteVersion%22%3A%22c10%22%2C%22skinPath%22%3A%22default%22%7D; ' + #13#10 +
    'com.huawei.boss.CURRENT_MENUID=root_workbeach; com.huawei.gdbes.CURRENT_MENUID=root_workbeach; u-locale=zh_CN';

    // 配置文件路径
    CONFIG_PATH = 'config';
    // 配置文件
    CONFIG_FILE = 'config.ini';
    // 服务器列表
    SERVER_CONFIG_FILE = 'server_list.txt';

    // 接口文件路径
    INTERFACE_PATH = 'interface';

    // 文件类型
    FILE_TYPE_TEMP = 0;
    FILE_TYPE_DIR = 1;
    FILE_TYPE_FILE = 2;

    // REST文件格式
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
    // 加载配置文件
    procedure LoadConfig;
    // 保存配置文件
    procedure SaveConfig;
    // 获取文件列表
    procedure FindFileList(pParentNode: TTreeNode; strPath: string; strFileAttr: string);
    // 调用rest服务
    procedure HitRest(strSrcRestPath: string; strRestParam: string);
    // 程序异常
    procedure AppException (Sender: TObject; E: Exception);
    // 增加目录
    procedure AddDir;
    // 增加根目录
    procedure AddRootDir;
    // 增加文件
    procedure AddFile;
    // 修改文件
    procedure ModifyFile;
    // 保存文件
    procedure SaveFile(strFileName: string; strRestPath: string; strRestParam: string);
    // 删除文件
    procedure DelFile;
    // 刷新文件列表
    procedure RefreshFileList;
    // 删除目录
    function DelDir(const strDirName : string) : boolean;
    procedure CheckReg;
    procedure HttpPost(url, data, Len, Auth: string; res: TStream);
    // 格式化json
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

// 根据开始和结束符取得中间字符串
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

// 获取配置值
function GetConfigValue(const strSrc : string; strConfigName: string): string;
begin
    result := CenterStr(strSrc, '<' + strConfigName + '>', '</' + strConfigName + '>'); 
end;

{新建一个TXT文档}
Procedure NewTxt(FileName:String);
Var
    F : Textfile; {定义 F 为 Textfile}
Begin
    AssignFile(F,FileName); {将文件名与变量 F 关联}
    ReWrite(F); {创建Txt文档并命名为 “FileName ” }
    Closefile(F); {关闭文件 F}
End;

{先附上原内容在写入新内容}
Procedure AppendTxt(Str:String;FileName:String);
Var
    F:Textfile;
Begin
    AssignFile(F, FileName);
    Append(F); {附上原来的内容以免原内容被清空}
    Writeln(F, Str); {把内容 Ser 写入文件F }
    Closefile(F);
End;

// 记录日志
procedure WriteTxtLog(const strFileName, strContent: string);
var
    strDir: string;
begin
    try
        if (Trim(strFileName) = '') then
            exit;
        strDir := ExtractFileDir(strFileName);
        // 如果文件夹不存在，则创建
        if (not DirectoryExists(strDir)) then
        begin
            ForceDirectories(strDir);
            Application.ProcessMessages;
            Sleep(100);
            Application.ProcessMessages;
        end;
            
        // 如果文件不存在，则创建
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

// 打印日志
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
                    WriteLog('连接服务器注册成功');
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


//将Java中的日期转换为Delphi中的日期
function ConvertJavaDateTimeToDelphiDateTime(Value: Int64): TDateTime;
begin
   Result := IncMilliSecond(StrToDate('1970-01-01'), Value);
end;

//将Delphi中的日期转换为Java中的日期
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

//取本机的计算机名
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

//取Windows登录用户名
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

//取得文件版本
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

// 加载配置文件
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

// 保存配置文件
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

// 获取文件列表
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
            // 目录处理
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
            // 文件处理
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
    // 暂时不需要注册
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
                WriteStatus('已注册');
                break;
            end;
        end;
        strlistFile.Free;
    end;

    if not g_bReg then
    begin
        strRegKey := EncryStrHex(strIp, 'wi!!RToolKey2017');
        WriteLog('客户端未注册,请将注册Key[' + strRegKey + ']发送给xWX425108');
        btnReg.Enabled := true;
        WriteStatus('未注册');
    end
    else
    begin
        btnReg.Visible := false;
        lbedRegPassword.Visible := false;
    end;
    }
end;

// 窗体创建
procedure TfrmMain.FormCreate(Sender: TObject);
begin
    Application.OnException := AppException;
    
    g_strPath := ExtractFilePath(Application.ExeName);
    WiIniCom.IniFile := g_strPath + CONFIG_PATH + '\' + CONFIG_FILE;
    // 加载配置
    LoadConfig;
    // 加载接口文件和目录
    tvMain.Items.Clear;
    FindFileList(nil, g_strPath + INTERFACE_PATH, '*.*');

    g_strVersion := GetFileVer(Application.ExeName);
    lblVer.Caption := lblVer.Caption + ',file version:' + g_strVersion;

    // 暂时不需要注册
//    g_activeThread := TActiveThread.Create(true);
//    g_activeThread.Resume;

    CheckReg;
end;

// 调用rest服务
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
    // 保存配置
    SaveConfig;
    
    redResp.Text := '';
    
//    if not g_bLogined then
//    begin
//        WriteLog('未登录，请先登录！');
//        Exit;
//    end;

    if not g_bReg then
    begin
        WriteLog('未注册，请先注册！');
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
        // 判断是否restPath中有accessToken
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
        
        // 界面互联网增加model param...参数
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
                strMsg := 'json格式报文:' + strAllReqParam + '错误,请确认输入参数是否正确!';
                WriteLog(strMsg);
//                MessageBox(frmMain.Handle, PChar(strMsg), '提示', 64);
                exit;
            end;
        end;
        WriteLog('地址:' + strUrl);
        WriteLog('服务:' + strRestPath);

        WriteLog('入参:');
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
            strTimeUnit := '秒';
            fTime := fTime / 1000;
        end
        else
            strTimeUnit := '毫秒';
        WriteLog('调用耗时:' + FloatToStr(fTime) + '(' + strTimeUnit + ')');
        streamReq.Free;

        WriteLog('调用结果:');
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
                            WriteLog('获取accessToken:' + g_strIBHAccessToken);
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
                    WriteLog('获取能开平台access_token:' + g_strAOPENAccessToken);
                end;
            until not ObjectFindNext(iter);
        end;

        ObjectFindClose(iter);

        WriteLog(json.AsString);

        strResult := json.AsJSon(true, false);

        redResp.Text := strResult;
        WriteStatus('返回码:' + IntToStr(idHttpMain.ResponseCode));

    except
        on e: Exception do
        begin
            WriteLog('调用失败:' + e.Message);
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
    sbMain.Panels.Items[0].Text := '已连接';
    WriteLog('socket已连接');
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

//ASC转换成unicode
function EncodeUniCode(Str:WideString):string; //字符串－>PDU
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
    WriteLog('socket接收报文' + #10#13 + strRecText);
    if (Pos('HTTP/', strRecText) > 0) then
        redResp.Text := strRecText;
    WriteLine;
end;

procedure TfrmMain.csMainDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
    WriteLine;
    WriteLog('socket断开连接');
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
        // 保存配置
        SaveConfig;
        
        WriteLine;

        if rbHttps.Checked then
        begin
            strProtocolType := 'https';
        end
        else
            strProtocolType := 'http';

        idHTTPMain.Request.UserAgent := '';
        // 设置cookie信息
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
        WriteLog('登录地址:' + strUrl);
        WriteLog('登录入参:' + strParam);
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
        WriteLog('登录结果:' + strResult);
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
            WriteLog('登录出错:' + e.Message);
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
    sbMain.Panels.Items[0].Text := '已连接服务器';
    WriteLog('已连接服务器');
    WriteLine;
end;

procedure TfrmMain.csActiveDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
    WriteLine;
    //WriteLog('同服务器断开连接，请退出程序，重新登录。');
    WriteLog('注册服务器关闭');
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
    WriteLog('注册服务器socket error:' + IntToStr(ErrorCode));
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
        WriteLog('用户校验成功');
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
        MessageBox(Handle, '请选择对应的服务文件！', '提示', 64);
        exit;
    end;
//    pTreeData := PTreeFileData(pTreeNode.Data);
//    if pTreeData.fileType = FILE_TYPE_FILE then
//        HitRest(pTreeData.restPath, pTreeData.restParam);
    HitRest(lbedRestPath.Text, redReq.Text);
end;

// 刷新列表
procedure TfrmMain.N3Click(Sender: TObject);
begin
    // 刷新文件列表
    RefreshFileList;
end;

// 程序异常
procedure TfrmMain.AppException (Sender: TObject; E: Exception);
begin
    WriteLog('程序异常[' + E.Message + ']');
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

// 修改文件
procedure TfrmMain.N7Click(Sender: TObject);
begin
    ModifyFile;
end;

// 增加目录
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
        MessageBox(Handle, '请选择对应的上层目录', '提示', 64);
        exit;
    end;
    
    strDir := InputBox('请输入目录名称', '目录名称:', '');
    if Trim(strDir) <> '' then
    begin
        strDir := pTreeData.filePath + '\' + strDir;
        if DirectoryExists(strDir) then
        begin
            MessageBox(Handle, PChar('目录[' + strDir + ']已存在!'), '提示', 64);
            exit;
        end;
        CreateDir(strDir);
        N3.Click;
    end;
end;

// 增加根目录
procedure TfrmMain.AddRootDir;
var
    strDir: string;
begin
    strDir := InputBox('请输入目录名称', '目录名称:', '');
    if Trim(strDir) <> '' then
    begin
        strDir := g_strPath + INTERFACE_PATH + '\' + strDir;
        if DirectoryExists(strDir) then
        begin
            MessageBox(Handle, PChar('目录[' + strDir + ']已存在!'), '提示', 64);
            exit;
        end;
        CreateDir(strDir);
        // 刷新文件列表
        RefreshFileList;
    end;
end;

// 增加文件
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
        MessageBox(Handle, '请选择增加文件的目录!', '提示', 64);
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
        // 刷新文件列表
        RefreshFileList;
    end;
    frmRest.Free;
end;

// 修改文件
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
        MessageBox(Handle, '请选择要修改的文件!', '提示', 64);
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
        // 保存文件
        SaveFile(frmRest.g_strFilePath, frmRest.g_strRestPath, frmRest.g_strRestParam);
        // 文件名修改
        if ExtractFileName(frmRest.g_strFilePath) <> ExtractFileName(pTreeData.filePath) then
            DeleteFile(pTreeData.filePath);
        // 刷新文件列表
        RefreshFileList;
    end;
    frmRest.Free;
end;

// 保存文件
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
    
    WriteLog('保存文件[' + strFileName + ']成功');
end;


// 删除目录
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
					// 先递归进入这个目录删除里面的文件,在里面findfirst并  findclose
					if DelDir(strPath + rs.name) then
                    begin
                        // 退出递归后再删除目录
                        WriteLog('正在删除目录[' + strPath + rs.name + '].....');
						RMDir(strPath + rs.name);
                    end;
                end
                else
                begin
                    WriteLog('正在删除文件[' + strPath + rs.name + '].....');
                    DeleteFile(strPath + rs.name);
                end;
			until FindNext(rs)<>0;
		end;
		// 关闭
		FindClose(rs);
	except
        on e : Exception do
        begin
            WriteLog('删除文件目录失败[' + e.Message + '].');
        end;
	end;
end;

// 删除文件
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

// 刷新文件列表
procedure TfrmMain.RefreshFileList;
begin
    // 加载接口文件和目录
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

    strData := InputBox('注册码', '请输入注册码:', '');
    try
        strRegIp := DecryStrHex(strData, '2017RegRToolwi!!');
    except
        on e: Exception do
        begin
            MessageBox(Handle, '注册信息系错误!', '提示', 64);
            exit;
        end;
    end;
    
    if strIp <> strRegIp then
    begin
        MessageBox(Handle, '注册信息系错误!', '提示', 64);
        exit;
    end;

    strRegFile := pRegFile + '\' + REG_FILE;
    strlistFile := TStringList.Create;
    strlistFile.Text := strData; 
    strlistFile.SaveToFile(strRegFile);
    strlistFile.Free;
    
    WriteStatus('注册成功');
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
        MessageBox(Handle, '配置有误！', '提示', 64);
        Exit;
    end;
    strServerAddr := Copy(strConfig, 0, Pos(':', strConfig) - 1);
    if Trim(strServerAddr) = '' then
    begin
        MessageBox(Handle, '配置有误！', '提示', 64);
        Exit;
    end;

    strPort := Copy(strConfig, Pos(':', strConfig) + 1, Length(strConfig));
    if not TryStrToInt(strPort, iPort) then
    begin
        MessageBox(Handle, '配置有误！', '提示', 64);
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
    // 调用服务
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
        MessageBox(Handle, '请选择具体的对应接口报文！', '提示', 64);
        exit;
    end;
    //redReq.Text := FormatJson(redReq.Text, true);
    pTreeData := PTreeFileData(pTreeNode.Data);
    // 保存文件
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
  名称：   BaseImage
  参数：   fn: TFilename
  返回值： string
  功能：   将fn文件转换成Base64编码，返回值为编码
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
    EncdDecd.EncodeStream(m1, m2);                       // 将m1的内容Base64到m2中
    str := m2.DataString;
    str := StringReplace(str, #13, '', [rfReplaceAll]);  // 这里m2中数据会自动添加回车换行，所以需要将回车换行替换成空字符
    str := StringReplace(str, #10, '', [rfReplaceAll]);
    result := str;                                       // 返回值为Base64的Stream
    m1.Free;
    m2.Free;
end;

procedure TfrmMain.btnToBase64Click(Sender: TObject);
var
    m1: TMemoryStream;    // base64的图片
    m2: TStringStream;    // 压缩之后的图片
    jpg: TJpegImage;      // jpg原图
    bmp: TBitmap;         // bmp压缩转换
    strResult: string;
begin
    if not odPic.Execute then
        Exit;

    WriteLog('转base64结果:' + #13#10 + BaseImage(odPic.FileName));
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
//    m1.Position := 0;               // 一定要还原指针，才能base64
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

// 格式化json
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

