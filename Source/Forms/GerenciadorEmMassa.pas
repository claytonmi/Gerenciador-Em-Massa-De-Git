unit GerenciadorEmMassa;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, ShellAPI,
  Vcl.Menus, Configuracao, System.IOUtils, System.Types, Informacoes, Solucoes;

type
  TGerenciadorEmMassaaDeGit = class(TForm)
    BtIniciar: TButton;
    GrupoSelecao: TRadioGroup;
    BtSair: TButton;
    EdBrachEspecifica: TEdit;
    MainMenu1: TMainMenu;
    Menu1: TMenuItem;
    BtConfiguracoes: TMenuItem;
    BtInfo1: TMenuItem;
    Soluesdepossiveiserros1: TMenuItem;
    procedure GrupoSelecaoClick(Sender: TObject);
    procedure BtSairClick(Sender: TObject);
    procedure BtIniciarClick(Sender: TObject);
    procedure BtConfiguracoesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtInfo1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Soluesdepossiveiserros1Click(Sender: TObject);
  private
    { Private declarations }
    function BuscarArquivoExe(const Diretorio, NomeArquivo: string): string;
    procedure ExecutarGitCheckoutPull(const CaminhoArquivo: string);
  public
    { Public declarations }
    Config: string;
    Comando, Comando2: string end;

    function CriarArquivoBAT(const Caminho: string): Boolean;

  var
    Branch: string;
    GerenciadorEmMassaaDeGit: TGerenciadorEmMassaaDeGit;
    CaminhoCompleto: string;
    CaminhoGitBash: string;

implementation

{$R *.dfm}

procedure TGerenciadorEmMassaaDeGit.Soluesdepossiveiserros1Click
  (Sender: TObject);
begin
  Application.CreateForm(TSolucoesDeErro, SolucoesDeErro);
  SolucoesDeErro.showModal;
  FreeAndNil(SolucoesDeErro);
end;

procedure TGerenciadorEmMassaaDeGit.BtConfiguracoesClick(Sender: TObject);
begin
  Application.CreateForm(TConfiguracoes, Configuracoes);
  Configuracoes.showModal;
  FreeAndNil(Configuracoes);
end;

procedure TGerenciadorEmMassaaDeGit.BtInfo1Click(Sender: TObject);
begin
  Application.CreateForm(TInfo, Info);
  Info.showModal;
  FreeAndNil(Info);
end;

procedure TGerenciadorEmMassaaDeGit.ExecutarGitCheckoutPull
  (const CaminhoArquivo: string);
var
  ListaDePastas: TStringList;
  Caminho: string;
  GitCommand: string;
  i: Integer;
  Branch: string;
  ScriptBAT: TStringList;
  BatFilePath: string;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  ExitCode: DWORD;
begin
  // Crie uma lista de strings para armazenar os caminhos das pastas
  ListaDePastas := TStringList.Create;
  ScriptBAT := TStringList.Create;

  try
    // Leia o arquivo ConfigCaminho.txt
    ListaDePastas.Delimiter := ';';
    ListaDePastas.StrictDelimiter := True;
    ListaDePastas.DelimitedText := TFile.ReadAllText(CaminhoArquivo);

    // Verifique se a lista est� vazia
    if ListaDePastas.Count = 0 then
    begin
      ShowMessage('A lista de pastas est� vazia.');
      Exit;
    end;

    // Verifique qual branch ser� usado com base no GrupoSelecao
    case GrupoSelecao.ItemIndex of
      0:
        Branch := 'develop';
      1:
        Branch := 'release';
      2:
        Branch := 'main';
      3:
        Branch := EdBrachEspecifica.Text;
    else
      ShowMessage('Selecione um Grupo no raio de grupo.');
      Exit;
    end;
    // Salve os comandos Git no arquivo .bat
    ScriptBAT.Add('@echo off'); // Adiciona a declara��o "@echo off" no in�cio do arquivo .bat

    // Itere sobre os caminhos e crie os comandos Git no ScriptBAT
    for i := 0 to ListaDePastas.Count - 1 do
    begin
      Caminho := Trim(ListaDePastas[i]);

      if DirectoryExists(Caminho) then
      begin
        ScriptBAT.Add(Format('"%s" --login -i -c "git -C ''%s'' checkout %s"',
          [CaminhoGitBash, Caminho, Branch]));

        ScriptBAT.Add(Format('"%s" --login -i -c "git -C ''%s'' pull"',
          [CaminhoGitBash, Caminho]));
      end;
    end;

    // Obtenha o caminho do diret�rio onde o aplicativo est� sendo executado
    BatFilePath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Config.bat');

    // Salve os comandos Git no arquivo .bat
    TFile.WriteAllText(BatFilePath, ScriptBAT.Text);

    // Inicialize as estruturas StartupInfo e ProcessInfo
    FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
    FillChar(ProcessInfo, SizeOf(TProcessInformation), 0);

    // Execute o arquivo .bat
    if CreateProcess(nil, PChar('cmd.exe /C "' + BatFilePath + '"'), nil, nil,
      False, 0, nil, nil, StartupInfo, ProcessInfo) then
    begin
      // Aguarde at� que o processo seja conclu�do
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

      // Obtenha o c�digo de sa�da do processo
      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

      // Libere os recursos do processo
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);

      // Verifique se o processo foi encerrado com �xito
      if ExitCode = 0 then
      begin
        // Remova o arquivo .bat somente ap�s a conclus�o bem-sucedida do processo
        TFile.Delete(BatFilePath);
      end
      else
        ShowMessage('Erro ao executar o processo. C�digo de sa�da: ' +
          IntToStr(ExitCode));
    end
    else
      ShowMessage('Erro ao criar o processo. C�digo de erro: ' +
        IntToStr(GetLastError));

    // Exiba uma mensagem informando que os comandos foram executados com sucesso
    ShowMessage
      ('Comandos Git executados com sucesso para os caminhos especificados.');
  finally
    // Libere a mem�ria das listas
    ListaDePastas.Free;
    ScriptBAT.Free;
  end;
