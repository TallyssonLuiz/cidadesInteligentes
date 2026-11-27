# ============================================================================
# SMART PARKING API - BACK-END COM FASTAPI
# Esta API gerencia o estado de ocupação da vaga 1 do estacionamento,
# permitindo consultar (GET) e atualizar (PUT) via HTTP/JSON (ex.: pelo ESP32).
# ============================================================================

from fastapi import FastAPI     # Importa a classe principal para criar a API web
from pydantic import BaseModel  # Importa a base para validar os dados JSON recebidos

# Cria a instância da aplicação FastAPI com metadados exibidos em /docs (Swagger UI)
app = FastAPI(
    title="Smart Parking API",
    description="API de monitoramento inteligente de estacionamento",
    version="1.0.0"
)

# Estado em memória da vaga 1 (reinicia como livre toda vez que o servidor é reiniciado)
vaga = {
    "id": 1,          # Identificador da vaga
    "ocupada": False  # False = vaga livre | True = vaga ocupada
}


# Modelo Pydantic que define e valida o formato do JSON esperado no método PUT.
# Se alguém enviar um valor que não seja booleano (ou faltar o campo), retorna erro 422.
class VagaUpdate(BaseModel):
    """Corpo JSON esperado para atualizar o estado da vaga."""
    ocupada: bool


# Rota raiz (GET /) usada apenas para testar rapidamente se a API está no ar
@app.get("/")
def inicio():
    """Retorna uma mensagem simples confirmando que a API está ativa."""
    return {
        "projeto": "Smart Parking",
        "status": "API funcionando"
    }


# Rota de consulta (GET /api/vagas/1) -> retorna o estado atual da vaga 1 em JSON
@app.get("/api/vagas/1")
def consultar_vaga():
    """Retorna o ID, o status booleano e uma mensagem legível sobre a vaga 1."""
    return {
        "id": vaga["id"],
        "ocupada": vaga["ocupada"],
        # Expressão condicional: escolhe o texto de acordo com vaga["ocupada"]
        "mensagem": (
            "Vaga ocupada"
            if vaga["ocupada"]
            else "Vaga livre"
        )
    }


# Rota de atualização (PUT /api/vagas/1) -> recebe JSON {"ocupada": true/false}
# O FastAPI valida o corpo da requisição usando o modelo VagaUpdate automaticamente.
@app.put("/api/vagas/1")
def atualizar_vaga(dados: VagaUpdate):
    """Atualiza o estado da vaga 1 com o valor recebido no corpo JSON."""
    # Atualiza o dicionário em memória com o novo estado enviado (pelo ESP32 ou /docs)
    vaga["ocupada"] = dados.ocupada

    # Devolve o estado já atualizado e uma confirmação para quem fez a requisição
    return {
        "id": vaga["id"],
        "ocupada": vaga["ocupada"],
        "mensagem": "Estado atualizado com sucesso"
    }
