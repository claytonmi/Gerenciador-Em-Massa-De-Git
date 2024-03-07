unit GerenciadorEmMassa;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, ShellAPI,
  Vcl.Menus,Configuracao,System.IOUtils, System.Types,Informacoes,Solucoes;

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
  public
    { Public declarations }
    Config: string;
    Comando,Comando2: string
  end;

  function CriarArquivoBAT(const Caminho: string): Boolean;
var
  Branch: string;
  GerenciadorEmMassaaDeGit: TGerenciadorEmMassaaDeGit;
  CaminhoCompleto: string;
  CaminhoGitBash: string;

implementation

{$R *.dfm}

procedure TGerenciadorEmMassaaDeGit.Soluesdepossiveiserros1Click(
  Sender: TObject);
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

procedure TGerenciadorEmMassaaDeGit.BtIniciarClick(Sender: TObject);
const
  NomeArquivoBAT = 'Conf.bat';
begin
  CaminhoCompleto := ExtractFilePath(ParamStr(0)) + NomeArquivoBAT;
     if GrupoSelecao.ItemIndex = 3 then
     begin
      if (EdBrachEspecifica.Text <> '') then
      begin
        Branch:= EdBrachEspecifica.Text;
      end
      else
      begin
         ShowMessage('O Branch est� vazio!');
         Exit;
       end;
     end;
     if CriarArquivoBAT(CaminhoCompleto) then
     begin
       // Execute o arquivo BAT
        WinExec(PAnsiChar(AnsiString('cmd.exe /C "' + CaminhoCompleto + '"')), SW_SHOWNORMAL);
     end
     else
      ShowMessage('Erro ao criar o arquivo BAT.');
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
      ScriptBAT :=
        '@echo off' + sLineBreak +
        '"' + CaminhoGitBash + '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} checkout develop"' + sLineBreak +
        '"' + CaminhoGitBash + '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} pull"';
    end
    else if GerenciadorEmMassaaDeGit.GrupoSelecao.ItemIndex = 1 then
    begin
      ScriptBAT :=
        '@echo off' + sLineBreak +
        '"' + CaminhoGitBash + '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} checkout release"' + sLineBreak +
        '"' + CaminhoGitBash + '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} pull"';
    end
    else if GerenciadorEmMassaaDeGit.GrupoSelecao.ItemIndex = 2 then
    begin
      ScriptBAT :=
        '@echo off' + sLineBreak +
        '"' + CaminhoGitBash + '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} checkout main"' + sLineBreak +
        '"' + CaminhoGitBash + '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} pull"';
    end
    else if GerenciadorEmMassaaDeGit.GrupoSelecao.ItemIndex = 3 then
    begin
      ScriptBAT :=
        '@echo off' + sLineBreak +
        '"' + CaminhoGitBash + '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} checkout '+Branch+'"' + sLineBreak +
        '"' + CaminhoGitBash + '" --login -i -c "find . -name ''.git'' -type d | sed ''s/\/.git//'' | xargs -P10 -I{} git -C {} pull"';
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


function TGerenciadorEmMassaaDeGit.BuscarArquivoExe(const Diretorio, NomeArquivo: string): string;
var
  Arquivos: TArray<string>;
begin
  Result := '';
  Arquivos := TDirectory.GetFiles(Diretorio, NomeArquivo, TSearchOption.soTopDirectoryOnly);

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
        ShowMessage('Arquivo Config.txt foi criado com valor padr�o do local do sh.exe, caso esteja instalado em outro local favor ir em configura��o e alterar o caminho.');
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
      EdBrachEspecifica.Visible := true;
  end else
      EdBrachEspecifica.Visible := false;
  end;


end.