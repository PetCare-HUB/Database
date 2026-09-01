SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PETCARE HUB - FUNCTIONS DA RUBRICA (SPRINT 3)
-- "Mastering Relational and Non-Relational Database"
------------------------------------------------------------

------------------------------------------------------------
-- FUNCAO 1: converte um registro relacional (PET + TUTOR +
-- CLINICA) em uma string JSON, montada manualmente.
-- PROIBIDO usar TO_JSON / JSON_OBJECT / JSON_VALUE / etc.
------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_pet_para_json (
    p_id_pet        IN NUMBER,
    p_nome_pet      IN VARCHAR2,
    p_especie_pet   IN VARCHAR2,
    p_nome_tutor    IN VARCHAR2,
    p_email_tutor   IN VARCHAR2,
    p_nome_clinica  IN VARCHAR2
) RETURN VARCHAR2
IS
    e_id_pet_nulo    EXCEPTION;
    e_nome_pet_nulo  EXCEPTION;
    v_json           VARCHAR2(4000);
BEGIN
    IF p_id_pet IS NULL THEN
        RAISE e_id_pet_nulo;
    END IF;

    IF p_nome_pet IS NULL THEN
        RAISE e_nome_pet_nulo;
    END IF;

    v_json :=
        '{"id_pet":' || p_id_pet
        || ',"nome_pet":"' || REPLACE(p_nome_pet, '"', '\"') || '"'
        || ',"especie":"' || REPLACE(NVL(p_especie_pet, ''), '"', '\"') || '"'
        || ',"tutor":{'
            || '"nome":"' || REPLACE(NVL(p_nome_tutor, ''), '"', '\"') || '"'
            || ',"email":"' || REPLACE(NVL(p_email_tutor, ''), '"', '\"') || '"'
        || '}'
        || ',"clinica":"' || REPLACE(NVL(p_nome_clinica, ''), '"', '\"') || '"'
        || '}';

    RETURN v_json;

EXCEPTION
    WHEN e_id_pet_nulo THEN
        RETURN '{"erro":"id_pet obrigatorio para gerar JSON"}';
    WHEN e_nome_pet_nulo THEN
        RETURN '{"erro":"nome_pet obrigatorio para gerar JSON"}';
    WHEN VALUE_ERROR THEN
        RETURN '{"erro":"valor invalido ao montar JSON"}';
    WHEN OTHERS THEN
        RETURN '{"erro":"erro inesperado ao montar JSON"}';
END;
/

------------------------------------------------------------
-- FUNCAO 2: substitui o processo de validacao de senha do
-- fluxo de ativacao de conta do TUTOR (regra de negocio:
-- minimo 8 caracteres, pelo menos 1 letra e 1 numero).
------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_validar_forca_senha (
    p_senha IN VARCHAR2
) RETURN VARCHAR2
IS
    e_senha_nula        EXCEPTION;
    e_senha_curta       EXCEPTION;
    e_senha_sem_numero  EXCEPTION;
BEGIN
    IF p_senha IS NULL THEN
        RAISE e_senha_nula;
    END IF;

    IF LENGTH(p_senha) < 8 THEN
        RAISE e_senha_curta;
    END IF;

    IF NOT REGEXP_LIKE(p_senha, '[0-9]') THEN
        RAISE e_senha_sem_numero;
    END IF;

    IF NOT REGEXP_LIKE(p_senha, '[A-Za-z]') THEN
        RETURN 'INVALIDA: senha precisa conter ao menos uma letra.';
    END IF;

    RETURN 'VALIDA';

EXCEPTION
    WHEN e_senha_nula THEN
        RETURN 'INVALIDA: senha nao informada.';
    WHEN e_senha_curta THEN
        RETURN 'INVALIDA: senha deve ter no minimo 8 caracteres.';
    WHEN e_senha_sem_numero THEN
        RETURN 'INVALIDA: senha deve conter ao menos um numero.';
    WHEN OTHERS THEN
        RETURN 'INVALIDA: erro inesperado na validacao.';
END;
/

------------------------------------------------------------
-- TESTE / EVIDENCIA (tirar print desses resultados)
------------------------------------------------------------

-- Caso de sucesso da Funcao 1 (usa o pet 'Rex' ja carregado)
SELECT fn_pet_para_json(
    p.id_pet, p.nome, p.especie, t.nome, t.email, c.nome
) AS json_pet
FROM PET p
JOIN TUTOR t ON t.id_tutor = p.id_tutor
JOIN CLINICA c ON c.id_clinica = p.id_clinica
WHERE p.nome = 'Rex';

-- Caso de excecao da Funcao 1 (id_pet nulo)
SELECT fn_pet_para_json(NULL, 'Teste', 'CAO', 'Tutor Teste', 'teste@teste.com', 'Clinica Teste') AS json_erro
FROM DUAL;

-- Caso de sucesso da Funcao 2
SELECT fn_validar_forca_senha('Senha123') AS resultado FROM DUAL;

-- Casos de excecao da Funcao 2 (print para a documentacao)
SELECT fn_validar_forca_senha(NULL) AS resultado FROM DUAL;
SELECT fn_validar_forca_senha('abc') AS resultado FROM DUAL;
SELECT fn_validar_forca_senha('semnumero') AS resultado FROM DUAL;
