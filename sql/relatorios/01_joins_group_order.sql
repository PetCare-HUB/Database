SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PETCARE HUB - RELATÓRIOS COM JOIN, GROUP BY E ORDER BY
-- Arquivo 01_joins_group_order.sql
------------------------------------------------------------

------------------------------------------------------------
-- BLOCO ANÔNIMO 1
-- Mostra dados inseridos usando joins, agrupamento e ordenação
------------------------------------------------------------

DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 1 - TOTAL DE PETS POR CLÍNICA E ESPÉCIE');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            c.nome AS clinica,
            p.especie,
            COUNT(p.id_pet) AS total_pets
        FROM CLINICA c
        JOIN PET p ON p.id_clinica = c.id_clinica
        GROUP BY c.nome, p.especie
        ORDER BY c.nome, p.especie
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Clínica: ' || r.clinica ||
            ' | Espécie: ' || r.especie ||
            ' | Total de pets: ' || r.total_pets
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 2 - TOTAL DE CONSULTAS POR CLÍNICA E TIPO');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            c.nome AS clinica,
            co.tipo_consulta,
            COUNT(co.id_consulta) AS total_consultas,
            SUM(co.valor) AS valor_total
        FROM CLINICA c
        JOIN CONSULTA co ON co.id_clinica = c.id_clinica
        GROUP BY c.nome, co.tipo_consulta
        ORDER BY c.nome, total_consultas DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Clínica: ' || r.clinica ||
            ' | Tipo: ' || r.tipo_consulta ||
            ' | Total: ' || r.total_consultas ||
            ' | Valor total: R$ ' || NVL(r.valor_total, 0)
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 3 - MÉDIA DE SCORE POR CLÍNICA');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            c.nome AS clinica,
            ROUND(AVG(s.score_total), 2) AS media_score,
            COUNT(DISTINCT p.id_pet) AS total_pets
        FROM CLINICA c
        JOIN PET p ON p.id_clinica = c.id_clinica
        JOIN SCORE_SAUDE s ON s.id_pet = p.id_pet
        GROUP BY c.nome
        ORDER BY media_score DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Clínica: ' || r.clinica ||
            ' | Média de score: ' || r.media_score ||
            ' | Total de pets avaliados: ' || r.total_pets
        );
    END LOOP;
END;
/

------------------------------------------------------------
-- BLOCO ANÔNIMO 2
-- Mais consultas com JOIN, GROUP BY e ORDER BY
------------------------------------------------------------

DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 4 - ALERTAS ABERTOS POR CLÍNICA E NÍVEL');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            c.nome AS clinica,
            a.nivel_alerta,
            COUNT(a.id_alerta) AS total_alertas
        FROM CLINICA c
        JOIN PET p ON p.id_clinica = c.id_clinica
        JOIN ALERTA_SAUDE a ON a.id_pet = p.id_pet
        WHERE a.resolvido = 'N'
        GROUP BY c.nome, a.nivel_alerta
        ORDER BY total_alertas DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Clínica: ' || r.clinica ||
            ' | Nível: ' || r.nivel_alerta ||
            ' | Total de alertas: ' || r.total_alertas
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 5 - EVENTOS PREVENTIVOS POR PET E STATUS');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            p.nome AS pet,
            ep.status,
            COUNT(ep.id_evento) AS total_eventos
        FROM PET p
        JOIN EVENTO_PREVENTIVO ep ON ep.id_pet = p.id_pet
        GROUP BY p.nome, ep.status
        ORDER BY p.nome, ep.status
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Pet: ' || r.pet ||
            ' | Status: ' || r.status ||
            ' | Total de eventos: ' || r.total_eventos
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 6 - LEITURAS POR PET E TIPO');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            p.nome AS pet,
            ls.tipo_leitura,
            COUNT(ls.id_leitura) AS total_leituras,
            ROUND(AVG(ls.valor), 2) AS media_valor
        FROM PET p
        JOIN LEITURA_SENSOR ls ON ls.id_pet = p.id_pet
        GROUP BY p.nome, ls.tipo_leitura
        ORDER BY p.nome, ls.tipo_leitura
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Pet: ' || r.pet ||
            ' | Tipo leitura: ' || r.tipo_leitura ||
            ' | Total: ' || r.total_leituras ||
            ' | Média: ' || r.media_valor
        );
    END LOOP;
END;
/