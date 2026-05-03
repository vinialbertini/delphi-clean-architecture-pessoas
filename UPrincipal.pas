unit UPrincipal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  FireDAC.Comp.Client,
  uPessoaModel, Vcl.Samples.Spin;

const
  NOMES: array[0..9] of string = (
    'Vinicius','Maria','Carlos','Ana','Pedro','Lucas','Bruno','Marcos','Juliana','Fernanda' );

  SOBRENOMES: array[0..9] of string = (
    'Albertini','Souza','Oliveira','Costa','Pereira','Almeida','Ferreira','Rodrigues','Santos','Lima');

  DOCUMENTOS_FAKE: array[0..9] of string = (
    '04752845636','02365478410','09532475601','06574102368','07563541089',
    '08321456987','01987654321','05678912345','07894561230','03216549870');

  CEPS: array[0..9] of string = (
    '82710412','89802121','80010000','30140071','20040002',
    '01310930','01001000','12903834','90010000','70040900');

type
  TForm1 = class(TForm)
    btTestarConexao: TButton;
    btInserir: TButton;
    btAtualizar: TButton;
    btExcluir: TButton;
    btnInserirLote: TButton;
    btEnderecos: TButton;
    Memo1: TMemo;
    Label2: TLabel;
    gbConexao: TGroupBox;
    gbPessoa: TGroupBox;
    gbLote: TGroupBox;
    gbIntegracao: TGroupBox;
    gbLog: TGroupBox;
    seQtdeLote: TSpinEdit;

    procedure btTestarConexaoClick(Sender: TObject);
    procedure btInserirClick(Sender: TObject);
    procedure btAtualizarClick(Sender: TObject);
    procedure btExcluirClick(Sender: TObject);
    procedure btnInserirLoteClick(Sender: TObject);
    procedure btEnderecosClick(Sender: TObject);

  private
    FLastIdPessoa: Int64;
    procedure Log(const AMensagem: string);
    function CriarPessoa(const Doc: string; const nmPrimeiro: string = 'Vinicius';
                                            const nmSegundo: string = 'Albertini'): TPessoa;
    function NomeAleatorio: string;
    function SobrenomeAleatorio: string;
    function CEPAleatorio: string;
    function DocumentoFakeUnico(AIndice: Integer): string;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  uConnectionFactory,
  uPessoaService,
  uApiCepService;

procedure TForm1.Log(const AMensagem: string);
begin
  Memo1.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + AMensagem);
end;

function TForm1.NomeAleatorio: string;
begin
  Result := NOMES[Random(Length(NOMES))];
end;

function TForm1.SobrenomeAleatorio: string;
begin
  Result := SOBRENOMES[Random(Length(SOBRENOMES))];
end;

function TForm1.CEPAleatorio: string;
begin
  Result := CEPS[Random(Length(CEPS))];
end;

function TForm1.DocumentoFakeUnico(AIndice: Integer): string;
var
  Base: string;
begin
  Base := DOCUMENTOS_FAKE[Random(Length(DOCUMENTOS_FAKE))];
  Result := Copy(Base, 1, 6) + FormatFloat('00000', AIndice mod 100000);
  Result := Copy(Result, 1, 11);
end;

function TForm1.CriarPessoa(const Doc: string; const nmPrimeiro: string; const nmSegundo: string): TPessoa;
begin
  Result := TPessoa.Create;
  Result.FlNatureza := 1;
  Result.DsDocumento := Doc;
  Result.NmPrimeiro := nmPrimeiro;
  Result.NmSegundo := nmSegundo;
  Result.DtRegistro := Date;
  Result.Endereco.DsCep := '82710412';
end;

procedure TForm1.btTestarConexaoClick(Sender: TObject);
var
  Conexao: TFDConnection;
begin
  Conexao := nil;
  try
    Conexao := TConnectionFactory.CriarConexao;
    Log('Conectado com sucesso.');
  except
    on E: Exception do
      Log('Erro ao conectar: ' + E.Message);
  end;
  Conexao.Free;
end;

