unit uPessoaService;

interface

uses
  System.Generics.Collections,
  uPessoaModel;
type
  TPessoaService = class
  private
    procedure Validar(pPessoa: TPessoa);
    procedure ValidarLista(pPessoas: TObjectList<TPessoa>);
  public
    function Inserir(pPessoa: TPessoa): Int64;
    procedure Atualizar(pPessoa: TPessoa);
    procedure Excluir(pIdPessoa: Int64);
    procedure InserirLote(pPessoas: TObjectList<TPessoa>; const pTamanhoLote: integer = 1000);
  end;

implementation

uses
  System.SysUtils,
  uPessoaRepository,
  FireDac.DApt;

procedure TPessoaService.Validar(pPessoa: TPessoa);
begin
  if not Assigned(pPessoa) then
    raise Exception.Create('Pessoa não informado');

  if pPessoa.NmPrimeiro.Trim.IsEmpty then
    raise Exception.Create('Nome não informado');

  if pPessoa.NmSegundo.Trim.IsEmpty then
    raise Exception.Create('Sobrenome não informado');

  if pPessoa.DsDocumento.Trim.IsEmpty then
    raise Exception.Create('Documento não informado');

  if pPessoa.FlNatureza <= 0 then
    raise Exception.Create('Natureza não informado');

  if not Assigned(pPessoa.Endereco) then
    raise Exception.Create('Endereço não informado');

  if pPessoa.Endereco.DsCep.Trim.IsEmpty then
    raise Exception.Create('CEP não informado');
end;

procedure TPessoaService.ValidarLista(pPessoas: TObjectList<TPessoa>);
var
  Pessoa: TPessoa;
begin
  if not (Assigned(pPessoas)) or (pPessoas.Count = 0 ) then
    raise Exception.Create('Lista de pessoas não informada');

  for Pessoa in pPessoas do
    Validar(Pessoa);
end;

function TPessoaService.Inserir(pPessoa: TPessoa): Int64;
var
  PessoaRepo: TPessoaRepository;
begin
  Validar(pPessoa);

  PessoaRepo := TPessoaRepository.Create;
  try
    Result := PessoaRepo.Inserir(pPessoa);
  finally
    PessoaRepo.Free;
  end;
end;

procedure TPessoaService.Atualizar(pPessoa: TPessoa);
var
  PessoaRepo: TPessoaRepository;
begin
  if not (Assigned(pPessoa)) or (pPessoa.IdPessoa <= 0) then
    raise Exception.Create('Pessoa não informada');

  Validar(pPessoa);

  PessoaRepo := TPessoaRepository.Create;
  try
    PessoaRepo.Atualizar(pPessoa);
  finally
    PessoaRepo.Free;
  end;
end;

procedure TPessoaService.Excluir(pIdPessoa: Int64);
var
  PessoaRepo: TPessoaRepository;
begin
  if pIdPessoa <= 0 then
    raise Exception.Create('Código pessoa inválido');

  PessoaRepo := TPessoaRepository.Create;
  try
    PessoaRepo.Excluir(pIdPessoa);
  finally
    PessoaRepo.Free;
  end;
end;

procedure TPessoaService.InserirLote(pPessoas: TObjectList<TPessoa>; const pTamanhoLote: integer);
var
  PessoaRepo: TPessoaRepository;
begin
  ValidarLista(pPessoas);

  PessoaRepo := TPessoaRepository.Create;
  try
    PessoaRepo.InserirLote(pPessoas, pTamanhoLote);
  finally
    PessoaRepo.Free;
  end;
end;

end.
