# UnB RU — Wiki (Sprint 3)

> Planejamento e distribuição de tarefas da Sprint 3: **refatoração e documentação do código** (Capítulo 9 do ESaaS, Edição 1.2.1). Aqui ficam a divisão do trabalho, a ordem de execução e, ao final da sprint, a tabela de antes e depois da refatoração. A especificação está na [Sprint 1](Sprint-1.md) e a implementação na [Home](Home.md) (Sprint 2).

> **Consolidação em 25/11/2026:** os cinco escopos foram integrados à `sprint-3`. A seção [6.4](#64-verificação-consolidada-do-po--25112026) apresenta a verificação completa de C1–C4 e os entregáveis. Daniel autorizou a integração do fechamento e a abertura do PR final para a disciplina em **25/11/2026**.

## Identificação

| | |
|---|---|
| **Grupo** | 02 |
| **Sprint** | Sprint 3 — Refatoração e documentação |
| **Período** | 18/11/2026 a 27/11/2026 |
| **Entrega** | **27/11/2026** |
| **Branch de integração e entrega** | [`sprint-3`](https://github.com/Luisserra99/UnB_RU/tree/sprint-3) |
| **Kanban** | [Project do grupo — Sprint 3](https://github.com/users/Luisserra99/projects/1) (Backlog, Doing, Done, Accepted; no quadro atual, Doing = In progress, com In review antes de Done) |

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
| C1 | Complexidade por método | [RubyCritic](https://github.com/whitesmith/rubycritic) (Flog) e RuboCop (ABC) | **Flog < 20 e ABC < 20** em todo método; métodos próximos de 20 também são refatorados |
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
| T0 | Adicionar `rubycritic`, `simplecov` e `rdoc` ao `Gemfile`, iniciar o SimpleCov no topo de `spec/spec_helper.rb` com grupos por pasta (Controllers, Models, Services, Forms, Helpers), configurar o RubyCritic (`.rubycritic.yml`), criar as tarefas `qualidade:*` e `documentacao` e ignorar `doc/` no `.gitignore`. Ver [como rodar](#como-rodar-as-ferramentas-t0) | Luis | 1 |
| T1 | Rodar RubyCritic e SimpleCov no commit da T0 e publicar a medição de antes: lista dos métodos com ABC ≥ 15 e a cobertura de cada controller e model | Luis | 2 |
| T2 | Criar o GitHub Project da Sprint 3 com as lanes Backlog, Doing, Done e Accepted | Weldo | 1 |
| T3 | Arquivo `.txt` da entrega (link do repositório, nomes e matrículas) | Weldo | 7 |
| T4 | Consolidar esta página: seção "O que foi refatorado" e tabela de antes e depois com as linhas de todos | Daniel | 7 |
| T5 | Verificação final na `sprint-3`: nenhum método com Flog ≥ 20 ou ABC ≥ 20, SimpleCov > 90% por controller e model, `rspec` e `cucumber` passando sem alteração nos `.feature` existentes, RDoc gerado sem método sem documentação, RuboCop limpo | Daniel | 7 |
| T6 | Atualizar a [Home](Home.md) (papéis, branch de entrega e resultados dos testes) e abrir o PR `Grupo 02 - Sprint 3` | Daniel | 8 |

### Como rodar as ferramentas (T0)

Depois de `bundle install`, os comandos abaixo valem para todos os integrantes. No Windows, use `ruby bin/rails ...`.

| Critério | Comando | O que mostra |
|---|---|---|
| C1 | `bin/rails "qualidade:metodos[15]"` | Tabela Markdown com o **Flog** (mesmo analisador do RubyCritic) e o **ABC** (cálculo do RuboCop, com o vetor `<A, B, C>`) de cada método com nota ≥ 15 em `app/`. Para filtrar: `bin/rails "qualidade:metodos[0,app/forms/dados_cartao.rb app/models]"` |
| C1 | `bundle exec rubycritic` | Relatório completo em `tmp/rubycritic/overview.html`: nota geral, smells (Reek), duplicação (Flay) e métodos com Flog ≥ 25 |
| C2 | `bundle exec rspec` e depois `bin/rails qualidade:cobertura` | O RSpec gera `coverage/index.html`; a tarefa imprime a tabela Markdown da cobertura de cada controller e model. Para outras pastas: `bin/rails "qualidade:cobertura[app/services app/forms]"` |
| C4 | `bin/rails qualidade:rdoc` | Classes, constantes e métodos (inclusive privados) sem comentário RDoc. Aceita caminhos: `bin/rails "qualidade:rdoc[app/models/pagamento.rb]"` |
| C4 | `bin/rails documentacao` | Gera o HTML do RDoc em `doc/app/index.html` |

`coverage/`, `tmp/rubycritic/` e `doc/` ficam fora do git. O RubyCritic só sinaliza métodos com Flog ≥ 25, então a lista completa por método sai da tarefa `qualidade:metodos`. **O grupo adota as duas medidas no critério C1: um método só está pronto com Flog < 20 e ABC < 20.**

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
| `[S3][<Fxx>] Refatoração — Flog e ABC < 20` | Métodos do escopo com nota ≥ 15 na [medição de antes](#61-medição-de-antes-t1); técnica usada (extract method, extract class, objeto de serviço etc.) |
| `[S3][<Fxx>] Cobertura > 90%` | Cobertura de antes por controller e model e specs adicionados |
| `[S3][<Fxx>] Happy path e sad path` | Casos que só tinham um dos caminhos e os testes adicionados, sem alterar os `.feature` existentes |
| `[S3][<Fxx>] Documentação RDoc` | Comentários (a)–(d) em todos os métodos do escopo |

Tarefas transversais viram issues próprias do responsável (`[S3][T0] Ferramentas de análise`, `[S3][T3] Arquivo txt da entrega` etc.).

### Padrão de RDoc

Definido no piloto (F02, F03 e login do Portal do Estudante). Vale para **todo método**, público ou privado, inclusive ações de controller e validações. Cada comentário fica logo acima do `def` e responde aos itens (a)–(d) do enunciado com três rótulos fixos, que o RDoc mostra como uma lista de definições:

```ruby
# <(a) O que o método faz, numa frase no presente.>
#
# Argumentos:: <(b) +nome+ (Tipo): significado. Ou "nenhum.">
# Retorno:: <(c) Tipo e significado; se houver mais de uma possibilidade, todas, separadas por ";">
# Efeitos colaterais:: <(d) banco, sessão, flash, redirecionamento, render, exceções. Ou "nenhum.">
```

Exemplo real ([`app/forms/solicitacao_recarga.rb`](../app/forms/solicitacao_recarga.rb)):

```ruby
# Valida o formulário e grava a recarga com seus itens e o pagamento pendente (RN02.2).
#
# Argumentos:: nenhum.
# Retorno:: true quando a recarga foi gravada (disponível em #recarga); false quando o formulário
#           é inválido ou o banco rejeita a gravação (os motivos ficam em #errors).
# Efeitos colaterais:: grava Recarga, ItemRecarga e Pagamento numa única transação; para PIX,
#                      gera o código Copia e Cola. Não credita saldo.
def salvar
```

Regras:

- **Os quatro itens sempre aparecem**, mesmo quando a resposta é "nenhum": assim o leitor sabe que o item foi pensado, não esquecido.
- Nomes de código entre `+...+` (`+params[:id]+`, `+new+`). Classes e métodos do projeto escritos por extenso (`Pagamento#confirmar!`, `DadosCartao`) viram links no HTML.
- Continuação de linha alinhada com o texto do rótulo, como no exemplo.
- **Ação de controller:** a primeira linha diz a rota (`POST /recargas: ...`); os argumentos são os `params` lidos; o retorno é "nenhum (ação de controller)"; os efeitos colaterais listam cada `render` e `redirect_to` com a condição de cada um.
- **Validação:** o retorno é "nenhum relevante"; os efeitos colaterais dizem em qual atributo o erro é adicionado.
- **Classes, módulos e constantes** também recebem uma linha de comentário. Numa classe dentro de módulo (`module Pagamentos` / `class ProcessarRetorno`), o comentário fica logo acima da classe, dentro do módulo; acima do `module` ele documentaria o módulo.
- Conferir com `bin/rails "qualidade:rdoc[<arquivos do escopo>]"`, que deve dar 100%, e ver o resultado com `bin/rails documentacao` (abre em `doc/app/index.html`).

### Padrão de refatoração e testes do piloto

| Situação | O que o piloto fez | Exemplo |
|---|---|---|
| Método longo com várias etapas | *Extract method*, com nomes que dizem a intenção | `SolicitacaoRecarga#salvar` → `montar_recarga`, `adicionar_item`, `adicionar_pagamento` |
| Muitas chamadas repetidas com dados diferentes | Trocar o código repetido por uma lista de dados percorrida por um laço | `GatewaySimulado#copia_e_cola` → `campos_br_code` |
| Condição composta no meio de uma ação | Predicado privado com nome de regra de negócio | `RecargasController#cobranca_cartao_em_aberto?`, `ExtratosController#extrato_de_outro_estudante?` |
| Consulta montada no meio de uma validação | Scopes nomeados no model | `TarifaRefeicao.nao_encerradas_em` e `.iniciadas_antes_de` |
| Formatação de erro feita no controller | Mover para o objeto que tem os erros | `SolicitacaoRecarga#mensagem_erro` |
| Validação com vários `if` encadeados | Separar em uma validação por regra, com `return` antecipado | `MovimentacaoSaldo#validar_recarga_do_credito` e `#validar_passagem_do_debito` |

- **Comportamento idêntico:** os `.feature` não mudam e o RSpec e o Cucumber continuam passando. Quando a saída é um texto gerado (código PIX, SVG do QR Code), o piloto comparou a saída antes e depois byte a byte.
- **"Próximo de 20":** o piloto deixou todo método abaixo de **18** (90% do limite) nas duas medidas. Métodos entre 15 e 18 foram revistos e mantidos quando dividi-los não deixava o código mais claro (ex.: `DadosCartao#luhn_valido?`, 15,68).
- **Happy path e sad path:** para cada unidade testada (model, form, service, helper, request), há ao menos um caso de sucesso e um de falha. O que faltava foi adicionado em RSpec, no `describe` da própria unidade, por exemplo o banco rejeitando a recarga em `SolicitacaoRecarga#salvar` e o logout sem sessão.
- **Antes e depois:** cada método refatorado ganha uma linha na seção 6.2 com Flog e ABC de antes (da 6.1) e de depois (`bin/rails "qualidade:metodos[0,<arquivo>]"`), e com a técnica usada.

### Branches

- `sprint-3-chore-Luis/ferramentas`: T0.
- `sprint-3-refactor-<integrante>/<escopo>`: refatoração e testes, criada a partir de `sprint-3` (ex.: `sprint-3-refactor-Tarsila/relatorios`).
- `sprint-3-docs-<integrante>/<escopo>`: só comentários RDoc, se o integrante preferir separar.

As branches da etapa 5 são criadas a partir da `sprint-3` **depois** do merge do piloto, para já conterem o padrão.

Commits seguem o padrão do grupo; para esta sprint, use também `refactor` (mudança de estrutura sem mudança de comportamento) e `chore` (configuração de ferramentas). Ex.: `refactor(relatorios): extrai cálculo de arrecadação de OperacaoGlobal`.

### Definição de pronto (Done)

- Nenhum método do escopo com Flog ≥ 20 ou ABC ≥ 20 (`bin/rails qualidade:metodos`), e os próximos de 20 também revistos.
- Cada controller e model do escopo com cobertura > 90% no SimpleCov.
- `bundle exec rspec` e `bundle exec cucumber` passando, sem alteração nos `.feature` existentes.
- Todos os métodos do escopo com comentário RDoc cobrindo (a)–(d), no padrão do piloto.
- `bundle exec rubocop` sem ocorrências.
- Linha do integrante preenchida na tabela de antes e depois e uso de IA registrado na seção 7.
- PR revisado e aprovado por outro integrante.

---

## 6. Antes e depois da refatoração

### 6.1 Medição de antes (T1)

> Medida em 18/11/2026 no commit `575ba8c` (T0, branch `sprint-3-chore-Luis/ferramentas`), antes de qualquer refatoração, com os comandos da [seção 3](#como-rodar-as-ferramentas-t0). O responsável de cada arquivo é quem o criou na Sprint 2, conforme a [distribuição](#4-distribuição-por-integrante).

Esta é a medição de partida da sprint: os números abaixo servem de "antes" na [seção 6.2](#62-antes-e-depois) e definem quais métodos e arquivos cada integrante precisa corrigir.

#### Como a medição foi feita

**Ambiente:** Linux, Ruby 3.3.4, Rails 8.1.4.1, banco SQLite de teste. Versões das ferramentas (do `Gemfile.lock`): RubyCritic 5.0.0 (com Flog 4.9.4, Reek 6.5.0 e Flay 2.14.5), RuboCop 1.92.2, SimpleCov 1.3.2 e RDoc 8.1.0.

**Comandos, na ordem em que foram rodados:**

```bash
git checkout 575ba8c          # commit da T0, sem nenhuma refatoração
bundle install

# Testes: confirmam que o ponto de partida está verde e geram a cobertura
bundle exec rspec                       # gera coverage/coverage.json (SimpleCov)
bundle exec cucumber --format progress
bundle exec rubocop

# C1: complexidade por método
bin/rails "qualidade:metodos[15]"       # todos os métodos com Flog ou ABC >= 15
bin/rails "qualidade:metodos[20]"       # só os que estão acima do limite
bundle exec rubycritic                  # nota geral, smells e duplicação

# C2: cobertura, lida do coverage.json do RSpec acima
bin/rails qualidade:cobertura                                     # controllers e models
bin/rails "qualidade:cobertura[app/forms app/helpers app/services]"

# C4: documentação
bin/rails qualidade:rdoc
```

**Como os números foram consolidados:**

- **Nota do método:** é a maior entre o Flog e o ABC que a tarefa `qualidade:metodos` imprime. Os métodos com nota ≥ 20 estão marcados como **Refatorar** (violam o C1) e os que têm nota entre 15 e 20 como **Revisar** ("próximos de 20", como pede o enunciado).
- **Por que duas medidas:** o RubyCritic, ferramenta indicada pelo enunciado, mede a complexidade pelo **Flog**, uma variação ponderada do ABC, e só lista os métodos com Flog ≥ 25. O ABC exato (vetor `<Assignments, Branches, Conditions>`) vem do cálculo do cop `Metrics/AbcSize` do RuboCop. Esse cop fica desligado no estilo `omakase` do projeto, por isso o "RuboCop limpo" não diz nada sobre complexidade. A tarefa `qualidade:metodos` junta as duas medidas para cada `def` de `app/`.
- **Contagens:** 57 métodos têm nota ≥ 20 (saída de `qualidade:metodos[20]`), e todos eles têm Flog ≥ 20. Na mesma saída, 30 têm também ABC ≥ 20, e nenhum passa de 20 só no ABC.
- **Responsável:** cada arquivo foi atribuído pelo caminho, de acordo com as listas da [seção 4](#4-distribuição-por-integrante).
- **Cobertura:** corresponde ao percentual de linhas que o SimpleCov registra para cada arquivo durante o `bundle exec rspec`. O Cucumber não entra nessa conta.

#### Resultado de cada ferramenta

| Ferramenta | Critério | Resultado no commit `575ba8c` |
|---|---|---|
| RSpec | C2, C3 | 507 exemplos, 0 falhas |
| Cucumber | C3 | 163 cenários e 1456 passos, todos passando |
| RuboCop | — | 222 arquivos, nenhuma ofensa |
| `qualidade:metodos` (Flog e ABC) | C1 | 82 métodos com nota ≥ 15: **57 para refatorar** (nota ≥ 20) e 25 para revisar. Maior nota: `Catracas::Operar#ler`, com Flog 67,65 e ABC 54,90 |
| RubyCritic | C1 | Nota geral **85,37**. Dos 79 arquivos de `app/`: 49 A, 19 B, 6 C, 5 D e nenhum E ou F. 384 smells, 502 pontos de duplicação em 13 arquivos e 40 métodos com Flog ≥ 25 |
| SimpleCov | C2 | **99,27%** no total (2049 de 2064 linhas). Só 1 controller ou model fica com 90% ou menos: `controle/terminal_controller.rb`, com 83,33% |
| RDoc | C4 | **17,01%** documentado. 305 dos 369 métodos estão sem comentário |

A contagem de 40 métodos do RubyCritic difere da tabela abaixo, que tem 39 métodos com Flog ≥ 25. A diferença é `Relatorios::AcessosOperacao#montar_acesso`, que a tarefa mede com 24,83 e o RubyCritic sinaliza como ≥ 25. De qualquer forma, o método já está na lista para refatorar.

#### Resumo por responsável

| Responsável | Métodos com nota ≥ 20 (refatorar) | Métodos com nota entre 15 e 20 (revisar) | Controllers e models com cobertura ≤ 90% |
|---|---|---|---|
| Luis | 12 | 6 | nenhum |
| Weldo | 2 | 4 | nenhum |
| Daniel | 8 | 4 | `terminal_controller.rb` |
| Leonardo | 6 | 2 | nenhum |
| Tarsila | 29 | 9 | nenhum |
| **Total** | **57** | **25** | **1** |

“Nota” é a maior entre Flog e ABC. Um método só está pronto com as duas abaixo de 20.

#### Métodos com Flog ou ABC ≥ 15

| Responsável | Método | Arquivo:linha | Flog | ABC `<A, B, C>` | Situação |
|---|---|---|---|---|---|
| Luis | `Pagamentos::GatewaySimulado#copia_e_cola` | `app/services/pagamentos/gateway_simulado.rb:26` | 49,39 | 28,44 `<5, 28, 0>` | **Refatorar** |
| Luis | `SolicitacaoRecarga#salvar` | `app/forms/solicitacao_recarga.rb:76` | 45,87 | 30,03 `<6, 29, 5>` | **Refatorar** |
| Luis | `DadosCartao#validade_futura` | `app/forms/dados_cartao.rb:35` | 29,95 | 19,75 `<2, 19, 5>` | **Refatorar** |
| Luis | `SessoesEstudanteController#create` | `app/controllers/sessoes_estudante_controller.rb:10` | 28,44 | 25,24 `<5, 24, 6>` | **Refatorar** |
| Luis | `MovimentacaoSaldo#validar_credito` | `app/models/movimentacao_saldo.rb:45` | 28,12 | 22,14 `<0, 21, 7>` | **Refatorar** |
| Luis | `RecargasController#pagar_cartao` | `app/controllers/recargas_controller.rb:31` | 26,70 | 24,54 `<3, 23, 8>` | **Refatorar** |
| Luis | `MovimentacaoSaldo#validar_debito` | `app/models/movimentacao_saldo.rb:56` | 26,61 | 21,19 `<0, 20, 7>` | **Refatorar** |
| Luis | `RecargasHelper#qr_padrao_localizacao` | `app/helpers/recargas_helper.rb:54` | 26,17 | 19,10 `<10, 12, 11>` | **Refatorar** |
| Luis | `RecargasController#create` | `app/controllers/recargas_controller.rb:14` | 26,07 | 19,75 `<2, 19, 5>` | **Refatorar** |
| Luis | `ExtratosController#show` | `app/controllers/extratos_controller.rb:7` | 25,09 | 19,47 `<3, 19, 3>` | **Refatorar** |
| Luis | `TarifaRefeicao#sem_sobreposicao_de_vigencia` | `app/models/tarifa_refeicao.rb:35` | 21,68 | 17,58 `<2, 17, 4>` | **Refatorar** |
| Luis | `Pagamentos::GatewaySimulado#crc16` | `app/services/pagamentos/gateway_simulado.rb:47` | 21,35 | 13,08 `<7, 11, 1>` | **Refatorar** |
| Luis | `Extratos::Consulta#refeicoes` | `app/services/extratos/consulta.rb:33` | 18,19 | 13,34 `<3, 12, 5>` | Revisar |
| Luis | `AutenticacaoEstudante#exigir_estudante!` | `app/controllers/concerns/autenticacao_estudante.rb:34` | 16,43 | 15,39 `<4, 14, 5>` | Revisar |
| Luis | `Pagamento#confirmar!` | `app/models/pagamento.rb:34` | 15,69 | 12,41 `<1, 12, 3>` | Revisar |
| Luis | `DadosCartao#luhn_valido?` | `app/forms/dados_cartao.rb:49` | 15,68 | 11,53 `<6, 9, 4>` | Revisar |
| Luis | `RecargasHelper#qr_modulos` | `app/helpers/recargas_helper.rb:35` | 15,57 | 12,25 `<5, 11, 2>` | Revisar |
| Luis | `MovimentacaoSaldo#descricao` | `app/models/movimentacao_saldo.rb:23` | 15,21 | 12,08 `<1, 9, 8>` | Revisar |
| Weldo | `Controle::HistoricoController#create` | `app/controllers/controle/historico_controller.rb:18` | 30,17 | 25,40 `<4, 25, 2>` | **Refatorar** |
| Weldo | `Controle::SessoesController#create` | `app/controllers/controle/sessoes_controller.rb:12` | 25,52 | 22,91 `<4, 22, 5>` | **Refatorar** |
| Weldo | `CadastroEstudante#salvar` | `app/forms/cadastro_estudante.rb:29` | 18,78 | 13,30 `<2, 13, 2>` | Revisar |
| Weldo | `ControleHelper#item_nav_controle` | `app/helpers/controle_helper.rb:5` | 17,13 | 13,64 `<4, 11, 7>` | Revisar |
| Weldo | `CadastroEstudante#validar_email` | `app/forms/cadastro_estudante.rb:67` | 16,99 | 13,34 `<0, 13, 3>` | Revisar |
| Weldo | `Controle::HistoricoController#historico_liberado?` | `app/controllers/controle/historico_controller.rb:39` | 16,27 | 10,82 `<1, 10, 4>` | Revisar |
| Daniel | `Catracas::Operar#ler` | `app/services/catracas/operar.rb:10` | 67,65 | 54,90 `<15, 50, 17>` | **Refatorar** |
| Daniel | `RateioConsumo#origens_e_limites` | `app/models/rateio_consumo.rb:11` | 59,79 | 43,12 `<3, 41, 13>` | **Refatorar** |
| Daniel | `Catracas::Operar#passar` | `app/services/catracas/operar.rb:50` | 40,28 | 26,27 `<4, 25, 7>` | **Refatorar** |
| Daniel | `PontosAcesso::Configurar::call` | `app/services/pontos_acesso/configurar.rb:5` | 39,34 | 29,31 `<7, 27, 9>` | **Refatorar** |
| Daniel | `RegistroAcesso#coerencia_da_passagem` | `app/models/registro_acesso.rb:31` | 31,21 | 22,83 `<0, 20, 11>` | **Refatorar** |
| Daniel | `Catracas::Operar#ratear!` | `app/services/catracas/operar.rb:118` | 30,18 | 22,20 `<6, 21, 4>` | **Refatorar** |
| Daniel | `ConfiguracaoPontoAcesso#disponivel?` | `app/models/configuracao_ponto_acesso.rb:20` | 29,08 | 18,38 `<0, 17, 7>` | **Refatorar** |
| Daniel | `Controle::PontosAcessoController#create` | `app/controllers/controle/pontos_acesso_controller.rb:3` | 27,68 | 21,19 `<2, 21, 2>` | **Refatorar** |
| Daniel | `Catracas::Operar#confirmar_liberacao` | `app/services/catracas/operar.rb:76` | 17,17 | 12,81 `<2, 12, 4>` | Revisar |
| Daniel | `Controle::TerminalController#passagem` | `app/controllers/controle/terminal_controller.rb:19` | 17,09 | 12,21 `<2, 12, 1>` | Revisar |
| Daniel | `Catracas::Operar#expirar_pendentes!` | `app/services/catracas/operar.rb:96` | 16,94 | 12,08 `<1, 12, 1>` | Revisar |
| Daniel | `Controle::TerminalController#ler` | `app/controllers/controle/terminal_controller.rb:12` | 16,69 | 12,21 `<2, 12, 1>` | Revisar |
| Leonardo | `ServicoRefeicao#sem_sobreposicao_de_horario` | `app/models/servico_refeicao.rb:40` | 29,09 | 21,63 `<2, 20, 8>` | **Refatorar** |
| Leonardo | `Cardapios::ImportadorJson#importar` | `app/services/cardapios/importador_json.rb:25` | 28,72 | 20,25 `<13, 15, 4>` | **Refatorar** |
| Leonardo | `Restaurante#atualizar_com_pisos` | `app/models/restaurante.rb:49` | 26,90 | 17,38 `<3, 17, 2>` | **Refatorar** |
| Leonardo | `Admin::CatracasController#salvar` | `app/controllers/admin/catracas_controller.rb:43` | 21,25 | 23,19 `<9, 21, 4>` | **Refatorar** |
| Leonardo | `CardapiosController#show` | `app/controllers/cardapios_controller.rb:3` | 22,75 | 19,72 `<8, 17, 6>` | **Refatorar** |
| Leonardo | `Catraca#identificacao_unica_no_restaurante` | `app/models/catraca.rb:30` | 21,43 | 15,33 `<1, 15, 3>` | **Refatorar** |
| Leonardo | `Cardapios::ImportadorJson#importar_cardapio` | `app/services/cardapios/importador_json.rb:58` | 18,05 | 16,67 `<10, 13, 3>` | Revisar |
| Leonardo | `Cardapios::ImportadorJson#itens_da_dieta` | `app/services/cardapios/importador_json.rb:73` | 17,15 | 16,03 `<8, 12, 7>` | Revisar |
| Tarsila | `Relatorios::AcessosOperacaoPdf#corpo_agrupado` | `app/services/relatorios/acessos_operacao_pdf.rb:57` | 45,84 | 28,23 `<3, 28, 2>` | **Refatorar** |
| Tarsila | `Relatorios::AcessosOperacao#initialize` | `app/services/relatorios/acessos_operacao.rb:22` | 45,77 | 37,43 `<14, 34, 7>` | **Refatorar** |
| Tarsila | `Relatorios::AcessosOperacaoPdf#cabecalho` | `app/services/relatorios/acessos_operacao_pdf.rb:42` | 37,04 | 28,04 `<1, 28, 1>` | **Refatorar** |
| Tarsila | `Relatorios::OperacaoGlobalCsv#render` | `app/services/relatorios/operacao_global_csv.rb:15` | 34,02 | 19,13 `<2, 19, 1>` | **Refatorar** |
| Tarsila | `Relatorios::OperacaoGlobalPdf#indicadores` | `app/services/relatorios/operacao_global_pdf.rb:51` | 33,83 | 25,02 `<1, 25, 0>` | **Refatorar** |
| Tarsila | `Extratos::Relatorio#paginas_visiveis` | `app/services/extratos/relatorio.rb:112` | 31,48 | 19,10 `<4, 18, 5>` | **Refatorar** |
| Tarsila | `Extratos::Pdf#resumo` | `app/services/extratos/pdf.rb:54` | 30,58 | 22,02 `<1, 22, 0>` | **Refatorar** |
| Tarsila | `Relatorios::OperacaoGlobalPdf#cabecalho` | `app/services/relatorios/operacao_global_pdf.rb:39` | 29,70 | 22,02 `<1, 22, 0>` | **Refatorar** |
| Tarsila | `Extratos::Pdf#cabecalho` | `app/services/extratos/pdf.rb:40` | 28,52 | 22,09 `<2, 22, 0>` | **Refatorar** |
| Tarsila | `Relatorios::OperacaoGlobal#initialize` | `app/services/relatorios/operacao_global.rb:29` | 28,47 | 23,02 `<9, 20, 7>` | **Refatorar** |
| Tarsila | `Relatorios::AcessosOperacao#grupos` | `app/services/relatorios/acessos_operacao.rb:67` | 27,87 | 17,61 `<6, 15, 7>` | **Refatorar** |
| Tarsila | `Relatorios::AcessosOperacao#consulta` | `app/services/relatorios/acessos_operacao.rb:139` | 26,67 | 19,34 `<3, 19, 2>` | **Refatorar** |
| Tarsila | `Extratos::Relatorio#lancamento_de_refeicao` | `app/services/extratos/relatorio.rb:204` | 26,17 | 20,32 `<4, 19, 6>` | **Refatorar** |
| Tarsila | `Extratos::Pdf#tabela` | `app/services/extratos/pdf.rb:65` | 25,88 | 22,83 `<6, 22, 1>` | **Refatorar** |
| Tarsila | `Relatorios::AcessosOperacaoPdf#tabela` | `app/services/relatorios/acessos_operacao_pdf.rb:74` | 25,52 | 23,11 `<7, 22, 1>` | **Refatorar** |
| Tarsila | `Extratos::Relatorio#initialize` | `app/services/extratos/relatorio.rb:46` | 25,38 | 21,68 `<11, 18, 5>` | **Refatorar** |
| Tarsila | `Relatorios::AcessosOperacao#montar_acesso` | `app/services/relatorios/acessos_operacao.rb:150` | 24,83 | 19,47 `<3, 19, 3>` | **Refatorar** |
| Tarsila | `Relatorios::OperacaoGlobalPdf#consolidacao` | `app/services/relatorios/operacao_global_pdf.rb:62` | 24,05 | 18,28 `<3, 18, 1>` | **Refatorar** |
| Tarsila | `Relatorios::OperacaoGlobal#distribuicao_por_refeicao` | `app/services/relatorios/operacao_global.rb:94` | 23,77 | 18,60 `<9, 16, 3>` | **Refatorar** |
| Tarsila | `ExportacaoRelatorio#validar_conclusao` | `app/models/exportacao_relatorio.rb:71` | 22,92 | 17,72 `<0, 17, 5>` | **Refatorar** |
| Tarsila | `ExportacoesExtratoController#create` | `app/controllers/exportacoes_extrato_controller.rb:5` | 22,61 | 18,22 `<2, 18, 2>` | **Refatorar** |
| Tarsila | `Relatorios::OperacaoGlobal#horarios_das_refeicoes` | `app/services/relatorios/operacao_global.rb:160` | 22,24 | 16,03 `<6, 14, 5>` | **Refatorar** |
| Tarsila | `Extratos::PlanilhaCsv#render` | `app/services/extratos/planilha_csv.rb:16` | 21,88 | 13,19 `<2, 13, 1>` | **Refatorar** |
| Tarsila | `Relatorios::OperacaoGlobal#acessos` | `app/services/relatorios/operacao_global.rb:175` | 21,55 | 15,33 `<1, 15, 3>` | **Refatorar** |
| Tarsila | `Relatorios::ExportarAcessosOperacao#call` | `app/services/relatorios/exportar_acessos_operacao.rb:27` | 20,88 | 15,65 `<2, 15, 4>` | **Refatorar** |
| Tarsila | `Relatorios::AcessosOperacaoPdf#render` | `app/services/relatorios/acessos_operacao_pdf.rb:26` | 20,63 | 15,07 `<1, 15, 1>` | **Refatorar** |
| Tarsila | `Relatorios::OperacaoGlobal#linhas` | `app/services/relatorios/operacao_global.rb:39` | 20,33 | 16,40 `<8, 14, 3>` | **Refatorar** |
| Tarsila | `Extratos::Relatorio#corresponde?` | `app/services/extratos/relatorio.rb:178` | 20,23 | 14,90 `<1, 11, 10>` | **Refatorar** |
| Tarsila | `Admin::RelatoriosGlobaisController#exportar` | `app/controllers/admin/relatorios_globais_controller.rb:10` | 20,03 | 16,25 `<2, 16, 2>` | **Refatorar** |
| Tarsila | `Relatorios::OperacaoGlobal#liquidacoes` | `app/services/relatorios/operacao_global.rb:65` | 18,94 | 13,15 `<5, 12, 2>` | Revisar |
| Tarsila | `Relatorios::ExportarAcessosOperacao#concluir` | `app/services/relatorios/exportar_acessos_operacao.rb:50` | 17,34 | 14,32 `<3, 14, 0>` | Revisar |
| Tarsila | `Relatorios::OperacaoGlobalPdf#liquidacao` | `app/services/relatorios/operacao_global_pdf.rb:69` | 16,77 | 13,38 `<3, 13, 1>` | Revisar |
| Tarsila | `Relatorios::OperacaoGlobalPdf#tabela` | `app/services/relatorios/operacao_global_pdf.rb:87` | 15,00 | 16,67 `<9, 14, 1>` | Revisar |
| Tarsila | `Extratos::Exportar#concluir` | `app/services/extratos/exportar.rb:58` | 16,43 | 13,60 `<4, 13, 0>` | Revisar |
| Tarsila | `Extratos::Relatorio#refeicoes_por_tipo` | `app/services/extratos/relatorio.rb:86` | 16,32 | 10,95 `<2, 10, 4>` | Revisar |
| Tarsila | `Admin::AcessosOperacaoController#exportar` | `app/controllers/admin/acessos_operacao_controller.rb:10` | 16,16 | 13,30 `<2, 13, 2>` | Revisar |
| Tarsila | `Relatorios::ExportarOperacaoGlobal#call` | `app/services/relatorios/exportar_operacao_global.rb:30` | 15,01 | 11,58 `<2, 11, 3>` | Revisar |
| Tarsila | `Extratos::Exportar#call` | `app/services/extratos/exportar.rb:39` | 15,01 | 11,58 `<2, 11, 3>` | Revisar |

#### Cobertura de controllers e models (RSpec)

| Responsável | Arquivo | Cobertura | Linhas cobertas |
|---|---|---|---|
| Luis | `app/controllers/concerns/autenticacao_estudante.rb` | 100,00% | 34/34 |
| Luis | `app/controllers/extratos_controller.rb` | 100,00% | 8/8 |
| Luis | `app/controllers/portal_estudante_controller.rb` | 100,00% | 2/2 |
| Luis | `app/controllers/recargas_controller.rb` | 100,00% | 47/47 |
| Luis | `app/controllers/sessoes_estudante_controller.rb` | 100,00% | 24/24 |
| Luis | `app/models/item_recarga.rb` | 100,00% | 16/16 |
| Luis | `app/models/movimentacao_saldo.rb` | 97,37% | 37/38 |
| Luis | `app/models/pagamento.rb` | 100,00% | 42/42 |
| Luis | `app/models/recarga.rb` | 100,00% | 27/27 |
| Luis | `app/models/tarifa_refeicao.rb` | 95,65% | 22/23 |
| Weldo | `app/controllers/application_controller.rb` | 100,00% | 5/5 |
| Weldo | `app/controllers/cadastros_controller.rb` | 100,00% | 11/11 |
| Weldo | `app/controllers/concerns/autenticacao_funcionario.rb` | 100,00% | 36/36 |
| Weldo | `app/controllers/controle/base_controller.rb` | 100,00% | 15/15 |
| Weldo | `app/controllers/controle/historico_controller.rb` | 100,00% | 25/25 |
| Weldo | `app/controllers/controle/painel_controller.rb` | 100,00% | 4/4 |
| Weldo | `app/controllers/controle/sessoes_controller.rb` | 100,00% | 26/26 |
| Weldo | `app/controllers/paginas_controller.rb` | 100,00% | 2/2 |
| Weldo | `app/models/application_record.rb` | 100,00% | 2/2 |
| Weldo | `app/models/estudante.rb` | 100,00% | 12/12 |
| Weldo | `app/models/papel.rb` | 100,00% | 9/9 |
| Weldo | `app/models/sessao_autenticacao.rb` | 100,00% | 32/32 |
| Weldo | `app/models/usuario.rb` | 100,00% | 33/33 |
| Weldo | `app/models/usuario_papel.rb` | 100,00% | 4/4 |
| Daniel | `app/controllers/controle/pontos_acesso_controller.rb` | 100,00% | 16/16 |
| Daniel | `app/controllers/controle/terminal_controller.rb` | **83,33%** | 20/24 |
| Daniel | `app/models/configuracao_ponto_acesso.rb` | 100,00% | 20/20 |
| Daniel | `app/models/rateio_consumo.rb` | 100,00% | 17/17 |
| Daniel | `app/models/registro_acesso.rb` | 96,15% | 25/26 |
| Leonardo | `app/controllers/admin/base_controller.rb` | 100,00% | 8/8 |
| Leonardo | `app/controllers/admin/catracas_controller.rb` | 100,00% | 37/37 |
| Leonardo | `app/controllers/admin/restaurantes_controller.rb` | 100,00% | 26/26 |
| Leonardo | `app/controllers/cardapios_controller.rb` | 100,00% | 20/20 |
| Leonardo | `app/controllers/controle/catracas_controller.rb` | 100,00% | 5/5 |
| Leonardo | `app/models/cardapio.rb` | 100,00% | 12/12 |
| Leonardo | `app/models/catraca.rb` | 100,00% | 25/25 |
| Leonardo | `app/models/item_cardapio.rb` | 100,00% | 5/5 |
| Leonardo | `app/models/opcao_cardapio.rb` | 100,00% | 8/8 |
| Leonardo | `app/models/piso.rb` | 100,00% | 7/7 |
| Leonardo | `app/models/restaurante.rb` | 100,00% | 57/57 |
| Leonardo | `app/models/servico_refeicao.rb` | 100,00% | 27/27 |
| Leonardo | `app/models/tipo_refeicao.rb` | 100,00% | 9/9 |
| Leonardo | `app/models/unidade_gestora.rb` | 100,00% | 8/8 |
| Tarsila | `app/controllers/admin/acessos_operacao_controller.rb` | 100,00% | 14/14 |
| Tarsila | `app/controllers/admin/relatorios_base_controller.rb` | 100,00% | 12/12 |
| Tarsila | `app/controllers/admin/relatorios_globais_controller.rb` | 100,00% | 13/13 |
| Tarsila | `app/controllers/exportacoes_extrato_controller.rb` | 100,00% | 10/10 |
| Tarsila | `app/models/exportacao_relatorio.rb` | 100,00% | 38/38 |

Fora de controllers e models, ficaram abaixo de 100%: `app/forms/cadastro_estudante.rb` (95,56%), `app/forms/solicitacao_recarga.rb` (97,01%), `app/helpers/controle_helper.rb` (88,89%) e `app/services/catracas/operar.rb` (97,67%).

#### Documentação (RDoc)

`bin/rails qualidade:rdoc` em `app/` (inclui métodos privados):

| Item | Total | Sem documentação |
|---|---|---|
| Classes | 70 | 43 |
| Módulos | 20 | 10 |
| Constantes | 142 | 136 |
| Atributos | 34 | 33 |
| **Métodos** | **369** | **305** |
| Total | 635 | 527 (17,01% documentado) |

#### Relatório do RubyCritic

`bundle exec rubycritic` (relatório em `tmp/rubycritic/overview.html`). Arquivos com nota C ou D:

| Nota | Arquivo | Complexidade (Flog do arquivo) | Duplicação | Smells |
|---|---|---|---|---|
| D | `app/services/extratos/relatorio.rb` | 289,0 | 0 | 21 |
| D | `app/services/relatorios/operacao_global.rb` | 228,4 | 0 | 14 |
| D | `app/services/relatorios/acessos_operacao.rb` | 221,0 | 0 | 23 |
| D | `app/services/extratos/exportar.rb` | 51,2 | 110 | 10 |
| D | `app/services/relatorios/exportar_operacao_global.rb` | 49,9 | 135 | 11 |
| C | `app/services/catracas/operar.rb` | 189,8 | 0 | 30 |
| C | `app/services/relatorios/operacao_global_pdf.rb` | 153,5 | 0 | 13 |
| C | `app/services/relatorios/acessos_operacao_pdf.rb` | 148,5 | 33 | 18 |
| C | `app/services/extratos/pdf.rb` | 101,8 | 33 | 11 |
| C | `app/forms/solicitacao_recarga.rb` | 101,0 | 0 | 7 |
| C | `app/services/relatorios/exportar_acessos_operacao.rb` | 48,9 | 41 | 8 |

Smells mais frequentes (Reek): `IrresponsibleModule` (60, classe ou módulo sem comentário), `DuplicateMethodCall` (56), `TooManyStatements` (44), `HighComplexity` e `VeryHighComplexity` (40, Flog ≥ 25), `NilCheck` (29), `InstanceVariableAssumption` (28), `UtilityFunction` (28), `FeatureEnvy` (25) e `DuplicateCode` (21, do Flay). A duplicação se concentra entre os serviços de exportação: `Extratos::Exportar` e `Relatorios::ExportarOperacaoGlobal` têm 110 e 135 pontos.

#### Por que essas correções são necessárias

- **C1, complexidade (57 métodos para refatorar e 25 para revisar):** quanto maiores o Flog e o ABC, mais atribuições, chamadas e condições o método acumula. Um método assim é mais difícil de ler, testar por partes e alterar sem efeito colateral. O enunciado exige ABC < 20 e pede que os métodos próximos de 20 também sejam refatorados. O grupo exige também Flog < 20 porque é essa a medida que o RubyCritic mostra a quem avalia: 27 dos 57 métodos passariam só pelo ABC e continuariam com complexidade alta no relatório. O trabalho se concentra nos serviços de relatórios e extratos (F09, F11 e F12: 29 métodos) e em `Catracas::Operar` (F05 e F06), que também são os arquivos com nota C e D no RubyCritic.
- **Duplicação:** os serviços de exportação repetem o mesmo fluxo de criar, gerar e concluir a exportação. Extrair esse fluxo comum reduz a complexidade dos dois de uma vez e evita que uma correção feita em um deles falte no outro.
- **C2, cobertura (1 arquivo abaixo da meta):** o projeto já tem 99,27% de cobertura, mas `controle/terminal_controller.rb` tem 83,33% e precisa de testes para as 4 linhas não cobertas. A cobertura alta é também o que garante que a refatoração não muda o comportamento: antes de mexer num método, os testes que passam por ele precisam existir.
- **C3, happy path e sad path:** não há ferramenta que meça isso. Cada integrante confere, unidade por unidade, se há um caso de sucesso e um de falha. Como os `.feature` não podem mudar, o caso que faltar entra em RSpec.
- **C4, documentação (305 de 369 métodos sem RDoc):** é o maior volume de trabalho da sprint. Sem descrição, argumentos, retorno e efeitos colaterais, quem chega ao código precisa ler a implementação inteira para saber o que um método faz e o que ele altera. O smell `IrresponsibleModule` (60 ocorrências) aponta a mesma falta nas classes e módulos.

### 6.2 Antes e depois

> Antes: medição T1 no commit `575ba8c`. Depois: conjunto completo integrado até `e6c17a4`, verificado em 25/11/2026 na branch de consolidação. As 82 linhas de complexidade foram conferidas contra a medição atual; todos os controllers e models listados ficaram com 100% de cobertura. Métodos mantidos entre 15 e 18 têm justificativa na tabela.

#### O que foi refatorado

| Integrante | Alterações verificadas |
|---|---|
| Luis | Piloto integrado: separação da criação de recargas, validações monetárias, geração do PIX e autenticação do estudante; testes e RDoc conforme as linhas abaixo |
| Weldo | F01/F04/F07 e identidade: separação das etapas de cadastro e autenticação, conferência e liberação do histórico; predicados nos helpers e validações, testes de sucesso e recusa e RDoc da base de identidade |
| Daniel | F05: seleção e confirmação do ponto separadas em validação da sessão, localização dos cadastros e gravação transacional; reconfiguração do controller compartilhada por `create` e `edit`. F06: leitura, avaliação de estudante/refeição, passagem, débito e consumo FIFO separados em métodos com intenção explícita; validações de passagem e limites do rateio divididas por regra. Mantidos locks, rollback, idempotência, mensagens e prazo inclusivo de cinco segundos |
| Leonardo | F08: validações de sobreposição de horário e de identificação de catraca divididas em predicados com nome de regra (`horario_completo?`, `sobrepoe?`, `identificacao_repetida?`) e scope `Catraca.do_restaurante`; acréscimo de pisos e gravação da catraca separados em métodos de uma etapa. F10: importação do cardápio separada por restaurante, refeição e opção da dieta; montagem da tela do cardápio em `carregar_restaurante`, `carregar_refeicao` e `cardapio_consultado`. Remoção de restaurante e de catraca unificada em `Admin::BaseController#remover_e_voltar_a_lista` (eliminou a duplicação apontada pelo Flay). Mantidas as transações, as mensagens e a idempotência da importação. RubyCritic no escopo: nota 92,86 → 93,76 e smells 63 → 40 |
| Tarsila | F09/F11/F12: filtros, consultas, agregações e exportações divididos por etapa; composição de PDF compartilhada em `Extratos::ComposicaoPdf` e entrega dos arquivos em `EntregaDeExportacao`; testes de falha das exportações e RDoc de todo o escopo |

No escopo do Daniel, foram acrescentados **59 exemplos RSpec** (547 → 606 no projeto), cobrindo sucesso e recusa da seleção, rollback da reconfiguração, sessão/perfil/cadastros indisponíveis, dados obrigatórios da passagem, limites financeiros e atualização do próprio rateio, entradas inválidas, perda de vínculo entre leitura e passagem, crédito esgotado no FIFO, rollback por falta de créditos e respostas de erro/expiração do terminal. Os sete arquivos têm **100% de cobertura** e **100% de documentação RDoc** (61 métodos; 74 itens). Nenhum método tem Flog ou ABC ≥ 18.

Os resultados do Daniel foram medidos localmente a partir da `sprint-3` (`5ad39cb`), em **23/11/2026**, com Ruby **3.4.10** no macOS. As alterações estão na branch `sprint-3-refactor-Daniel/catracas`, com integração acompanhada no [PR #68](https://github.com/Luisserra99/UnB_RU/pull/68). Daniel informou que revisou e aprovou seu escopo e autorizou sua finalização em **23/11/2026**. Os resultados dos demais escopos também estão consolidados abaixo; a verificação completa está na seção 6.4.

No escopo da Tarsila (F09, F11 e F12): depois da refatoração, a maior nota do escopo é 17,25 (Flog de `Relatorios::AcessosOperacao#montar_acesso`); nenhum método do escopo, novo ou antigo, chega a 18 em nenhuma das duas medidas. Os services, o helper e os dois arquivos novos (`app/services/extratos/composicao_pdf.rb` e `app/controllers/concerns/entrega_de_exportacao.rb`) também estão com 100,00%.

#### Complexidade por método

| Responsável | Classe#método | Flog antes | Flog depois | ABC antes | ABC depois | Refatoração aplicada |
|---|---|---|---|---|---|---|
| Luis | `Pagamentos::GatewaySimulado#copia_e_cola` | 49,39 | 9,06 | 28,44 | 8,66 | Campos do BR Code viram uma lista de dados (`campos_br_code`); extraídos `conta_pix` e `txid_emv` |
| Luis | `SolicitacaoRecarga#salvar` | 45,87 | 16,10 | 30,03 | 11,22 | *Extract method*: `montar_recarga`, `categorias_compradas`, `adicionar_item` e `adicionar_pagamento` |
| Luis | `DadosCartao#validade_futura` | 29,95 | 9,68 | 19,75 | 7,68 | *Extract method*: `fim_da_validade` e `mes_e_ano_da_validade`; regex em constante |
| Luis | `SessoesEstudanteController#create` | 28,44 | 16,71 | 25,24 | 14,87 | *Extract method*: `campos_em_branco` e `entrar`; usuário sem cadastro de estudante recusado com a mesma mensagem de credencial inválida |
| Luis | `MovimentacaoSaldo#validar_credito` | 28,12 | 10,39 | 22,14 | 9,22 | Validação da recarga separada em `validar_recarga_do_credito`, com `return` antecipado |
| Luis | `RecargasController#pagar_cartao` | 26,70 | 10,15 | 24,54 | 9,27 | Predicado `cobranca_cartao_em_aberto?`; extraídos `params_cartao`, `dados_cartao_invalidos`, `cobrar_cartao` e `redirecionar_apos_pagamento` (reusado em `simular_confirmacao`) |
| Luis | `MovimentacaoSaldo#validar_debito` | 26,61 | 10,39 | 21,19 | 9,22 | Validação da passagem separada em `validar_passagem_do_debito`, com `return` antecipado |
| Luis | `RecargasHelper#qr_padrao_localizacao` | 26,17 | 9,10 | 19,10 | 9,00 | Cantos em constante; desenho do padrão extraído para `qr_modulo_do_localizador` |
| Luis | `RecargasController#create` | 26,07 | 16,15 | 19,75 | 15,26 | Predicado `somente_calcular?`; formatação dos erros movida para `SolicitacaoRecarga#mensagem_erro` |
| Luis | `ExtratosController#show` | 25,09 | 8,02 | 19,47 | 7,35 | Predicado `extrato_de_outro_estudante?`; extraídos `negar_acesso` e `filtros_do_relatorio` |
| Luis | `TarifaRefeicao#sem_sobreposicao_de_vigencia` | 21,68 | 9,87 | 17,58 | 8,54 | Consulta extraída para `tarifas_sobrepostas`, com os scopes `nao_encerradas_em` e `iniciadas_antes_de` |
| Luis | `Pagamentos::GatewaySimulado#crc16` | 21,35 | 8,03 | 13,08 | 7,28 | Laço por byte e por bit extraído para `crc16_byte` e `crc16_bit` |
| Luis | `Extratos::Consulta#refeicoes` | 18,19 | 6,26 | 13,34 | 5,39 | Conversão de cada débito extraída para `refeicao_de` |
| Luis | `AutenticacaoEstudante#exigir_estudante!` | 16,43 | 11,72 | 15,39 | 11,79 | Escolha do aviso extraída para `mensagem_de_login_obrigatorio` |
| Luis | `Pagamento#confirmar!` | 15,69 | 15,69 | 12,41 | 12,41 | Revisto e mantido: transação curta e legível |
| Luis | `DadosCartao#luhn_valido?` | 15,68 | 15,68 | 11,53 | 11,53 | Revisto e mantido: algoritmo de Luhn em um só bloco |
| Luis | `RecargasHelper#qr_modulos` | 15,57 | 15,57 | 12,25 | 12,25 | Revisto e mantido: um laço sobre a grade do QR Code |
| Luis | `MovimentacaoSaldo#descricao` | 15,21 | 7,86 | 12,08 | 6,32 | Descrição do crédito extraída para `descricao_do_credito` |
| Weldo | `Controle::HistoricoController#create` | 30,17 | 5,58 | 25,40 | 5,20 | *Extract method*: `credencial_valida?`, `liberar_historico` e `recusar_credencial` |
| Weldo | `Controle::SessoesController#create` | 25,52 | 13,28 | 22,91 | 11,45 | *Extract method*: `campos_em_branco` (como no login do estudante), `autenticar`, `motivo_da_recusa` e `entrar` |
| Weldo | `CadastroEstudante#salvar` | 18,78 | 8,22 | 13,30 | 6,40 | Gravação de Usuario, Estudante e papel extraída para `criar_conta!` |
| Weldo | `ControleHelper#item_nav_controle` | 17,13 | 6,45 | 13,64 | 7,07 | Predicado `item_nav_ativo?` e item desabilitado extraído para `item_nav_desabilitado`, com `return` antecipado |
| Weldo | `CadastroEstudante#validar_email` | 16,99 | 9,83 | 13,34 | 8,25 | Condição composta virou o predicado `email_institucional?`; no mesmo padrão, `validar_matricula` (14,17 → 9,92) ganhou `matricula_ja_cadastrada?` |
| Weldo | `Controle::HistoricoController#historico_liberado?` | 16,27 | 4,62 | 10,82 | 4,24 | Conferência do ponto de acesso e do prazo extraída para o predicado `liberacao_vigente?` |
| Daniel | `Catracas::Operar#ler` | 67,65 | 8,38 | 54,90 | 7,68 | *Extract method*: validação da entrada, referência idempotente, disponibilidade e avaliação da leitura |
| Daniel | `RateioConsumo#origens_e_limites` | 59,79 | 9,98 | 43,12 | 8,94 | Origens, crédito da recarga e limite do débito separados; somas excluem o próprio rateio |
| Daniel | `Catracas::Operar#passar` | 40,28 | 14,07 | 26,27 | 10,63 | Extraídos `cobrar_passagem!`, `estudante_apto?` e `debitar!`, preservando os locks e a transação |
| Daniel | `PontosAcesso::Configurar::call` | 39,34 | 2,20 | 29,31 | 3,61 | Fachada delega ao serviço de instância; sessão, restaurante, catraca e confirmação isolados (método de instância: Flog 6,36 / ABC 6,40) |
| Daniel | `RegistroAcesso#coerencia_da_passagem` | 31,21 | 2,00 | 22,83 | 2,00 | Separadas a completude dos dados e a janela de passagem, com predicados nomeados |
| Daniel | `Catracas::Operar#ratear!` | 30,18 | 9,71 | 22,20 | 9,43 | Extraídos a consulta FIFO e o consumo de cada crédito, preservando soma e rollback |
| Daniel | `ConfiguracaoPontoAcesso#disponivel?` | 29,08 | 5,24 | 18,38 | 4,47 | Predicados `sessao_disponivel?` e `cadastros_disponiveis?` |
| Daniel | `Controle::PontosAcessoController#create` | 27,68 | 13,58 | 21,19 | 10,10 | Preparação compartilhada da reconfiguração e apresentação de erro extraídas |
| Daniel | `Catracas::Operar#confirmar_liberacao` | 17,17 | 17,17 | 12,81 | 12,81 | Revisto e mantido: abaixo de 18 nas duas medidas; fluxo curto de confirmação, expiração e idempotência |
| Daniel | `Controle::TerminalController#passagem` | 17,09 | 17,09 | 12,21 | 12,21 | Revisto e mantido: abaixo de 18; ação curta com resposta HTTP de sucesso e erro, ambas testadas |
| Daniel | `Catracas::Operar#expirar_pendentes!` | 16,94 | 10,75 | 12,08 | 8,12 | Consulta de liberações vencidas extraída para `liberacoes_vencidas` |
| Daniel | `Controle::TerminalController#ler` | 16,69 | 16,69 | 12,21 | 12,21 | Revisto e mantido: abaixo de 18; delegação da leitura e tratamento HTTP de erro documentados e testados |
| Leonardo | `ServicoRefeicao#sem_sobreposicao_de_horario` | 29,09 | 11,05 | 21,63 | 9,90 | Predicados `horario_completo?` (reusado em `inicio_antes_do_fim`) e `sobrepoe?`; consulta extraída para `servicos_do_mesmo_dia` |
| Leonardo | `Cardapios::ImportadorJson#importar` | 28,72 | 10,56 | 20,25 | 8,94 | *Extract method*: laços por dia e refeição em `importar_restaurante` (Flog 6,80 / ABC 11,58) e busca do serviço em `importar_refeicao`; contadores num Hash passado ao `Resultado` |
| Leonardo | `Restaurante#atualizar_com_pisos` | 26,90 | 7,25 | 17,38 | 5,48 | *Extract method*: `acrescentar_pisos_faltantes` e `numeros_dos_pisos_faltantes` (Flog 12,26 / ABC 10,20) |
| Leonardo | `Admin::CatracasController#salvar` | 21,25 | 12,33 | 23,19 | 13,00 | *Extract method*: `params_catraca`, `preencher_catraca` e `recusar_restaurante_inexistente` |
| Leonardo | `CardapiosController#show` | 22,75 | 9,45 | 19,72 | 8,31 | *Extract method*: `carregar_restaurante`, `carregar_refeicao` e `cardapio_consultado` |
| Leonardo | `Catraca#identificacao_unica_no_restaurante` | 21,43 | 8,73 | 15,33 | 7,62 | Consulta extraída para o predicado `identificacao_repetida?`, com o scope `Catraca.do_restaurante` |
| Leonardo | `Cardapios::ImportadorJson#importar_cardapio` | 18,05 | 9,62 | 16,67 | 10,20 | Gravação da opção e dos itens extraída para `criar_opcao` |
| Leonardo | `Cardapios::ImportadorJson#itens_da_dieta` | 17,15 | 8,35 | 16,03 | 8,77 | Predicados `possui_item_proprio?` e `campo_da_dieta?` |
| Tarsila | `Relatorios::AcessosOperacaoPdf#corpo_agrupado` | 45,84 | 4,81 | 28,23 | 4,58 | *Extract method*: `bloco_do_restaurante`, `bloco_da_catraca` e `resumo` |
| Tarsila | `Relatorios::AcessosOperacao#initialize` | 45,77 | 9,02 | 37,43 | 8,54 | *Extract method*, uma etapa por grupo de filtros: `definir_periodo`, `definir_locais`, `definir_exibicao`, `interpretar_por_pagina` e `encontrar_por_id` |
| Tarsila | `Relatorios::AcessosOperacaoPdf#cabecalho` | 37,04 | 9,80 | 28,04 | 8,06 | Linhas do cabeçalho viram listas de dados (`linhas_de_titulo`, `linhas_de_emissao`, `linhas_de_filtros`) escritas por `ComposicaoPdf#escrever_linhas` |
| Tarsila | `Relatorios::OperacaoGlobalCsv#render` | 34,02 | 7,41 | 19,13 | 5,48 | Linhas do arquivo viram uma lista (`linhas`, `linha_de_dados`) percorrida por um laço |
| Tarsila | `Relatorios::OperacaoGlobalPdf#indicadores` | 33,83 | 7,30 | 25,02 | 6,08 | Indicadores viram listas de dados (`indicadores_de_movimento`, `indicadores_de_conferencia`) escritas por `escrever_linhas` |
| Tarsila | `Extratos::Relatorio#paginas_visiveis` | 31,48 | 7,62 | 19,10 | 6,63 | *Extract method*: `paginas_candidatas`; predicado `salto_entre?` |
| Tarsila | `Extratos::Pdf#resumo` | 30,58 | 7,30 | 22,02 | 6,08 | Linhas do resumo viram listas de dados (`linhas_de_valores`, `linhas_de_quantidades`); título pela `ComposicaoPdf#secao` |
| Tarsila | `Relatorios::OperacaoGlobalPdf#cabecalho` | 29,70 | 8,60 | 22,02 | 7,07 | Linhas do cabeçalho viram listas de dados (`linhas_de_filtros`, `linhas_de_emissao`) |
| Tarsila | `Extratos::Pdf#cabecalho` | 28,52 | 8,60 | 22,09 | 7,07 | Linhas do cabeçalho viram listas de dados (`linhas_do_estudante`, `linhas_de_filtros`) |
| Tarsila | `Relatorios::OperacaoGlobal#initialize` | 28,47 | 13,36 | 23,02 | 13,08 | *Extract method*: `escolher_unidade` |
| Tarsila | `Relatorios::AcessosOperacao#grupos` | 27,87 | 8,03 | 17,61 | 6,56 | *Extract method*: `montar_grupo`, `subtotais_por_catraca` e `somar_valores` |
| Tarsila | `Relatorios::AcessosOperacao#consulta` | 26,67 | 5,68 | 19,34 | 5,20 | *Extract method*: `registros_do_periodo`, `intervalo_do_periodo` e `filtro_de_local`; associações em constante |
| Tarsila | `Extratos::Relatorio#lancamento_de_refeicao` | 26,17 | 12,64 | 20,32 | 10,39 | *Extract method*: `local_da_refeicao` |
| Tarsila | `Extratos::Pdf#tabela` | 25,88 | 7,04 | 22,83 | 6,78 | *Extract method* `linha_da_tabela`; desenho movido para `ComposicaoPdf#desenhar_tabela` (*extract module*) |
| Tarsila | `Relatorios::AcessosOperacaoPdf#tabela` | 25,52 | 5,78 | 23,11 | 6,48 | *Extract method* `linha_da_tabela`; desenho movido para `ComposicaoPdf#desenhar_tabela` (*extract module*) |
| Tarsila | `Extratos::Relatorio#initialize` | 25,38 | 5,49 | 21,68 | 6,40 | *Extract method*: `definir_filtros`, `valor_permitido` e `id_de_catraca_disponivel` |
| Tarsila | `Relatorios::AcessosOperacao#montar_acesso` | 24,83 | 17,25 | 19,47 | 13,08 | *Extract method*: `local_do_acesso` e `nome_da_refeicao` |
| Tarsila | `Relatorios::OperacaoGlobalPdf#consolidacao` | 24,05 | 15,17 | 18,28 | 12,41 | *Extract method* `linha_de_restaurante`; título da seção passa a ser escrito por `tabela` |
| Tarsila | `Relatorios::OperacaoGlobal#distribuicao_por_refeicao` | 23,77 | 7,87 | 18,60 | 7,48 | Consulta repetida extraída para `totais_por` (reusada em `linhas`); *extract method* `montar_turno` |
| Tarsila | `ExportacaoRelatorio#validar_conclusao` | 22,92 | 7,66 | 17,72 | 6,78 | Uma validação por regra, com `return` antecipado: `validar_conclusao` (laço sobre `CAMPOS_DA_CONCLUSAO`) e `validar_emissao_sem_conclusao` |
| Tarsila | `ExportacoesExtratoController#create` | 22,61 | 16,12 | 18,22 | 13,15 | Resposta (arquivo ou redirecionamento) movida para o concern `EntregaDeExportacao#entregar_exportacao` |
| Tarsila | `Relatorios::OperacaoGlobal#horarios_das_refeicoes` | 22,24 | 11,39 | 16,03 | 7,87 | *Extract method*: `faixa_de_horario` |
| Tarsila | `Extratos::PlanilhaCsv#render` | 21,88 | 10,87 | 13,19 | 7,35 | *Extract method*: `linha` |
| Tarsila | `Relatorios::OperacaoGlobal#acessos` | 21,55 | 7,07 | 15,33 | 5,39 | *Extract method*: `acessos_do_dia` e `servicos_do_turno` |
| Tarsila | `Relatorios::ExportarAcessosOperacao#call` | 20,88 | 11,78 | 15,65 | 8,77 | *Extract method*: `registrar_pedido` e `falhar` |
| Tarsila | `Relatorios::AcessosOperacaoPdf#render` | 20,63 | 6,38 | 15,07 | 6,08 | *Extract method*: `corpo` e `numerar_paginas`; abertura do documento em `ComposicaoPdf#novo_documento` |
| Tarsila | `Relatorios::OperacaoGlobal#linhas` | 20,33 | 6,45 | 16,40 | 6,16 | Consulta extraída para `totais_por`; *extract method* `montar_linha` |
| Tarsila | `Extratos::Relatorio#corresponde?` | 20,23 | 4,08 | 14,90 | 3,74 | Um predicado por filtro: `no_periodo?`, `do_tipo?` e `da_catraca?` |
| Tarsila | `Admin::RelatoriosGlobaisController#exportar` | 20,03 | 13,55 | 16,25 | 11,18 | Resposta movida para o concern `EntregaDeExportacao#entregar_exportacao` |
| Tarsila | `Relatorios::OperacaoGlobal#liquidacoes` | 18,94 | 6,82 | 13,15 | 6,71 | *Extract method*: `valores_liquidados` e `montar_liquidacao` |
| Tarsila | `Relatorios::ExportarAcessosOperacao#concluir` | 17,34 | 13,48 | 14,32 | 11,40 | *Extract method*: `dados_da_conclusao` |
| Tarsila | `Relatorios::OperacaoGlobalPdf#liquidacao` | 16,77 | 14,47 | 13,38 | 12,41 | Título da seção passa a ser escrito por `tabela` |
| Tarsila | `Relatorios::OperacaoGlobalPdf#tabela` | 15,00 | 4,50 | 16,67 | 6,40 | Desenho movido para `ComposicaoPdf#desenhar_tabela` (*extract module*) |
| Tarsila | `Extratos::Exportar#concluir` | 16,43 | 9,96 | 13,60 | 8,94 | *Extract method*: `dados_da_conclusao` |
| Tarsila | `Extratos::Relatorio#refeicoes_por_tipo` | 16,32 | 10,40 | 10,95 | 5,39 | Ordem das refeições em constante (`ORDEM_DAS_REFEICOES`) e `Hash#slice` no lugar do laço |
| Tarsila | `Admin::AcessosOperacaoController#exportar` | 16,16 | 9,81 | 13,30 | 8,25 | Resposta movida para o concern `EntregaDeExportacao#entregar_exportacao` |
| Tarsila | `Relatorios::ExportarOperacaoGlobal#call` | 15,01 | 7,45 | 11,58 | 5,74 | *Extract method*: `registrar_pedido` e `falhar` |
| Tarsila | `Extratos::Exportar#call` | 15,01 | 7,45 | 11,58 | 5,74 | *Extract method*: `registrar_pedido` e `falhar` |

#### Cobertura (SimpleCov)

| Responsável | Controller / model | Cobertura antes | Cobertura depois |
|---|---|---|---|
| Luis | `app/controllers/concerns/autenticacao_estudante.rb` | 100,00% | 100,00% |
| Luis | `app/controllers/extratos_controller.rb` | 100,00% | 100,00% |
| Luis | `app/controllers/portal_estudante_controller.rb` | 100,00% | 100,00% |
| Luis | `app/controllers/recargas_controller.rb` | 100,00% | 100,00% |
| Luis | `app/controllers/sessoes_estudante_controller.rb` | 100,00% | 100,00% |
| Luis | `app/models/item_recarga.rb` | 100,00% | 100,00% |
| Luis | `app/models/movimentacao_saldo.rb` | 97,37% | 100,00% |
| Luis | `app/models/pagamento.rb` | 100,00% | 100,00% |
| Luis | `app/models/recarga.rb` | 100,00% | 100,00% |
| Luis | `app/models/tarifa_refeicao.rb` | 95,65% | 100,00% |
| Weldo | `app/controllers/application_controller.rb` | 100,00% | 100,00% |
| Weldo | `app/controllers/cadastros_controller.rb` | 100,00% | 100,00% |
| Weldo | `app/controllers/concerns/autenticacao_funcionario.rb` | 100,00% | 100,00% |
| Weldo | `app/controllers/controle/base_controller.rb` | 100,00% | 100,00% |
| Weldo | `app/controllers/controle/historico_controller.rb` | 100,00% | 100,00% |
| Weldo | `app/controllers/controle/painel_controller.rb` | 100,00% | 100,00% |
| Weldo | `app/controllers/controle/sessoes_controller.rb` | 100,00% | 100,00% |
| Weldo | `app/controllers/paginas_controller.rb` | 100,00% | 100,00% |
| Weldo | `app/models/application_record.rb` | 100,00% | 100,00% |
| Weldo | `app/models/estudante.rb` | 100,00% | 100,00% |
| Weldo | `app/models/papel.rb` | 100,00% | 100,00% |
| Weldo | `app/models/sessao_autenticacao.rb` | 100,00% | 100,00% |
| Weldo | `app/models/usuario.rb` | 100,00% | 100,00% |
| Weldo | `app/models/usuario_papel.rb` | 100,00% | 100,00% |
| Daniel | `app/controllers/controle/pontos_acesso_controller.rb` | 100,00% | 100,00% |
| Daniel | `app/controllers/controle/terminal_controller.rb` | 83,33% | 100,00% |
| Daniel | `app/models/configuracao_ponto_acesso.rb` | 100,00% | 100,00% |
| Daniel | `app/models/rateio_consumo.rb` | 100,00% | 100,00% |
| Daniel | `app/models/registro_acesso.rb` | 96,15% | 100,00% |
| Leonardo | `app/controllers/admin/base_controller.rb` | 100,00% | 100,00% |
| Leonardo | `app/controllers/admin/catracas_controller.rb` | 100,00% | 100,00% |
| Leonardo | `app/controllers/admin/restaurantes_controller.rb` | 100,00% | 100,00% |
| Leonardo | `app/controllers/cardapios_controller.rb` | 100,00% | 100,00% |
| Leonardo | `app/controllers/controle/catracas_controller.rb` | 100,00% | 100,00% |
| Leonardo | `app/models/cardapio.rb` | 100,00% | 100,00% |
| Leonardo | `app/models/catraca.rb` | 100,00% | 100,00% |
| Leonardo | `app/models/item_cardapio.rb` | 100,00% | 100,00% |
| Leonardo | `app/models/opcao_cardapio.rb` | 100,00% | 100,00% |
| Leonardo | `app/models/piso.rb` | 100,00% | 100,00% |
| Leonardo | `app/models/restaurante.rb` | 100,00% | 100,00% |
| Leonardo | `app/models/servico_refeicao.rb` | 100,00% | 100,00% |
| Leonardo | `app/models/tipo_refeicao.rb` | 100,00% | 100,00% |
| Leonardo | `app/models/unidade_gestora.rb` | 100,00% | 100,00% |
| Tarsila | `app/controllers/admin/acessos_operacao_controller.rb` | 100,00% | 100,00% |
| Tarsila | `app/controllers/admin/relatorios_base_controller.rb` | 100,00% | 100,00% |
| Tarsila | `app/controllers/admin/relatorios_globais_controller.rb` | 100,00% | 100,00% |
| Tarsila | `app/controllers/exportacoes_extrato_controller.rb` | 100,00% | 100,00% |
| Tarsila | `app/controllers/concerns/entrega_de_exportacao.rb` | — (novo na refatoração) | 100,00% |
| Tarsila | `app/models/exportacao_relatorio.rb` | 100,00% | 100,00% |


#### Resumo do projeto

| Métrica | Antes | Depois — conjunto completo |
|---|---|---|
| Métodos com Flog ≥ 20 | 57 | 0 |
| Métodos com ABC ≥ 20 | 30 | 0 |
| Maior Flog | 67,65 (`Catracas::Operar#ler`) | 17,25 (`Relatorios::AcessosOperacao#montar_acesso`) |
| Maior ABC | 54,90 (`Catracas::Operar#ler`) | 15,84 (`Extratos::ComposicaoPdf#desenhar_tabela`) |
| Nota geral do RubyCritic | 85,37 | 86,12 |
| Cobertura total (SimpleCov, RSpec) | 99,27% | 99,96% (2327/2328 linhas) |
| Controllers e models com cobertura ≤ 90% | 1 | 0; os 49 arquivos estão com 100% |
| Exemplos RSpec | 507 (501 da Sprint 2 + 6 das ferramentas) | 687, sem falhas |
| Cenários Cucumber | 163 | 163 cenários e 1456 passos passando |
| Métodos sem documentação RDoc | 305 de 369 | 0 de 534; 818 itens com 100% de documentação |

---


### 6.3 Verificação parcial do PO — 23/11/2026 (T4, T5 e T6)

> Registro histórico de 23/11/2026. O estado atual está na seção 6.4.

Verificação do checkout local da `sprint-3` (base `5ad39cb` mais as alterações de F05/F06). **A entrega final ainda não está liberada:** a etapa 7 depende dos merges e das medições dos demais integrantes. Os números abaixo não substituem a coluna final de depois da seção 6.2.

| Verificação | Resultado parcial |
|---|---|
| RSpec | **606 exemplos, 0 falhas**; SimpleCov com 2169/2173 linhas (99,82%, arredondado pela tarefa `qualidade:cobertura`) |
| Cucumber | **163 cenários, 1456 passos**, todos passando |
| Features existentes | Sem diferenças contra `origin/sprint-3` e `origin/sprint-2` |
| RuboCop | **227 arquivos, nenhuma ocorrência** |
| C1 no escopo Daniel | 61 métodos, todos com Flog e ABC < 18; maior Flog 17,17 e maior ABC 12,81 |
| C2 no escopo Daniel | Sete arquivos com **100%**; nenhum controller/model do projeto com cobertura ≤ 90% |
| C4 no escopo Daniel | **100%** dos 74 itens documentados, incluindo os 61 métodos públicos e privados |
| C1 no projeto | **37 métodos com Flog ≥ 20**, dos quais **17 também com ABC ≥ 20**; faltam os escopos Weldo (2), Leonardo (6) e Tarsila (29) |
| RubyCritic | Relatório gerado em `tmp/rubycritic/overview.html`; nota geral **85,47** |
| C4 no projeto | HTML gerado por `bin/rails documentacao` em `doc/app/index.html`; ainda **216 de 434 métodos sem comentário**, fora do escopo Daniel |

**Pendências registradas em 23/11/2026 (histórico):**

- **T4:** incorporar os resultados medidos dos demais escopos depois dos merges e preencher o resumo final. O PR [#52 (Weldo)](https://github.com/Luisserra99/UnB_RU/pull/52) está aberto; seus resultados ainda não fazem parte desta medição da `sprint-3`.
- **T5:** repetir os comandos da seção 3 após integrar todos os escopos; conferir C1–C4 e obter a revisão de outro integrante antes do aceite. A cobertura de linhas, por si só, não substitui a revisão dos happy paths e sad paths.
- **T6:** Home atualizada com os papéis, a branch e os resultados parciais. Abrir **`Grupo 02 - Sprint 3`**, de `Luisserra99:sprint-3` para `neatzzy/UnB_RU:main`, após concluir T4/T5 e receber o `.txt` da T3 (Weldo). O PR final e o aceite dos escopos restantes permanecem pendentes. F05/F06 foram revisadas e aprovadas pelo Daniel em 23/11/2026; as issues #61–#64 registram essa entrega e T4/T5/T6 continuam abertas para a consolidação do grupo.

**Issues do Daniel**, atribuídas a `Debzzan`, com labels e estimativas iniciais:

| Critério/tarefa | Issue | Pontos |
|---|---|---|
| C1 — Refatoração F05/F06 | [#61](https://github.com/Luisserra99/UnB_RU/issues/61) | 5 |
| C2 — Cobertura F05/F06 | [#62](https://github.com/Luisserra99/UnB_RU/issues/62) | 3 |
| C3 — Happy path e sad path | [#63](https://github.com/Luisserra99/UnB_RU/issues/63) | 3 |
| C4 — RDoc F05/F06 | [#64](https://github.com/Luisserra99/UnB_RU/issues/64) | 3 |
| T4 — Consolidação da wiki | [#65](https://github.com/Luisserra99/UnB_RU/issues/65) | 2 |
| T5 — Verificação final | [#66](https://github.com/Luisserra99/UnB_RU/issues/66) | 3 |
| T6 — Home e PR da disciplina | [#67](https://github.com/Luisserra99/UnB_RU/issues/67) | 2 |

### 6.4 Verificação consolidada do PO — 25/11/2026

O `.txt` do Weldo está em [`docs/sprint-3/entrega.txt`](../docs/sprint-3/entrega.txt), integrado pelo [PR #70](https://github.com/Luisserra99/UnB_RU/pull/70). Conferidos o repositório, a branch de entrega, os cinco nomes e as matrículas; o link da wiki segue à parte, como pede o enunciado. As integrações de Luis (piloto), Weldo ([#52](https://github.com/Luisserra99/UnB_RU/pull/52)), Daniel ([#68](https://github.com/Luisserra99/UnB_RU/pull/68)), Tarsila ([#69](https://github.com/Luisserra99/UnB_RU/pull/69) e [#73](https://github.com/Luisserra99/UnB_RU/pull/73)) e Leonardo ([#72](https://github.com/Luisserra99/UnB_RU/pull/72)) constam da `sprint-3` até `e6c17a4`.

Validação local em macOS, Ruby 3.4.10, com as versões do `Gemfile.lock`. O único ajuste final em `app/` é o comentário da classe-base `ApplicationJob`, que completa a documentação das classes e não altera comportamento.

| Critério | Evidência | Resultado |
|---|---|---|
| C1 — Complexidade | `qualidade:metodos[0]`, 539 definições | Nenhuma com Flog ou ABC ≥ 18; maiores notas 17,25 e 15,84 |
| C2 — Cobertura | RSpec + SimpleCov | 49 controllers/models com 100%; total 2327/2328 linhas, 99,96% arredondado |
| C3 — Sucesso e recusa | RSpec e Cucumber | 687 exemplos sem falhas; 163 cenários e 1456 passos passando |
| C3 — Preservação dos BDD | Comparação dos `.feature` existentes com `origin/sprint-2` | Nenhuma diferença |
| C4 — Documentação | `qualidade:rdoc` e geração do HTML | 100% dos 818 itens, incluindo os 534 métodos reconhecidos pelo RDoc |
| C4 — Formato dos comentários | Conferência das 539 definições Ruby | Todas possuem `Argumentos::`, `Retorno::` e `Efeitos colaterais::`, além da descrição |
| Estilo | RuboCop | 235 arquivos, nenhuma ocorrência |
| Consolidado | Tabelas da seção 6.2 | 82 linhas de complexidade conferidas; coberturas e uso de IA dos cinco integrantes preenchidos |
| CI remoto | Consulta do PR interno #74 em 25/11/2026 | Nenhum check novo apresentado pelo GitHub; resultados desta verificação obtidos localmente |

A única linha sem cobertura é a declaração da classe-base `ApplicationJob`, que não contém métodos nem é usada pelos fluxos atuais. A meta C2 se aplica a controllers e models, todos com 100%. A tarefa de complexidade conta definições no AST; o RDoc organiza 534 itens do tipo método. Os dois relatórios estão completos no seu respectivo escopo.

**Estado das tarefas do PO:**

- **T4 (#65):** cinco escopos, tabelas e uso de IA consolidados; a publicação e o encerramento da tarefa são registrados na issue #65.
- **T5 (#66):** verificação completa C1–C4 concluída localmente, com HTML de RDoc e RubyCritic gerados. O GitHub não apresentou checks novos do [PR interno #74](https://github.com/Luisserra99/UnB_RU/pull/74); Daniel autorizou a integração do fechamento com essa validação local em 25/11/2026. O encerramento da tarefa é registrado na issue #66.
- **T6 (#67):** Home e README atualizados e descrição do PR preparada em [`docs/sprint-3/pr-final.md`](../docs/sprint-3/pr-final.md). **Daniel autorizou a abertura do PR final em 25/11/2026**; o link da submissão fica registrado na [issue #67](https://github.com/Luisserra99/UnB_RU/issues/67) e na wiki pública.

A documentação da verificação está em [`docs/sprint-3/verificacao-final.md`](../docs/sprint-3/verificacao-final.md). A entrega prevista para **27/11/2026** será o PR `Grupo 02 - Sprint 3`, de `Luisserra99:sprint-3` para `neatzzy/UnB_RU:main`, acompanhado do `.txt` e do link da wiki.

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
| Luis Eduardo Curi Serra | Claude Code (Claude Opus 5.5) | Ferramentas da T0 (configuração e tarefas `qualidade:*`, com specs); medição de antes (T1) e de depois do escopo; refatoração da F02, da F03 e do login do portal; testes RSpec de happy path e sad path; comentários RDoc de todo o escopo; padrão de RDoc e de refatoração da seção 5; texto das issues do Luis (criadas por ele no GitHub) | Verificação automática a cada passo: RSpec (547 exemplos), Cucumber (163 cenários, `.feature` sem alteração), RuboCop e RDoc a 100% no escopo. O código PIX e o SVG do QR Code foram comparados byte a byte antes e depois da refatoração. Revisão do código e dos textos pelo Luis antes do push e dos PRs |
| Weldo Gonçalves da Silva Junior | Claude Code (Claude Opus 5.5) | Medição de antes e depois do escopo (F01, F04, F07 e base de identidade); refatoração dos 6 métodos com nota ≥ 15; comentários RDoc de todo o escopo (21 arquivos, 100% documentado); testes RSpec de happy path e sad path (specs novos de `ControleHelper`, `IconesHelper` e da página inicial; banco rejeitando o cadastro; papel inexistente; ponto de acesso e encerramento da sessão; logout sem sessão; escolha de restaurante no painel) | Verificação automática a cada passo: RSpec (593 exemplos), Cucumber (163 cenários, `.feature` sem alteração), RuboCop e RDoc a 100% no escopo, nenhum método do escopo com nota ≥ 15. Revisão do código e dos textos pelo Weldo antes do push e do PR |
| Daniel Dezan Baby | Codex (GPT-6) | Refatoração de F05/F06; 59 exemplos RSpec de sucesso, falha e rollback; RDoc dos sete arquivos do escopo; medições de complexidade e cobertura; consolidação da wiki, atualização da Home e registro das issues; fechamento de T4/T5, conferência do `.txt` e preparação do PR final | Verificação automatizada do escopo: 606 exemplos RSpec, 163 cenários Cucumber, RuboCop sem ocorrências; 100% de cobertura e RDoc no escopo, Flog e ABC < 18; `.feature` existentes preservados. Daniel confirmou sua revisão humana, aprovou o resultado e autorizou a finalização do seu escopo em 23/11/2026. Em 25/11/2026, a verificação do conjunto completo confirmou 687 exemplos RSpec e 163 cenários; Daniel autorizou a integração do fechamento e a abertura do PR final em 25/11/2026 |
| Leonardo Tome Sampaio | Claude Code (Claude Opus 5.5) | Refatoração de F08 e F10; 16 exemplos RSpec de happy path e sad path; comentários RDoc de todo o escopo; medição de antes e depois do escopo; teste visual das telas de F08 e F10 no navegador (agent-browser) | Verificação automática: RSpec (622 exemplos), Cucumber (163 cenários, `.feature` sem alteração), RuboCop sem ocorrências, RDoc a 100% no escopo e todos os métodos com Flog e ABC < 18. Revisão do código e dos textos pelo Leonardo antes do push e do PR |
| Tarsila Marques de Oliveira Alves | Claude (Claude Fable 5.2) | Medição do escopo com `qualidade:metodos`; refatoração dos 38 métodos de F09, F11 e F12; specs de sad path das exportações e specs dos módulos novos; comentários RDoc de todo o escopo; texto das issues (criadas por ela no GitHub) | Saída dos PDFs e CSVs comparada byte a byte antes e depois da refatoração; RSpec (566 exemplos), Cucumber (163 cenários, `.feature` inalterados), RuboCop sem ocorrências e `qualidade:rdoc` em 100%; código lido e conferido pela responsável antes do PR |
