unit uPessoaRepository;

interface

uses
  System.Generics.Collections,
  uPessoaModel;

type
  TPessoaRepository = class
  private
    procedure GerarIdLote(pQtd: Integer; pIdPessoa, pIdEndereco: TList<Int64>);
  public
    function Inserir(pPessoa: TPessoa): Int64;
    procedure Atualizar(pPessoa: TPessoa);
    procedure Excluir(pIdPessoa: Int64);
    procedure InserirLote(pPessoas: TObjectList<TPessoa>; Const pTamanhoLote: integer = 1000);
  end;

implementation

uses
  System.SysUtils,
  System.Math,
  FireDAC.Comp.Client,
  uConnectionFactory;

procedure TPessoaRepository.GerarIdLote(pQtd: Integer; pIdPessoa, pIdEndereco: TList<Int64>);
var
  Conexao: TFDConnection;
  qryAux: TFDQuery;
begin
  Conexao := TConnectionFactory.CriarConexao;
  qryAux := TFDQuery.Create(nil);
  try
    qryAux.Connection := Conexao;
    qryAux.SQL.Text := 'select ' +
                       ' nextval(''pessoa_idpessoa_seq'') as idpessoa, ' +
                       ' nextval(''endereco_idendereco_seq'') as idendereco ' +
                       'from generate_series(1, :qtd)';

    qryAux.ParamByName('qtd').AsInteger := pQtd;
    qryAux.Open;
    qryAux.First;
    while not qryAux.Eof do
    begin
      pIdPessoa.Add(qryAux.FieldByName('idpessoa').AsLargeInt);
      pIdEndereco.Add(qryAux.FieldByName('idendereco').AsLargeInt);
      qryAux.Next;
    end;
  finally
    qryAux.Free;
    Conexao.Free;
  end;
end;

function TPessoaRepository.Inserir(pPessoa: TPessoa): Int64;
var
  Conexao: TFDConnection;
  qryAux: TFDQuery;
  IdPessoa: Int64;
  IdEndereco: Int64;
begin
  Conexao := TConnectionFactory.CriarConexao;
  qryAux := TFDQuery.Create(nil);
  try
    qryAux.Connection := Conexao;

    Conexao.StartTransaction;
    try
      qryAux.SQL.Text := 'insert into pessoa ' +
                         '(flnatureza, dsdocumento, nmprimeiro, nmsegundo, dtregistro) ' +
                         'values (:flnatureza, :dsdocumento, :nmprimeiro, :nmsegundo, :dtregistro) ' +
                         'returning idpessoa';

      qryAux.ParamByName('flnatureza').AsInteger := pPessoa.FlNatureza;
      qryAux.ParamByName('dsdocumento').AsString := pPessoa.DsDocumento;
      qryAux.ParamByName('nmprimeiro').AsString := pPessoa.NmPrimeiro;
      qryAux.ParamByName('nmsegundo').AsString := pPessoa.NmSegundo;
      qryAux.ParamByName('dtregistro').AsDate := pPessoa.DtRegistro;

      qryAux.Open;
      IdPessoa := qryAux.FieldByName('idpessoa').AsLargeInt;
      qryAux.Close;

      qryAux.SQL.Text := 'insert into endereco ' +
                         '(idpessoa, dscep) ' +
                         'values (:idpessoa, :dscep) ' +
                         'returning idendereco';

      qryAux.ParamByName('idpessoa').AsLargeInt := IdPessoa;
      qryAux.ParamByName('dscep').AsString := pPessoa.Endereco.DsCep;

      qryAux.Open;
      IdEndereco := qryAux.FieldByName('idendereco').AsLargeInt;
      qryAux.Close;

      Conexao.Commit;

      pPessoa.IdPessoa := IdPessoa;
      pPessoa.Endereco.IdPessoa := IdPessoa;
      pPessoa.Endereco.IdEndereco := IdEndereco;

      Result := IdPessoa;
    except
      on E: Exception do
      begin
        if Conexao.InTransaction then
          Conexao.Rollback;
        raise Exception.Create('Falha ao inserir pessoa: ' + E.Message);
      end;
    end;
  finally
    qryAux.Free;
    Conexao.Free;
  end;
end;

procedure TPessoaRepository.Atualizar(pPessoa: TPessoa);
var
  Conexao: TFDConnection;
  qryAux: TFDQuery;
begin
  Conexao := TConnectionFactory.CriarConexao;
  qryAux := TFDQuery.Create(nil);
  try
    qryAux.Connection := Conexao;

    Conexao.StartTransaction;
    try
      qryAux.SQL.Text := 'update pessoa set ' +
                         'flnatureza = :flnatureza, ' +
                         'dsdocumento = :dsdocumento, ' +
                         'nmprimeiro = :nmprimeiro, ' +
                         'nmsegundo = :nmsegundo, ' +
                         'dtregistro = :dtregistro ' +
                         'where idpessoa = :idpessoa';

      qryAux.ParamByName('idpessoa').AsLargeInt := pPessoa.IdPessoa;
      qryAux.ParamByName('flnatureza').AsInteger := pPessoa.FlNatureza;
      qryAux.ParamByName('dsdocumento').AsString := pPessoa.DsDocumento;
      qryAux.ParamByName('nmprimeiro').AsString := pPessoa.NmPrimeiro;
      qryAux.ParamByName('nmsegundo').AsString := pPessoa.NmSegundo;
      qryAux.ParamByName('dtregistro').AsDate := pPessoa.DtRegistro;
      qryAux.ExecSQL;

      if qryAux.RowsAffected = 0 then
        raise Exception.Create('Pessoa não encontrada para atualização.');

      qryAux.SQL.Text := 'update endereco set dscep = :dscep where idpessoa = :idpessoa';

      qryAux.ParamByName('idpessoa').AsLargeInt := pPessoa.IdPessoa;
      qryAux.ParamByName('dscep').AsString := pPessoa.Endereco.DsCep;
      qryAux.ExecSQL;

      Conexao.Commit;
    except
      on E: Exception do
      begin
        if Conexao.InTransaction then
          Conexao.Rollback;
        raise Exception.Create('Falha ao atualizar pessoa: ' + E.Message);
      end;
    end;
  finally
    qryAux.Free;
    Conexao.Free;
  end;
