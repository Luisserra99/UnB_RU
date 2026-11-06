# Não envolver campos com erro em <div class="field_with_errors">: quebrava o layout dos campos com ícone.
# As views marcam os campos inválidos com a classe "invalido" e aria-invalid.
Rails.application.config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }
