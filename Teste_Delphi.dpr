program Teste_Delphi;

uses
  Vcl.Forms,
  UPrincipal in 'UPrincipal.pas' {Form1},
  uConnectionFactory in 'uConnectionFactory.pas',
  uPessoaRepository in 'src\Repositories\uPessoaRepository.pas',
  uEnderecoModel in 'src\Models\uEnderecoModel.pas',
  uPessoaModel in 'src\Models\uPessoaModel.pas',
  uPessoaService in 'src\Services\uPessoaService.pas',
  uEnderecoRepository in 'src\Repositories\uEnderecoRepository.pas',
  uApiCepService in 'src\Services\uApiCepService.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