end;

procedure TPessoaRepository.Excluir(pIdPessoa: Int64);
var
  Conexao: TFDConnection;
  qryAux: TFDQuery;
begin
  Conexao := TConnectionFactory.CriarConexao;
  qryAux := TFDQuery.Create(nil);
  try
    qryAux.Connection := Conexao;

    Conexao.StartTransaction;
    try
      qryAux.SQL.Text := 'delete from pessoa where idpessoa = :idpessoa';
      qryAux.ParamByName('idpessoa').AsLargeInt := pIdPessoa;
      qryAux.ExecSQL;
      if qryAux.RowsAffected = 0 then
        raise Exception.Create('Nenhum registro encontrado para exclusão.');
      Conexao.Commit;
    except
      on E: Exception do
      begin
        if Conexao.InTransaction then
          Conexao.Rollback;
        raise Exception.Create('Falha ao atualizar pessoa: ' + E.Message);
      end;
    end;
  finally
    qryAux.Free;
    Conexao.Free;
  end;
end;

procedure TPessoaRepository.InserirLote(pPessoas: TObjectList<TPessoa>; Const pTamanhoLote: integer);
var
  Conexao: TFDConnection;
  qryPessoa: TFDQuery;
  qryEndereco: TFDQuery;
  IdsPessoa: TList<Int64>;
  IdsEndereco: TList<Int64>;
  Inicio, i, j, QtdLote: Integer;
begin
  if (pPessoas = nil) or (pPessoas.Count = 0) then
    Exit;

  IdsPessoa := TList<Int64>.Create;
  IdsEndereco := TList<Int64>.Create;
  Conexao := nil;
  qryPessoa := nil;
  qryEndereco := nil;

  try
    GerarIdLote(pPessoas.Count, IdsPessoa, IdsEndereco);

    Conexao := TConnectionFactory.CriarConexao;
    qryPessoa := TFDQuery.Create(nil);
    qryEndereco := TFDQuery.Create(nil);

    qryPessoa.Connection := Conexao;
    qryEndereco.Connection := Conexao;

    Inicio := 0;

    while Inicio < pPessoas.Count do
    begin
      QtdLote := Min(pTamanhoLote, pPessoas.Count - Inicio);

      Conexao.StartTransaction;
      try
        qryPessoa.SQL.Text :=  'insert into pessoa ' +
                               '(idpessoa, flnatureza, dsdocumento, nmprimeiro, nmsegundo, dtregistro) ' +
                               'values (:idpessoa, :flnatureza, :dsdocumento, :nmprimeiro, :nmsegundo, :dtregistro)';

        qryPessoa.Params.ArraySize := QtdLote;

        for j := 0 to qtdLote - 1 do
        begin
          i := Inicio + j;

          qryPessoa.ParamByName('idpessoa').AsLargeInts[j] := IdsPessoa[i];
          qryPessoa.ParamByName('flnatureza').AsIntegers[j] := pPessoas[i].FlNatureza;
          qryPessoa.ParamByName('dsdocumento').AsStrings[j] := pPessoas[i].DsDocumento;
          qryPessoa.ParamByName('nmprimeiro').AsStrings[j] := pPessoas[i].NmPrimeiro;
          qryPessoa.ParamByName('nmsegundo').AsStrings[j] := pPessoas[i].NmSegundo;
          qryPessoa.ParamByName('dtregistro').AsDates[j] := pPessoas[i].DtRegistro;
        end;

        qryPessoa.Execute(QtdLote, 0);

        qryEndereco.SQL.Text := 'insert into endereco ' +
                                 '(idendereco, idpessoa, dscep) ' +
                                 'values (:idendereco, :idpessoa, :dscep)';

        qryEndereco.Params.ArraySize := qtdLote;

        for j := 0 to qtdLote - 1 do
        begin
          i := Inicio + j;

          qryEndereco.ParamByName('idendereco').AsLargeInts[j] := IdsEndereco[i];
          qryEndereco.ParamByName('idpessoa').AsLargeInts[j] := IdsPessoa[i];
          qryEndereco.ParamByName('dscep').AsStrings[j] := pPessoas[i].Endereco.DsCep;

          pPessoas[i].IdPessoa := IdsPessoa[i];
          pPessoas[i].Endereco.IdEndereco := IdsEndereco[i];
          pPessoas[i].Endereco.IdPessoa := IdsPessoa[i];
        end;

        qryEndereco.Execute(QtdLote, 0);

        Conexao.Commit;
      except
        on E: Exception do
        begin
          if Conexao.InTransaction then
            Conexao.Rollback;
          raise Exception.CreateFmt('Falha ao inserir lote iniciado no registro %d: %s', [Inicio + 1, E.Message]);
        end;
      end;

      Inc(Inicio, QtdLote);
    end;
  finally
    qryEndereco.Free;
    qryPessoa.Free;
    Conexao.Free;
    IdsEndereco.Free;
    IdsPessoa.Free;
  end;
end;

end.
