unit CriadorDeBats;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.ShellAPI, Vcl.Dialogs,GerenciadorEmMassa;

type
  TCriadorDeBats = class
  TGerenciadorEmMassaaDeGit = class(TForm);
  private

  public
    class procedure ExecuteGitCheckoutPull(const CaminhoArquivo: string; const Branch: string);
  end;

implementation

  var


{ TCriadorDeBats }
procedure TGerenciadorEmMassaaDeGit.ExecutarGitCheckoutPull
  (const CaminhoArquivo: string);
var
  ListaDePastas: TStringList;
  Caminho: string;
  GitCommand: string;
  i: Integer;
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
      GerenciadorEmMassa.BtIniciar.Enabled := True;
      Exit;
    end;

    // Salve os comandos Git no arquivo .bat
    ScriptBAT.Add('@echo off');
    // Adiciona a declara��o "@echo off" no in�cio do arquivo .bat

    // Itere sobre os caminhos e crie os comandos Git no ScriptBAT
    for i := 0 to ListaDePastas.Count - 1 do
    begin
      Caminho := Trim(ListaDePastas[i]);

      if DirectoryExists(Caminho) then
      begin
        if GerenciadorEmMassa.CheckTag.Checked = false then
        begin
          ScriptBAT.Add(Format('"%s" --login -i -c "git -C ''%s'' checkout %s"',
            [CaminhoGitBash, Caminho, Branch]));
          ScriptBAT.Add(Format('"%s" --login -i -c "git -C ''%s'' pull"',
            [CaminhoGitBash, Caminho]));
        end
        else
        begin
          ScriptBAT.Add
            (Format('"%s" --login -i -c "git -C ''%s'' show-ref --tags %s" > nul 2>&1 && (',
            [CaminhoGitBash, Caminho, Branch]));
          // Tag existe, adicionar linhas ao script BAT
          ScriptBAT.Add
            (Format('"%s" --login -i -c "git -C ''%s'' checkout --no-track tags/%s"',
            [CaminhoGitBash, Caminho, Branch]));
          ScriptBAT.Add
            (Format('"%s" --login -i -c "git -C ''%s'' checkout -b Branch_%s"',
            [CaminhoGitBash, Caminho, Branch]));
          ScriptBAT.Add(') || (');
          ScriptBAT.Add('');
          ScriptBAT.Add
            (Format('echo Nao existe a tag ''%s'' no projeto do caminho: ''%S''',
            [Branch, Caminho]));
          ScriptBAT.Add('');
          ScriptBAT.Add('pause');
          ScriptBAT.Add(')');
        end;
      end;
    end;

    // Obtenha o caminho do diret�rio onde o aplicativo est� sendo executado
    BatFilePath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Conf.bat');

    // Salve os comandos Git no arquivo .bat
    TFile.WriteAllText(BatFilePath, ScriptBAT.Text);

    // Inicialize as estruturas StartupInfo e ProcessInfo
    FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
    FillChar(ProcessInfo, SizeOf(TProcessInformation), 0);

    // Execute o arquivo .bat
    if CreateProcess(nil, PChar('cmd.exe /C "' + BatFilePath + '"'), nil, nil,
      false, 0, nil, nil, StartupInfo, ProcessInfo) then
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
    begin
      ShowMessage('Erro ao criar o processo. C�digo de erro: ' +
        IntToStr(GetLastError));
    end;

  finally
    // Libere a mem�ria das listas
    ListaDePastas.Free;
    ScriptBAT.Free;
  end;
  BtIniciar.Enabled := True;
end;

end.
