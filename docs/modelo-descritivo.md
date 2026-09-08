# Modelo Descritivo — PetCare Hub

## Objetivo do Banco

O banco de dados do PetCare Hub tem como objetivo armazenar informações de tutores, clínicas, pets, consultas, protocolos preventivos, eventos preventivos, dispositivos IoT, leituras coletadas pelos dispositivos, alertas de saúde, scores de saúde, auditoria e logs de erros.

A estrutura foi pensada para apoiar a jornada contínua de cuidado do pet, permitindo histórico clínico estruturado, monitoramento preventivo, geração de alertas, acompanhamento por clínicas parceiras e rastreabilidade de alterações realizadas nos dados de tutores.

## Tabelas Definidas

| Tabela | Função | Usada no Java | Usada no .NET | Usada no Banco |
|---|---|---|---|---|
| TUTOR | Armazena os tutores dos pets e informações de acesso | Sim | Não diretamente | Sim |
| CLINICA | Armazena clínicas parceiras | Sim | Sim | Sim |
| PET | Armazena os pets cadastrados | Sim | Sim | Sim |
| CONSULTA | Armazena o histórico de consultas clínicas | Sim | Sim | Sim |
| PROTOCOLO_PREVENTIVO | Armazena regras preventivas por espécie/raça | Sim | Consulta | Sim |
| EVENTO_PREVENTIVO | Armazena vacinas, check-ups e retornos previstos | Sim | Sim | Sim |
| DISPOSITIVO_IOT | Armazena dispositivos vinculados ao pet | Sim | Consulta | Sim |
| LEITURA_COLEIRA | Armazena leituras relacionadas à coleira inteligente | Sim | Sim | Sim |
| LEITURA_COMEDOURO | Armazena leituras relacionadas ao comedouro inteligente | Sim | Sim | Sim |
| LEITURA_AMBIENTE | Armazena leituras de condições ambientais | Sim | Sim | Sim |
| ALERTA_SAUDE | Armazena alertas gerados por situações de risco | Sim | Sim | Sim |
| SCORE_SAUDE | Armazena o score de saúde calculado ao longo do tempo | Sim | Sim | Sim |
| AUDITORIA_TUTOR | Registra operações de INSERT, UPDATE e DELETE realizadas em TUTOR | Não | Não | Sim |
| LOG_ERROS | Armazena erros das procedures PL/SQL | Não | Não | Sim |

## Justificativa das Tabelas

### TUTOR

Representa o tutor do pet. É responsável pelo acompanhamento do animal e possui dados cadastrais e informações relacionadas ao acesso à plataforma, incluindo status de acesso e credenciais armazenadas de forma apropriada.

### CLINICA

Representa a clínica veterinária parceira. É usada para organizar os pets atendidos e as consultas realizadas, além de apoiar o acompanhamento e os recursos de gestão da clínica.

### PET

É a entidade central do sistema. Representa o animal acompanhado pela solução, contendo dados como espécie, raça, nascimento, peso e condições crônicas, além de referências ao tutor e à clínica.

### CONSULTA

Armazena o histórico clínico do pet, incluindo informações sobre data, tipo da consulta, descrição, diagnóstico, valor, retorno recomendado e data de retorno.

### PROTOCOLO_PREVENTIVO

Armazena regras preventivas associadas a espécie, raça e tipo de evento, permitindo definir recomendações como vacinação, vermifugação, check-up e acompanhamento periódico.

### EVENTO_PREVENTIVO

Representa eventos preventivos associados ao pet, como vacina, consulta de retorno, check-up ou vermífugo. Também registra previsão, realização e status do evento.

### DISPOSITIVO_IOT

Representa dispositivos IoT vinculados ao pet, como coleira inteligente e comedouro inteligente, armazenando informações de identificação, tipo, número de série, data de ativação e status.

### LEITURA_COLEIRA

Armazena dados coletados pela coleira inteligente, incluindo informações de atividade, nível de bateria e momento da leitura.

### LEITURA_COMEDOURO

Armazena dados coletados pelo comedouro inteligente, incluindo nível de ração, quantidade consumida e momento da leitura.

### LEITURA_AMBIENTE

Armazena dados relacionados ao ambiente do pet, como temperatura, umidade, qualidade do ar, presença do pet e momento da leitura.

### ALERTA_SAUDE

Armazena alertas de saúde associados ao pet, incluindo tipo e nível do alerta, mensagem, valor detectado, limite de referência, situação de resolução e datas relacionadas ao alerta.

### SCORE_SAUDE

Armazena o score de saúde calculado do pet ao longo do tempo. O registro permite acompanhar indicadores relacionados à atividade, alimentação, ambiente, consulta e prevenção, além da categoria e data do cálculo.

### LOG_ERROS

Armazena erros ocorridos durante a execução das procedures PL/SQL, contendo informações como nome da procedure, usuário, data, código e mensagem do erro.

## Relacionamentos

- Um tutor pode possuir vários pets.
- Uma clínica pode acompanhar vários pets.
- Um pet pertence a um tutor.
- Um pet pode estar associado a uma clínica.
- Um pet pode possuir várias consultas.
- Uma clínica pode possuir várias consultas.
- Um pet pode possuir vários eventos preventivos.
- Um protocolo preventivo pode gerar vários eventos preventivos.
- Um pet pode possuir vários dispositivos IoT.
- Um pet pode possuir várias leituras de coleira.
- Um pet pode possuir várias leituras de comedouro.
- Um pet pode possuir várias leituras ambientais.
- Um pet pode possuir vários alertas de saúde.
- Um pet pode possuir vários registros de score de saúde.
- Um tutor pode possuir vários registros de auditoria.
- Os registros de auditoria são gerados automaticamente pelo trigger `TRG_AUDITORIA_TUTOR`.

## Procedimentos, Funções e Trigger

O banco também possui lógica procedural em PL/SQL para atender aos requisitos da Sprint 3.

### Procedures

- `PRC_REL_PETS_TUTOR_CLINICA_JSON`: consulta dados relacionais de pets, tutores e clínicas e apresenta as informações em formato JSON.
- `PRC_REL_CONSULTAS_SUBTOTAL`: realiza a consulta das consultas e calcula subtotais e total geral de forma procedural.

### Functions

- `FN_PET_PARA_JSON`: converte manualmente dados relacionais do pet para JSON, sem depender de funções automáticas de geração de JSON.
- `FN_VALIDAR_FORCA_SENHA`: realiza a validação da força da senha de acordo com os critérios definidos no sistema.

### Trigger de Auditoria

- `TRG_AUDITORIA_TUTOR`: executa automaticamente após `INSERT`, `UPDATE` ou `DELETE` na tabela `TUTOR`, registrando a operação na tabela `AUDITORIA_TUTOR`.

## Integração com Java

A API Java é responsável por operações relacionadas ao cadastro e gerenciamento de tutores, clínicas e pets, além do registro e consulta das informações utilizadas pela aplicação.

## Integração com .NET

A API .NET é responsável por funcionalidades relacionadas ao dashboard da clínica, incluindo visualização de pets, alertas, consultas, eventos preventivos e métricas de acompanhamento.
