SET SERVEROUTPUT ON;

------------------------------------------------------------
-- REMOVE A PROCEDURE ANTIGA
------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_ins_responsavel';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

------------------------------------------------------------
-- PROCEDURE: INSERIR TUTOR (pré-cadastro feito pela clínica, sem senha)
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_tutor (
    p_nome      IN VARCHAR2,
    p_email     IN VARCHAR2,
    p_telefone  IN VARCHAR2,
    p_cpf       IN VARCHAR2
) AS
BEGIN
    IF p_nome IS NULL OR p_email IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nome e email do tutor sao obrigatorios.');
    END IF;

    INSERT INTO TUTOR (
        id_tutor,
        nome,
        email,
        telefone,
        cpf,
        data_cadastro,
        ativo,
        status_acesso
    ) VALUES (
        seq_tutor.NEXTVAL,
        p_nome,
        p_email,
        p_telefone,
        p_cpf,
        SYSDATE,
        'S',
        'PRE_CADASTRADO'
    );

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        prc_registrar_log_erro('PRC_INS_TUTOR', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_TUTOR', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_TUTOR', SQLCODE, SQLERRM);
END;
/