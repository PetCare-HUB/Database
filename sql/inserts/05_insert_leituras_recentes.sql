SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PETCARE HUB - CARGA COMPLEMENTAR 4 (leituras recentes)
-- Adiciona leituras de coleira, comedouro e ambiente para
-- Rex e Luna (pets da Ana Souza) com timestamp relativo a
-- HOJE (ontem + hoje), nao datas fixas - assim o dado sempre
-- aparece como "recente" pro app, nao importa quando esse
-- script for executado.
--
-- Nao apaga nada. Convive com as leituras de teste antigas
-- (01/05 e 02/05) e com as leituras reais que o app/API ja
-- escreveu no banco.
------------------------------------------------------------

DECLARE
    v_pet_rex   NUMBER;
    v_pet_luna  NUMBER;

    -- Ancora no inicio do dia de hoje (00:00:00), pra montar
    -- horarios de ontem e de hoje somando/subtraindo intervalo.
    v_hoje TIMESTAMP := CAST(TRUNC(SYSDATE) AS TIMESTAMP);
BEGIN
    SELECT p.id_pet INTO v_pet_rex
    FROM PET p
    JOIN TUTOR t ON t.id_tutor = p.id_tutor
    WHERE p.nome = 'Rex' AND t.email = 'ana.souza@email.com';

    SELECT p.id_pet INTO v_pet_luna
    FROM PET p
    JOIN TUTOR t ON t.id_tutor = p.id_tutor
    WHERE p.nome = 'Luna' AND t.email = 'ana.souza@email.com';

    --------------------------------------------------------
    -- MOVIMENTO (COLEIRA) - REX
    -- Recarregou a bateria depois da leitura SEDENTARIO/15%
    -- e volta a ficar ativo ao longo de ontem e hoje.
    --------------------------------------------------------

    prc_ins_leitura_coleira(v_pet_rex, 'ATIVO', 92, v_hoje - INTERVAL '1' DAY + INTERVAL '8' HOUR);
    prc_ins_leitura_coleira(v_pet_rex, 'MODERADO', 87, v_hoje - INTERVAL '1' DAY + INTERVAL '12' HOUR);
    prc_ins_leitura_coleira(v_pet_rex, 'ATIVO', 80, v_hoje - INTERVAL '1' DAY + INTERVAL '18' HOUR);
    prc_ins_leitura_coleira(v_pet_rex, 'ATIVO', 75, v_hoje + INTERVAL '8' HOUR);
    prc_ins_leitura_coleira(v_pet_rex, 'MODERADO', 68, v_hoje + INTERVAL '14' HOUR);

    --------------------------------------------------------
    -- MOVIMENTO (COLEIRA) - LUNA
    --------------------------------------------------------

    prc_ins_leitura_coleira(v_pet_luna, 'ATIVO', 90, v_hoje - INTERVAL '1' DAY + INTERVAL '9' HOUR);
    prc_ins_leitura_coleira(v_pet_luna, 'MODERADO', 84, v_hoje - INTERVAL '1' DAY + INTERVAL '15' HOUR);
    prc_ins_leitura_coleira(v_pet_luna, 'ATIVO', 96, v_hoje + INTERVAL '9' HOUR);
    prc_ins_leitura_coleira(v_pet_luna, 'ATIVO', 90, v_hoje + INTERVAL '15' HOUR);

    --------------------------------------------------------
    -- ENTRE OUTROS: comedouro e ambiente recentes pros dois
    --------------------------------------------------------

    prc_ins_leitura_comedouro(v_pet_rex, 60, 115.00, v_hoje + INTERVAL '8' HOUR + INTERVAL '30' MINUTE);
    prc_ins_leitura_comedouro(v_pet_luna, 58, 88.00, v_hoje + INTERVAL '9' HOUR + INTERVAL '15' MINUTE);

    prc_ins_leitura_ambiente(v_pet_rex, 23.80, 54, 410, 1, v_hoje + INTERVAL '14' HOUR);
    prc_ins_leitura_ambiente(v_pet_luna, 23.50, 53, 400, 1, v_hoje + INTERVAL '15' HOUR);

    DBMS_OUTPUT.PUT_LINE('Carga complementar 4 (leituras recentes) finalizada com sucesso.');
END;
/

------------------------------------------------------------
-- CONFERENCIA: leituras de coleira do Rex e da Luna, das
-- mais recentes para as mais antigas
------------------------------------------------------------

SELECT p.nome AS pet, lc.status_atividade, lc.nivel_bateria, lc.timestamp_leitura
FROM LEITURA_COLEIRA lc
JOIN PET p ON p.id_pet = lc.id_pet
JOIN TUTOR t ON t.id_tutor = p.id_tutor
WHERE t.email = 'ana.souza@email.com'
ORDER BY p.nome, lc.timestamp_leitura DESC;






SELECT
    t.id_tutor,
    t.nome AS tutor,
    t.email,
    t.status_acesso,
    p.id_pet,
    p.nome AS pet
FROM tutor t
LEFT JOIN pet p ON p.id_tutor = t.id_tutor
ORDER BY t.id_tutor, p.id_pet;