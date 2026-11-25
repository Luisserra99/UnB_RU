# Sprint 3 — Verificação consolidada do Product Owner

Preparação da entrega do Grupo 02 por Daniel Dezan Baby (232046097), em **25/11/2026**. Prazo da disciplina: **27/11/2026**.

## Versão e estado da entrega

Os cinco escopos estão integrados na `sprint-3` até o commit `e6c17a474620496c2d6b4f146d2b7c9968aee6b3`, que contém o merge do PR #72 de F08/F10. A branch `sprint-3-docs-Daniel/consolidacao` acrescenta a consolidação da documentação e um comentário na classe-base `ApplicationJob`, sem mudança de comportamento.

| Escopo | Integração no fork do grupo |
|---|---|
| Luis — F02/F03 e ferramentas | Piloto e medições já integrados antes das demais refatorações |
| Weldo — F01/F04/F07 e identidade | PR #52 |
| Daniel — F05/F06 | PR #68 |
| Tarsila — F09/F11/F12 | PRs #69 e #73 |
| Leonardo — F08/F10 | PR #72 |
| Weldo — arquivo `.txt` | PR #70, commit `b440032` |

O PR final **`Grupo 02 - Sprint 3`**, de **`Luisserra99:sprint-3`** para **`neatzzy/UnB_RU:main`**, teve sua abertura autorizada pelo Daniel em **25/11/2026**, junto à integração do fechamento com a validação local. A descrição está em [pr-final.md](pr-final.md); o link da submissão fica registrado na [issue #67](https://github.com/Luisserra99/UnB_RU/issues/67) e na wiki pública. A consolidação e a wiki são publicadas antes da abertura.

## Conferência do arquivo do Scrum Master

Localizado em [entrega.txt](entrega.txt). Conferidos o repositório do grupo, a branch `sprint-3` e os cinco nomes/matrículas, sem alterar o arquivo do Weldo. O link da wiki segue à parte, como pede o enunciado:

| Integrante | Matrícula |
|---|---|
| Luis Eduardo Curi Serra | 251033574 |
| Weldo Gonçalves da Silva Junior | 222014133 |
| Daniel Dezan Baby | 232046097 |
| Leonardo Tome Sampaio | 222005448 |
| Tarsila Marques de Oliveira Alves | 242012029 |

## Resultado dos critérios de aceite

| Critério | Antes — T1 (`575ba8c`) | Depois — conjunto completo |
|---|---|---|
| C1 — Métodos com Flog ≥ 20 | 57 | 0 |
| C1 — Métodos com ABC ≥ 20 | 30 | 0 |
| C1 — Maior Flog | 67,65 | 17,25, `Relatorios::AcessosOperacao#montar_acesso` |
| C1 — Maior ABC | 54,90 | 15,84, `Extratos::ComposicaoPdf#desenhar_tabela` |
| C2 — Cobertura total de linhas | 99,27% | 99,96%, 2327/2328 linhas |
| C2 — Controllers/models com cobertura ≤ 90% | 1 | 0; os 49 arquivos estão com 100% |
| C3 — RSpec | 507 exemplos | 687 exemplos, 0 falhas |
| C3 — Cucumber | 163 cenários | 163 cenários e 1456 passos passando |
| C3 — Features existentes | Referência da Sprint 2 | Nenhuma diferença |
| C4 — Métodos sem comentário RDoc | 305 de 369 | 0 de 534 |
| C4 — Itens documentados no RDoc | 17,01% | 100% dos 818 itens |
| RuboCop | Sem ocorrências | 235 arquivos, nenhuma ocorrência |
| RubyCritic — nota geral | 85,37 | 86,12 |

Os 539 métodos definidos no AST estão abaixo de **18** em Flog e ABC, incluindo os extraídos durante a refatoração. As 82 linhas da tabela de antes/depois na wiki foram comparadas com a medição atual; nenhum valor de depois divergiu.

O RDoc organiza 534 itens do tipo método. A inspeção dos comentários das 539 definições Ruby também confirmou os rótulos `Argumentos::`, `Retorno::` e `Efeitos colaterais::`, além da descrição. Classes, módulos, constantes e atributos estão documentados.

A cobertura total é arredondada a duas casas a partir de 2327/2328 linhas. A única linha sem execução é a declaração da classe-base `ApplicationJob`, sem métodos ou uso nos fluxos atuais. Não foi acrescentado um teste que apenas carregasse essa classe para elevar o percentual. Todos os controllers e models cumprem a meta C2 de cobertura estritamente maior que 90%.

## Comandos e evidências

Ambiente local: macOS, Ruby **3.4.10**, SQLite de teste e versões do `Gemfile.lock`. Os testes usam o banco de teste; o banco de desenvolvimento não foi recriado.

```sh
bundle check
bundle exec rspec --format progress
bundle exec cucumber --format progress
bundle exec rubocop --cache false
bin/rails "qualidade:metodos[0]"
bin/rails qualidade:cobertura
bin/rails qualidade:rdoc
bin/rails documentacao
bundle exec rubycritic
git diff origin/sprint-2 -- 'features/*.feature'
```

Os relatórios gerados ficam em `coverage/index.html`, `tmp/rubycritic/overview.html` e `doc/app/index.html`, fora do versionamento. Os logs da verificação local estão em `tmp/sprint-3-final-*.log`.

### Estado do CI remoto em 25/11/2026

O [PR interno #74](https://github.com/Luisserra99/UnB_RU/pull/74) contém esta consolidação. O GitHub não apresentou checks novos para esse PR; a consulta à API de workflows retornou uma lista vazia, e o arquivo `.github/workflows/ci.yml` não foi encontrado na branch padrão `main`. O arquivo existe na `sprint-3` e na branch de consolidação. A causa da ausência de execução não foi confirmada e nenhuma configuração do Actions foi alterada.

Os resultados desta verificação foram obtidos localmente. Daniel autorizou em 25/11/2026 a integração do fechamento com essa validação local e a abertura do PR final para a disciplina. As últimas execuções históricas disponíveis no GitHub pertencem a commits anteriores e não foram apresentadas como checks do PR #74.

Os cenários BDD originais foram comparados com a `origin/sprint-2` e estão preservados. Os testes acrescentados exercitam, entre outros, validação de formulários, autenticação e papéis, autorização por sessão, prazos, idempotência, rollback, limites de rateio, gestão de cadastros, filtros inválidos e falhas de exportação. A cobertura de linhas complementa essa verificação dos caminhos de sucesso e recusa.

## Tarefas do PO e aprovação da entrega

- **T4 — #65:** tabelas dos cinco integrantes, resumo global, refatorações e uso de IA consolidados. A publicação e o encerramento da tarefa são registrados na issue #65.
- **T5 — #66:** critérios C1–C4 conferidos no conjunto completo; relatórios HTML gerados. O CI da consolidação complementa a verificação; o encerramento é registrado na issue #66.
- **T6 — #67:** Home e README atualizados; título, destino e descrição do PR final preparados. **Abertura autorizada pelo Daniel em 25/11/2026**; o link da submissão fica registrado na issue #67 e na wiki pública.

A preparação e a submissão usam a [descrição final](pr-final.md), a [wiki fonte](../../wiki/Sprint-3.md) e o [arquivo de entrega](entrega.txt). A autorização do Daniel foi recebida em 25/11/2026.

## Cobertura por controller e model

| Arquivo | Cobertura | Linhas cobertas |
|---|---|---|
| `app/controllers/admin/acessos_operacao_controller.rb` | 100,00% | 12/12 |
| `app/controllers/admin/base_controller.rb` | 100,00% | 12/12 |
| `app/controllers/admin/catracas_controller.rb` | 100,00% | 40/40 |
| `app/controllers/admin/relatorios_base_controller.rb` | 100,00% | 12/12 |
| `app/controllers/admin/relatorios_globais_controller.rb` | 100,00% | 11/11 |
| `app/controllers/admin/restaurantes_controller.rb` | 100,00% | 24/24 |
| `app/controllers/application_controller.rb` | 100,00% | 5/5 |
| `app/controllers/cadastros_controller.rb` | 100,00% | 11/11 |
| `app/controllers/cardapios_controller.rb` | 100,00% | 27/27 |
| `app/controllers/concerns/autenticacao_estudante.rb` | 100,00% | 36/36 |
| `app/controllers/concerns/autenticacao_funcionario.rb` | 100,00% | 36/36 |
| `app/controllers/concerns/entrega_de_exportacao.rb` | 100,00% | 7/7 |
| `app/controllers/controle/base_controller.rb` | 100,00% | 15/15 |
| `app/controllers/controle/catracas_controller.rb` | 100,00% | 5/5 |
| `app/controllers/controle/historico_controller.rb` | 100,00% | 31/31 |
| `app/controllers/controle/painel_controller.rb` | 100,00% | 4/4 |
| `app/controllers/controle/pontos_acesso_controller.rb` | 100,00% | 19/19 |
| `app/controllers/controle/sessoes_controller.rb` | 100,00% | 32/32 |
| `app/controllers/controle/terminal_controller.rb` | 100,00% | 24/24 |
| `app/controllers/exportacoes_extrato_controller.rb` | 100,00% | 9/9 |
| `app/controllers/extratos_controller.rb` | 100,00% | 14/14 |
| `app/controllers/paginas_controller.rb` | 100,00% | 2/2 |
| `app/controllers/portal_estudante_controller.rb` | 100,00% | 2/2 |
| `app/controllers/recargas_controller.rb` | 100,00% | 54/54 |
| `app/controllers/sessoes_estudante_controller.rb` | 100,00% | 23/23 |
| `app/models/application_record.rb` | 100,00% | 2/2 |
| `app/models/cardapio.rb` | 100,00% | 12/12 |
| `app/models/catraca.rb` | 100,00% | 27/27 |
| `app/models/configuracao_ponto_acesso.rb` | 100,00% | 24/24 |
| `app/models/estudante.rb` | 100,00% | 12/12 |
| `app/models/exportacao_relatorio.rb` | 100,00% | 40/40 |
| `app/models/item_cardapio.rb` | 100,00% | 5/5 |
| `app/models/item_recarga.rb` | 100,00% | 16/16 |
| `app/models/movimentacao_saldo.rb` | 100,00% | 41/41 |
| `app/models/opcao_cardapio.rb` | 100,00% | 8/8 |
| `app/models/pagamento.rb` | 100,00% | 42/42 |
| `app/models/papel.rb` | 100,00% | 9/9 |
| `app/models/piso.rb` | 100,00% | 7/7 |
| `app/models/rateio_consumo.rb` | 100,00% | 28/28 |
| `app/models/recarga.rb` | 100,00% | 27/27 |
| `app/models/registro_acesso.rb` | 100,00% | 34/34 |
| `app/models/restaurante.rb` | 100,00% | 62/62 |
| `app/models/servico_refeicao.rb` | 100,00% | 32/32 |
| `app/models/sessao_autenticacao.rb` | 100,00% | 32/32 |
| `app/models/tarifa_refeicao.rb` | 100,00% | 25/25 |
| `app/models/tipo_refeicao.rb` | 100,00% | 9/9 |
| `app/models/unidade_gestora.rb` | 100,00% | 8/8 |
| `app/models/usuario.rb` | 100,00% | 33/33 |
| `app/models/usuario_papel.rb` | 100,00% | 4/4 |