end;

procedure TGerenciadorEmMassaaDeGit.BtIniciarClick(Sender: TObject);
const
  NomeArquivoBAT = 'Conf.bat';
  NomeArquivoConfigCaminho = 'ConfigCaminho.txt';
  PastaMeusDocumentos = 'Meus Documentos';
var
  CaminhoDocumentos: string;
begin
  // Verifique se algum item foi selecionado no GrupoSelecao
  if GrupoSelecao.ItemIndex = -1 then
  begin
    ShowMessage('Escolha uma op��o no grupo para continuar.');
    Exit;
  end;

  CaminhoCompleto := ExtractFilePath(ParamStr(0)) + NomeArquivoBAT;

  // Obtenha o caminho para a pasta "Meus Documentos"
  CaminhoDocumentos := TPath.GetDocumentsPath;

  // Verifique se o arquivo ConfigCaminho.txt existe na pasta "Meus Documentos"
  if FileExists(TPath.Combine(CaminhoDocumentos, NomeArquivoConfigCaminho)) then
  begin
    // Se o arquivo existe, execute os comandos Git para cada pasta especificada
    ExecutarGitCheckoutPull(TPath.Combine(CaminhoDocumentos,
      NomeArquivoConfigCaminho));
  end
  else
  begin
    // Se o arquivo n�o existe, continue com o procedimento existente
    if GrupoSelecao.ItemIndex = 3 then
    begin
      if (EdBrachEspecifica.Text <> '') then
      begin
        Branch := EdBrachEspecifica.Text;
      end
      else
      begin
        ShowMessage('O campo "Nome da Branch" est� vazio!');
        Exit;
      end;
    end;

    if CriarArquivoBAT(CaminhoCompleto) then
    begin
      // Execute o arquivo BAT
      WinExec(PAnsiChar(AnsiString('cmd.exe /C "' + CaminhoCompleto + '"')),
        SW_SHOWNORMAL);
    end
    else
      ShowMessage('Erro ao criar o arquivo .BAT');
  end;
end;

function CriarArquivoBAT(const Caminho: string): Boolean;
var
  ScriptBAT: string;
  Arquivo: TextFile;
