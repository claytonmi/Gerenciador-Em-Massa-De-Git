unit Informacoes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TInfo = class(TForm)
    VersaoProduto: TLabel;
    LbNomeProduto: TLabel;
    LBVersaoProduto: TLabel;
    LBDescProduto: TLabel;
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  Info: TInfo;

implementation

{$R *.dfm}

procedure TInfo.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Verifica se Ctrl e Shift foram pressionados
  if (ssCtrl in Shift) and (Key = Ord('P')) then
  begin
    ShowMessage('Criado por Clayton Machado.');
    Key := 0;
  end;
end;

procedure TInfo.FormShow(Sender: TObject);
begin
  LbNomeProduto.Caption := 'Gerenciador em massa';
  LBVersaoProduto.Caption := '1.0';
  LBDescProduto.Caption :=
    'Simplifique o checkout e pull simultāneo em diversos' + #13#10 +
    ' projetos  com esta ferramenta.';
end;

end.
