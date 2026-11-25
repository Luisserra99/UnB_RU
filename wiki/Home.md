# UnB RU — Wiki do Grupo 02

Sistema de gestão do Restaurante Universitário da UnB. O estudante faz o cadastro, compra créditos (PIX ou cartão), consulta o cardápio e o extrato. O funcionário opera a catraca: identifica o estudante, libera a passagem e debita a refeição. O administrador gerencia restaurantes e catracas e emite os relatórios de operação.

Projeto da disciplina de **Engenharia de Software** (UnB), da professora Genaina Nunes Rodrigues.

> **Sprint 2 concluída:** as 12 funcionalidades especificadas na Sprint 1 estão implementadas na branch [`sprint-2`](https://github.com/Luisserra99/UnB_RU/tree/sprint-2), com **163 cenários BDD** (Cucumber) e **501 exemplos RSpec**, todos passando, verificados a cada push pelo CI no GitHub Actions.

> **Sprint 3 — preparação da entrega:** os cinco escopos foram integrados à [`sprint-3`](https://github.com/Luisserra99/UnB_RU/tree/sprint-3), e o [`.txt` do Weldo](../docs/sprint-3/entrega.txt) foi conferido. A verificação completa de **25/11/2026** registra **687 exemplos RSpec**, **163 cenários BDD**, 100% de cobertura em cada controller/model e 100% de RDoc. A [descrição do PR](../docs/sprint-3/pr-final.md) está concluída, e Daniel autorizou a integração do fechamento e a abertura para a disciplina em **25/11/2026**. Entrega em **27/11/2026**. Veja a [verificação consolidada do PO](Sprint-3.md#64-verificação-consolidada-do-po--25112026).

---

## Identificação

| | |
|---|---|
| **Grupo** | 02 |
| **Repositório da disciplina** | [neatzzy/UnB_RU](https://github.com/neatzzy/UnB_RU) |
| **Fork do grupo** | [Luisserra99/UnB_RU](https://github.com/Luisserra99/UnB_RU) |
| **Branch de entrega (release)** | [`sprint-3`](https://github.com/Luisserra99/UnB_RU/tree/sprint-3) |
| **Kanban** | [Project do grupo — Sprint 3](https://github.com/users/Luisserra99/projects/1), compartilhado com o histórico da Sprint 2 |
| **Stack** | Ruby 3.3, Rails 8.1, SQLite, RSpec, Cucumber + Capybara, Prawn (PDF) |

## Equipe

| Integrante | Matrícula | Papel na Sprint 3 | Funcionalidades |
|---|---|---|---|
| Luis Eduardo Curi Serra | 251033574 | Desenvolvedor | F02, F03 e ferramentas |
| Tarsila Marques de Oliveira Alves | 242012029 | Desenvolvedora | F09, F11, F12 |
| Daniel Dezan Baby | 232046097 | Product Owner | F05, F06 |
| Leonardo Tome Sampaio | 222005448 | Desenvolvedor | F08, F10 |
| Weldo Gonçalves da Silva Junior | 222014133 | Scrum Master | F01, F04, F07 e identidade |

| Papel Scrum | Responsável | Atribuições |
|---|---|---|
| **Scrum Master** | Weldo Gonçalves da Silva Junior | Organizar o Project, conferir as issues e os prazos e preparar o `.txt` da entrega (T2/T3) |
| **Product Owner** | Daniel Dezan Baby | Consolidar a wiki, verificar C1–C4, aceitar as issues e abrir o PR de entrega (T4/T5/T6) |

Na [Sprint 1](Sprint-1.md), Daniel foi Scrum Master e Leonardo foi Product Owner. Na Sprint 2, Luis foi Scrum Master e Tarsila foi Product Owner. O [planejamento da Sprint 3](Sprint-3.md) detalha o rodízio e os critérios de aceite.

---

## Funcionalidades

Cada página documenta as regras de negócio implementadas, as rotas, os cenários BDD, como testar manualmente e as limitações conhecidas. As histórias de usuário e os cenários originais estão na [especificação da Sprint 1](Sprint-1.md).

| # | Funcionalidade | Responsável | Documentação | Cenários BDD | Issue |
|---|---|---|---|---|---|
| F01 | Cadastro de estudante | Weldo | [F01](F01.md) | [cadastro_usuario.feature](../features/cadastro_usuario.feature) | [#18](https://github.com/Luisserra99/UnB_RU/issues/18) · [#1](https://github.com/neatzzy/UnB_RU/issues/1) |
| F02 | Recarga de saldo (PIX e cartão) | Luis | [F02](F02.md) | [recarga_saldo.feature](../features/recarga_saldo.feature) | [#23](https://github.com/Luisserra99/UnB_RU/issues/23) · [#2](https://github.com/neatzzy/UnB_RU/issues/2) |
| F03 | Extrato e histórico de refeições | Luis | [F03](F03.md) | [extrato_historico.feature](../features/extrato_historico.feature) | [#24](https://github.com/Luisserra99/UnB_RU/issues/24) · [#3](https://github.com/neatzzy/UnB_RU/issues/3) |
| F04 | Autenticação do funcionário | Weldo | [F04](F04.md) | [autenticacao_funcionario.feature](../features/autenticacao_funcionario.feature) | [#19](https://github.com/Luisserra99/UnB_RU/issues/19) · [#4](https://github.com/neatzzy/UnB_RU/issues/4) |
| F05 | Configuração do ponto de acesso | Daniel | [F05](F05.md) | [configuracao_ponto_acesso.feature](../features/configuracao_ponto_acesso.feature) | [#26](https://github.com/Luisserra99/UnB_RU/issues/26) · [#5](https://github.com/neatzzy/UnB_RU/issues/5) |
| F06 | Leitura e autorização na catraca | Daniel | [F06](F06.md) | [validacao_entrada.feature](../features/validacao_entrada.feature) | [#27](https://github.com/Luisserra99/UnB_RU/issues/27) · [#6](https://github.com/neatzzy/UnB_RU/issues/6) |
| F07 | Histórico local da catraca | Weldo | [F07](F07.md) | [historico_local_catraca.feature](../features/historico_local_catraca.feature) | [#20](https://github.com/Luisserra99/UnB_RU/issues/20) · [#7](https://github.com/neatzzy/UnB_RU/issues/7) |
| F08 | Gestão de restaurantes e catracas | Leonardo | [F08](F08.md) | [gestao_restaurante_catracas.feature](../features/gestao_restaurante_catracas.feature) | [#13](https://github.com/Luisserra99/UnB_RU/issues/13) · [#8](https://github.com/neatzzy/UnB_RU/issues/8) |
| F09 | Relatório global de operação | Tarsila | [F09](F09.md) | [relatorio_global_acesso.feature](../features/relatorio_global_acesso.feature) | [#31](https://github.com/Luisserra99/UnB_RU/issues/31) · [#9](https://github.com/neatzzy/UnB_RU/issues/9) |
| F10 | Cardápio da refeição atual | Leonardo | [F10](F10.md) | [cardapio_atual.feature](../features/cardapio_atual.feature) | [#14](https://github.com/Luisserra99/UnB_RU/issues/14) · [#10](https://github.com/neatzzy/UnB_RU/issues/10) |
| F11 | Exportação do extrato (PDF e CSV) | Tarsila | [F11](F11.md) | [exportacao_PDF_historico_estudante.feature](../features/exportacao_PDF_historico_estudante.feature) | [#32](https://github.com/Luisserra99/UnB_RU/issues/32) · [#11](https://github.com/neatzzy/UnB_RU/issues/11) |
| F12 | Exportação em PDF do relatório de operação | Tarsila | [F12](F12.md) | [exportacao_pdf_relatorio_operacao.feature](../features/exportacao_pdf_relatorio_operacao.feature) | [#33](https://github.com/Luisserra99/UnB_RU/issues/33) · [#12](https://github.com/neatzzy/UnB_RU/issues/12) |

Na coluna Issue, o primeiro link é a issue do Kanban do grupo e o segundo é a issue original no repositório da disciplina. A base comum de identidade (usuários, papéis, sessões e usuários de teste) está em [Identidade e Acesso](Sprint-2-Identidade-e-Acesso.md).

### Velocity

Pontos estimados na [Sprint 1](Sprint-1.md#3-responsáveis-por-funcionalidade-e-velocity). As histórias que estavam sem estimativa (F02, F08, F09 e F11) foram pontuadas pelo responsável na Sprint 2. Todas as histórias foram concluídas.

| F01 | F02 | F03 | F04 | F05 | F06 | F07 | F08 | F09 | F10 | F11 | F12 | **Total** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 3 | 8 | 5 | 3 | 3 | 5 | 5 | 5 | 8 | 5 | 5 | 5 | **60** |

---

## Arquitetura

A aplicação tem três áreas, cada uma com o seu login e o seu layout:

| Área | Público | Entrada | Funcionalidades |
|---|---|---|---|
| **Portal do Estudante** | Estudantes | `/entrar` | Cadastro (F01), recarga (F02), extrato e exportação (F03, F11), cardápio (F10) |
| **Aplicação de controle** | Funcionários | `/controle/login` | Login (F04), ponto de acesso (F05), terminal da catraca (F06), histórico local (F07) |
| **Administração** | Administradores | `/controle/login` | Restaurantes e catracas (F08), relatório global (F09), relatório de operação em PDF (F12) |

| Camada | Onde fica | Conteúdo |
|---|---|---|
| Models | `app/models` | `Usuario`, `Papel`, `Estudante`, `SessaoAutenticacao`, `UnidadeGestora`, `Restaurante`, `Piso`, `Catraca`, `ServicoRefeicao`, `Cardapio`, `TipoRefeicao`, `TarifaRefeicao`, `Recarga`, `Pagamento`, `MovimentacaoSaldo`, `ConfiguracaoPontoAcesso`, `RegistroAcesso`, `RateioConsumo`, `ExportacaoRelatorio` e outros |
| Form objects | `app/forms` | Cadastro do estudante, solicitação de recarga e dados do cartão |
| Services | `app/services` | Regras que envolvem vários models: pagamentos, operação da catraca, pontos de acesso, extratos, relatórios e importação do cardápio |
| Controllers | `app/controllers`, `controle/`, `admin/` | Um namespace por área; `Controle::BaseController` e `Admin::BaseController` exigem a sessão e o papel corretos |

O modelo de dados segue o diagrama ER da [segunda etapa da Sprint 1](../docs/sprint-1/relatorio-etapa-2.md).

---

## Testes

| Suíte | Comando | Resultado do conjunto completo em 25/11/2026 |
|---|---|---|
| Cenários BDD (Cucumber) | `bundle exec cucumber` | 163 cenários, 1456 passos, todos passando |
| Testes unitários e de integração (RSpec) | `bundle exec rspec` | 687 exemplos, 0 falhas |
| Lint (RuboCop, estilo `rubocop-rails-omakase`) | `bundle exec rubocop` | 235 arquivos, 0 ocorrências |

Os specs RSpec cobrem models, form objects, services, helpers e requests, incluindo regras de segurança (acesso por papel, dados de cartão, parâmetros malformados) e a geração dos arquivos PDF e CSV.

Os resultados acima correspondem aos cinco escopos integrados até `e6c17a4`, com a documentação final da classe-base `ApplicationJob`. Os 49 controllers e models têm 100% de cobertura, e todos os métodos ficam abaixo de 18 em Flog e ABC. O [relatório da verificação](../docs/sprint-3/verificacao-final.md) registra os comandos e a evidência; os `.feature` existentes permanecem idênticos aos da Sprint 2.

### Integração contínua (CI)

O workflow [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) roda no GitHub Actions a cada push e pull request, com três jobs em paralelo no Ubuntu: **Lint (RuboCop)**, **Testes (RSpec)** e **Cenários BDD (Cucumber)**. Os resultados ficam na aba [Actions](https://github.com/Luisserra99/UnB_RU/actions) do fork.

Na preparação de 25/11/2026, o GitHub não apresentou checks novos para o [PR interno #74](https://github.com/Luisserra99/UnB_RU/pull/74). Os resultados atuais foram verificados localmente; a observação e a autorização do Daniel para integrar com a validação local estão registradas no [relatório do PO](../docs/sprint-3/verificacao-final.md#estado-do-ci-remoto-em-25112026).

---

## Kanban

Na Sprint 3, cada integrante cria suas issues de refatoração, cobertura, caminhos de teste e RDoc, conforme o [planejamento](Sprint-3.md#5-issues-branches-e-padrões). O [Project do grupo](https://github.com/users/Luisserra99/projects/1) reúne as tarefas da Sprint 3 e o histórico da Sprint 2. No quadro atual, `In progress` corresponde a Doing e `In review` registra o trabalho aguardando revisão antes de Done.

| Lane | Significado |
|---|---|
| **Backlog** | Issue criada, ainda não iniciada |
| **Doing** | Em desenvolvimento na branch do escopo |
| **Done** | PR revisado e mergeado na `sprint-3`, com C1–C4 verificados |
| **Accepted** | Revisada e aceita pelo Product Owner |

---

## Como rodar

Requisitos: Ruby 3.3 e Bundler.

```bash
bundle install
bin/rails db:prepare db:seed
bin/rails server            # http://localhost:3000
bundle exec rspec           # testes RSpec
bundle exec cucumber        # cenários BDD (features/)
```

### No Windows

| Situação | Solução |
|---|---|
| No PowerShell ou no CMD, `bin/rails ...` abre a janela "Selecionar um aplicativo para abrir 'rails'" | Rode com `ruby` na frente: `ruby bin/rails db:prepare db:seed` e `ruby bin/rails server`. No Git Bash, `bin/rails ...` funciona direto |
| `Could not find prawn-2.4.0, ... in locally installed gems` | Rode `bundle install` de novo: as funcionalidades de relatório trouxeram gems novas |
| `invalid byte sequence in UTF-8` com terminal em português | Já tratado no `Gemfile`. Se aparecer em outro ambiente, defina `CUCUMBER_OUTPUT_ENCODING=UTF-8` (PowerShell: `$env:CUCUMBER_OUTPUT_ENCODING='UTF-8'`) |
| `Migrations are pending` ao rodar os testes | Rode `ruby bin/rails db:prepare` |

### Usuários de teste

Criados por `bin/rails db:seed`:

| Perfil | Entrada | Identificação | Senha |
|---|---|---|---|
| Estudante com saldo (R$ 22,50) | `/entrar` | `251033574` | `Estudante@123` |
| Estudante sem saldo | `/entrar` | `222014133` | `Estudante@123` |
| Funcionário | `/controle/login` | `funcionario01` | `senhaCorreta` |
| Funcionário da CAT-01 (histórico local) | `/controle/login` | `100200300` | `Senha@123` |
| Administrador | `/controle/login` | `admin` | `Admin@1234` |

Pagamentos simulados: no PIX, use o botão "Simular pagamento" (só em desenvolvimento). No cartão, `4111 1111 1111 1111` é aprovado e `4000 0000 0000 0002` é recusado, com qualquer validade futura e CVV de 3 dígitos.

A lista completa de usuários está em [Identidade e Acesso](Sprint-2-Identidade-e-Acesso.md). Cada página de funcionalidade tem a sua seção "Como testar".

---

## Padrões do grupo

### Commits

[Conventional Commits](https://www.conventionalcommits.org/pt-br/): `<tipo>(<escopo>): <descrição no imperativo>`.

| Tipo | Uso |
|---|---|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `docs` | Documentação |
| `style` | Formatação, sem mudança de lógica |
| `test` | Testes |
| `refactor` | Mudança de estrutura sem mudar comportamento |
| `chore` | Configuração e ferramentas |

Exemplo: `feat(cardapio): adiciona listagem do cardápio do dia`.

### Branches

- `main`: código estável, recebe merge só por Pull Request.
- `sprint-N`: branch de integração e de entrega da sprint. Depois do PR para o repositório da disciplina, não recebe mais commits.
- `sprint-N-feature-<integrante>/<nome-curto>`: uma branch por funcionalidade, criada a partir de `sprint-N`.
- `sprint-N-fix-<integrante>/<nome-curto>`: correções, criada a partir de `sprint-N`.
- `sprint-3-refactor-<integrante>/<escopo>`: refatoração, testes e RDoc, criada após o merge do piloto.

### Revisão

- Todo merge passa por Pull Request, com pelo menos uma aprovação de outro integrante.
- O PR referencia a issue da funcionalidade.
- Conflitos são resolvidos pelo autor do PR antes da revisão.
- A issue só vai para Done com RSpec e Cucumber passando.

---

## Entrega

A branch de entrega é a [`sprint-3`](https://github.com/Luisserra99/UnB_RU/tree/sprint-3) do fork do grupo. Após integrar todos os escopos e verificar C1–C4, o Product Owner abre o Pull Request para o repositório da disciplina:

- **base:** `neatzzy/UnB_RU`, branch `main`
- **head:** `Luisserra99/UnB_RU`, branch `sprint-3`
- **título:** `Grupo 02 - Sprint 3`
- **descrição:** nome e matrícula dos integrantes, escopos refatorados, resultados finais e link da wiki

Entrega em **27/11/2026**. O [`.txt` do SM](../docs/sprint-3/entrega.txt) está integrado e conferido. A [verificação consolidada](Sprint-3.md#64-verificação-consolidada-do-po--25112026) e a [descrição do PR](../docs/sprint-3/pr-final.md) estão preparadas. A abertura do PR final para a disciplina foi autorizada pelo Daniel em **25/11/2026**; o link da submissão fica registrado na [issue #67](https://github.com/Luisserra99/UnB_RU/issues/67) e na wiki pública.

---

## Uso de IA

Na Sprint 2, o grupo usou o **Claude Code** (Anthropic) como apoio. O código gerado foi revisado pelo responsável de cada funcionalidade e só entrou na `sprint-2` com os testes passando.

| Uso | Funcionalidades |
|---|---|
| Implementação a partir dos cenários BDD, do diagrama ER e do Figma: migrations, models, controllers, views, specs e steps | F01–F12 |
| Testes adicionais de regra e de segurança, escritos por um agente separado do que implementou | F02, F03 |
| Documentação das páginas | F01–F12 e esta Home |

F01–F08 e F10 usaram o Claude Code (Claude Opus 5.5); F09, F11 e F12 usaram o Claude (Claude Fable 5.2). O detalhamento está na seção "Uso de IA" das páginas. O uso na Sprint 1 está registrado na [wiki da Sprint 1](Sprint-1.md#6-uso-de-ia-na-sprint), e o da Sprint 3 na [wiki da Sprint 3](Sprint-3.md#7-uso-de-ia-na-sprint).

---

## Páginas

- [Sprint 1 — especificação das funcionalidades](Sprint-1.md)
- [Sprint 3 — refatoração e documentação: distribuição de tarefas](Sprint-3.md)
- [Identidade e Acesso — base comum e usuários de teste](Sprint-2-Identidade-e-Acesso.md)
- [Relatório da segunda etapa da Sprint 1: modelo ER](../docs/sprint-1/relatorio-etapa-2.md) ([PDF](../docs/sprint-1/relatorio-etapa-2.pdf))
- [README do repositório](../README.MD)
