Entrega da Sprint 3 do Grupo 02: refatoração e documentação das 12 funcionalidades do sistema do Restaurante Universitário, mantendo o comportamento entregue na Sprint 2 e os arquivos BDD originais.

## Equipe e escopos

| Integrante | Matrícula | Papel na Sprint 3 | Escopo |
|---|---|---|---|
| Luis Eduardo Curi Serra | 251033574 | Desenvolvedor | F02/F03, ferramentas de qualidade e piloto de refatoração |
| Weldo Gonçalves da Silva Junior | 222014133 | Scrum Master | F01/F04/F07, identidade e arquivo de entrega |
| Daniel Dezan Baby | 232046097 | Product Owner | F05/F06, consolidação da wiki e verificação final |
| Leonardo Tome Sampaio | 222005448 | Desenvolvedor | F08/F10, restaurantes, catracas e cardápios |
| Tarsila Marques de Oliveira Alves | 242012029 | Desenvolvedora | F09/F11/F12, relatórios e exportações |

## Resultado da refatoração

Os fluxos de cadastro, autenticação, recarga, controle da catraca, gestão física, cardápio e relatórios foram divididos em etapas e predicados com responsabilidades explícitas. A composição dos PDFs e a entrega das exportações passaram a ser compartilhadas. Os métodos públicos e privados receberam descrição, argumentos, retorno e efeitos colaterais no padrão RDoc.

| Critério | Resultado do conjunto completo |
|---|---|
| C1 — Complexidade | Nenhuma das 539 definições analisadas tem Flog ou ABC ≥ 18; maiores notas: Flog 17,25 e ABC 15,84 |
| C2 — Cobertura | Todos os 49 controllers e models com 100%; cobertura total 2327/2328 linhas, 99,96% arredondado |
| C3 — Happy path e sad path | 687 exemplos RSpec sem falhas; 163 cenários e 1456 passos Cucumber passando |
| C3 — Preservação dos BDD | Nenhuma alteração nos `.feature` existentes em relação à Sprint 2 |
| C4 — Documentação | RDoc com 100% dos 818 itens documentados, incluindo os 534 métodos reconhecidos pela ferramenta |
| Estilo | RuboCop: 235 arquivos, nenhuma ocorrência |

Antes da refatoração havia 57 métodos com Flog ≥ 20, 30 com ABC ≥ 20, um controller com cobertura ≤ 90% e 305 métodos sem comentário RDoc. Os valores de antes e depois, as técnicas aplicadas e o uso de IA de cada integrante estão na wiki. A única linha sem cobertura no conjunto final é a declaração da classe-base `ApplicationJob`, sem métodos e sem uso nos fluxos atuais.

## Entregáveis

- [Wiki da Sprint 3: planejamento, refatorações, medições e uso de IA](https://github.com/Luisserra99/UnB_RU/wiki/Sprint-3).
- [Arquivo de entrega do SM: repositório, wiki, nomes e matrículas](https://github.com/Luisserra99/UnB_RU/blob/sprint-3/docs/sprint-3/entrega.txt).
- [Verificação final do PO, comandos e cobertura por arquivo](https://github.com/Luisserra99/UnB_RU/blob/sprint-3/docs/sprint-3/verificacao-final.md).
- [Home do projeto: papéis, execução e resultados](https://github.com/Luisserra99/UnB_RU/blob/sprint-3/wiki/Home.md).

Validação local em 25/11/2026, no macOS com Ruby 3.4.10 e as dependências do `Gemfile.lock`: RSpec, Cucumber, RuboCop, Flog/ABC, SimpleCov e RDoc. Há um workflow configurado para RSpec, Cucumber e RuboCop no Ubuntu com Ruby 3.3, mas nenhuma execução nova foi apresentada pelo GitHub nesta preparação; os resultados acima são locais. O estado observado do CI está registrado no relatório de verificação. Os relatórios HTML são gerados por `bundle exec rubycritic` e `bin/rails documentacao`.
