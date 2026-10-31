import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.sql.*;

/**
 * Roda os scripts de sql/export/ e grava o JSON resultante em mongodb/.
 *
 * Arquivo unico de proposito: roda direto com o launcher de codigo-fonte do
 * Java (11+), sem Maven, sem build, sem projeto.
 *
 *   $env:ORACLE_USER     = 'seu_usuario'
 *   $env:ORACLE_PASSWORD = 'sua_senha'
 *   $env:ORACLE_DSN      = '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle.fiap.com.br)(PORT=1521))(CONNECT_DATA=(SID=orcl)))'
 *   java -cp "$env:USERPROFILE\.m2\repository\com\oracle\database\jdbc\ojdbc11\23.5.0.24.07\ojdbc11-23.5.0.24.07.jar" tools\ExportarJson.java
 *
 * As credenciais vem do ambiente, nunca de arquivo no repositorio: este
 * repositorio e publico.
 *
 * Este programa nao monta JSON nenhum. Quem gera o JSON e o Oracle, com
 * SQL/JSON (JSON_OBJECT + JSON_ARRAYAGG) nos scripts de sql/export/. Aqui so
 * se le o CLOB e escreve no disco -- a responsabilidade do formato fica no
 * banco, que e o que a disciplina cobra.
 */
public class ExportarJson {

    /** script em sql/export/ -> arquivo em mongodb/ */
    private static final String[][] EXPORTS = {
        { "01_export_pets.sql",       "pets.json"       },
        { "02_export_telemetria.sql", "telemetria.json" },
        { "03_export_alertas.sql",    "alertas.json"    },
    };

    public static void main(String[] args) throws Exception {
        // A raiz do repositorio, a partir do diretorio de execucao.
        Path raiz = Paths.get("").toAbsolutePath();
        if (!Files.isDirectory(raiz.resolve("sql/export"))) {
            throw new IllegalStateException(
                    "rode a partir da raiz do repositorio (nao achei sql/export em " + raiz + ")");
        }

        String usuario = exigir("ORACLE_USER");
        String senha   = exigir("ORACLE_PASSWORD");
        String dsn     = exigir("ORACLE_DSN");

        try (Connection c = DriverManager.getConnection(
                "jdbc:oracle:thin:@" + dsn.trim(), usuario, senha)) {

            for (String[] par : EXPORTS) {
                Path script = raiz.resolve("sql/export").resolve(par[0]);
                Path saida  = raiz.resolve("mongodb").resolve(par[1]);
                exportar(c, script, saida);
            }
        }
    }

    private static void exportar(Connection c, Path script, Path saida) throws Exception {
        String sql = Files.readString(script).replace("\r\n", "\n").strip();

        // O ";" final e do cliente de linha de comando, nao da sintaxe: o JDBC
        // recusa a instrucao se ele vier junto.
        if (sql.endsWith(";")) sql = sql.substring(0, sql.length() - 1);

        try (Statement st = c.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            if (!rs.next()) throw new IllegalStateException(script + ": nenhuma linha devolvida");

            String json = rs.getString(1);
            if (json == null) {
                throw new IllegalStateException(script + ": resultado NULL -- tabela de origem vazia?");
            }

            Files.createDirectories(saida.getParent());
            Files.writeString(saida, json + "\n", StandardCharsets.UTF_8);

            System.out.printf("%-26s -> %-16s %,9d bytes  %3d documentos%n",
                    script.getFileName(), saida.getFileName(), json.length(), contarDocumentos(json));
        }
    }

    /**
     * Conta os documentos do nivel de cima sem precisar de biblioteca de JSON.
     * Ignora chaves dentro de texto (um nome com "{" nao conta como documento).
     */
    private static int contarDocumentos(String json) {
        int profundidade = 0, docs = 0;
        boolean dentroDeTexto = false, escapado = false;

        for (char ch : json.toCharArray()) {
            if (escapado) { escapado = false; continue; }

            if (dentroDeTexto) {
                if (ch == '\\') escapado = true;
                else if (ch == '"') dentroDeTexto = false;
                continue;
            }

            switch (ch) {
                case '"' -> dentroDeTexto = true;
                case '{' -> { if (++profundidade == 1) docs++; }
                case '}' -> profundidade--;
                default  -> { }
            }
        }
        return docs;
    }

    private static String exigir(String variavel) {
        String valor = System.getenv(variavel);
        if (valor == null || valor.isBlank()) {
            throw new IllegalStateException("defina a variavel de ambiente " + variavel);
        }
        return valor;
    }
}
