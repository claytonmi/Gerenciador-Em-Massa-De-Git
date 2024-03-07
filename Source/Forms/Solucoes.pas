unit Solucoes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.AppAnalytics, RLReport;

type
  TSolucoesDeErro = class(TForm)
    Image1: TImage;
    RLMemo1: TRLMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SolucoesDeErro: TSolucoesDeErro;

implementation

{$R *.dfm}

end.
