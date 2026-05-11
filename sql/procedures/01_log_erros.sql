SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PETCARE HUB - PROCEDURE DE LOG DE ERROS
-- Essa procedure será usada pelas outras procedures de carga
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_registrar_log_erro (
    p_nome_procedure IN VARCHAR2,
    p_codigo_erro    IN NUMBER,
    p_mensagem_erro  IN VARCHAR2
) AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO LOG_ERROS (
        id_log,
        nome_procedure,
        nome_usuario,
        data_ocorrencia,
        codigo_erro,
        mensagem_erro
    ) VALUES (
        seq_log_erros.NEXTVAL,
        p_nome_procedure,
        USER,
        SYSTIMESTAMP,
        p_codigo_erro,
        SUBSTR(p_mensagem_erro, 1, 1000)
    );

    COMMIT;
END;
/

------------------------------------------------------------
-- TESTE: verificar se a procedure foi criada
------------------------------------------------------------

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'PRC_REGISTRAR_LOG_ERRO';