unit Configuracao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,System.IOUtils;

type
  TConfiguracoes = class(TForm)
    BtPesquisa: TButton;
    EditCaminhoGitBash: TEdit;
    OpenDialog: TOpenDialog;
    BitBtn1: TBitBtn;
    procedure BtPesquisaClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
    Config: string;
  public
    { Public declarations }
  end;

var
  Configuracoes: TConfiguracoes;

implementation

{$R *.dfm}

procedure TConfiguracoes.BitBtn1Click(Sender: TObject);
var
  StreamWriter: TStreamWriter;
begin
  Config := TPath.Combine(TPath.GetDocumentsPath, 'Config.txt');

  // Verifica se o campo EditCaminhoGitBash est� vazio
  if EditCaminhoGitBash.Text = '' then
  begin
    ShowMessage('O campo Caminho Git Bash n�o pode estar vazio.');
    Exit; // N�o permite continuar se o campo estiver vazio
  end;

  try
    // Cria um StreamWriter para escrever no arquivo
    StreamWriter := TStreamWriter.Create(Config);

    // Escreve o conte�do do EditCaminhoGitBash no arquivo
    StreamWriter.Write(EditCaminhoGitBash.Text);
    ShowMessage('Configura��es salvas com sucesso!');
  finally
    // Libera o StreamWriter
    StreamWriter.Free;
    Configuracoes.Close;
  end;
end;

procedure TConfiguracoes.BtPesquisaClick(Sender: TObject);
begin
OpenDialog := TOpenDialog.Create(Self);
  try
    OpenDialog.Filter := 'Arquivos Execut�veis (*.exe)|*.exe';
    OpenDialog.Title := 'Selecione um Arquivo Execut�vel';

    if OpenDialog.Execute then
    begin
      // Verificar se o arquivo selecionado � um execut�vel (.exe)
      if SameText(ExtractFileExt(OpenDialog.FileName), '.exe') then
      begin
        EditCaminhoGitBash.Text := OpenDialog.FileName;
      end
      else
      begin
        ShowMessage('Por favor, selecione um arquivo execut�vel (.exe).');
      end;
    end;
  finally
    OpenDialog.Free;
  end;
end;
end.
