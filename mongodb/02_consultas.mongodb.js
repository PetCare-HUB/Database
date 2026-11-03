// ------------------------------------------------------------
// PETCARE HUB -- Consultas de prova no MongoDB
// ------------------------------------------------------------
// Rodar com:  mongosh "mongodb://localhost:27017/petcarehub" --file 02_consultas.mongodb.js
//
// Cada consulta aqui existe para provar uma coisa especifica sobre a
// importacao, nao so para mostrar que tem dado dentro. Os numeros
// esperados estao no comentario de cada bloco -- se um nao bater, a
// importacao perdeu ou duplicou algo.
// ------------------------------------------------------------

print('============================================================');
print('1. CONTAGEM POR COLECAO');
print('------------------------------------------------------------');
// Esperado: pets 7, telemetria 120, alertas 8.
// Os mesmos numeros que o Oracle devolve: 7 linhas em PET, 8 em
// ALERTA_SAUDE, e 120 buckets (pet x tipo de sensor x dia).
['pets', 'telemetria', 'alertas'].forEach(function (c) {
    print('  ' + c.padEnd(12) + db.getCollection(c).countDocuments());
});

print('');
print('============================================================');
print('2. NENHUMA LEITURA SE PERDEU NO CAMINHO');
print('------------------------------------------------------------');
// Esperado: 924 -- exatamente 325 (coleira) + 301 (comedouro) + 298
// (ambiente) do Oracle. As leituras foram agrupadas em arrays dentro
// dos buckets, entao a contagem precisa somar os arrays, nao os
// documentos. E a prova de que o pipeline e sem perda.
const totalLeituras = db.telemetria.aggregate([
    { $group: { _id: null, total: { $sum: '$qtdLeituras' } } }
]).toArray();
print('  leituras somadas pelos buckets: ' + totalLeituras[0].total);

const totalItens = db.telemetria.aggregate([
    { $unwind: '$leituras' },
    { $count: 'total' }
]).toArray();
print('  itens reais dentro dos arrays:  ' + totalItens[0].total);

print('');
print('============================================================');
print('3. AS DATAS SAO DATAS, NAO TEXTO');
print('------------------------------------------------------------');
// Se o export tivesse gravado as datas como string, esta consulta
// devolveria zero: comparacao de intervalo com string nao funciona.
// Ela devolver linha e a prova de que o {"$date": ...} do Extended
// JSON virou BSON date de verdade no import.
const tipoDoCampo = db.telemetria.findOne({}, { dia: 1 });
print('  typeof dia: ' + (tipoDoCampo.dia instanceof Date ? 'Date' : typeof tipoDoCampo.dia));

const porMes = db.telemetria.aggregate([
    { $group: {
        _id: { ano: { $year: '$dia' }, mes: { $month: '$dia' } },
        buckets: { $sum: 1 },
        leituras: { $sum: '$qtdLeituras' }
    } },
    { $sort: { '_id.ano': 1, '_id.mes': 1 } }
]).toArray();
porMes.forEach(function (m) {
    print('  ' + m._id.ano + '-' + String(m._id.mes).padStart(2, '0') +
          '  buckets: ' + String(m.buckets).padStart(3) +
          '  leituras: ' + m.leituras);
});

print('');
print('============================================================');
print('4. UM JOIN DE 6 TABELAS VIRA UM findOne');
print('------------------------------------------------------------');
// No Oracle, montar esta resposta custa PET + TUTOR + CLINICA +
// CONSULTA + EVENTO_PREVENTIVO + PROTOCOLO_PREVENTIVO + SCORE_SAUDE.
// Aqui e uma leitura de um documento.
const rex = db.pets.findOne({ nome: 'Rex' });
print('  pet:        ' + rex.nome + ' (' + rex.especie + ', ' + rex.idadeMeses + ' meses)');
print('  tutor:      ' + rex.tutor.nome);
print('  clinica:    ' + rex.clinica.nome);
print('  consultas:  ' + rex.consultas.length);
print('  preventivos:' + rex.eventosPreventivos.length);
print('  score 30d:  ' + rex.scoreSaude.medio30d);

print('');
print('============================================================');
print('5. TRES FORMATOS DE LEITURA NA MESMA COLECAO');
print('------------------------------------------------------------');
// O ponto da modelagem em documento: no relacional isso exigiu tres
// tabelas porque as colunas sao diferentes. Aqui e uma colecao, e o
// campo "tipo" diz qual formato esperar dentro do array.
db.telemetria.aggregate([
    { $group: { _id: '$tipo', buckets: { $sum: 1 }, leituras: { $sum: '$qtdLeituras' } } },
    { $sort: { _id: 1 } }
]).toArray().forEach(function (t) {
    const exemplo = db.telemetria.findOne({ tipo: t._id });
    const campos = Object.keys(exemplo.leituras[0]).filter(function (k) { return k !== 'id'; });
    print('  ' + t._id.padEnd(10) + ' buckets: ' + String(t.buckets).padStart(3) +
          '  leituras: ' + String(t.leituras).padStart(3) + '  campos: ' + campos.join(', '));
});

print('');
print('============================================================');
print('6. ALERTAS ABERTOS POR PET (o GROUP BY do relatorio)');
print('------------------------------------------------------------');
// O equivalente do relatorio com GROUP BY + ORDER BY que existe em
// PKG_RELATORIOS, agora como aggregation pipeline.
db.alertas.aggregate([
    { $match: { resolvido: false } },
    { $group: {
        _id: { id: '$pet.id', nome: '$pet.nome' },
        abertos: { $sum: 1 },
        tipos: { $addToSet: '$tipo' },
        maisRecente: { $max: '$dataAlerta' }
    } },
    { $sort: { abertos: -1 } }
]).toArray().forEach(function (a) {
    // O id entra no rotulo porque o agrupamento e por pet, nao por nome:
    // existem dois pets chamados Rex na base, e sem o id a saida parece
    // uma linha repetida quando sao dois animais diferentes.
    print('  #' + String(a._id.id).padEnd(4) + a._id.nome.padEnd(10) +
          ' abertos: ' + String(a.abertos).padStart(3) +
          '  tipos: ' + a.tipos.sort().join(', '));
});

print('');
print('============================================================');
print('7. NENHUM HASH DE SENHA VAZOU NO EXPORT');
print('------------------------------------------------------------');
// TUTOR e CLINICA tem SENHA_HASH no Oracle. Os scripts de export
// nao selecionam essa coluna de proposito. Esta consulta confirma.
const comHash = db.pets.countDocuments({
    $or: [
        { 'tutor.senhaHash':   { $exists: true } },
        { 'tutor.senha_hash':  { $exists: true } },
        { 'clinica.senhaHash': { $exists: true } }
    ]
});
print('  documentos com hash de senha: ' + comHash + (comHash === 0 ? '  (ok)' : '  (PROBLEMA)'));

print('');
print('============================================================');
