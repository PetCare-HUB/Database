# ------------------------------------------------------------
# PETCARE HUB -- Importacao do JSON exportado do Oracle para o MongoDB
# ------------------------------------------------------------
# Pre-requisitos:
#   - MongoDB Server rodando em localhost:27017
#   - MongoDB Database Tools (mongoimport) e mongosh no PATH
#
# Os arquivos .json deste diretorio sao gerados pelos scripts de
# sql/export/ -- nao edite na mao. Para regerar, veja o README.
#
# Por que --mode upsert e nao --drop: o _id de cada documento vem da
# chave primaria do Oracle (id_pet, id_alerta) ou de uma chave
# composta estavel (id_pet|tipo|dia na telemetria). Isso faz a
# importacao ser idempotente: rodar duas vezes atualiza, nao duplica.
# Com --drop a colecao seria apagada a cada execucao e qualquer dado
# que o app tivesse escrito direto no Mongo iria embora junto.
# ------------------------------------------------------------

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

# O instalador das Database Tools nao coloca o diretorio no PATH, e o
# do mongosh coloca. Resolver os dois aqui deixa o script rodar numa
# maquina recem-instalada sem ninguem ter que mexer em variavel de
# ambiente -- so instalar e executar.
function Resolve-Ferramenta {
    param([string]$Nome, [string[]]$Candidatos)

    $noPath = Get-Command $Nome -ErrorAction SilentlyContinue
    if ($noPath) { return $noPath.Source }

    foreach ($c in $Candidatos) {
        $achado = Get-ChildItem -Path $c -Filter "$Nome.exe" -Recurse -ErrorAction SilentlyContinue |
                  Select-Object -First 1
        if ($achado) { return $achado.FullName }
    }
    throw "$Nome nao encontrado. Instale com: winget install MongoDB.DatabaseTools MongoDB.Shell"
}

$mongoimport = Resolve-Ferramenta -Nome 'mongoimport' -Candidatos @('C:\Program Files\MongoDB\Tools')
$mongosh     = Resolve-Ferramenta -Nome 'mongosh'     -Candidatos @(
                   "$env:LOCALAPPDATA\Programs\mongosh", 'C:\Program Files\mongosh')

Write-Host "mongoimport: $mongoimport"
Write-Host "mongosh    : $mongosh`n"

$uri   = 'mongodb://localhost:27017'
$banco = 'petcarehub'

# O database e o mesmo que a API .NET usa (colecao resumos_pet_ia).
# As colecoes abaixo sao novas e nao encostam nela: instancia unica
# compartilhada entre as disciplinas, dados separados por colecao.
$colecoes = @(
    @{ nome = 'pets';        arquivo = 'pets.json' },
    @{ nome = 'telemetria';  arquivo = 'telemetria.json' },
    @{ nome = 'alertas';     arquivo = 'alertas.json' }
)

foreach ($c in $colecoes) {
    Write-Host "importando $($c.arquivo) -> $banco.$($c.nome)" -ForegroundColor Cyan
    & $mongoimport `
        --uri $uri `
        --db $banco `
        --collection $c.nome `
        --file $c.arquivo `
        --jsonArray `
        --mode upsert `
        --upsertFields _id
    if ($LASTEXITCODE -ne 0) { throw "mongoimport falhou em $($c.arquivo)" }
}

Write-Host "`ncriando indices" -ForegroundColor Cyan
& $mongosh "$uri/$banco" --quiet --eval @'
// Os indices seguem as consultas que o app faz de verdade, nao as
// chaves estrangeiras que existiam no relacional.

// "quais pets sao desta tutora" -- a tela inicial do app mobile.
db.pets.createIndex({ "tutor.email": 1 });

// "as leituras deste pet neste periodo" -- o grafico do dashboard.
// pet.id ascendente + dia descendente: o mais recente primeiro.
db.telemetria.createIndex({ "pet.id": 1, dia: -1 });

// "alertas abertos deste pet, do mais novo para o mais velho".
db.alertas.createIndex({ "pet.id": 1, resolvido: 1, dataAlerta: -1 });

// "quantos alertas de cada tipo" -- usado pelo relatorio.
db.alertas.createIndex({ tipo: 1 });

print("indices por colecao:");
["pets", "telemetria", "alertas"].forEach(function (c) {
    print("  " + c + ": " + db.getCollection(c).getIndexes().length);
});
'@
if ($LASTEXITCODE -ne 0) { throw 'mongosh falhou ao criar os indices' }

Write-Host "`nimportacao concluida" -ForegroundColor Green
