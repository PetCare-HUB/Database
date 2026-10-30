------------------------------------------------------------
-- PKG_LOG -- Registro de erros das rotinas do PetCare Hub.
------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_log AS

    -- Fica sozinho de proposito: todos os outros packages dependem dele, e nada
    -- aqui depende de ninguem. Assim ele compila primeiro e nunca entra em
    -- dependencia circular com quem o chama.

    PROCEDURE prc_registrar_log_erro (
        p_nome_procedure IN VARCHAR2,
        p_codigo_erro    IN NUMBER,
        p_mensagem_erro  IN VARCHAR2
    );

END pkg_log;
/

CREATE OR REPLACE PACKAGE BODY pkg_log AS

    -- Origem: 01_log_erros.sql:8
    PROCEDURE prc_registrar_log_erro (
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

END pkg_log;
/
