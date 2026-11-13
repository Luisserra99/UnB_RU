# UnB RU — Wiki do Grupo 02

Sistema de gestão do Restaurante Universitário da UnB. O estudante faz o cadastro, compra créditos (PIX ou cartão), consulta o cardápio e o extrato. O funcionário opera a catraca: identifica o estudante, libera a passagem e debita a refeição. O administrador gerencia restaurantes e catracas e emite os relatórios de operação.

Projeto da disciplina de **Engenharia de Software** (UnB), da professora Genaina Nunes Rodrigues.

> **Sprint 2 concluída:** as 12 funcionalidades especificadas na Sprint 1 estão implementadas na branch [`sprint-2`](https://github.com/Luisserra99/UnB_RU/tree/sprint-2), com **163 cenários BDD** (Cucumber) e **501 exemplos RSpec**, todos passando, verificados a cada push pelo CI no GitHub Actions.

---

## Identificação

| | |
|---|---|
| **Grupo** | 02 |
| **Repositório da disciplina** | [neatzzy/UnB_RU](https://github.com/neatzzy/UnB_RU) |
| **Fork do grupo** | [Luisserra99/UnB_RU](https://github.com/Luisserra99/UnB_RU) |
| **Branch de entrega (release)** | [`sprint-2`](https://github.com/Luisserra99/UnB_RU/tree/sprint-2) |
| **Kanban** | [GitHub Project — Sprint 2](https://github.com/users/Luisserra99/projects/1) (Backlog, Doing, Done, Accepted) |
| **Stack** | Ruby 3.3, Rails 8.1, SQLite, RSpec, Cucumber + Capybara, Prawn (PDF) |

## Equipe

| Integrante | Matrícula | Papel na Sprint 2 | Funcionalidades |
|---|---|---|---|
| Luis Eduardo Curi Serra | 251033574 | Scrum Master | F02, F03 |
| Tarsila Marques de Oliveira Alves | 242012029 | Product Owner | F09, F11, F12 |
| Daniel Dezan Baby | 232046097 | Desenvolvedor | F05, F06 |
| Leonardo Tome Sampaio | 222005448 | Desenvolvedor | F08, F10 |
| Weldo Gonçalves da Silva Junior | 222014133 | Desenvolvedor | F01, F04, F07 |

| Papel Scrum | Responsável | Atribuições |
|---|---|---|
| **Scrum Master** | Luis Eduardo Curi Serra | Montar o GitHub Project com as quatro lanes e revisar as issues de todos: criadas, com responsável e na lane certa |
| **Product Owner** | Tarsila Marques de Oliveira Alves | Manter esta wiki, aceitar as issues (mover para Accepted) e conduzir a entrega |

Na [Sprint 1](Sprint-1.md), Daniel foi Scrum Master e Leonardo foi Product Owner.

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

| Suíte | Comando | Resultado na `sprint-2` |
|---|---|---|
| Cenários BDD (Cucumber) | `bundle exec cucumber` | 163 cenários, 1456 passos, todos passando |
| Testes unitários e de integração (RSpec) | `bundle exec rspec` | 501 exemplos, 0 falhas |
| Lint (RuboCop, estilo `rubocop-rails-omakase`) | `bundle exec rubocop` | 0 ocorrências |

Os specs RSpec cobrem models, form objects, services, helpers e requests, incluindo regras de segurança (acesso por papel, dados de cartão, parâmetros malformados) e a geração dos arquivos PDF e CSV.

### Integração contínua (CI)

O workflow [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) roda no GitHub Actions a cada push e pull request, com três jobs em paralelo no Ubuntu: **Lint (RuboCop)**, **Testes (RSpec)** e **Cenários BDD (Cucumber)**. Os resultados ficam na aba [Actions](https://github.com/Luisserra99/UnB_RU/actions) do fork.

---

## Kanban

O [GitHub Project da Sprint 2](https://github.com/users/Luisserra99/projects/1) tem uma issue por funcionalidade, com o responsável atribuído, distribuídas nas lanes:

| Lane | Significado |
|---|---|
| **Backlog** | Issue criada, ainda não iniciada |
| **Doing** | Em desenvolvimento na branch da funcionalidade |
| **Done** | PR mergeado na `sprint-2`, com RSpec e Cucumber passando |
| **Accepted** | Revisada e aceita pela Product Owner |

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

Exemplo: `feat(cardapio): adiciona listagem do cardápio do dia`.

### Branches

- `main`: código estável, recebe merge só por Pull Request.
- `sprint-N`: branch de integração e de entrega da sprint. Depois do PR para o repositório da disciplina, não recebe mais commits.
- `sprint-N-feature-<integrante>/<nome-curto>`: uma branch por funcionalidade, criada a partir de `sprint-N`.
- `sprint-N-fix-<integrante>/<nome-curto>`: correções, criada a partir de `sprint-N`.

### Revisão

- Todo merge passa por Pull Request, com pelo menos uma aprovação de outro integrante.
- O PR referencia a issue da funcionalidade.
- Conflitos são resolvidos pelo autor do PR antes da revisão.
- A issue só vai para Done com RSpec e Cucumber passando.

---

## Entrega

A branch de entrega é a [`sprint-2`](https://github.com/Luisserra99/UnB_RU/tree/sprint-2) do fork do grupo. O Pull Request vai do fork para o repositório da disciplina:

- **base:** `neatzzy/UnB_RU`, branch `main`
- **head:** `Luisserra99/UnB_RU`, branch `sprint-2`
- **título:** `Grupo 02 - Sprint 2`
- **descrição:** nome e matrícula dos integrantes e as funcionalidades de cada um

---

## Uso de IA

O grupo usou o **Claude Code** (Anthropic) como apoio. O código gerado foi revisado pelo responsável de cada funcionalidade e só entrou na `sprint-2` com os testes passando.

| Uso | Funcionalidades |
|---|---|
| Implementação a partir dos cenários BDD, do diagrama ER e do Figma: migrations, models, controllers, views, specs e steps | F01–F12 |
| Testes adicionais de regra e de segurança, escritos por um agente separado do que implementou | F02, F03 |
| Documentação das páginas | F01–F12 e esta Home |

F01–F08 e F10 usaram o Claude Code (Claude Opus 5.5); F09, F11 e F12 usaram o Claude (Claude Fable 5.2). O detalhamento está na seção "Uso de IA" das páginas. O uso na Sprint 1 está registrado na [wiki da Sprint 1](Sprint-1.md#6-uso-de-ia-na-sprint).

---

## Páginas

- [Sprint 1 — especificação das funcionalidades](Sprint-1.md)
- [Identidade e Acesso — base comum e usuários de teste](Sprint-2-Identidade-e-Acesso.md)
- [Relatório da segunda etapa da Sprint 1: modelo ER](../docs/sprint-1/relatorio-etapa-2.md) ([PDF](../docs/sprint-1/relatorio-etapa-2.pdf))
- [README do repositório](../README.MD)
