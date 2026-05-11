# Modelo Descritivo — PetCare Hub

## Objetivo do Banco

O banco de dados do PetCare Hub tem como objetivo armazenar informações de tutores, clínicas, pets, consultas, protocolos preventivos, eventos preventivos, dispositivos IoT, leituras de sensores, alertas de saúde e scores de saúde.

A estrutura foi pensada para apoiar a jornada contínua de cuidado do pet, permitindo histórico clínico estruturado, monitoramento preventivo, geração de alertas e acompanhamento por clínicas parceiras.

## Tabelas Definidas

| Tabela | Função | Usada no Java | Usada no .NET | Usada no Banco |
|---|---|---|---|---|
| TUTOR | Armazena os responsáveis pelos pets | Sim | Não diretamente | Sim |
| CLINICA | Armazena clínicas parceiras | Sim | Sim | Sim |
| PET | Armazena os pets cadastrados | Sim | Sim | Sim |
| CONSULTA | Armazena histórico de consultas clínicas | Sim | Sim | Sim |
| PROTOCOLO_PREVENTIVO | Armazena regras preventivas por espécie/raça | Sim | Consulta | Sim |
| EVENTO_PREVENTIVO | Armazena vacinas, check-ups e retornos previstos | Sim | Sim | Sim |
| DISPOSITIVO_IOT | Armazena dispositivos vinculados ao pet | Sim | Consulta | Sim |
| LEITURA_SENSOR | Armazena leituras vindas dos sensores IoT | Sim | Sim | Sim |
| ALERTA_SAUDE | Armazena alertas gerados por risco | Sim | Sim | Sim |
| SCORE_SAUDE | Armazena o score de saúde calculado | Sim | Sim | Sim |
| LOG_ERROS | Armazena erros das procedures PL/SQL | Não | Não | Sim |

## Justificativa das Tabelas

### TUTOR

Representa o responsável pelo pet. É necessário para vincular cada animal a uma pessoa responsável pelo acompanhamento.

### CLINICA

Representa a clínica veterinária parceira. É usada para organizar os pets atendidos, consultas, alertas e métricas do dashboard.

### PET

Entidade central do sistema. Representa o animal acompanhado pela solução, contendo dados como espécie, raça, nascimento, peso e condições crônicas.

### CONSULTA

Armazena o histórico clínico do pet, incluindo check-ups, vacinas, emergências, retornos e exames.

### PROTOCOLO_PREVENTIVO

Armazena regras preventivas por espécie e raça, como vacinação, vermífugo, check-up e acompanhamento periódico.

### EVENTO_PREVENTIVO

Representa eventos gerados para o pet, como próxima vacina, consulta de retorno, check-up ou vermífugo.

### DISPOSITIVO_IOT

Representa dispositivos conectados ao pet, como coleira, comedouro ou sensor de ambiente.

### LEITURA_SENSOR

Armazena os dados coletados pelos sensores IoT, como atividade, nível de ração, umidade e qualidade do ar.

### ALERTA_SAUDE

Armazena alertas gerados a partir de leituras fora do padrão ou score de saúde baixo.

### SCORE_SAUDE

Armazena o score calculado do pet ao longo do tempo, permitindo análise de evolução e risco.

### LOG_ERROS

Armazena erros ocorridos durante a execução das procedures PL/SQL, contendo procedure, usuário, data, código e mensagem do erro.

## Relacionamentos Iniciais

- Um tutor pode possuir vários pets.
- Uma clínica pode acompanhar vários pets.
- Um pet pode possuir várias consultas.
- Uma clínica pode possuir várias consultas.
- Um pet pode possuir vários eventos preventivos.
- Um protocolo preventivo pode gerar vários eventos preventivos.
- Um pet pode possuir vários dispositivos IoT.
- Um dispositivo IoT pode gerar várias leituras.
- Um pet pode possuir várias leituras de sensor.
- Uma leitura de sensor pode gerar alertas de saúde.
- Um pet pode possuir vários alertas de saúde.
- Um pet pode possuir vários registros de score de saúde.

## Integração com Java

A API Java será responsável por cadastrar tutores, clínicas e pets, registrar leituras de sensores, calcular score de saúde, gerar alertas e consultar o histórico do pet.

## Integração com .NET

A API .NET será responsável pelo dashboard da clínica, exibindo pets em risco, alertas, consultas, eventos preventivos e métricas de acompanhamento.