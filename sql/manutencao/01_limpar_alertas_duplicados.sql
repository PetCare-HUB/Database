------------------------------------------------------------
-- LIMPEZA -- Alertas duplicados anteriores a deduplicacao.
--
-- Ate 30/10/2026 cada leitura IoT fora do limite abria uma
-- linha nova em ALERTA_SAUDE. Com o simulador mandando
-- leitura a cada poucos segundos, o pet 9 (Rex) acumulou 197
-- alertas BAIXA_ALIMENTACAO identicos em cerca de uma hora.
--
-- O bug ja foi corrigido nos dois lados -- PKG_CARGA.
-- PRC_INS_ALERTA_SAUDE no banco e AlertaSaudeService.
-- criarInterno na API Java atualizam o alerta aberto do mesmo
-- tipo em vez de duplicar. Falta limpar o que ficou para tras,
-- que esta indo junto no export: 197 dos 204 documentos de
-- mongodb/alertas.json sao a mesma ocorrencia repetida.
--
-- O script NAO da COMMIT. Confira o passo 3 antes.
------------------------------------------------------------


------------------------------------------------------------
-- 1. Diagnostico
--
-- Rode sozinho primeiro. Se nao voltar nenhuma linha, nao ha
-- duplicata e o resto do script e desnecessario.
------------------------------------------------------------
SELECT a.id_pet,
       p.nome              AS pet,
       a.tipo_alerta,
       COUNT(*)            AS abertos,
       MIN(a.data_alerta)  AS mais_antigo,
       MAX(a.data_alerta)  AS mais_recente
FROM ALERTA_SAUDE a
JOIN PET p ON p.id_pet = a.id_pet
WHERE a.resolvido = 'N'
GROUP BY a.id_pet, p.nome, a.tipo_alerta
HAVING COUNT(*) > 1
ORDER BY abertos DESC;


------------------------------------------------------------
-- 2. Limpeza
--
-- Tres cuidados deliberados:
--
-- a) "resolvido = 'N'" nos dois lados do NOT IN. Alerta
--    resolvido e historico real: um pet pode ter ficado
--    sedentario em setembro, melhorado, e ficado de novo em
--    outubro. Sao dois fatos, nao duplicata. Nada que ja foi
--    resolvido e tocado por este DELETE.
--
-- b) MAX(id_alerta), nao MAX(data_alerta). O id vem da
--    sequence e e unico. data_alerta empata quando duas
--    leituras chegam no mesmo instante, e no empate o NOT IN
--    deixaria as duas linhas ou nenhuma.
--
-- c) Sobra exatamente uma linha aberta por par pet/tipo, que
--    e o que o codigo de hoje produziria se os mesmos dados
--    fossem gerados agora.
------------------------------------------------------------
DELETE FROM ALERTA_SAUDE a
WHERE a.resolvido = 'N'
  AND a.id_alerta NOT IN (
      SELECT MAX(b.id_alerta)
      FROM ALERTA_SAUDE b
      WHERE b.resolvido = 'N'
      GROUP BY b.id_pet, b.tipo_alerta
  );


------------------------------------------------------------
-- 3. Conferencia -- ANTES do commit
--
-- A primeira query tem que voltar VAZIA: nenhum par pet/tipo
-- com mais de um alerta aberto.
------------------------------------------------------------
SELECT a.id_pet, a.tipo_alerta, COUNT(*) AS abertos
FROM ALERTA_SAUDE a
WHERE a.resolvido = 'N'
GROUP BY a.id_pet, a.tipo_alerta
HAVING COUNT(*) > 1;

-- E a distribuicao tem que ficar pequena e variada, em vez de
-- um tipo so dominando o total.
SELECT tipo_alerta,
       COUNT(*)                                        AS total,
       SUM(CASE WHEN resolvido = 'N' THEN 1 ELSE 0 END) AS abertos
FROM ALERTA_SAUDE
GROUP BY tipo_alerta
ORDER BY total DESC;


------------------------------------------------------------
-- 4. Efetivar
--
-- So depois de conferir o passo 3. Para desistir, ROLLBACK.
------------------------------------------------------------
-- COMMIT;


------------------------------------------------------------
-- 5. Depois do commit
--
-- O JSON versionado em mongodb/ foi gerado antes da limpeza,
-- entao ainda carrega as duplicatas. Refaca o export e a
-- importacao:
--
--   sql/export/03_export_alertas.sql  -> mongodb/alertas.json
--   mongodb/01_importar.ps1
--
-- E atualize a contagem da colecao "alertas" na tabela das
-- tres colecoes, no README.
------------------------------------------------------------
