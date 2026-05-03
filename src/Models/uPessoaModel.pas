unit uPessoaModel;

interface

uses
  System.SysUtils,
  uEnderecoModel;

type
  TPessoa = class
  private
    FIdPessoa: Int64;
    FFlNatureza: SmallInt;
    FDsDocumento: string;
    FNmPrimeiro: string;
    FNmSegundo: string;
    FDtRegistro: TDate;
    FEndereco: TEndereco;
  public
    constructor Create;
    destructor Destroy; override;

    property IdPessoa: Int64 read FIdPessoa write FIdPessoa;
    property FlNatureza: SmallInt read FFlNatureza write FFlNatureza;
    property DsDocumento: string read FDsDocumento write FDsDocumento;
    property NmPrimeiro: string read FNmPrimeiro write FNmPrimeiro;
    property NmSegundo: string read FNmSegundo write FNmSegundo;
    property DtRegistro: TDate read FDtRegistro write FDtRegistro;
    property Endereco: TEndereco read FEndereco write FEndereco;
  end;

implementation

constructor TPessoa.Create;
begin
  inherited;
  FEndereco := TEndereco.Create;
end;

destructor TPessoa.Destroy;
begin
  FEndereco.Free;
  inherited;
end;

end.
