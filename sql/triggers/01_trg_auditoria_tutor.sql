SET SERVEROUTPUT ON;

------------------------------------------------------------
-- TABELA DE AUDITORIA
------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE AUDITORIA_TUTOR CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE AUDITORIA_TUTOR (
    id_auditoria     NUMBER(10)      NOT NULL,
    id_tutor         NUMBER(10),
    operacao         VARCHAR2(10)    NOT NULL,
    usuario_bd       VARCHAR2(60)    NOT NULL,
    data_hora        TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    status_anterior  VARCHAR2(20),
    status_novo      VARCHAR2(20),
    email_anterior   VARCHAR2(120),
    email_novo       VARCHAR2(120),

    CONSTRAINT pk_auditoria_tutor PRIMARY KEY (id_auditoria),
    CONSTRAINT ck_auditoria_operacao CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'))
);

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_auditoria_tutor';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE SEQUENCE seq_auditoria_tutor START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

------------------------------------------------------------
-- TRIGGER DE AUDITORIA (INSERT / UPDATE / DELETE em TUTOR)
------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_auditoria_tutor
AFTER INSERT OR UPDATE OR DELETE ON TUTOR
FOR EACH ROW
DECLARE
    v_operacao VARCHAR2(10);
BEGIN
    IF INSERTING THEN
        v_operacao := 'INSERT';
    ELSIF UPDATING THEN
        v_operacao := 'UPDATE';
    ELSE
        v_operacao := 'DELETE';
    END IF;

    INSERT INTO AUDITORIA_TUTOR (
        id_auditoria, id_tutor, operacao, usuario_bd, data_hora,
        status_anterior, status_novo, email_anterior, email_novo
    ) VALUES (
        seq_auditoria_tutor.NEXTVAL,
        NVL(:NEW.id_tutor, :OLD.id_tutor),
        v_operacao,
        USER,
        SYSTIMESTAMP,
        :OLD.status_acesso,
        :NEW.status_acesso,
        :OLD.email,
        :NEW.email
    );
END;
/

------------------------------------------------------------
-- TESTE
------------------------------------------------------------
-- INSERT INTO TUTOR (id_tutor, nome, email, cpf, data_cadastro, ativo, status_acesso)
--   VALUES (seq_tutor.NEXTVAL, 'Teste Auditoria', 'auditoria@teste.com', '99999999999', SYSDATE, 'S', 'PRE_CADASTRADO');
-- UPDATE TUTOR SET status_acesso = 'ATIVO', senha_hash = 'hash_teste' WHERE email = 'auditoria@teste.com';
-- SELECT * FROM AUDITORIA_TUTOR ORDER BY data_hora DESC;