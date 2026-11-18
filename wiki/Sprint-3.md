# UnB RU — Wiki (Sprint 3)

> Planejamento e distribuição de tarefas da Sprint 3: **refatoração e documentação do código** (Capítulo 9 do ESaaS, Edição 1.2.1). Aqui ficam a divisão do trabalho, a ordem de execução e, ao final da sprint, a tabela de antes e depois da refatoração. A especificação está na [Sprint 1](Sprint-1.md) e a implementação na [Home](Home.md) (Sprint 2).

## Identificação

| | |
|---|---|
| **Grupo** | 02 |
| **Sprint** | Sprint 3 — Refatoração e documentação |
| **Período** | 18/11/2026 a 27/11/2026 |
| **Entrega** | **27/11/2026** |
| **Branch de integração e entrega** | [`sprint-3`](https://github.com/Luisserra99/UnB_RU/tree/sprint-3) |
| **Kanban** | GitHub Project — Sprint 3 (Backlog, Doing, Done, Accepted) |

### Integrantes e papéis

| Integrante | Matrícula | Papel na Sprint 3 | Escopo de código (de quem implementou na Sprint 2) |
|---|---|---|---|
| Luis Eduardo Curi Serra | 251033574 | Desenvolvedor | F02, F03 e as ferramentas da sprint |
| Weldo Gonçalves da Silva Junior | 222014133 | **Scrum Master** | F01, F04, F07 e a base de identidade |
| Daniel Dezan Baby | 232046097 | **Product Owner** | F05, F06 |
| Leonardo Tome Sampaio | 222005448 | Desenvolvedor | F08, F10 |
| Tarsila Marques de Oliveira Alves | 242012029 | Desenvolvedora | F09, F11, F12 |

**Rodízio dos papéis:**

| Sprint | Scrum Master | Product Owner |
|---|---|---|
| Sprint 1 | Daniel Dezan Baby | Leonardo Tome Sampaio |
| Sprint 2 | Luis Eduardo Curi Serra | Tarsila Marques de Oliveira Alves |
| **Sprint 3** | **Weldo Gonçalves da Silva Junior** | **Daniel Dezan Baby** |

Nenhum dos papéis repete a Sprint 2. Weldo assume um papel pela primeira vez, e Daniel troca de papel em relação à Sprint 1 (foi Scrum Master).

| Papel Scrum | Responsável | Atribuições |
|---|---|---|
| **Scrum Master** | Weldo Gonçalves da Silva Junior | Montar o GitHub Project da Sprint 3 com as quatro lanes, cobrar que cada integrante crie as suas issues e conferir se estão com responsável, label e na lane certa, garantir que cada etapa da [ordem de execução](#2-ordem-de-execução) termine na data e preparar o arquivo `.txt` da entrega |
| **Product Owner** | Daniel Dezan Baby | Aceitar as issues (mover para Accepted) conferindo os quatro critérios, consolidar esta página com a tabela de antes e depois, fazer a verificação final e abrir o PR para o repositório da disciplina |

---

## 1. Objetivo e critérios de aceite

O foco da sprint é refatorar e documentar o código já entregue, **sem mudar o comportamento**. Todo o código entregue deve cumprir:

| # | Critério | Ferramenta | Meta |
|---|---|---|---|
| C1 | Complexidade por método | [RubyCritic](https://github.com/whitesmith/rubycritic) (ABC Score) | **ABC < 20** em todo método; métodos próximos de 20 também são refatorados |
| C2 | Cobertura de testes RSpec | [SimpleCov](https://github.com/simplecov-ruby/simplecov) | **> 90%** em cada controller e model do grupo, com os valores anotados |
| C3 | Happy path e sad path | RSpec e Cucumber | Todo caso de teste tem happy path e sad path. **Os `.feature` já existentes não podem ser alterados** |
| C4 | Documentação do código | [RDoc](https://github.com/ruby/rdoc) | Todo método tem: (a) descrição, (b) argumentos, (c) retorno e possibilidades de retorno, (d) efeitos colaterais (redirecionamento, escrita no banco etc.) |

Como os `.feature` existentes não podem mudar, o sad path que faltar num cenário Cucumber entra como novo exemplo RSpec (request, model ou service) ou como cenário num arquivo `.feature` **novo**.

### Entregáveis (27/11/2026)

| Entregável | Responsável |
|---|---|
| 1 Pull Request com o código finalizado (`sprint-3` → `neatzzy/UnB_RU`) | Daniel (PO) |
| Arquivo `.txt` com o link do repositório, nome e matrícula dos integrantes | Weldo (SM) |
| Wiki da Sprint 3 no GitHub, com o que foi refatorado e a tabela de antes e depois | Daniel (PO), com uma seção preenchida por cada integrante |

---

## 2. Ordem de execução

As etapas 1 a 4 preparam a base da sprint: instalação das ferramentas, medição de antes e um **piloto** de refatoração em F02 e F03. O piloto fixa o padrão que todos seguem: formato dos comentários RDoc, estilo de refatoração e forma de preencher a tabela de antes e depois. Os demais escopos começam a ser alterados depois que o piloto estiver mergeado na `sprint-3`.

As etapas são sequenciais: uma etapa só começa quando a anterior termina. Dentro de uma etapa, as tarefas da mesma linha podem correr em paralelo.

| Etapa | Data | Quem | O que faz | Começa quando | Termina quando |
|---|---|---|---|---|---|
| **1** | 18/11 (qua) | Luis | **T0** — instala e configura RubyCritic, SimpleCov e RDoc | — | PR da T0 mergeado na `sprint-3` |
| | 18/11 (qua) | Weldo | **T2** — cria o GitHub Project da Sprint 3 | — | Board com as quatro lanes |
| **2** | 19/11 (qui) | Luis | **T1** — roda RubyCritic e SimpleCov no commit da T0 e publica a medição de antes nesta página | Etapa 1 concluída | Medição de antes publicada (seção 6) |
| **3** | 19/11 (qui) | Todos | Cada integrante cria as suas issues a partir da T1 | Etapa 2 concluída | Todas as issues no Backlog, com responsável e pontos |
| **4** | 19/11 a 21/11 | Luis | **Piloto** — refatora, testa e documenta F02 e F03; publica o padrão de RDoc na seção 5 | Etapa 3 concluída | PR do piloto mergeado na `sprint-3` |
| | 19/11 a 21/11 | Weldo, Daniel, Leonardo, Tarsila | Leem a T1, listam os métodos do seu escopo que precisam de refatoração, de testes e de RDoc e planejam a abordagem nas issues. **Sem alterar código** | Etapa 3 concluída | Plano registrado nas issues |
| **5** | 22/11 a 24/11 | Weldo, Daniel, Leonardo, Tarsila | Refatoram, testam e documentam o seu escopo seguindo o padrão do piloto | PR do piloto mergeado | PRs mergeados na `sprint-3` até 24/11 |
| | 22/11 a 24/11 | Luis | Revisa os PRs da etapa 5, conferindo se seguem o padrão do piloto | Etapa 4 concluída | Todos os PRs da etapa 5 aprovados |
| **6** | 25/11 (qua) | Todos | Medem o depois do seu escopo, preenchem a sua linha da tabela de antes e depois e registram o uso de IA na seção 7 | Etapa 5 concluída | Linhas de todos preenchidas |
| **7** | 25/11 a 26/11 | Daniel | **T5** — verificação final na `sprint-3`; **T4** — consolida esta página | Etapa 6 concluída | Os quatro critérios conferidos |
| | 25/11 a 26/11 | Weldo | **T3** — arquivo `.txt` da entrega | Etapa 6 concluída | Arquivo no repositório |
| **8** | 26/11 (qui) | Daniel | **T6** — atualiza a Home e abre o PR `Grupo 02 - Sprint 3` | Etapa 7 concluída | PR aberto |
| **9** | **27/11 (sex)** | Daniel | **Entrega** — envia o PR, o `.txt` e o link da wiki | Etapa 8 concluída | Sprint entregue |

O dia 27/11 fica só para a entrega. Se alguma etapa atrasar, o Scrum Master avisa o grupo no mesmo dia, e a folga sai da etapa 7, nunca da etapa 2: sem a medição de antes, a tabela de antes e depois fica sem referência.

---

## 3. Tarefas transversais

| ID | Tarefa | Responsável | Etapa |
|---|---|---|---|
| T0 | Adicionar `rubycritic` e `simplecov` ao `Gemfile` (grupo `development, test`), iniciar o SimpleCov no topo de `spec/rails_helper.rb` (e em `features/support/env.rb`, se o grupo quiser a cobertura do Cucumber), configurar grupos por pasta (Controllers, Models, Services, Forms, Helpers), definir a geração do RDoc (`.rdoc_options` ou tarefa rake restrita a `app/`) e ignorar no `.gitignore` as saídas `coverage/`, `tmp/rubycritic/` e `doc/` | Luis | 1 |
| T1 | Rodar RubyCritic e SimpleCov no commit da T0 e publicar a medição de antes: lista dos métodos com ABC ≥ 15 e a cobertura de cada controller e model | Luis | 2 |
| T2 | Criar o GitHub Project da Sprint 3 com as lanes Backlog, Doing, Done e Accepted | Weldo | 1 |
| T3 | Arquivo `.txt` da entrega (link do repositório, nomes e matrículas) | Weldo | 7 |
| T4 | Consolidar esta página: seção "O que foi refatorado" e tabela de antes e depois com as linhas de todos | Daniel | 7 |
| T5 | Verificação final na `sprint-3`: RubyCritic sem método com ABC ≥ 20, SimpleCov > 90% por controller e model, `rspec` e `cucumber` passando sem alteração nos `.feature` existentes, RDoc gerado sem método sem documentação, RuboCop limpo | Daniel | 7 |
| T6 | Atualizar a [Home](Home.md) (papéis, branch de entrega e resultados dos testes) e abrir o PR `Grupo 02 - Sprint 3` | Daniel | 8 |

---

## 4. Distribuição por integrante

Cada integrante refatora, testa e documenta o código que implementou na Sprint 2, porque é quem conhece as regras daquele código. Em cada escopo, o integrante cumpre C1 a C4 em todos os arquivos listados, incluindo controllers, models, services, forms e helpers.

### Luis Eduardo Curi Serra — F02, F03 e as ferramentas

| Camada | Arquivos |
|---|---|
| Controllers | `recargas_controller.rb`, `extratos_controller.rb`, `sessoes_estudante_controller.rb`, `portal_estudante_controller.rb`, `concerns/autenticacao_estudante.rb` |
| Models | `recarga.rb`, `item_recarga.rb`, `pagamento.rb`, `movimentacao_saldo.rb`, `tarifa_refeicao.rb` |
| Forms e services | `forms/solicitacao_recarga.rb`, `forms/dados_cartao.rb`, `services/pagamentos/gateway_simulado.rb`, `services/pagamentos/processar_retorno.rb`, `services/extratos/consulta.rb` |
| Helpers | `recargas_helper.rb` |
| Features | `recarga_saldo.feature`, `extrato_historico.feature` |

Prováveis pontos de atenção: `SolicitacaoRecarga` (120 linhas) e `RecargasController` (87 linhas). Tarefas transversais: T0 e T1. Depois do piloto, revisa os PRs da etapa 5.

### Weldo Gonçalves da Silva Junior (SM) — F01, F04, F07 e a base de identidade

| Camada | Arquivos |
|---|---|
| Controllers | `application_controller.rb`, `cadastros_controller.rb`, `paginas_controller.rb`, `concerns/autenticacao_funcionario.rb`, `controle/base_controller.rb`, `controle/sessoes_controller.rb`, `controle/painel_controller.rb`, `controle/historico_controller.rb` |
| Models | `usuario.rb`, `papel.rb`, `usuario_papel.rb`, `estudante.rb`, `sessao_autenticacao.rb`, `application_record.rb` |
| Forms e services | `forms/cadastro_estudante.rb`, `services/historico_catraca/consulta.rb`, `services/historico_catraca/credencial.rb` |
| Helpers | `application_helper.rb`, `controle_helper.rb`, `historico_helper.rb`, `icones_helper.rb` |
| Features | `cadastro_usuario.feature`, `autenticacao_funcionario.feature`, `historico_local_catraca.feature` |

Tarefas do papel: T2 e T3.

### Daniel Dezan Baby (PO) — F05, F06

| Camada | Arquivos |
|---|---|
| Controllers | `controle/pontos_acesso_controller.rb`, `controle/terminal_controller.rb` |
| Models | `configuracao_ponto_acesso.rb`, `registro_acesso.rb`, `rateio_consumo.rb` |
| Services | `services/catracas/operar.rb`, `services/pontos_acesso/configurar.rb` |
| Features | `configuracao_ponto_acesso.feature`, `validacao_entrada.feature` |

`Catracas::Operar` (131 linhas) é o service mais provável de ter métodos com ABC alto no escopo. Tarefas do papel: T4, T5 e T6.

### Leonardo Tome Sampaio — F08, F10

| Camada | Arquivos |
|---|---|
| Controllers | `admin/base_controller.rb`, `admin/restaurantes_controller.rb`, `admin/catracas_controller.rb`, `controle/catracas_controller.rb`, `cardapios_controller.rb` |
| Models | `restaurante.rb`, `catraca.rb`, `piso.rb`, `unidade_gestora.rb`, `servico_refeicao.rb`, `tipo_refeicao.rb`, `cardapio.rb`, `item_cardapio.rb`, `opcao_cardapio.rb` |
| Services | `services/cardapios/importador_json.rb` |
| Helpers | `cardapios_helper.rb` |
| Features | `gestao_restaurante_catracas.feature`, `cardapio_atual.feature` |

Prováveis pontos de atenção: `Cardapios::ImportadorJson` (97 linhas) e o model `Restaurante` (93 linhas).

### Tarsila Marques de Oliveira Alves — F09, F11, F12

| Camada | Arquivos |
|---|---|
| Controllers | `admin/relatorios_base_controller.rb`, `admin/relatorios_globais_controller.rb`, `admin/acessos_operacao_controller.rb`, `exportacoes_extrato_controller.rb` |
| Models | `exportacao_relatorio.rb` |
| Services | `extratos/relatorio.rb`, `extratos/exportar.rb`, `extratos/pdf.rb`, `extratos/planilha_csv.rb`, `extratos/formatacao.rb`, `relatorios/operacao_global.rb`, `relatorios/operacao_global_pdf.rb`, `relatorios/operacao_global_csv.rb`, `relatorios/exportar_operacao_global.rb`, `relatorios/acessos_operacao.rb`, `relatorios/acessos_operacao_pdf.rb`, `relatorios/exportar_acessos_operacao.rb` |
| Helpers | `extratos_helper.rb` |
| Features | `relatorio_global_acesso.feature`, `exportacao_PDF_historico_estudante.feature`, `exportacao_pdf_relatorio_operacao.feature` |

É o escopo com os maiores services do projeto: `Extratos::Relatorio` (213 linhas), `Relatorios::OperacaoGlobal` (196) e `Relatorios::AcessosOperacao` (165). Por isso Tarsila não tem tarefa transversal nesta sprint e pode usar a etapa 4 para planejar a divisão desses services.

---

## 5. Issues, branches e padrões

**Cada integrante cria as suas próprias issues** no GitHub Project da Sprint 3 (etapa 3), se atribui como responsável, estima os pontos e as move pelas lanes. O Scrum Master confere, e o Product Owner aceita.

Sugestão de issues por integrante (uma por critério e escopo, para a tabela de antes e depois sair direto delas):

| Issue sugerida | Conteúdo |
|---|---|
| `[S3][<Fxx>] Refatoração — ABC < 20` | Métodos com ABC ≥ 15 do escopo, segundo a T1; técnica usada (extract method, extract class, objeto de serviço etc.) |
| `[S3][<Fxx>] Cobertura > 90%` | Cobertura de antes por controller e model e specs adicionados |
| `[S3][<Fxx>] Happy path e sad path` | Casos que só tinham um dos caminhos e os testes adicionados, sem alterar os `.feature` existentes |
| `[S3][<Fxx>] Documentação RDoc` | Comentários (a)–(d) em todos os métodos do escopo |

Tarefas transversais viram issues próprias do responsável (`[S3][T0] Ferramentas de análise`, `[S3][T3] Arquivo txt da entrega` etc.).

### Padrão de RDoc

> A ser publicado por Luis ao fim do piloto (etapa 4), com um método real do escopo F02/F03 como exemplo dos itens (a)–(d). Os demais integrantes seguem o mesmo formato na etapa 5.

### Branches

- `sprint-3-chore-Luis/ferramentas`: T0.
- `sprint-3-refactor-<integrante>/<escopo>`: refatoração e testes, criada a partir de `sprint-3` (ex.: `sprint-3-refactor-Tarsila/relatorios`).
- `sprint-3-docs-<integrante>/<escopo>`: só comentários RDoc, se o integrante preferir separar.

As branches da etapa 5 são criadas a partir da `sprint-3` **depois** do merge do piloto, para já conterem o padrão.

Commits seguem o padrão do grupo; para esta sprint, use também `refactor` (mudança de estrutura sem mudança de comportamento) e `chore` (configuração de ferramentas). Ex.: `refactor(relatorios): extrai cálculo de arrecadação de OperacaoGlobal`.

### Definição de pronto (Done)

- Nenhum método do escopo com ABC ≥ 20 no RubyCritic, e os próximos de 20 também revistos.
- Cada controller e model do escopo com cobertura > 90% no SimpleCov.
- `bundle exec rspec` e `bundle exec cucumber` passando, sem alteração nos `.feature` existentes.
- Todos os métodos do escopo com comentário RDoc cobrindo (a)–(d), no padrão do piloto.
- `bundle exec rubocop` sem ocorrências.
- Linha do integrante preenchida na tabela de antes e depois e uso de IA registrado na seção 7.
- PR revisado e aprovado por outro integrante.

---

## 6. Antes e depois da refatoração

> A coluna "antes" é preenchida por Luis na etapa 2 (T1). A coluna "depois" é preenchida por cada integrante na etapa 6. Uma linha por método refatorado e uma por controller ou model do grupo.

### ABC Score (RubyCritic)

| Responsável | Classe#método | ABC antes | ABC depois | Refatoração aplicada |
|---|---|---|---|---|
| | | | | |

### Cobertura (SimpleCov)

| Responsável | Controller / model | Cobertura antes | Cobertura depois |
|---|---|---|---|
| | | | |

### Resumo do projeto

| Métrica | Antes | Depois |
|---|---|---|
| Métodos com ABC ≥ 20 | | |
| Maior ABC Score | | |
| Nota geral do RubyCritic | | |
| Cobertura total (SimpleCov) | | |
| Exemplos RSpec | 501 | |
| Cenários Cucumber | 163 | |
| Métodos sem documentação RDoc | | |

---

## 7. Uso de IA na sprint

### Planejamento da sprint

Esta página (distribuição de tarefas, papéis, ordem de execução e modelos de tabela) foi elaborada com apoio do **Claude Code (Claude Opus 5.5)** e revisada por Luis Eduardo Curi Serra. Estratégia:

- Leitura do enunciado da Sprint 3 (critérios C1 a C4 e entregáveis) e das páginas [Sprint 1](Sprint-1.md) e [Home](Home.md), para seguir o formato das sprints anteriores e o rodízio de papéis.
- Levantamento, pelo histórico do git, de quem criou cada arquivo de `app/`, para atribuir a cada integrante o código que ele implementou na Sprint 2.
- Contagem de linhas dos arquivos para apontar os prováveis pontos de atenção de cada escopo. A lista definitiva dos métodos a refatorar sai da medição de antes (T1), não dessa estimativa.
- Nenhum código foi alterado nem nenhuma issue foi criada pela IA: as issues são criadas por cada integrante.

### Execução da sprint

Cada integrante registra aqui, na etapa 6, se usou IA no seu escopo, no mesmo formato da Sprint 2: ferramenta e modelo, em que tarefa (refatoração, testes, RDoc ou análise das métricas) e como o resultado foi revisado. Todo código gerado com IA só entra na `sprint-3` revisado pelo responsável e com RSpec e Cucumber passando.

| Integrante | Ferramenta e modelo | Uso | Revisão |
|---|---|---|---|
| Luis Eduardo Curi Serra | | | |
| Weldo Gonçalves da Silva Junior | | | |
| Daniel Dezan Baby | | | |
| Leonardo Tome Sampaio | | | |
| Tarsila Marques de Oliveira Alves | | | |
