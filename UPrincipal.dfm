object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Teste'
  ClientHeight = 560
  ClientWidth = 820
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object gbConexao: TGroupBox
    Left = 16
    Top = 16
    Width = 250
    Height = 80
    Caption = 'Conex'#227'o'
    TabOrder = 0
    object btTestarConexao: TButton
      Left = 16
      Top = 28
      Width = 210
      Height = 32
      Caption = 'Teste de Conex'#227'o'
      TabOrder = 0
      OnClick = btTestarConexaoClick
    end
  end
  object gbPessoa: TGroupBox
    Left = 282
    Top = 16
    Width = 520
    Height = 80
    Caption = 'Pessoa'
    TabOrder = 1
    object btInserir: TButton
      Left = 16
      Top = 28
      Width = 150
      Height = 32
      Caption = 'Inserir '
      TabOrder = 0
      OnClick = btInserirClick
    end
    object btAtualizar: TButton
      Left = 184
      Top = 28
      Width = 150
      Height = 32
      Caption = 'Atualizar'
      TabOrder = 1
      OnClick = btAtualizarClick
    end
    object btExcluir: TButton
      Left = 352
      Top = 28
      Width = 150
      Height = 32
      Caption = 'Excluir'
      TabOrder = 2
      OnClick = btExcluirClick
    end
  end
  object gbLote: TGroupBox
    Left = 16
    Top = 112
    Width = 386
    Height = 88
    Caption = 'Inclus'#227'o em Lote'
    TabOrder = 2
    object Label2: TLabel
      Left = 16
      Top = 27
      Width = 88
      Height = 15
      Caption = 'Quantidade lote:'
    end
    object btnInserirLote: TButton
      Left = 184
      Top = 40
      Width = 180
      Height = 32
      Caption = 'Inserir Pessoas em Lote'
      TabOrder = 0
      OnClick = btnInserirLoteClick
    end
    object seQtdeLote: TSpinEdit
      Left = 16
      Top = 48
      Width = 121
      Height = 24
      MaxValue = 50000
      MinValue = 1
      TabOrder = 1
      Value = 50000
    end
  end
  object gbIntegracao: TGroupBox
    Left = 416
    Top = 112
    Width = 386
    Height = 88
    Caption = 'Integra'#231#227'o'
    TabOrder = 3
    object btEnderecos: TButton
      Left = 16
      Top = 36
      Width = 340
      Height = 32
      Caption = 'Atualizar Endere'#231'os ViaCEP'
      TabOrder = 0
      OnClick = btEnderecosClick
    end
  end
  object gbLog: TGroupBox
    Left = 16
    Top = 216
    Width = 786
    Height = 320
    Caption = 'Log'
    TabOrder = 4
    object Memo1: TMemo
      Left = 16
      Top = 24
      Width = 754
      Height = 280
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
end
