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

O banco também possui lógica procedural em PL/SQL para atender aos requisitos da Sprint 3. Na Sprint 4 esses objetos foram reorganizados em packages, conforme descrito adiante.

### Procedures

- `PRC_REL_PETS_TUTOR_CLINICA_JSON`: consulta dados relacionais de pets, tutores e clínicas e apresenta as informações em formato JSON.
- `PRC_REL_CONSULTAS_SUBTOTAL`: realiza a consulta das consultas e calcula subtotais e total geral de forma procedural.

### Functions

- `FN_PET_PARA_JSON`: converte manualmente dados relacionais do pet para JSON, sem depender de funções automáticas de geração de JSON.
- `FN_VALIDAR_FORCA_SENHA`: realiza a validação da força da senha de acordo com os critérios definidos no sistema.

### Trigger de Auditoria

- `TRG_AUDITORIA_TUTOR`: executa automaticamente após `INSERT`, `UPDATE` ou `DELETE` na tabela `TUTOR`, registrando a operação na tabela `AUDITORIA_TUTOR`.

### Packages

Na Sprint 4 as procedures, as functions e a lógica do trigger foram reorganizadas em cinco packages PL/SQL, em `sql/packages`. Os objetos soltos continuam existindo no schema porque os scripts de carga da massa de teste os utilizam diretamente; a aplicação Java, por sua vez, passou a chamar exclusivamente a versão empacotada.

- `PKG_LOG`: registro de erros na tabela `LOG_ERROS`. Não depende de nenhum outro package e é utilizado por todos os demais, o que evita dependência circular na compilação.
- `PKG_UTIL`: funções de cálculo e formatação, entre elas `FN_CALCULAR_IDADE_PET`, `FN_SCORE_MEDIO_PET`, `FN_PET_PARA_JSON` e `FN_VALIDAR_FORCA_SENHA`. São rotinas apenas de leitura, sem gravação em tabela.
- `PKG_CARGA`: procedures de inserção validada nas tabelas do domínio. As rotinas de leitura IoT também abrem alerta de saúde automaticamente quando o valor recebido sai da faixa de referência.
- `PKG_RELATORIOS`: procedures de relatório, com saída por `DBMS_OUTPUT`. Foi separado da carga por conter apenas leitura, de modo que o uso dos relatórios não exige permissão de escrita.
- `PKG_AUDITORIA`: lógica da trilha de auditoria. O Oracle não permite trigger dentro de package, portanto o corpo do `TRG_AUDITORIA_TUTOR` foi transferido para `PRC_REGISTRAR_TUTOR` e o trigger passou a conter apenas a chamada ao package. A regra passa a ser testável sem disparar DML em `TUTOR`, e uma futura trilha para `PET` ou `CONSULTA` reaproveita o mesmo package.

## Exportação para JSON e Estrutura MongoDB

O banco relacional permanece como fonte da verdade. A estrutura MongoDB é uma cópia modelada em documento, gerada a partir do Oracle e destinada à leitura.

A geração do JSON é feita no próprio banco, com `JSON_OBJECT` e `JSON_ARRAYAGG`, por três scripts em `sql/export`. As 13 tabelas foram reduzidas a três coleções, de acordo com o padrão de acesso de cada uma:

| Coleção | O que é um documento | Origem no relacional |
|---|---|---|
| `pets` | Um pet, com tutor, clínica, consultas, eventos preventivos, dispositivos e score embutidos | `PET` e tabelas relacionadas |
| `telemetria` | Um bucket: as leituras de um pet, de um tipo de sensor, em um dia | `LEITURA_COLEIRA`, `LEITURA_COMEDOURO` e `LEITURA_AMBIENTE` |
| `alertas` | Um alerta, com pet, tutor e clínica no estado em que estavam no disparo | `ALERTA_SAUDE` |

A opção por três coleções, e não por uma coleção para cada tabela, decorre do modelo de documento. O que no relacional exige junção de seis tabelas é resolvido com uma única leitura, e as três tabelas de leitura — separadas no relacional porque possuem colunas diferentes — convivem na mesma coleção, já que cada documento carrega o formato do seu próprio tipo de sensor.

A importação utiliza `mongoimport` em modo `upsert`, com o `_id` originado da chave primária do Oracle, o que permite repetir a carga sem duplicar documentos.

## Integração com Java

A API Java é responsável por operações relacionadas ao cadastro e gerenciamento de tutores, clínicas e pets, além do registro e consulta das informações utilizadas pela aplicação.

A integração com o código PL/SQL é direta. A classe `PlSqlRepository` chama `PKG_CARGA.PRC_INS_LEITURA_COLEIRA` no endpoint `POST /leituras/coleira`, e `PKG_UTIL.FN_SCORE_MEDIO_PET` e `PKG_UTIL.FN_CALCULAR_IDADE_PET` no endpoint `GET /pets/{id}/score-saude/media`. O nome do package é informado como catálogo na configuração do `SimpleJdbcCall`, o que garante que a chamada passe pela versão empacotada.

O registro da leitura da coleira não é feito por operação do mapeamento objeto-relacional: a procedure valida o pet, insere utilizando a sequence e dispara o alerta de atividade baixa quando o status recebido é SEDENTARIO. A regra permanece no banco, junto do dado.

## Integração com .NET

A API .NET é responsável por funcionalidades relacionadas ao dashboard da clínica, incluindo visualização de pets, alertas, consultas, eventos preventivos e métricas de acompanhamento.
