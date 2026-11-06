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

Usuários de teste e detalhes: [wiki/Sprint-2-Identidade-e-Acesso.md](wiki/Sprint-2-Identidade-e-Acesso.md).
## Sprint 1

- [Wiki e especificação das funcionalidades](wiki/Home.md)
- [Relatório da segunda etapa: modelo ER e investigação das views Rails](docs/sprint-1/relatorio-etapa-2.md)
- [PDF da segunda etapa](docs/sprint-1/relatorio-etapa-2.pdf)

