SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PETCARE HUB - INSERTS DE TESTE
-- Carga de dados usando procedures
------------------------------------------------------------

------------------------------------------------------------
-- LIMPEZA DOS DADOS
-- Mantém as tabelas, mas apaga os registros anteriores.
------------------------------------------------------------

BEGIN
    DELETE FROM ALERTA_SAUDE;
    DELETE FROM SCORE_SAUDE;
    DELETE FROM LEITURA_SENSOR;
    DELETE FROM DISPOSITIVO_IOT;
    DELETE FROM EVENTO_PREVENTIVO;
    DELETE FROM CONSULTA;
    DELETE FROM PET;
    DELETE FROM PROTOCOLO_PREVENTIVO;
    DELETE FROM CLINICA;
    DELETE FROM RESPONSAVEL;
    DELETE FROM LOG_ERROS;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Dados antigos removidos com sucesso.');
END;
/

------------------------------------------------------------
-- CARGA PRINCIPAL
------------------------------------------------------------

DECLARE
    v_responsavel_ana    NUMBER;
    v_responsavel_bruno  NUMBER;
    v_responsavel_carla  NUMBER;

    v_clinica_vida       NUMBER;
    v_clinica_hospital   NUMBER;

    v_pet_rex            NUMBER;
    v_pet_luna           NUMBER;
    v_pet_thor           NUMBER;

    v_prot_vacina_cao    NUMBER;
    v_prot_vacina_gato   NUMBER;
    v_prot_checkup_cao   NUMBER;
    v_prot_checkup_gato  NUMBER;

    v_disp_rex_coleira   NUMBER;
    v_disp_rex_comedouro NUMBER;
    v_disp_luna_coleira  NUMBER;
    v_disp_thor_coleira  NUMBER;
