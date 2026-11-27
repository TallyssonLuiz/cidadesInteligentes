# cidadesInteligentes

#include <WiFi.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>

const char* ssid = "Wokwi-GUEST";
const char* password = "";

const char* apiURL =
  "https://modification-inf-accuracy-sphere.trycloudflare.com/api/vagas/1";

const int ledVerde = 2;
const int ledVermelho = 4;

void conectarWiFi() {
  Serial.print("Conectando ao WiFi");
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password, 6);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi conectado!");
  Serial.println(WiFi.localIP());
}

void consultarAPI() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi desconectado!");
    return;
  }

  WiFiClientSecure client;
  client.setInsecure();

  HTTPClient http;
  Serial.println("\nConsultando FastAPI...");

  if (http.begin(client, apiURL)) {
    http.setTimeout(15000);
    int codigo = http.GET();

    if (codigo == HTTP_CODE_OK) {
      String resposta = http.getString();
      Serial.println("Resposta da API:");
      Serial.println(resposta);

      if (resposta.indexOf("\"ocupada\":true") >= 0) {
        digitalWrite(ledVermelho, HIGH);
        digitalWrite(ledVerde, LOW);
        Serial.println("VAGA OCUPADA");
      } else if (resposta.indexOf("\"ocupada\":false") >= 0) {
        digitalWrite(ledVermelho, LOW);
        digitalWrite(ledVerde, HIGH);
        Serial.println("VAGA LIVRE");
      }
    } else {
      Serial.print("Erro HTTP: ");
      Serial.print(codigo);
      Serial.print(" -> ");
      Serial.println(http.errorToString(codigo));
    }

    http.end();
  } else {
    Serial.println("Falha ao iniciar requisicao HTTP");
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(ledVerde, OUTPUT);
  pinMode(ledVermelho, OUTPUT);
  digitalWrite(ledVerde, LOW);
  digitalWrite(ledVermelho, LOW);
  conectarWiFi();
}

void loop() {
  consultarAPI();
  delay(3000);
}
