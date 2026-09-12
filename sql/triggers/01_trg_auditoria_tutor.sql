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
-- TESTE / EVIDENCIA (tirar print para o PDF)
-- Demonstra a auditoria capturando um ciclo de vida completo
-- (INSERT, 3x UPDATE, DELETE) num tutor de teste, com usuario,
-- operacao, data/hora e valores anteriores/novos. O tutor de
-- teste e removido no final, entao nao conta para o minimo de
-- 5 tutores exigido pelo Procedimento 1 da rubrica. 5 eventos
-- de auditoria tambem garantem o minimo de 5 linhas em
-- AUDITORIA_TUTOR na conferencia final de carga.
------------------------------------------------------------

INSERT INTO TUTOR (
    id_tutor, nome, email, telefone, cpf, data_cadastro, ativo, status_acesso
) VALUES (
    seq_tutor.NEXTVAL, 'Teste Auditoria', 'auditoria@teste.com',
    '11900000000', '00000000000', SYSDATE, 'S', 'PRE_CADASTRADO'
);
COMMIT;

UPDATE TUTOR
SET status_acesso = 'ATIVO', senha_hash = 'hash_teste_auditoria'
WHERE email = 'auditoria@teste.com';
COMMIT;

UPDATE TUTOR
SET status_acesso = 'BLOQUEADO'
WHERE email = 'auditoria@teste.com';
COMMIT;

UPDATE TUTOR
SET status_acesso = 'ATIVO'
WHERE email = 'auditoria@teste.com';
COMMIT;

DELETE FROM TUTOR WHERE email = 'auditoria@teste.com';
COMMIT;

SELECT id_auditoria, id_tutor, operacao, usuario_bd, data_hora,
       status_anterior, status_novo, email_anterior, email_novo
FROM AUDITORIA_TUTOR
WHERE email_anterior = 'auditoria@teste.com' OR email_novo = 'auditoria@teste.com'
ORDER BY data_hora;
-- Esperado: 5 linhas (INSERT, UPDATE, UPDATE, UPDATE, DELETE)
-- para esse tutor, com status_anterior/status_novo mostrando o
-- ciclo PRE_CADASTRADO -> ATIVO -> BLOQUEADO -> ATIVO, e
-- id_tutor/email preenchidos em todas as 5 linhas.