# Sprint 2 — Identidade e Acesso

**Responsável:** Weldo Gonçalves da Silva Junior (222014133)

| Feature | Cenários BDD | Status |
|---|---|---|
| F01 — Cadastro de estudante | [features/cadastro_usuario.feature](../features/cadastro_usuario.feature) | Implementada, 4/4 cenários passando |
| F04 — Login de funcionário | [features/autenticacao_funcionario.feature](../features/autenticacao_funcionario.feature) | Implementada, 11/11 cenários passando |
| F07 — Histórico local da catraca | [features/historico_local_catraca.feature](../features/historico_local_catraca.feature) | Aguardando `Catraca` (F08) e `RegistroAcesso` (F06) |

Models: `Usuario`, `Papel`, `UsuarioPapel`, `Estudante`, `SessaoAutenticacao`, mais os seeds de papéis e usuários de teste.

---

## F01 — Cadastro de estudante

**Rota:** `GET/POST /cadastro`, em `CadastrosController` com o form object `CadastroEstudante` ([app/forms/cadastro_estudante.rb](../app/forms/cadastro_estudante.rb)).

O cadastro cria, numa única transação, o `Usuario` (identificação = matrícula), o `Estudante` e o vínculo com o papel `estudante`. Se qualquer validação falhar, nada é gravado.

| Regra | Implementação |
|---|---|
| RN01.1: matrícula de 9 números | `Estudante::FORMATO_MATRICULA = /\A\d{9}\z/`, única. `vinculo_ativo` começa como `true` |
| RN01.2: email válido | Formato validado em `Usuario`, único, salvo em minúsculas |
| RN01.3: senha com no mínimo 8 caracteres | `Usuario::SENHA_TAMANHO_MINIMO = 8` (`has_secure_password`, bcrypt) |
| RN01.4: domínio da faculdade | Aceita somente `@aluno.unb.br` e `@unb.br` (`CadastroEstudante::DOMINIOS_FACULDADE`) |
| RN01.5: concluir com dados corretos | Redireciona para a página inicial com "Conta criada com sucesso" |

Mensagens de erro: "Matrícula inválida: informe exatamente 9 números", "Email inválido: use o email institucional (@aluno.unb.br ou @unb.br)" e "Senha inválida: informe no mínimo 8 caracteres". Matrícula ou email repetidos também são rejeitados.

## F04 — Login de funcionário

**Rotas:** `GET/POST /controle/login`, `DELETE /controle/logout` e `GET /controle` (painel).

| Regra | Implementação |
|---|---|
| RN04.1: campos obrigatórios | Indica "Identificação é obrigatória" e/ou "Senha é obrigatória" |
| RN04.2 e RN04.3: credenciais e conta ativa | `Usuario.autenticar` usa `authenticate_by` (tempo constante) e exige `ativo`. Qualquer falha mostra "Não foi possível autenticar as credenciais." |
| RN04.4: estudante não entra | Só os papéis `funcionario` e `administrador` acessam o controle. Conta só de estudante recebe "Acesso negado: a aplicação de controle é restrita a funcionários." |
| RN04.5: escolher o ponto de acesso | A sessão nasce com `ponto_acesso_pendente = true` e o painel mostra "Escolha do restaurante e da catraca" (a seleção em si é a F05) |
| RN04.6: sessão obrigatória e expiração | `Controle::BaseController` aplica `exigir_funcionario!`. A sessão dura 8 horas (`SessaoAutenticacao::DURACAO`); depois disso o sistema pede novo login com "Sua sessão expirou." |
| RN04.7: logout | Preenche `encerrada_em`, limpa o cookie e volta à tela de login |

**Segurança da sessão:** o cookie (criptografado pelo Rails) guarda um token aleatório. O banco guarda somente o SHA-256 desse token (`token_digest`). No login, `reset_session` evita fixação de sessão. Desativar o usuário derruba a sessão na próxima requisição.

## F07 — Histórico local da catraca

Ainda não implementada: depende de `Catraca` (Luis, F08), `ConfiguracaoPontoAcesso` e `RegistroAcesso` (Daniel, F05/F06). Assim que esses models forem mergeados, a consulta entra como `Controle::HistoricoController < Controle::BaseController`, filtrando `RegistroAcesso` pela catraca configurada na sessão atual.

---

## Para os outros integrantes

- **Proteger uma tela da aplicação de controle:** herde de `Controle::BaseController`. Dentro dele estão disponíveis `funcionario_atual` e `sessao_atual`; nas views também existe `funcionario_autenticado?`.
- **Plural em português:** [config/initializers/inflections.rb](../config/initializers/inflections.rb) faz `ao → oes` e `el → eis`. Exemplos: `TarifaRefeicao → tarifa_refeicoes`, `Papel → papeis`, `SessaoAutenticacao → sessao_autenticacoes`. Use `rails g model` normalmente; os nomes de tabela já saem certos.
- **Seeds:** `db/seeds.rb` carrega `db/seeds/*.rb` em ordem. Crie o seu próprio arquivo (ex.: `db/seeds/02_restaurantes.rb`) em vez de editar o arquivo de outra pessoa. Os seeds devem ser idempotentes.
- **Testes:** as factories `:usuario`, `:funcionario`, `:administrador`, `:usuario_estudante`, `:estudante` e `:sessao_autenticacao` ficam em [spec/factories/identidade.rb](../spec/factories/identidade.rb). Em request specs, `login_controle(usuario)` faz o login.

### Usuários de teste (`bin/rails db:seed`)

| Identificação | Senha | Papel |
|---|---|---|
| `admin` | `Admin@1234` | administrador |
| `funcionario01` | `senhaCorreta` | funcionário |
| `funcionario02` | `senhaCorreta` | funcionário **inativo** |
| `100200300` | `Senha@123` | funcionário (CAT-01 na F07) |
| `100200301` | `Senha@456` | funcionário (CAT-02 na F07) |
| `251033574` | `Estudante@123` | estudante |
| `222014133` | `Estudante@123` | estudante |

### Como rodar

```bash
bundle install
bin/rails db:prepare db:seed
bin/rails server                      # http://localhost:3000

bundle exec rspec                     # testes RSpec
bundle exec cucumber features/cadastro_usuario.feature features/autenticacao_funcionario.feature
```

> `bundle exec cucumber` sem argumentos roda todas as features em modo `--strict`. Features cujos passos ainda não foram implementados aparecem como *undefined* e fazem o comando falhar até serem implementadas.

## Uso de IA

Implementação de F01 e F04 (estrutura do app Rails, models, controllers, views, specs RSpec e step definitions do Cucumber) e esta página feitas com apoio do **Claude Code (Claude Opus 5.5)**, a partir dos cenários BDD da Sprint 1 e do diagrama ER do grupo. Revisadas pelo responsável.
