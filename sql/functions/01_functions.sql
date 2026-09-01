SET SERVEROUTPUT ON;

------------------------------------------------------------
-- FUNCTION 1: Calcula idade do pet em meses
------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_calcular_idade_pet (
    p_id_pet IN NUMBER
) RETURN NUMBER
IS
    v_data_nascimento DATE;
    v_idade_meses      NUMBER;
BEGIN
    SELECT data_nascimento
    INTO v_data_nascimento
    FROM PET
    WHERE id_pet = p_id_pet;

    IF v_data_nascimento IS NULL THEN
        RETURN NULL;
    END IF;

    v_idade_meses := MONTHS_BETWEEN(SYSDATE, v_data_nascimento);

    RETURN TRUNC(v_idade_meses);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

------------------------------------------------------------
-- FUNCTION 2: Score médio do pet nos últimos N dias
------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_score_medio_pet (
    p_id_pet IN NUMBER,
    p_dias   IN NUMBER
) RETURN NUMBER
IS
    v_media NUMBER;
BEGIN
    SELECT AVG(score_total)
    INTO v_media
    FROM SCORE_SAUDE
    WHERE id_pet = p_id_pet
      AND data_calculo >= SYSTIMESTAMP - p_dias;

    RETURN ROUND(NVL(v_media, 0), 1);

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
/

------------------------------------------------------------
-- TESTE
------------------------------------------------------------
-- SELECT fn_calcular_idade_pet(1) FROM DUAL;
-- SELECT fn_score_medio_pet(1, 30) FROM DUAL;