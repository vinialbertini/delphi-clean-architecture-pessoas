unit uEnderecoModel;

interface

type
  TEndereco = class
  private
    FIdEndereco: Int64;
    FIdPessoa: Int64;
    FDsCep: string;
  public
    property IdEndereco: Int64 read FIdEndereco write FIdEndereco;
    property IdPessoa: Int64 read FIdPessoa write FIdPessoa;
    property DsCep: string read FDsCep write FDsCep;
  end;

implementation

end.
