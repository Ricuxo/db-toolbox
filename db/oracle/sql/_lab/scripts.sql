Rem
Rem    NOME
Rem      scripts.sql 
Rem
Rem    DESCRIÇÃO
Rem      Indice dos scripts do DBA.
Rem
Rem    UTILIZAÇÃO
Rem      @scripts
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      19/02/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

PROMPT
PROMPT Scripts Básicos
PROMPT cls              - Limpa o buffer do SQL*Plus
PROMPT cab              - Ajustes do SQL*Plus
PROMPT rod              - Reset do SQL*Plus
PROMPT login            - Ajustes do ambiente SQl*Plus e informações da base de dados
PROMPT plus             - Ajustes do SQl*Plus e informações da base de dados
PROMPT
PROMPT Locks / Waits
PROMPT access           - Lista os objetos que estão atualmente bloqueados e as sessões que estão acessando eles <object>
PROMPT locks            - Lista as sessões com locks no banco de dados
PROMPT waits            - Mostra os maiores eventos de espera do banco no momento
PROMPT eventsession     - Lista quais sessões estão aguardando um determinado evento de espera <evento>
PROMPT segwaits         - Verifica qual segmento está ocasionando o determinado evento espera <evento>
PROMPT systemevent      - Lista os eventos de espera do banco (total de todas as sessões desde a última inicialização)
PROMPT verwait          - Mostra o recurso ou evento pelo qual a sessão está aguardando <sid>
PROMPT verwaituser      - Verifica quais eventos de espera as sessões de um usuario está aguardando
PROMPT sessionevent     - Mostra por quais recursos/eventos uma sessão esperou.
PROMPT
PROMPT OBS: Para ver mais scripts tecle ENTER!
PAUSE
PROMPT Conexões / Sessões / Transações
PROMPT ver              - Lista as conexões ativas do banco de dados
PROMPT versid           - Lista informações sobre uma sessão especifica <sid>
PROMPT versql           - Verifica o que um determinado usuário/sid está processando <sid>
PROMPT versqltext       - Mostra o texto completo do SQL <hash_value>
PROMPT veruser          - Lista informações sobre um usuário especifico <username>
PROMPT verspid          - Info sobre spid especificado <SPID>
PROMPT verplan          - Plano de execução atual no Oracle
PROMPT verprocess       - Lista informações de sessão de um PROCESS especifico <process>
PROMPT verhash          - Lista informações sobre as sessões ativas para um determinado hash_value <hash_value>
PROMPT tophash          - Lista a quantidade de um determinado hash_value das sessões ativas no banco 
PROMPT longops          - Verifica varreduras integrais nas tabelas
PROMPT longopsid        - Verifica varreduras integrais nas tabelas para um determinado SID <sid>
PROMPT longopsuser      - Verificar varreduras integrais nas tabelas para um determinado USER <user> 
PROMPT parallel         - Lista execuções de processos paralelos
PROMPT trace            - Ativa trace para uma sessão específica
PROMPT countsessions    - Lista a quantidade de sessões por usuário, program, osuser e sql_hash_value
PROMPT constot          - Total de sessões ativas e inativas
PROMPT conscpu          - Lista as querys que mais estão consumindo CPU
PROMPT undo             - Informa a situação da Tablespace de UNDO, a taxas de geração de UNDO
PROMPT undotrans        - Exibe a quantidade de blocos de UNDO utilizada por uma transação de uma sessão
PROMPT undousage        - Descreve a quantidade de blocos de UNDO em cada status
PROMPT sortusage        - Mostra a utilização dos segmentos temporários
PROMPT killuser         - Cria um meta SQL para eliminar todas as conexões de um usuário específico <username>
PROMPT latchfree        - Mostra as sessões que estão aguardando por latch free
PROMPT
PROMPT OBS: Para ver mais scripts tecle ENTER!
PAUSE
PROMPT Tablespaces / Datafiles / Filesystems / Tabelas
PROMPT tbsfreeall       - Lista o nome, tamanho, espaço usado, espaço livre, o % de ocupação de todos os tablespaces
PROMPT tbsfree          - Lista o espaço livre nos tablespaces <TABLESPACE_NAME>
PROMPT tbs_inc 			- Lista os datafiles na tablespcae <TABLESPACE_NAME>
PROMPT tbsincrease      - Lista nome, tamanho de todos os datafiles de um tablespace específico <tablespace_name>
PROMPT tbsxmonth        - Lista a quantidade(GB) de datafiles adicionados por mês
PROMPT tbstemp          - Lista os temporary tablespaces e seus tempfiles
PROMPT dftot            - Verifica qual o tamanho total da base de dados
PROMPT dfio             - Verifica a distribuição da carga de I/O por datafile
PROMPT dfree            - Lista o espaço livre contíguo no final do datafile <DATAFILE>
PROMPT fsbcv            - Lista o nome dos filesystems que contém arquivos do banco de dados
PROMPT table_size_day   - Mostra o tamanho da tabela entre dias
PROMPT
PROMPT OBS: Para ver mais scripts tecle ENTER!
PAUSE
PROMPT Schemas / Objetos / Usuarios   
PROMPT schema           - Lista a quantidade de objetos (por tipo) do schema especificado <schema>
PROMPT schematot        - Lista o tamanho (em MB) somando os segmentos do schema especificado <schema>
PROMPT busca            - Lista os objetos com o nome especificado <objeto>
PROMPT segsize          - Lista o owner, o nome, o tamanho e o tipo de segmento <segment_name>
PROMPT segtbs           - Lista owner, nome, tipo e dos objetos existentes em um tablespace <tablespace_name>
PROMPT tab              - Lista informações da tabela especificada <owner> <tabela>
PROMPT fragtab          - Mostra informações de utilização de espaço de uma tabela <owner> <tabela>
PROMPT child            - Descobre as tabelas que utilizam uma constraint(PK ou UK) de uma tabela pai <PK ou UK>
PROMPT columns          - Lista as colunas de uma tabela <owner> <table_name>
PROMPT constraints      - Exibe as restrições de integridade(constraints) de uma determinada tabela <owner> <table_name>
PROMPT ind              - Lista informações do índice especificado <owner> <index_name>
PROMPT indrebuild       - Verifica os indices inválidos e gera o comando para rebuild dos mesmos
PROMPT fragidx          - Lista informações sobre a utilização de espaço de um indice
PROMPT bigidx           - Verifica se há indices maiores que suas tabelas(owner).
PROMPT dblink           - Verifica os dblinks existentes
PROMPT grants           - Lista os grants de sistema, objeto e role de um determinado usuário <username>
PROMPT grantdba         - Lista todos os usuários com privilégio DBA
PROMPT grantsofdba      - Lista todos os usuários que possuem os privilégios existentes na rola DBA, menos das CONNECT e RESOURCE
PROMPT role             - Lista informações da role especificada <ROLE>
PROMPT jobs             - Lista os jobs schedulados no Banco
PROMPT trig             - Exibe informações uma determinada trigger <owner> <trigger_name>
PROMPT users            - Lista informações dos usuários 
PROMPT verddl           - Lista o DDL do objeto especificado <OBJECT_TYPE> <OBJECT_NAME> <OWNER>
PROMPT criaexp          - Cria o usuário EXPIMP e concedeu seus privilégios
PROMPT
PROMPT OBS: Para ver mais scripts tecle ENTER!
PAUSE
PROMPT Database
PROMPT arch             - Verifica a quantidade de archives gerados por dia
PROMPT version          - Mostra a release do servidor Oracle e seus componentes
PROMPT control          - Exibe informações sobre os arquivos de controles
PROMPT license          - Lista v$license e e verifica o máximo de processos pela v$parameter
PROMPT vercursor        - Verifica os cursores abertos e conta por sessão
PROMPT redo             - Lista os Redo Log groups/files e calcula o total
PROMPT undo             - Informa a situação da Tablespace de UNDO, a taxas de geração de UNDO
PROMPT dict             - Lista as views do dicionário da dados
PROMPT dictcols         - Lista colunas da view do dicionário da dados especificada <view_name>
PROMPT fixed            - Lista as views de DESEMPENHO do dicionário da dados <view_name>
PROMPT 
PROMPT Tunning
PROMPT sgastat          - Informações detalhadas da system global area (SGA)
PROMPT caches           - verifica a situação das estruturas de memória e sugere melhorias
PROMPT buffercache      - Informações sobre o cache de buffer(buffer_cache)
PROMPT librarycache     - Informações sobre o cache de biblioteca(library_cache) 
PROMPT rowcache         - Informações sobre o cache de dicionario(row_cache)
PROMPT logbuffer        - Informações sobre o Buffer de Redo Log(log_buffer)
PROMPT pga              - Fornece informações sobre a PGA
PROMPT sysstat          - Lista as estatísticas da Instância desde a última inicialização
PROMPT utlxplan         - Cria tabela PLAN_TABLE
PROMPT xplan            - Exibe o plano de execução da query na sessão atual
PROMPT topsql           - Exibe as instruções com mais buffer_gets e executions no momento
PROMPT
PROMPT OBS: Para ver mais scripts tecle ENTER!
PAUSE
PROMPT Outros 
PROMPT beginbkp         - Coloca as tablespaces do banco em begin backup
PROMPT endbkp           - Coloca as tablespaces do banco em end backup
PROMPT backup           - Verifica se há tablespaces em begin backup
PROMPT stats            - Verifica se as tabelas estão sendo monitoradas para fins de coleta de estatisticas
PROMPT ovo              - Monta as entradas para configuração de monitoraçao de tablespaces no HP OVO
PROMPT dbaprod          - Lista os arquivos gerados para carga via loader, movimentação RTX62P1 -> BILLHIP1
PROMPT tlogon           - Verifica o status da trigger de logon usada para rastrear(traces) <owner>
PROMPT tkv              - Verifica o total de sessões do KV no banco BSCS62P1
PROMPT ver_sql 			- Verifica a quantidade de linhas processadas de uma query
PROMPT
PROMPT Novos recursos Oracle 10g   
PROMPT flashdb          - Exibe informações da utilização do recurso Flashback Database
PROMPT flashdrop        - Verifica as informações de uma determinada tabela dropada, dentro da Recycle Bin <owner> <table>
PROMPT recyclebin       - Lista informações sobre o conteúdo e tamanho da recycle bin
PROMPT flashtq          - Exibe todas as transações de uma tabela a partir de uma data <owner> <tabela>
PROMPT flashvq          - Ajuda a alterar uma consulta, usando pseudocolunas p/ exibir os valores que uma coluna já teve
PROMPT flashtb          - Este script prepara os comandos para executar um Flashback Table


