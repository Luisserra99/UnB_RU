# UnB RU

[![CI](https://github.com/Luisserra99/UnB_RU/actions/workflows/ci.yml/badge.svg?branch=sprint-2)](https://github.com/Luisserra99/UnB_RU/actions/workflows/ci.yml)

Sistema de gestão do Restaurante Universitário da UnB, desenvolvido pelo **Grupo 02** na disciplina de Engenharia de Software (UnB), da professora Genaina Nunes Rodrigues.

- **Estudantes:** fazem o cadastro, compram créditos por PIX ou cartão, consultam o cardápio da refeição atual e exportam o extrato em PDF ou CSV.
- **Funcionários:** fazem login na aplicação de controle, escolhem o restaurante e a catraca, validam a entrada dos estudantes e consultam o histórico local da catraca.
- **Administradores:** gerenciam restaurantes, pisos e catracas e emitem o relatório global de operação em CSV e PDF.

| | |
|---|---|
| **Wiki** | [Home](wiki/Home.md): equipe, funcionalidades, arquitetura, testes e padrões do grupo |
| **Kanban** | [GitHub Project — Sprint 2](https://github.com/users/Luisserra99/projects/1) |
| **Branch de entrega** | `sprint-2` |
| **Repositório da disciplina** | [neatzzy/UnB_RU](https://github.com/neatzzy/UnB_RU) |

## Funcionalidades

| # | Funcionalidade | Responsável | Documentação |
|---|---|---|---|
| F01 | Cadastro de estudante | Weldo Gonçalves da Silva Junior | [F01](wiki/F01.md) |
| F02 | Recarga de saldo (PIX e cartão) | Luis Eduardo Curi Serra | [F02](wiki/F02.md) |
| F03 | Extrato e histórico de refeições | Luis Eduardo Curi Serra | [F03](wiki/F03.md) |
| F04 | Autenticação do funcionário | Weldo Gonçalves da Silva Junior | [F04](wiki/F04.md) |
| F05 | Configuração do ponto de acesso | Daniel Dezan Baby | [F05](wiki/F05.md) |
| F06 | Leitura e autorização na catraca | Daniel Dezan Baby | [F06](wiki/F06.md) |
| F07 | Histórico local da catraca | Weldo Gonçalves da Silva Junior | [F07](wiki/F07.md) |
| F08 | Gestão de restaurantes e catracas | Leonardo Tome Sampaio | [F08](wiki/F08.md) |
| F09 | Relatório global de operação | Tarsila Marques de Oliveira Alves | [F09](wiki/F09.md) |
| F10 | Cardápio da refeição atual | Leonardo Tome Sampaio | [F10](wiki/F10.md) |
| F11 | Exportação do extrato (PDF e CSV) | Tarsila Marques de Oliveira Alves | [F11](wiki/F11.md) |
| F12 | Exportação em PDF do relatório de operação | Tarsila Marques de Oliveira Alves | [F12](wiki/F12.md) |

Os cenários BDD de cada funcionalidade ficam em [`features/`](features), e as histórias de usuário com as regras de negócio estão na [especificação da Sprint 1](wiki/Sprint-1.md).

## Tecnologias

Ruby 3.3 · Rails 8.1 · SQLite · bcrypt · Prawn (PDF) · RSpec · Cucumber + Capybara · FactoryBot

## Como rodar

Requisitos: Ruby 3.3 e Bundler.

```bash
bundle install
bin/rails db:prepare db:seed
bin/rails server            # http://localhost:3000
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
| Estudante com saldo | `/entrar` | `251033574` | `Estudante@123` |
| Estudante sem saldo | `/entrar` | `222014133` | `Estudante@123` |
| Funcionário | `/controle/login` | `funcionario01` | `senhaCorreta` |
| Administrador | `/controle/login` | `admin` | `Admin@1234` |

No PIX, o botão "Simular pagamento" confirma o pagamento (só em desenvolvimento). No cartão, `4111 1111 1111 1111` é aprovado e `4000 0000 0000 0002` é recusado. A lista completa está em [Identidade e Acesso](wiki/Sprint-2-Identidade-e-Acesso.md).

## Testes

```bash
bundle exec rspec           # 501 exemplos: models, forms, services, helpers e requests
bundle exec cucumber        # 163 cenários BDD das 12 funcionalidades
bundle exec rubocop         # lint (estilo padrão do Rails, rubocop-rails-omakase)
```

### Integração contínua

O workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) roda no GitHub Actions a cada push e pull request, em três jobs paralelos: **RuboCop**, **RSpec** e **Cucumber**. O resultado aparece na aba [Actions](https://github.com/Luisserra99/UnB_RU/actions) e no selo no topo deste README.

## Estrutura

```
app/
  controllers/          Portal do Estudante (raiz), controle/ (funcionário) e admin/ (administrador)
  forms/                Form objects: cadastro, solicitação de recarga e dados do cartão
  models/               Entidades do diagrama ER
  services/             Regras de negócio: pagamentos, catracas, pontos de acesso, extratos e relatórios
db/seeds/               Dados de exemplo: usuários, restaurantes, cardápio e recargas
features/               Cenários BDD (Cucumber) e step definitions
spec/                   Testes RSpec
wiki/                   Fonte das páginas da wiki
docs/sprint-1/          Relatório da Sprint 1 (modelo ER)
```

## Equipe

| Integrante | Matrícula | Papel |
|---|---|---|
| Luis Eduardo Curi Serra | 251033574 | Scrum Master |
| Tarsila Marques de Oliveira Alves | 242012029 | Product Owner |
| Daniel Dezan Baby | 232046097 | Desenvolvedor |
| Leonardo Tome Sampaio | 222005448 | Desenvolvedor |
| Weldo Gonçalves da Silva Junior | 222014133 | Desenvolvedor |

## Sprints

- **Sprint 1:** [especificação das funcionalidades e cenários BDD](wiki/Sprint-1.md) e [relatório do modelo ER](docs/sprint-1/relatorio-etapa-2.md) ([PDF](docs/sprint-1/relatorio-etapa-2.pdf))
- **Sprint 2:** implementação das 12 funcionalidades com testes RSpec e Cucumber ([wiki](wiki/Home.md))
