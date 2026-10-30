SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PETCARE HUB - CARGA COMPLEMENTAR 3 (pets da Ana)
-- Mais leituras de movimento (LEITURA_COLEIRA) para Rex e
-- Luna, os dois pets da tutora Ana Souza. A Luna tinha so 1
-- leitura de coleira contra as 5 do Rex - aqui os dois ficam
-- equilibrados, com dados espalhados em 2 dias (05-01 e
-- 05-02), simulando bateria recarregando durante a noite.
--
-- Tambem adiciona 1 leitura de comedouro e 1 de ambiente para
-- a Luna, que so tinha 1 de cada.
--
-- Roda DEPOIS de 03_insert_complemento_carga.sql, sem apagar
-- nada.
------------------------------------------------------------

DECLARE
    v_pet_rex   NUMBER;
    v_pet_luna  NUMBER;
BEGIN
    -- Busca pelo tutor (Ana Souza), nao so pelo nome do pet,
    -- porque pode existir outro pet com o mesmo nome cadastrado
    -- por outro tutor (ex: testes manuais da API).
    SELECT p.id_pet INTO v_pet_rex
    FROM PET p
    JOIN TUTOR t ON t.id_tutor = p.id_tutor
    WHERE p.nome = 'Rex' AND t.email = 'ana.souza@email.com';

    SELECT p.id_pet INTO v_pet_luna
    FROM PET p
    JOIN TUTOR t ON t.id_tutor = p.id_tutor
    WHERE p.nome = 'Luna' AND t.email = 'ana.souza@email.com';

    --------------------------------------------------------
    -- MOVIMENTO (COLEIRA) - LUNA
    -- Completa o dia 05-01 (ja tinha a leitura das 09:00) e
    -- adiciona a manha do dia 05-02.
    --------------------------------------------------------

    prc_ins_leitura_coleira(
        v_pet_luna, 'ATIVO', 88,
        TO_TIMESTAMP('2026-05-01 11:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_luna, 'MODERADO', 85,
        TO_TIMESTAMP('2026-05-01 13:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_luna, 'ATIVO', 87,
        TO_TIMESTAMP('2026-05-01 15:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_luna, 'MODERADO', 83,
        TO_TIMESTAMP('2026-05-01 17:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_luna, 'ATIVO', 95,
        TO_TIMESTAMP('2026-05-02 09:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    --------------------------------------------------------
    -- MOVIMENTO (COLEIRA) - REX
    -- Continuacao do dia 05-02 (o dia 05-01 ja tinha 5
    -- leituras, terminando com 87% de bateria).
    --------------------------------------------------------

    prc_ins_leitura_coleira(
        v_pet_rex, 'ATIVO', 96,
        TO_TIMESTAMP('2026-05-02 08:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_rex, 'ATIVO', 94,
        TO_TIMESTAMP('2026-05-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_rex, 'MODERADO', 91,
        TO_TIMESTAMP('2026-05-02 12:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_rex, 'ATIVO', 89,
        TO_TIMESTAMP('2026-05-02 14:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_rex, 'ATIVO', 85,
        TO_TIMESTAMP('2026-05-02 16:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    --------------------------------------------------------
    -- ENTRE OUTROS: mais 1 leitura de comedouro e 1 de
    -- ambiente para a Luna
    --------------------------------------------------------

    prc_ins_leitura_comedouro(
        v_pet_luna, 55, 85.00,
        TO_TIMESTAMP('2026-05-03 09:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_ambiente(
        v_pet_luna, 22.50, 52, 390, 1,
        TO_TIMESTAMP('2026-05-03 09:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    DBMS_OUTPUT.PUT_LINE('Carga complementar 3 (pets da Ana) finalizada com sucesso.');
END;
/

------------------------------------------------------------
-- CONFERENCIA: total de leituras por pet
------------------------------------------------------------

SELECT p.nome AS pet, COUNT(*) AS total_leituras_coleira
FROM LEITURA_COLEIRA lc
JOIN PET p ON p.id_pet = lc.id_pet
GROUP BY p.nome
ORDER BY p.nome;

SELECT p.nome AS pet, COUNT(*) AS total_leituras_comedouro
FROM LEITURA_COMEDOURO lc
JOIN PET p ON p.id_pet = lc.id_pet
WHERE p.nome IN ('Rex', 'Luna')
GROUP BY p.nome
ORDER BY p.nome;

SELECT p.nome AS pet, COUNT(*) AS total_leituras_ambiente
FROM LEITURA_AMBIENTE la
JOIN PET p ON p.id_pet = la.id_pet
WHERE p.nome IN ('Rex', 'Luna')
GROUP BY p.nome
ORDER BY p.nome;


SELECT * FROM TUTOR ORDER BY id_tutor;
SELECT * FROM CLINICA ORDER BY id_clinica;
SELECT * FROM PET ORDER BY id_pet;


SELECT p.nome AS pet, lc.status_atividade, lc.nivel_bateria, lc.timestamp_leitura
FROM LEITURA_COLEIRA lc
JOIN PET p ON p.id_pet = lc.id_pet
JOIN TUTOR t ON t.id_tutor = p.id_tutor
WHERE t.email = 'ana.souza@email.com' AND p.nome = 'Rex'
ORDER BY lc.timestamp_leitura DESC;




SELECT CNPJ
FROM CLINICA
WHERE ID_CLINICA = 10;
