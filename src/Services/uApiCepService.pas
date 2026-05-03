unit uApiCepService;

interface

type
  TApiCepService = class
  public
    procedure AtualizarEnderecos;
  end;

implementation

uses
  System.SysUtils,
  System.Threading,
  System.JSON,
  System.Net.HttpClient,
  System.Generics.Collections,
  uEnderecoRepository,
  System.Classes,
  Winapi.Windows;

//procedure TViaCepService.AtualizarEnderecos;
//var
//  EnderRepo: TEnderecoRepository;
//  Lista: TObjectList<TEnderecoDTO>;
//begin
//  EnderRepo := TEnderecoRepository.Create;
//  try
//    Lista := EnderRepo.BuscarEnderecos;
//  finally
//    EnderRepo.Free;
//  end;
//
//  try
//    if not Assigned(Lista) then
//      Exit;
//
//    if Lista.Count = 0 then
//      Exit;
//
//    TParallel.For(0, Lista.Count - 1, procedure(i: Integer)
//      var
//        Item: TEnderecoDTO;
//        Http: THTTPClient;
//        Resp: IHTTPResponse;
//        JsonValue: TJSONValue;
//        Json: TJSONObject;
//        EnderThread: TEnderecoRepository;
//        Url: string;
//      begin
//        Item := Lista[i];
//
//        if not Assigned(Item) then
//          Exit;
//
//        if Trim(Item.Cep) = '' then
//          Exit;
//
//        Http := THTTPClient.Create;
//        EnderThread := TEnderecoRepository.Create;
//        JsonValue := nil;
//
//        try
//          Url := 'https://viacep.com.br/ws/' + Item.Cep + '/json/';
//
//          Resp := Http.Get(Url);
//
//          if Resp.StatusCode <> 200 then
//            Exit;
//
//          JsonValue := TJSONObject.ParseJSONValue(Resp.ContentAsString);
//
//          if not (JsonValue is TJSONObject) then
//            Exit;
//
//          Json := TJSONObject(JsonValue);
//
//          if Assigned(Json.GetValue('erro')) then
//            Exit;
//
//          EnderThread.AtualizarIntegracao(
//            Item.IdEndereco,
//            Json.GetValue<string>('uf', ''),
//            Json.GetValue<string>('localidade', ''),
//            Json.GetValue<string>('bairro', ''),
//            Json.GetValue<string>('logradouro', ''),
//            Json.GetValue<string>('complemento', '')
//          );
//
//        except
//          on E: Exception do
//          begin
//            TThread.Queue(nil,
//              procedure
//              begin
//                OutputDebugString(PChar(Format('Erro ao atualizar endereço ID %d / CEP %s: %s',[Item.IdEndereco, Item.Cep, E.Message])
//                ));
//              end
//            );
//          end;
//        end;
//
//        JsonValue.Free;
//        EnderThread.Free;
//        Http.Free;
//      end
//    );
//
//  finally
//    Lista.Free;
//  end;
//end;

//Rotina refatorada para integrar por CEP.
//Consulta a api de CEP pelo numero CEPS distintos, não consulta pelo numero de registros em Pessoa
//Performance melhorou absurdamente
procedure TApiCepService.AtualizarEnderecos;
var
  EnderRepo: TEnderecoRepository;
  ListaCeps: TList<string>;
begin
  EnderRepo := TEnderecoRepository.Create;
  try
    ListaCeps := EnderRepo.BuscarCepsDistintos;
  finally
    EnderRepo.Free;
  end;

  try
    if not Assigned(ListaCeps) then
      Exit;

    if ListaCeps.Count = 0 then
      Exit;

    TParallel.For(0, ListaCeps.Count - 1,
      procedure(i: Integer)
      var
        Cep: string;
        Http: THTTPClient;
        Resp: IHTTPResponse;
        JsonValue: TJSONValue;
        Json: TJSONObject;
        EnderThread: TEnderecoRepository;
        Url: string;
      begin
        Cep := Trim(ListaCeps[i]);

        if Cep = '' then
          Exit;

        Http := THTTPClient.Create;
        EnderThread := TEnderecoRepository.Create;
        JsonValue := nil;

        try
          //Url := 'https://viacep.com.br/ws/' + Cep + '/json/';
          // alternativa ao ViaCEP devido a instabilidade durante testes
          Url := 'https://opencep.com/v1/' + Cep + '.json';

          Resp := Http.Get(Url);

          if Resp.StatusCode <> 200 then
            Exit;

          JsonValue := TJSONObject.ParseJSONValue(Resp.ContentAsString);

          if not (JsonValue is TJSONObject) then
            Exit;

          Json := TJSONObject(JsonValue);

          if Assigned(Json.GetValue('erro')) then
            Exit;

          EnderThread.AtualizarIntegracaoPorCep(
            Cep,
            Json.GetValue<string>('uf', ''),
            Json.GetValue<string>('localidade', ''),
            Json.GetValue<string>('bairro', ''),
            Json.GetValue<string>('logradouro', ''),
            Json.GetValue<string>('complemento', '')
          );

        except
          on E: Exception do
          begin
            TThread.Queue(nil,
              procedure
              begin
                OutputDebugString(PChar(
                  Format('Erro ao atualizar CEP %s: %s', [Cep, E.Message])
                ));
              end
            );
          end;
        end;

        JsonValue.Free;
        EnderThread.Free;
        Http.Free;
      end
    );

  finally
    ListaCeps.Free;
  end;
end;

end.
