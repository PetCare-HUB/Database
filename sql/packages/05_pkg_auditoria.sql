------------------------------------------------------------
-- PKG_AUDITORIA -- Trilha de auditoria das tabelas do dominio.
------------------------------------------------------------
-- Oracle nao aceita trigger dentro de package: trigger e sempre
-- objeto de schema, preso a uma tabela e a um evento. O que da
-- para empacotar e a logica dele -- e e o que foi feito aqui.
--
-- O corpo do TRG_AUDITORIA_TUTOR virou PRC_REGISTRAR_TUTOR, e o
-- trigger ficou com uma chamada so. A diferenca pratica: a regra
-- de auditoria passa a ser testavel sem disparar DML na TUTOR
-- (da para chamar a procedure direto), e quando a trilha for
-- estendida para PET ou CONSULTA, o segundo trigger reaproveita
-- este package em vez de copiar o INSERT.
------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_auditoria AS

    -- Grava uma linha na trilha de auditoria de TUTOR.
    -- Os valores anteriores/novos chegam do trigger (:OLD/:NEW);
    -- num INSERT os "anteriores" vem nulos, num DELETE os "novos".
    PROCEDURE prc_registrar_tutor (
        p_id_tutor         IN NUMBER,
        p_operacao         IN VARCHAR2,
        p_status_anterior  IN VARCHAR2,
        p_status_novo      IN VARCHAR2,
        p_email_anterior   IN VARCHAR2,
        p_email_novo       IN VARCHAR2
    );

END pkg_auditoria;
/

CREATE OR REPLACE PACKAGE BODY pkg_auditoria AS

    -- Origem: 01_trg_auditoria_tutor.sql:40 (corpo do trigger)
    PROCEDURE prc_registrar_tutor (
        p_id_tutor         IN NUMBER,
        p_operacao         IN VARCHAR2,
        p_status_anterior  IN VARCHAR2,
        p_status_novo      IN VARCHAR2,
        p_email_anterior   IN VARCHAR2,
        p_email_novo       IN VARCHAR2
    ) AS
    BEGIN
        INSERT INTO AUDITORIA_TUTOR (
            id_auditoria, id_tutor, operacao, usuario_bd, data_hora,
            status_anterior, status_novo, email_anterior, email_novo
        ) VALUES (
            seq_auditoria_tutor.NEXTVAL,
            p_id_tutor,
            p_operacao,
            USER,
            SYSTIMESTAMP,
            p_status_anterior,
            p_status_novo,
            p_email_anterior,
            p_email_novo
        );

    -- Sem COMMIT e sem WHEN OTHERS de proposito: a auditoria faz parte da
    -- mesma transacao da alteracao que a gerou. Se a alteracao der rollback,
    -- a linha de auditoria tem que sumir junto -- uma trilha que registra o
    -- que nao aconteceu e pior do que nenhuma trilha.
    END prc_registrar_tutor;

END pkg_auditoria;
/

------------------------------------------------------------
-- TRIGGER ENXUTO: so decide a operacao e delega ao package
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

    pkg_auditoria.prc_registrar_tutor(
        p_id_tutor        => NVL(:NEW.id_tutor, :OLD.id_tutor),
        p_operacao        => v_operacao,
        p_status_anterior => :OLD.status_acesso,
        p_status_novo     => :NEW.status_acesso,
        p_email_anterior  => :OLD.email,
        p_email_novo      => :NEW.email
    );
END;
/

------------------------------------------------------------
-- CONFERENCIA
------------------------------------------------------------

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('PKG_AUDITORIA', 'TRG_AUDITORIA_TUTOR')
ORDER BY object_type, object_name;
