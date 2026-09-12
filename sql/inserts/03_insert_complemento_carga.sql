SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PETCARE HUB - CARGA COMPLEMENTAR 2 (fechamento Sprint 3)
-- Completa o minimo de 5 registros validos exigido em
-- PROTOCOLO_PREVENTIVO, DISPOSITIVO_IOT, LEITURA_COMEDOURO,
-- LEITURA_AMBIENTE e SCORE_SAUDE.
--
-- ALERTA_SAUDE chega a 5 como efeito automatico das proprias
-- procedures (uma leitura de comedouro abaixo de 20% e uma
-- leitura de ambiente com qualidade do ar acima de 500ppm),
-- em vez de inserido direto - assim o teste tambem exercita
-- as regras automaticas descritas no README
-- ("Regras Automaticas Implementadas").
--
-- Roda DEPOIS de 02_insert_extra_sprint3.sql, sem apagar nada.
------------------------------------------------------------

DECLARE
    v_pet_rex        NUMBER;
    v_pet_luna       NUMBER;
    v_pet_thor       NUMBER;
    v_pet_mel        NUMBER;
    v_pet_nina       NUMBER;
    v_clinica_vida   NUMBER;
BEGIN
    SELECT id_pet INTO v_pet_rex  FROM PET WHERE nome = 'Rex';
    SELECT id_pet INTO v_pet_luna FROM PET WHERE nome = 'Luna';
    SELECT id_pet INTO v_pet_thor FROM PET WHERE nome = 'Thor';
    SELECT id_pet INTO v_pet_mel  FROM PET WHERE nome = 'Mel';
    SELECT id_pet INTO v_pet_nina FROM PET WHERE nome = 'Nina';

    SELECT id_clinica INTO v_clinica_vida FROM CLINICA WHERE cnpj = '11111111000111';

    --------------------------------------------------------
    -- 1 PROTOCOLO_PREVENTIVO A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_protocolo_preventivo(
        'CAO',
        NULL,
        'VERMIFUGO',
        'Vermifugacao semestral para caes',
        3,
        180
    );

    --------------------------------------------------------
    -- 1 DISPOSITIVO_IOT A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_dispositivo_iot(
        v_pet_rex,
        'AMBIENTE',
        'AMB-RX-001',
        TO_DATE('2026-05-01', 'YYYY-MM-DD')
    );

    --------------------------------------------------------
    -- 3 LEITURA_COMEDOURO A MAIS (total: 5)
    -- A leitura do Thor fica abaixo de 20% de proposito para
    -- gerar o alerta automatico RACAO_BAIXA.
    --------------------------------------------------------

    prc_ins_leitura_comedouro(
        v_pet_luna, 65, 90.00,
        TO_TIMESTAMP('2026-05-02 09:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_comedouro(
        v_pet_thor, 18, 60.00,
        TO_TIMESTAMP('2026-05-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_comedouro(
        v_pet_rex, 70, 130.00,
        TO_TIMESTAMP('2026-05-02 14:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    --------------------------------------------------------
    -- 4 LEITURA_AMBIENTE A MAIS (total: 5)
    -- A leitura da Nina fica com qualidade do ar acima de
    -- 500ppm de proposito para gerar o alerta automatico
    -- QUALIDADE_AR_RUIM.
    --------------------------------------------------------

    prc_ins_leitura_ambiente(
        v_pet_luna, 23.00, 50, 380, 1,
        TO_TIMESTAMP('2026-05-02 09:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_ambiente(
        v_pet_thor, 25.50, 60, 420, 1,
        TO_TIMESTAMP('2026-05-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_ambiente(
        v_pet_mel, 22.00, 55, 350, 1,
        TO_TIMESTAMP('2026-05-02 11:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_ambiente(
        v_pet_nina, 24.00, 58, 560, 1,
        TO_TIMESTAMP('2026-05-02 12:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    --------------------------------------------------------
    -- 2 SCORE_SAUDE A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_score_saude(
        v_pet_mel, 78, 75, 80, 70, 80, 75
    );

    prc_ins_score_saude(
        v_pet_nina, 91, 92, 90, 88, 93, 90
    );

    --------------------------------------------------------
    -- 2 CONSULTAS A MAIS, mesma clinica (Clinica Vida Pet) e
    -- mesmo tipo (CHECKUP) da consulta ja existente do Rex.
    -- Objetivo: demonstrar que PRC_REL_CONSULTAS_SUBTOTAL soma
    -- corretamente varias linhas da mesma combinacao
    -- clinica+tipo (180,00 do Rex + 170,00 da Luna + 190,00 da
    -- Mel = 540,00 no subtotal de CHECKUP da Clinica Vida Pet).
    --------------------------------------------------------

    prc_ins_consulta(
        v_pet_luna,
        v_clinica_vida,
        TO_DATE('2026-05-10', 'YYYY-MM-DD'),
        'CHECKUP',
        'Checkup de rotina',
        'Tudo normal',
        170.00,
        'N',
        NULL
    );

    prc_ins_consulta(
        v_pet_mel,
        v_clinica_vida,
        TO_DATE('2026-05-15', 'YYYY-MM-DD'),
        'CHECKUP',
        'Checkup de rotina',
        'Tudo normal',
        190.00,
        'N',
        NULL
    );

    DBMS_OUTPUT.PUT_LINE('Carga complementar 2 finalizada com sucesso.');
END;
/

------------------------------------------------------------
-- CONFERENCIA FINAL: contagem de todas as tabelas do banco
-- (print de evidencia para a documentacao)
------------------------------------------------------------

SELECT 'TUTOR' AS tabela, COUNT(*) AS total FROM TUTOR
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
SELECT 'LEITURA_COLEIRA', COUNT(*) FROM LEITURA_COLEIRA
UNION ALL
SELECT 'LEITURA_COMEDOURO', COUNT(*) FROM LEITURA_COMEDOURO
UNION ALL
SELECT 'LEITURA_AMBIENTE', COUNT(*) FROM LEITURA_AMBIENTE
UNION ALL
SELECT 'ALERTA_SAUDE', COUNT(*) FROM ALERTA_SAUDE
UNION ALL
SELECT 'SCORE_SAUDE', COUNT(*) FROM SCORE_SAUDE
UNION ALL
SELECT 'LOG_ERROS', COUNT(*) FROM LOG_ERROS
UNION ALL
SELECT 'AUDITORIA_TUTOR', COUNT(*) FROM AUDITORIA_TUTOR;
