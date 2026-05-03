unit uEnderecoRepository;

interface

uses
  System.Generics.Collections;

type
  TEnderecoDTO = class
  public
    IdEndereco: Int64;
    Cep: string;
  end;

  TEnderecoRepository = class
  public
    //function BuscarEnderecos: TObjectList<TEnderecoDTO>;
    function BuscarCepsDistintos: TList<string>;
    procedure AtualizarIntegracaoPorCep(
       const pCep, pUF, pCidade, pBairro, pLogradouro, pComplemento: string);
    //procedure AtualizarIntegracao(pIdEndereco: Int64;pUF, pCidade, pBairro, pLogradouro, pComplemento: string);
  end;

implementation

uses
  FireDAC.Comp.Client,
  uConnectionFactory;

//function TEnderecoRepository.BuscarEnderecos: TObjectList<TEnderecoDTO>;
//var
//  Conexao: TFDConnection;
//  qryAux: TFDQuery;
//  Item: TEnderecoDTO;
//begin
//  Result := TObjectList<TEnderecoDTO>.Create(True);
//
//  Conexao := TConnectionFactory.CriarConexao;
//  qryAux := TFDQuery.Create(nil);
//  try
//    qryAux.Connection := Conexao;
//    qryAux.SQL.Text := 'select idendereco, dscep from endereco where dscep is not null';
//    qryAux.Open;
//
//    while not qryAux.Eof do
//    begin
//      Item := TEnderecoDTO.Create;
//      Item.IdEndereco := qryAux.FieldByName('idendereco').AsLargeInt;
//      Item.Cep := qryAux.FieldByName('dscep').AsString;
//      Result.Add(Item);
//
//      qryAux.Next;
//    end;
//
//  finally
//    qryAux.Free;
//    Conexao.Free;
//  end;
//end;

//procedure TEnderecoRepository.AtualizarIntegracao(pIdEndereco: Int64;
//  pUF, pCidade, pBairro, pLogradouro, pComplemento: string
//);
//var
//  Conexao: TFDConnection;
//  qryAux: TFDQuery;
//begin
//  Conexao := TConnectionFactory.CriarConexao;
//  qryAux := TFDQuery.Create(nil);
//  try
//    qryAux.Connection := Conexao;
//
//    qryAux.SQL.Text := 'insert into endereco_integracao ' +
//                       '(idendereco, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento) ' +
//                       'values (:id, :uf, :cidade, :bairro, :logradouro, :complemento) ' +
//                       'on conflict (idendereco) do update set ' +
//                       'dsuf = excluded.dsuf, ' +
//                       'nmcidade = excluded.nmcidade, ' +
//                       'nmbairro = excluded.nmbairro, ' +
//                       'nmlogradouro = excluded.nmlogradouro, ' +
//                       'dscomplemento = excluded.dscomplemento';
//
//    qryAux.ParamByName('id').AsLargeInt := pIdEndereco;
//    qryAux.ParamByName('uf').AsString := pUF;
//    qryAux.ParamByName('cidade').AsString := pCidade;
//    qryAux.ParamByName('bairro').AsString := pBairro;
//    qryAux.ParamByName('logradouro').AsString := pLogradouro;
//    qryAux.ParamByName('complemento').AsString := pComplemento;
//
//    qryAux.ExecSQL;
//
//  finally
//    qryAux.Free;
//    Conexao.Free;
//  end;
//end;

procedure TEnderecoRepository.AtualizarIntegracaoPorCep(
  const pCep, pUF, pCidade, pBairro, pLogradouro, pComplemento: string);
var
  Conexao: TFDConnection;
  qryAux: TFDQuery;
begin
  Conexao := TConnectionFactory.CriarConexao;
  qryAux := TFDQuery.Create(nil);
  try
    qryAux.Connection := Conexao;

    qryAux.SQL.Text :=  'insert into endereco_integracao ' +
                        '(idendereco, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento) ' +
                        'select e.idendereco, :uf, :cidade, :bairro, :logradouro, :complemento ' +
                        'from endereco e ' +
                        'where e.dscep = :cep ' +
                        'and not exists ( ' +
                        '    select 1 from endereco_integracao ei ' +
                         '   where ei.idendereco = e.idendereco ' +
                         ')' +
                        'on conflict (idendereco) do update set ' +
                        'dsuf = excluded.dsuf, ' +
                        'nmcidade = excluded.nmcidade, ' +
                        'nmbairro = excluded.nmbairro, ' +
                        'nmlogradouro = excluded.nmlogradouro, ' +
                        'dscomplemento = excluded.dscomplemento';

    qryAux.ParamByName('cep').AsString := pCep;
    qryAux.ParamByName('uf').AsString := pUF;
    qryAux.ParamByName('cidade').AsString := pCidade;
    qryAux.ParamByName('bairro').AsString := pBairro;
    qryAux.ParamByName('logradouro').AsString := pLogradouro;
    qryAux.ParamByName('complemento').AsString := pComplemento;

    qryAux.ExecSQL;
  finally
    qryAux.Free;
    Conexao.Free;
  end;
end;

function TEnderecoRepository.BuscarCepsDistintos: TList<string>;
var
  Conexao: TFDConnection;
  qryAux: TFDQuery;
begin
  Result := TList<string>.Create;

  Conexao := TConnectionFactory.CriarConexao;
  qryAux := TFDQuery.Create(nil);
  try
    qryAux.Connection := Conexao;

    qryAux.SQL.Text :=  'select distinct dscep ' +
                        'from endereco ' +
                        'where coalesce(trim(dscep), '''') <> ''''';
    qryAux.Open;

    while not qryAux.Eof do
    begin
      Result.Add(qryAux.FieldByName('dscep').AsString);
      qryAux.Next;
    end;
  finally
    qryAux.Free;
    Conexao.Free;
  end;
end;

end.