BEGIN
    --------------------------------------------------------
    -- 1. RESPONSAVEIS
    --------------------------------------------------------

    prc_ins_responsavel(
        'Ana Souza',
        'ana.souza@email.com',
        '11999990001',
        '11111111111'
    );

    prc_ins_responsavel(
        'Bruno Lima',
        'bruno.lima@email.com',
        '11999990002',
        '22222222222'
    );

    prc_ins_responsavel(
        'Carla Mendes',
        'carla.mendes@email.com',
        '11999990003',
        '33333333333'
    );

    SELECT id_responsavel INTO v_responsavel_ana
    FROM RESPONSAVEL
    WHERE email = 'ana.souza@email.com';

    SELECT id_responsavel INTO v_responsavel_bruno
    FROM RESPONSAVEL
    WHERE email = 'bruno.lima@email.com';

    SELECT id_responsavel INTO v_responsavel_carla
    FROM RESPONSAVEL
    WHERE email = 'carla.mendes@email.com';

    --------------------------------------------------------
    -- 2. CLINICAS
    --------------------------------------------------------

    prc_ins_clinica(
        'Clinica Vida Pet',
        '11111111000111',
        'contato@vidapet.com',
        '1130000001',
        'Rua A, 100'
    );

    prc_ins_clinica(
        'Hospital Animal Care',
        '22222222000122',
        'contato@animalcare.com',
        '1130000002',
        'Rua B, 200'
    );

    SELECT id_clinica INTO v_clinica_vida
    FROM CLINICA
    WHERE cnpj = '11111111000111';

    SELECT id_clinica INTO v_clinica_hospital
    FROM CLINICA
    WHERE cnpj = '22222222000122';

    --------------------------------------------------------
    -- 3. PETS
    --------------------------------------------------------

    prc_ins_pet(
        v_responsavel_ana,
        v_clinica_vida,
        'Rex',
        'CAO',
        'Golden Retriever',
        TO_DATE('2021-04-10', 'YYYY-MM-DD'),
        28.50,
        'M',
        'Alergia de pele'
    );

    prc_ins_pet(
        v_responsavel_ana,
        v_clinica_vida,
        'Luna',
        'GATO',
        'Siames',
        TO_DATE('2022-08-20', 'YYYY-MM-DD'),
        4.20,
        'F',
        NULL
    );

    prc_ins_pet(
        v_responsavel_bruno,
        v_clinica_hospital,
        'Thor',
        'CAO',
        'Bulldog',
        TO_DATE('2020-01-15', 'YYYY-MM-DD'),
        22.00,
        'M',
        'Problema respiratorio'
    );

    SELECT id_pet INTO v_pet_rex
    FROM PET
    WHERE nome = 'Rex';

    SELECT id_pet INTO v_pet_luna
    FROM PET
    WHERE nome = 'Luna';

    SELECT id_pet INTO v_pet_thor
    FROM PET
    WHERE nome = 'Thor';

    --------------------------------------------------------
    -- 4. PROTOCOLOS PREVENTIVOS
    --------------------------------------------------------

    prc_ins_protocolo_preventivo(
        'CAO',
        NULL,
        'VACINA',
        'Vacina anual obrigatoria para caes',
        12,
        365
    );

    prc_ins_protocolo_preventivo(
        'GATO',
        NULL,
        'VACINA',
        'Vacina anual obrigatoria para gatos',
        12,
        365
    );

    prc_ins_protocolo_preventivo(
        'CAO',
        NULL,
        'CHECKUP',
        'Check-up semestral para caes adultos',
        6,
        180
    );

    prc_ins_protocolo_preventivo(
        'GATO',
        NULL,
        'CHECKUP',
        'Check-up semestral para gatos adultos',
        6,
        180
    );

    SELECT id_protocolo INTO v_prot_vacina_cao
    FROM PROTOCOLO_PREVENTIVO
    WHERE especie = 'CAO'
      AND tipo_evento = 'VACINA';

    SELECT id_protocolo INTO v_prot_vacina_gato
    FROM PROTOCOLO_PREVENTIVO
    WHERE especie = 'GATO'
      AND tipo_evento = 'VACINA';

    SELECT id_protocolo INTO v_prot_checkup_cao
    FROM PROTOCOLO_PREVENTIVO
    WHERE especie = 'CAO'
      AND tipo_evento = 'CHECKUP';

    SELECT id_protocolo INTO v_prot_checkup_gato
    FROM PROTOCOLO_PREVENTIVO
    WHERE especie = 'GATO'
      AND tipo_evento = 'CHECKUP';

    --------------------------------------------------------
    -- 5. CONSULTAS
    --------------------------------------------------------

    prc_ins_consulta(
        v_pet_rex,
        v_clinica_vida,
        TO_DATE('2026-03-10', 'YYYY-MM-DD'),
        'CHECKUP',
        'Consulta preventiva',
        'Pet em bom estado geral',
        180.00,
        'S',
        TO_DATE('2026-09-10', 'YYYY-MM-DD')
    );

    prc_ins_consulta(
        v_pet_rex,
        v_clinica_vida,
        TO_DATE('2026-04-01', 'YYYY-MM-DD'),
        'VACINA',
        'Aplicacao de vacina anual',
        'Sem reacao adversa',
        120.00,
        'N',
        NULL
    );

    prc_ins_consulta(
        v_pet_luna,
        v_clinica_vida,
        TO_DATE('2026-04-05', 'YYYY-MM-DD'),
        'EXAME',
        'Exame de sangue',
        'Acompanhamento preventivo',
        220.00,
        'S',
        TO_DATE('2026-05-05', 'YYYY-MM-DD')
    );

    prc_ins_consulta(
        v_pet_thor,
        v_clinica_hospital,
        TO_DATE('2026-04-12', 'YYYY-MM-DD'),
        'EMERGENCIA',
        'Dificuldade respiratoria',
        'Necessita acompanhamento',
        350.00,
        'S',
        TO_DATE('2026-04-20', 'YYYY-MM-DD')
    );

    prc_ins_consulta(
        v_pet_thor,
        v_clinica_hospital,
        TO_DATE('2026-04-20', 'YYYY-MM-DD'),
        'RETORNO',
        'Retorno da emergencia',
        'Melhora parcial',
        150.00,
        'S',
        TO_DATE('2026-05-20', 'YYYY-MM-DD')
    );

    --------------------------------------------------------
    -- 6. EVENTOS PREVENTIVOS
    --------------------------------------------------------

    prc_ins_evento_preventivo(
        v_pet_rex,
        v_prot_vacina_cao,
        'VACINA',
        'Vacina anual do Rex',
        TO_DATE('2026-04-01', 'YYYY-MM-DD'),
        TO_DATE('2026-04-01', 'YYYY-MM-DD'),
        'REALIZADO'
    );

    prc_ins_evento_preventivo(
        v_pet_rex,
        v_prot_checkup_cao,
        'CHECKUP',
        'Proximo check-up do Rex',
        TO_DATE('2026-09-10', 'YYYY-MM-DD'),
        NULL,
        'PENDENTE'
    );

    prc_ins_evento_preventivo(
        v_pet_luna,
        v_prot_vacina_gato,
        'VACINA',
        'Vacina anual da Luna',
        TO_DATE('2026-08-20', 'YYYY-MM-DD'),
        NULL,
        'PENDENTE'
    );

    prc_ins_evento_preventivo(
        v_pet_thor,
        v_prot_checkup_cao,
        'CHECKUP',
        'Check-up atrasado do Thor',
        TO_DATE('2026-02-01', 'YYYY-MM-DD'),
        NULL,
        'ATRASADO'
    );

    prc_ins_evento_preventivo(
        v_pet_thor,
        NULL,
        'RETORNO',
        'Retorno pos-emergencia do Thor',
        TO_DATE('2026-05-20', 'YYYY-MM-DD'),
        NULL,
        'PENDENTE'
    );

    --------------------------------------------------------
    -- 7. DISPOSITIVOS IOT
    --------------------------------------------------------

    prc_ins_dispositivo_iot(
        v_pet_rex,
        'COLEIRA',
        'COL-RX-001',
        TO_DATE('2026-04-01', 'YYYY-MM-DD')
    );

    prc_ins_dispositivo_iot(
        v_pet_rex,
        'COMEDOURO',
        'COM-RX-001',
        TO_DATE('2026-04-01', 'YYYY-MM-DD')
    );

    prc_ins_dispositivo_iot(
        v_pet_luna,
        'COLEIRA',
        'COL-LU-001',
        TO_DATE('2026-04-02', 'YYYY-MM-DD')
    );

    prc_ins_dispositivo_iot(
        v_pet_thor,
        'COLEIRA',
        'COL-TH-001',
        TO_DATE('2026-04-03', 'YYYY-MM-DD')
    );

    SELECT id_dispositivo INTO v_disp_rex_coleira
    FROM DISPOSITIVO_IOT
    WHERE codigo_serie = 'COL-RX-001';

    SELECT id_dispositivo INTO v_disp_rex_comedouro
    FROM DISPOSITIVO_IOT
    WHERE codigo_serie = 'COM-RX-001';

    SELECT id_dispositivo INTO v_disp_luna_coleira
    FROM DISPOSITIVO_IOT
    WHERE codigo_serie = 'COL-LU-001';

    SELECT id_dispositivo INTO v_disp_thor_coleira
    FROM DISPOSITIVO_IOT
    WHERE codigo_serie = 'COL-TH-001';

    --------------------------------------------------------
    -- 8. LEITURAS DE SENSOR
    -- Leituras de movimento, alimentação e ambiente.
    -- Não há medição de temperatura corporal do animal.
    --------------------------------------------------------

    -- Leituras de movimento/atividade pela coleira do Rex
    prc_ins_leitura_sensor(
        v_pet_rex,
        v_disp_rex_coleira,
        'ATIVIDADE',
        68.00,
        '%',
        TO_TIMESTAMP('2026-05-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_sensor(
        v_pet_rex,
        v_disp_rex_coleira,
        'ATIVIDADE',
        72.00,
        '%',
        TO_TIMESTAMP('2026-05-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_sensor(
        v_pet_rex,
        v_disp_rex_coleira,
        'ATIVIDADE',
        65.00,
        '%',
        TO_TIMESTAMP('2026-05-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    -- Leituras de temperatura ambiente pelo módulo do comedouro
    prc_ins_leitura_sensor(
        v_pet_rex,
        v_disp_rex_comedouro,
        'TEMPERATURA_AMBIENTE',
        24.50,
        'C',
        TO_TIMESTAMP('2026-05-01 14:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_sensor(
        v_pet_rex,
        v_disp_rex_comedouro,
        'TEMPERATURA_AMBIENTE',
        25.10,
        'C',
        TO_TIMESTAMP('2026-05-01 16:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    -- Leitura de nível de ração pelo comedouro
    prc_ins_leitura_sensor(
        v_pet_rex,
        v_disp_rex_comedouro,
        'NIVEL_RACAO',
        15.00,
        '%',
        TO_TIMESTAMP('2026-05-01 08:30:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    -- Leituras de movimento/atividade dos outros pets
    prc_ins_leitura_sensor(
        v_pet_luna,
        v_disp_luna_coleira,
        'ATIVIDADE',
        75.00,
        '%',
        TO_TIMESTAMP('2026-05-01 09:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_sensor(
        v_pet_thor,
        v_disp_thor_coleira,
        'ATIVIDADE',
        15.00,
        '%',
        TO_TIMESTAMP('2026-05-01 09:30:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    --------------------------------------------------------
    -- 9. SCORES DE SAUDE
    -- O score do Thor gera alerta automaticamente.
    --------------------------------------------------------

    prc_ins_score_saude(
        v_pet_rex,
        72,
        70,
        65,
        80,
        75,
        70
    );

    prc_ins_score_saude(
        v_pet_luna,
        88,
        90,
        85,
        88,
        90,
        87
    );

    prc_ins_score_saude(
        v_pet_thor,
        42,
        30,
        45,
        60,
        40,
        35
    );

    DBMS_OUTPUT.PUT_LINE('Carga de dados de teste finalizada com sucesso.');
END;
/

------------------------------------------------------------
-- CONFERENCIA FINAL
------------------------------------------------------------

SELECT 'RESPONSAVEL' AS tabela, COUNT(*) AS total FROM RESPONSAVEL
UNION ALL
SELECT 'CLINICA', COUNT(*) FROM CLINICA
UNION ALL
SELECT 'PET', COUNT(*) FROM PET
UNION ALL
SELECT 'CONSULTA', COUNT(*) FROM CONSULTA
UNION ALL
SELECT 'PROTOCOLO_PREVENTIVO', COUNT(*) FROM PROTOCOLO_PREVENTIVO
UNION ALL
SELECT 'EVENTO_PREVENTIVO', COUNT(*) FROM EVENTO_PREVENTIVO
UNION ALL
SELECT 'DISPOSITIVO_IOT', COUNT(*) FROM DISPOSITIVO_IOT
UNION ALL
SELECT 'LEITURA_SENSOR', COUNT(*) FROM LEITURA_SENSOR
UNION ALL
SELECT 'ALERTA_SAUDE', COUNT(*) FROM ALERTA_SAUDE
UNION ALL
SELECT 'SCORE_SAUDE', COUNT(*) FROM SCORE_SAUDE
UNION ALL
SELECT 'LOG_ERROS', COUNT(*) FROM LOG_ERROS;