begin
  try
    AssignFile(Arquivo, Caminho);
    Rewrite(Arquivo);

    if GerenciadorEmMassaaDeGit.GrupoSelecao.ItemIndex = 0 then
    begin
      ScriptBAT := '@echo off' + sLineBreak + '"' + CaminhoGitBash +
        '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} checkout develop"'
        + sLineBreak + '"' + CaminhoGitBash +
        '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} pull"';
    end
    else if GerenciadorEmMassaaDeGit.GrupoSelecao.ItemIndex = 1 then
    begin
      ScriptBAT := '@echo off' + sLineBreak + '"' + CaminhoGitBash +
        '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} checkout release"'
        + sLineBreak + '"' + CaminhoGitBash +
        '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} pull"';
    end
    else if GerenciadorEmMassaaDeGit.GrupoSelecao.ItemIndex = 2 then
    begin
      ScriptBAT := '@echo off' + sLineBreak + '"' + CaminhoGitBash +
        '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} checkout main"'
        + sLineBreak + '"' + CaminhoGitBash +
        '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} pull"';
    end
    else if GerenciadorEmMassaaDeGit.GrupoSelecao.ItemIndex = 3 then
    begin
      ScriptBAT := '@echo off' + sLineBreak + '"' + CaminhoGitBash +
        '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} checkout '
        + Branch + '"' + sLineBreak + '"' + CaminhoGitBash +
        '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} pull"';
    end;

    // Escreva o script no arquivo
    Write(Arquivo, ScriptBAT);
    CloseFile(Arquivo);

    Result := True;
  except
    Result := False;
  end;
end;

procedure TGerenciadorEmMassaaDeGit.BtSairClick(Sender: TObject);
begin
  CaminhoCompleto := ExtractFilePath(ParamStr(0)) + 'Conf.bat';

  try
    // Verifique se o arquivo existe antes de tentar exclu�-lo
    if FileExists(CaminhoCompleto) then
      DeleteFile(CaminhoCompleto);

    Application.Terminate;
  except
    on E: Exception do
      ShowMessage('Erro ao excluir o arquivo BAT: ' + E.Message);
  end;
end;

procedure TGerenciadorEmMassaaDeGit.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  CaminhoCompleto := ExtractFilePath(ParamStr(0)) + 'Conf.bat';

  try
    // Verifique se o arquivo existe antes de tentar exclu�-lo
    if FileExists(CaminhoCompleto) then
      DeleteFile(CaminhoCompleto);

    Application.Terminate;
  except
    on E: Exception do
      ShowMessage('Erro ao excluir o arquivo BAT: ' + E.Message);
  end;
end;

function TGerenciadorEmMassaaDeGit.BuscarArquivoExe(const Diretorio,
  NomeArquivo: string): string;
var
  Arquivos: TArray<string>;
begin
  Result := '';
  Arquivos := TDirectory.GetFiles(Diretorio, NomeArquivo,
    TSearchOption.soTopDirectoryOnly);

  if Length(Arquivos) > 0 then
    Result := Arquivos[0];
end;

procedure TGerenciadorEmMassaaDeGit.FormCreate(Sender: TObject);
var
  StreamWriter: TStreamWriter;
  StreamReader: TStreamReader;
begin
  Config := TPath.Combine(TPath.GetDocumentsPath, 'Config.txt');

  try
    // Verifica se o arquivo existe
    if FileExists(Config) then
    begin
      // Se existe, abre o arquivo para leitura
      StreamReader := TStreamReader.Create(Config);
      try
        // L� o conte�do do arquivo e coloca na vari�vel CaminhoGitBash
        CaminhoGitBash := StreamReader.ReadToEnd;
      finally
        // Fecha o StreamReader
        StreamReader.Free;
      end;
    end
    else
    begin
      // Se o arquivo n�o existe, procura no C: por sh.exe
      CaminhoGitBash := BuscarArquivoExe('C:\', 'sh.exe');

      // Se encontrou o arquivo, salva o caminho no arquivo Config.txt
      if CaminhoGitBash <> '' then
      begin
        StreamWriter := TStreamWriter.Create(Config);
        try
          StreamWriter.Write(CaminhoGitBash);
        finally
          StreamWriter.Free;
        end;
        ShowMessage('Caminho do arquivo salvo com sucesso!');
      end
      else
      begin
        // Se n�o encontrou o arquivo, define um valor padr�o
        CaminhoGitBash := 'C:\Program Files\Git\bin\sh.exe';
        StreamWriter := TStreamWriter.Create(Config);
        try
          StreamWriter.Write(CaminhoGitBash);
        finally
          StreamWriter.Free;
        end;
        ShowMessage
          ('Arquivo Config.txt foi criado com valor padr�o do local do sh.exe, caso esteja instalado em outro local favor ir em configura��o e alterar o caminho.');
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao carregar o arquivo: ' + E.Message);
  end;
end;

procedure TGerenciadorEmMassaaDeGit.GrupoSelecaoClick(Sender: TObject);
begin
  if GrupoSelecao.ItemIndex = 3 then
  begin
    EdBrachEspecifica.Visible := True;
  end
  else
    EdBrachEspecifica.Visible := False;
end;

end.
