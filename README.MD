# UnB RU

---

Sistema de gerenciamento para o Restaurante Universitário da UnB.

## Como rodar

Requisitos: Ruby 3.3.4 e Bundler.

```bash
bundle install
bin/rails db:prepare db:seed
bin/rails server            # http://localhost:3000
bundle exec rspec           # testes RSpec
bundle exec cucumber        # cenários BDD (features/)
```

Usuários de exemplo (criados pelo seed):

| Perfil | Entrada | Identificação | Senha |
|---|---|---|---|
| Estudante | `/entrar` | `251033574` | `Estudante@123` |
| Funcionário | `/controle/login` | `funcionario01` | `senhaCorreta` |
| Administrador | `/controle/login` | `admin` | `Admin@1234` |

Lista completa e detalhes: [wiki/Sprint-2-Identidade-e-Acesso.md](wiki/Sprint-2-Identidade-e-Acesso.md).

## Sprint 2

- [Home da wiki: divisão, status e links](wiki/Home.md)
- [Identidade e Acesso (F01, F04, F07)](wiki/Sprint-2-Identidade-e-Acesso.md)
- [F08 — Gestão de Restaurantes e Catracas](wiki/F08.md)
- [F10 — Cardápio da Refeição Atual](wiki/F10.md)

## Sprint 1

- [Wiki e especificação das funcionalidades](wiki/Sprint-1.md)
- [Relatório da segunda etapa: modelo ER e investigação das views Rails](docs/sprint-1/relatorio-etapa-2.md)
- [PDF da segunda etapa](docs/sprint-1/relatorio-etapa-2.pdf)

