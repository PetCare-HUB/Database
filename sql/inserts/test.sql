EXEC prc_ins_tutor('Teste Final', 'teste.final@petcare.com', '11988887777', '11122233344');
SELECT id_tutor, nome, status_acesso, senha_hash FROM TUTOR WHERE email = 'teste.final@petcare.com';
UPDATE TUTOR SET senha_hash = 'hash_fake_teste', status_acesso = 'ATIVO' WHERE email = 'teste.final@petcare.com';
COMMIT;
SELECT * FROM AUDITORIA_TUTOR ORDER BY data_hora DESC;