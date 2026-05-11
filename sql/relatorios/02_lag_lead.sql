SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PETCARE HUB - RELATÓRIO COM LAG E LEAD
-- Arquivo 02_lag_lead.sql
--
-- Objetivo:
-- Mostrar o valor anterior, atual e próximo de uma leitura.
-- Usaremos as leituras de temperatura corporal do pet Rex.
------------------------------------------------------------

DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO - TEMPERATURA DO PET');
    DBMS_OUTPUT.PUT_LINE('ANTERIOR | ATUAL | PRÓXIMA');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            p.nome AS nome_pet,
            ls.data_leitura,
            LAG(ls.valor) OVER (
                PARTITION BY ls.id_pet
                ORDER BY ls.data_leitura
            ) AS valor_anterior,
            ls.valor AS valor_atual,
            LEAD(ls.valor) OVER (
                PARTITION BY ls.id_pet
                ORDER BY ls.data_leitura
            ) AS valor_proximo,
            ls.unidade
        FROM LEITURA_SENSOR ls
        JOIN PET p ON p.id_pet = ls.id_pet
        WHERE p.nome = 'Rex'
          AND ls.tipo_leitura = 'TEMPERATURA_CORPORAL'
        ORDER BY ls.data_leitura
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Pet: ' || r.nome_pet ||
            ' | Data: ' || TO_CHAR(r.data_leitura, 'DD/MM/YYYY HH24:MI') ||
            ' | Anterior: ' || NVL(TO_CHAR(r.valor_anterior), 'Vazio') ||
            ' | Atual: ' || TO_CHAR(r.valor_atual) ||
            ' | Próxima: ' || NVL(TO_CHAR(r.valor_proximo), 'Vazio') ||
            ' | Unidade: ' || r.unidade
        );
    END LOOP;
END;
/