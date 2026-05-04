unit uConnectionFactory;

interface

uses
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  FireDAC.Phys.PGDef,
  FireDAC.Phys.PG,
  Data.DB,
  FireDAC.Comp.Client;

type
  TConnectionFactory = class
  private
    class procedure ConfigurarDriverPostgres;
  public
    class function CriarConexao: TFDConnection;
  end;

implementation

uses
  System.SysUtils;

var
  PgDriverLink: TFDPhysPgDriverLink;

class procedure TConnectionFactory.ConfigurarDriverPostgres;
begin
  if not Assigned(PgDriverLink) then
  begin
    PgDriverLink := TFDPhysPgDriverLink.Create(nil);
    //PgDriverLink.BaseDriverID := 'PG';
    PgDriverLink.VendorLib := 'C:\Program Files\PostgreSQL\15\bin\libpq.dll';
    //PgDriverLink.VendorLib := 'C:\Testes\Win64\Debug\libpq.dll';
  end;
end;

class function TConnectionFactory.CriarConexao: TFDConnection;
begin
  ConfigurarDriverPostgres;

  Result := TFDConnection.Create(nil);

  try
    Result.LoginPrompt := False;
    Result.DriverName := 'PG';

    Result.Params.Clear;
    Result.Params.Add('DriverID=PG');
    Result.Params.Add('Server=localhost');
    Result.Params.Add('Port=5432');
    Result.Params.Add('Database=teste_delphi');
    Result.Params.Add('User_Name=postgres');
    Result.Params.Add('Password=123456');
    Result.Params.Add('CharacterSet=UTF8');

    Result.Connected := True;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao conectar: ' + E.Message);
    end;
  end;
end;

initialization
  PgDriverLink := nil;

finalization
  PgDriverLink.Free;

end.
