# UnB RU — Wiki

## Identificação

| | |
|---|---|
| **Projeto** | UnB RU |
| **Sprint** | Sprint 2 (implementação das 12 funcionalidades especificadas na [Sprint 1](Sprint-1.md)) |
| **Período** | A definir |
| **Repositório** | [Luisserra99/UnB_RU](https://github.com/Luisserra99/UnB_RU) (fork de trabalho) · [neatzzy/UnB_RU](https://github.com/neatzzy/UnB_RU) (upstream) |
| **Branch de integração** | `sprint-2` |
| **Kanban** | [GitHub Project](https://github.com/users/Luisserra99/projects/1) (lanes: Backlog, Doing, Done, Accepted) |

### Integrantes

| Nome | Matrícula | Papel na Sprint 2 |
|---|---|---|
| Luis Eduardo Curi Serra | 251033574 | Scrum Master |
| Tarsila Marques de Oliveira Alves | 242012029 | Product Owner |
| Daniel Dezan Baby | 232046097 | Desenvolvedor |
| Leonardo Tome Sampaio | 222005448 | Desenvolvedor |
| Weldo Gonçalves da Silva Junior | 222014133 | Desenvolvedor |

Os papéis de Scrum Master e Product Owner mudaram em relação à [Sprint 1](Sprint-1.md), em que Daniel era Scrum Master e Leonardo era Product Owner.

---

## 1. Papéis Scrum

| Papel | Responsável | Atribuições na Sprint 2 |
|---|---|---|
| **Scrum Master** | Luis Eduardo Curi Serra | Montar o GitHub Project com as 4 lanes (Backlog, Doing, Done, Accepted) e revisar as issues de todos: se estão criadas, com responsável e na lane certa. |
| **Product Owner** | Tarsila Marques de Oliveira Alves | Escrever a Home da wiki, aceitar as issues (movê-las para Accepted) e conduzir a entrega: criar a `sprint-2`, abrir o PR e enviar o link do repositório. |

---

## 2. Funcionalidades

As histórias de usuário, as regras de negócio (RN) e os cenários BDD de cada funcionalidade estão na [wiki da Sprint 1](Sprint-1.md). Na Sprint 2, cada integrante implementa as suas funcionalidades de ponta a ponta: migrations e models, controllers e views, cenários BDD com RSpec passando e a própria página na wiki, com seu nome como responsável.

| Funcionalidade | Issue | Cenários BDD | Responsável | Página na wiki | Status |
|---|---|---|---|---|---|
| F01 — Cadastro de estudante | [#1](https://github.com/neatzzy/UnB_RU/issues/1) | [cadastro_usuario.feature](../features/cadastro_usuario.feature) | Weldo | [Identidade e Acesso](Sprint-2-Identidade-e-Acesso.md) | Implementada |
| F02 — Compra de créditos (PIX/cartão) | [#2](https://github.com/neatzzy/UnB_RU/issues/2) | [recarga_saldo.feature](../features/recarga_saldo.feature) | Luis | A criar | Pendente |
| F03 — Confirmação da recarga e saldo | [#3](https://github.com/neatzzy/UnB_RU/issues/3) | [extrato_historico.feature](../features/extrato_historico.feature) | Luis | A criar | Pendente |
| F04 — Login de funcionário | [#4](https://github.com/neatzzy/UnB_RU/issues/4) | [autenticacao_funcionario.feature](../features/autenticacao_funcionario.feature) | Weldo | [Identidade e Acesso](Sprint-2-Identidade-e-Acesso.md) | Implementada |
| F05 — Configuração do ponto de acesso | [#5](https://github.com/neatzzy/UnB_RU/issues/5) | [configuracao_ponto_acesso.feature](../features/configuracao_ponto_acesso.feature) | Daniel | A criar | Pendente |
| F06 — Leitura e autorização na catraca | [#6](https://github.com/neatzzy/UnB_RU/issues/6) | [validacao_entrada.feature](../features/validacao_entrada.feature) | Daniel | A criar | Pendente |
| F07 — Histórico da catraca | [#7](https://github.com/neatzzy/UnB_RU/issues/7) | [historico_local_catraca.feature](../features/historico_local_catraca.feature) | Weldo | [Identidade e Acesso](Sprint-2-Identidade-e-Acesso.md#f07--histórico-local-da-catraca) | Aguardando F05, F06 e F08 |
| F08 — Cadastro de restaurante, pisos e catracas | [#8](https://github.com/neatzzy/UnB_RU/issues/8) | [gestao_restaurante_catracas.feature](../features/gestao_restaurante_catracas.feature) | Leonardo | [F08](F08.md) | Implementada |
| F09 — Relatório administrativo/global | [#9](https://github.com/neatzzy/UnB_RU/issues/9) | [relatorio_global_acesso.feature](../features/relatorio_global_acesso.feature) | Tarsila | A criar | Pendente |
| F10 — Consulta de cardápio | [#10](https://github.com/neatzzy/UnB_RU/issues/10) | [cardapio_atual.feature](../features/cardapio_atual.feature) | Leonardo | [F10](F10.md) | Implementada |
| F11 — Extrato do estudante (PDF/CSV) | [#11](https://github.com/neatzzy/UnB_RU/issues/11) | [exportacao_PDF_historico_estudante.feature](../features/exportacao_PDF_historico_estudante.feature) | Tarsila | A criar | Pendente |
| F12 — Relatório do administrador geral | [#12](https://github.com/neatzzy/UnB_RU/issues/12) | [exportacao_pdf_relatorio_operacao.feature](../features/exportacao_pdf_relatorio_operacao.feature) | Tarsila | A criar | Pendente |

> O status reflete o que está mergeado na `sprint-2`. Uma issue só vai para Done com os testes verdes. A PO a move para Accepted.

---

## 3. Divisão da Sprint 2

Cada integrante cria as próprias issues no Kanban e atualiza as lanes (Backlog → Doing → Done). A PO move para Accepted.

| Responsável | Papel | Funcionalidades | Models |
|---|---|---|---|
| Weldo Gonçalves da Silva Junior | Dev: identidade e acesso (base, entregar primeiro) | F01, F04, F07 | `Usuario`, `Papel`, `UsuarioPapel`, `Estudante`, `SessaoAutenticacao`; seeds de papéis e usuários de teste |
| Luis Eduardo Curi Serra | SM: compra de créditos e pagamento | F02, F03 | `TipoRefeicao`, `TarifaRefeicao`, `Recarga`, `ItemRecarga`, `Pagamento`; cria a migration e o model de `MovimentacaoSaldo` (parte de crédito) |
| Daniel Dezan Baby | Dev: operação da catraca | F05, F06 | `ConfiguracaoPontoAcesso`, `RegistroAcesso`, `RateioConsumo`; lógica de débito em cima da `MovimentacaoSaldo` |
| Leonardo Tome Sampaio | Dev: restaurantes e cardápio | F08, F10 | `UnidadeGestora`, `Restaurante`, `Piso`, `Catraca`, `ServicoRefeicao`, `Cardapio`, `OpcaoCardapio`, `ItemCardapio`; import do `cardapio.json` como seed |
| Tarsila Marques de Oliveira Alves | PO: relatórios e entrega | F09, F11, F12 | `ExportacaoRelatorio` (começar com dados de seed e ligar nos reais depois) |

**Ajuste em relação à divisão inicial:** as atividades de desenvolvimento previstas para Luis (F08, F10, models de restaurante e cardápio e o import do `cardapio.json`) ficaram com Leonardo. Em troca, Luis assumiu as de Leonardo (F02, F03 e os models de compra de créditos). Luis mantém as atividades de Scrum Master, como o Kanban e a revisão das issues.

O model `TipoRefeicao` já foi criado por Leonardo na F10, junto com os models de cardápio. Luis o reutiliza na F02 em vez de recriá-lo.

### 3.1 Dependências e ordem

1. Weldo (`Usuario`/`Estudante`) e Leonardo (`Restaurante`/`Catraca`) sobem os models base nos primeiros dias, porque o resto depende deles. Os dois já estão na `sprint-2`.
2. Luis cria a `MovimentacaoSaldo` antes de Daniel implementar o débito (F06).
3. A F07 (Weldo) depende de `Catraca` (F08), de `ConfiguracaoPontoAcesso` (F05) e de `RegistroAcesso` (F06).
4. Os pontos de pendência entre as funcionalidades estão nas páginas [F08](F08.md#pendências) e [F10](F10.md#pendências).

### 3.2 Pull requests já mergeados na `sprint-2`

| PR | Conteúdo | Responsável |
|---|---|---|
| [#16](https://github.com/Luisserra99/UnB_RU/pull/16) | F01 e F04: cadastro de estudante, login de funcionário, models de identidade e visual do Figma | Weldo |
| [#17](https://github.com/Luisserra99/UnB_RU/pull/17) | F08 e F10: restaurantes, pisos, catracas, cardápio e import do `cardapio.json` | Leonardo |

---

## 4. Velocity

| Funcionalidade | Responsável | Pontos |
|---|---|---|
| F01 | Weldo | — |
| F02 | Luis | — |
| F03 | Luis | — |
| F04 | Weldo | — |
| F05 | Daniel | — |
| F06 | Daniel | — |
| F07 | Weldo | — |
| F08 | Leonardo | — |
| F09 | Tarsila | — |
| F10 | Leonardo | — |
| F11 | Tarsila | — |
| F12 | Tarsila | — |
| | **Total (Velocity da Sprint)** | **—** |

> **Velocity** = soma dos pontos das histórias de usuário concluídas na sprint. Os pontos serão preenchidos no fechamento da sprint.

---

## 5. Entrega

Responsável: Tarsila (PO).

1. Criar a branch `sprint-2` no fork, só com o que foi feito até essa sprint.
2. Abrir o PR com base no repositório `EngSwCIC/CAMAAR`, branch `main`, e head no fork do grupo, branch `sprint-2`.
3. Título: `Grupo 02 - #<issue> <nome>`.
4. Comentário: nome e matrícula de todos e as funcionalidades de cada um.
5. Depois do PR, ninguém faz commit na `sprint-2`.

> **A confirmar com o professor:** o enunciado cita o repositório CAMAAR, mas o nosso projeto é o UnB RU. O prazo informado (09/06/2026) também já passou.

---

## 6. Padrões do Grupo

### 6.1 Padrão de commits

Formato adotado: **Conventional Commits**

```
<tipo>(<escopo opcional>): <descrição curta no imperativo>

<corpo opcional>
```

| Tipo | Uso |
|---|---|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `docs` | Documentação |
| `style` | Formatação, sem mudança de lógica |
| `test` | Testes |

Exemplo: `feat(cardapio): adiciona listagem do cardápio do dia`

### 6.2 Política de branching

- `main`: código estável, só recebe merge via Pull Request no final da sprint.
- `sprint-N`: branch de integração da sprint.
- `sprint-N-feature-usuario/<nome-curto>`: uma branch por funcionalidade/história, criada a partir de `sprint-N`, `usuario` é o integrante.
- `sprint-N-fix-usuario/<nome-curto>`: correções, criada a partir de `sprint-N`, `usuario` é o integrante.
- Nada de commit direto na `main` nem na `sprint-N`: tudo entra por Pull Request.
- Congelamento: tudo mergeado 1 dia antes do prazo.

### 6.3 Política de revisão

- Todo merge é feito via **Pull Request**.
- Mínimo de **1 aprovação** de outro integrante (nunca o próprio autor).
- O PR deve referenciar a história/issue correspondente.
- Conflitos são resolvidos pelo autor do PR antes da revisão.
- A issue só vai para Done com os testes (RSpec e Cucumber) verdes.

---

## 7. Como rodar

Requisitos: Ruby 3.3.4 e Bundler.

```bash
bundle install
bin/rails db:prepare db:seed
bin/rails server            # http://localhost:3000
bundle exec rspec           # testes RSpec
bundle exec cucumber        # cenários BDD (features/)
```

Os usuários de teste e detalhes da base de identidade estão em [Identidade e Acesso](Sprint-2-Identidade-e-Acesso.md#usuários-de-teste-binrails-dbseed). Cada página de funcionalidade tem a sua seção "Como testar".

---

## 8. Links úteis

**Wiki**

- [Sprint 1 — especificação das funcionalidades](Sprint-1.md)
- [Identidade e Acesso (F01, F04, F07)](Sprint-2-Identidade-e-Acesso.md)
- [F08 — Gestão de Restaurantes e Catracas](F08.md)
- [F10 — Cardápio da Refeição Atual](F10.md)

**Repositório**

- [Kanban da Sprint 2 (GitHub Project)](https://github.com/users/Luisserra99/projects/1)
- [README](../README.MD)
- [Issues](https://github.com/neatzzy/UnB_RU/issues)
- [Pull requests do fork](https://github.com/Luisserra99/UnB_RU/pulls)
- [Cenários BDD (features/)](../features)
- [Relatório da segunda etapa: modelo ER e spike de views Rails](../docs/sprint-1/relatorio-etapa-2.md) ([PDF](../docs/sprint-1/relatorio-etapa-2.pdf))

---

## 9. Uso de IA na sprint

- A implementação de F01 e F04 (estrutura do app Rails, models, controllers, views, specs RSpec e steps do Cucumber) e a página [Identidade e Acesso](Sprint-2-Identidade-e-Acesso.md) foram feitas com apoio do **Claude Code (Claude Opus 5.5)**, a partir dos cenários BDD da Sprint 1 e do diagrama ER do grupo. Revisadas pelo responsável.
- A implementação de F08 e F10 e as páginas [F08](F08.md) e [F10](F10.md) foram feitas com apoio do **Claude Code (Claude Opus 5.5)**, a partir dos cenários BDD, do `cardapio.json` e do diagrama ER do grupo. Revisadas pelo responsável.
- Esta Home da Sprint 2 foi montada com apoio do **Claude Code (Claude Sonnet 5.5)**, a partir da divisão de tarefas do grupo e das páginas da wiki já existentes. Deve ser revisada pela PO.
- O uso de IA na Sprint 1 está registrado na [wiki da Sprint 1](Sprint-1.md#6-uso-de-ia-na-sprint).
