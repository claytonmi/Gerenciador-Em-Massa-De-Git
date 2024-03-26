program Gerenciador;

uses
  Vcl.Forms,
  GerenciadorEmMassa in 'Forms\GerenciadorEmMassa.pas' {GerenciadorEmMassaaDeGit},
  Configuracao in 'Forms\Configuracao.pas' {Configuracoes},
  Informacoes in 'Forms\Informacoes.pas' {Info},
  Solucoes in 'Forms\Solucoes.pas' {SolucoesDeErro},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 Dark');
  Application.CreateForm(TGerenciadorEmMassaaDeGit, GerenciadorEmMassaaDeGit);
  Application.Run;
end.