procedure TForm1.btInserirClick(Sender: TObject);
var
  Pessoa: TPessoa;
  Service: TPessoaService;
begin
  Randomize;
  Pessoa := CriarPessoa(DocumentoFakeUnico(Random(99999)), NomeAleatorio, SobrenomeAleatorio);
  Service := TPessoaService.Create;
  try
    FLastIdPessoa := Service.Inserir(Pessoa);
    Log('Pessoa inserida com sucesso. ID: ' + FLastIdPessoa.ToString);
  finally
    Service.Free;
    Pessoa.Free;
  end;
end;

procedure TForm1.btAtualizarClick(Sender: TObject);
var
  Pessoa: TPessoa;
  Service: TPessoaService;
  TextoId: string;
  IdPessoa: Int64;
begin
  TextoId := InputBox('Atualizar Pessoa','Informe o ID da pessoa para atualização:',FLastIdPessoa.ToString);

  if Trim(TextoId).IsEmpty then
    Exit;

  IdPessoa := StrToInt64Def(TextoId, 0);

  if IdPessoa <= 0 then
  begin
    Log('ID inválido para atualização.');
    Exit;
  end;

  Pessoa := TPessoa.Create;
  Service := TPessoaService.Create;
  try
    Pessoa.IdPessoa := IdPessoa;
    Pessoa.FlNatureza := 1;
    Pessoa.DsDocumento := DocumentoFakeUnico(IdPessoa);
    Pessoa.NmPrimeiro := 'Pessoa';
    Pessoa.NmSegundo := 'Atualizada';
    Pessoa.DtRegistro := Date;
    Pessoa.Endereco.DsCep := '89802121';

    Service.Atualizar(Pessoa);

    FLastIdPessoa := IdPessoa;
    Log('Pessoa atualizada com sucesso. ID: ' + IdPessoa.ToString);
  finally
    Service.Free;
    Pessoa.Free;
  end;
end;

procedure TForm1.btExcluirClick(Sender: TObject);
var
  Service: TPessoaService;
  TextoId: string;
  IdPessoa: Int64;
begin
  TextoId := InputBox(
    'Excluir Pessoa',
    'Informe o ID da pessoa para exclusão:',
    FLastIdPessoa.ToString
  );

  if Trim(TextoId).IsEmpty then
    Exit;

  IdPessoa := StrToInt64Def(TextoId, 0);

  if IdPessoa <= 0 then
  begin
    Log('ID inválido para exclusão.');
    Exit;
  end;

  Service := TPessoaService.Create;
  try
    Service.Excluir(IdPessoa);
    Log('Pessoa excluída. ID: ' + IdPessoa.ToString);

    if FLastIdPessoa = IdPessoa then
      FLastIdPessoa := 0;
  finally
    Service.Free;
  end;
end;

procedure TForm1.btnInserirLoteClick(Sender: TObject);
var
  Lista: TObjectList<TPessoa>;
  Pessoa: TPessoa;
  Service: TPessoaService;
  i, Qtd: Integer;
begin
  Randomize;
  Qtd := StrToIntDef(seQtdeLote.Text, 0);
  Lista := TObjectList<TPessoa>.Create(True);
  Service := TPessoaService.Create;
  try
    for i := 1 to Qtd do
    begin
      Pessoa := TPessoa.Create;
      Pessoa.FlNatureza := 1;
      Pessoa.DsDocumento := DocumentoFakeUnico(i);
      Pessoa.NmPrimeiro := NomeAleatorio;
      Pessoa.NmSegundo := SobrenomeAleatorio;
      Pessoa.DtRegistro := Date;
      Pessoa.Endereco.DsCep := CEPAleatorio;
      Lista.Add(Pessoa);
    end;
    Service.InserirLote(Lista);
    Log('Lote inserido.');
  finally
    Service.Free;
    Lista.Free;
  end;
end;

procedure TForm1.btEnderecosClick(Sender: TObject);
var
  Service: TApiCepService;
begin
  Service := TApiCepService.Create;
  try
    Service.AtualizarEnderecos;
    Log('Endereços atualizados.');
  finally
    Service.Free;
  end;
end;

end.
