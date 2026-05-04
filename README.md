
  
Orientações Gerais: 
- Ambiente uma versão do Delphi Seattle ou superior. 
- Acesso a um Banco de Dados (de preferência PostgresSQL). 
  
Todas as boas práticas de desenvolvimento serão consideradas na prova: 
- Clean Code; 
- Padrões de Projeto; 
- P.O.O.; 
- Herança, encapsulamento, polimorfismo; 
- Projeto 2 ou 3 camadas (recomendado fazer 3 camadas); 
- Tratamento adequado em criar e destruir objetos; 
- Utilização de recursos mais no Delphi (Generics, Threads). 
  
#
Observações quanto ao formato: 
# 
Orientações Técnicas: 
1. Criar banco de dados com estrutura do arquivo abaixo (preferencialmente em PostgreSQL): 
#  
CREATE TABLE pessoa ( 
    idpessoa bigserial NOT NULL, 
    flnatureza int2 NOT NULL, 
    dsdocumento varchar(20) NOT NULL, 
    nmprimeiro varchar(100) NOT NULL, 
    nmsegundo varchar(100) NOT NULL, 
    dtregistro date NULL, 
    CONSTRAINT pessoa_pk PRIMARY KEY (idpessoa)
); 
#  
CREATE TABLE endereco ( 
    idendereco bigserial NOT NULL, 
    idpessoa int8 NOT NULL, 
    dscep varchar(15) NULL, 
    CONSTRAINT endereco_pk PRIMARY KEY (idendereco), 
    CONSTRAINT endereco_fk_pessoa FOREIGN KEY (idpessoa) REFERENCES pessoa(idpessoa) ON DELETE cascade 
); 
#
CREATE INDEX endereco_idpessoa ON endereco (idpessoa); 
#  
CREATE TABLE endereco_integracao ( 
    idendereco bigint NOT null, 
    dsuf varchar(50) NULL, 
    nmcidade varchar(100) NULL, 
    nmbairro varchar(50) NULL, 
    nmlogradouro varchar(100) NULL, 
    dscomplemento varchar(100) NULL, 
    CONSTRAINT enderecointegracao_pk PRIMARY KEY (idendereco), 
    CONSTRAINT enderecointegracao_fk_endereco FOREIGN KEY (idendereco) REFERENCES endereco(idendereco) ON DELETE cascade 
); 
#  
2 Definir arquitetura do sistema em três camadas: 
#
Comunicação Rest com JSON entre aplicação Cliente / Servidor;
#
#
Aplicar Clean Code;
#
#
Orientação a objetos;
#
#
Padrões de projeto;
#
#
Garantir integridade entre registros (não ter pessoa sem endereço);
#
#
Camada de persistência, utilizar Firedac. 
#
  2.1 Desenvolver um cadastro de pessoas 
#
Tabelas: Pessoa e Endereco
#
#
Métodos:
#
o
Insert
o
o
Update
o
o
Delete
o
o
Insert em lote: lista de pessoas (considerando que essa lista poderá ter 50.000 registros. Adotar uma estratégia para que a inserção desses registros seja performática).
o
2.2 Desenvolver rotina utilizando Threads 
#
Objetivo é atualizar os endereços das pessoas cadastradas
#
#
Ler o campo CEP do cadastro das pessoas
#
#
Fazer integração com a API via cep através da URL viacep.com.br/ws/_numero_CEP/json/
#
o
Utilizar campo CEP da tabela endereco
o
#
Atualizar os campos da tabela endereco_integracao com os dados do JSON de retorno 



# Sistema de Cadastro de Pessoas e Integração de Endereços

Aplicação desenvolvida em Delphi com foco em arquitetura em camadas, integração de dados e processamento performático.

---

## 📌 Objetivo

Simular um cenário real de sistemas corporativos, contemplando:

- Cadastro de pessoas e endereços
- Processamento de grandes volumes de dados
- Integração com serviços externos (API de CEP)
- Atualização de dados de forma assíncrona

---

## ⚙️ Funcionalidades

- CRUD completo de pessoas e endereços
- Inserção em lote de até 50.000 registros
- Integração com API de CEP para enriquecimento de dados
- Atualização automática da tabela de integração de endereços
- Processamento paralelo utilizando threads

---

## 🏗️ Arquitetura

O projeto foi estruturado em camadas, visando organização, manutenção e escalabilidade:

- **Model** → Representação das entidades
- **Repository** → Acesso a dados utilizando FireDAC
- **Service** → Regras de negócio e orquestração

A aplicação segue princípios de separação de responsabilidades e boas práticas de desenvolvimento.

---

## 🚀 Performance

Para garantir eficiência em grandes volumes de dados:

- Utilização de **Array DML** para inserção em lote
- Processamento em blocos para evitar sobrecarga no banco
- Uso de **Threads** para paralelismo na integração de CEP
- Minimização de operações desnecessárias em memória

---

## 🔗 Integração

- Consumo de API de CEP para enriquecimento dos dados de endereço
- Tratamento de falhas e instabilidade de serviços externos
- Alternativa de API utilizada durante testes para maior confiabilidade

---

## 🗄️ Banco de Dados

- PostgreSQL
- Estrutura relacional com integridade entre entidades
- Utilização de BIGSERIAL mapeado para Int64

---

## 🛠️ Tecnologias

- Delphi (64-bit)
- FireDAC
- PostgreSQL
- REST/JSON
- Multithreading

---

## 💡 Diferenciais

- Foco em **processamento de grandes volumes de dados**
- Preocupação com **performance e escalabilidade**
- Uso de **integração externa com tratamento de falhas**
- Organização em camadas visando manutenção e evolução

---

## 📎 Observações

Este projeto foi desenvolvido com base em um cenário técnico simulado, sendo adaptado para fins de demonstração de portfólio.

---
