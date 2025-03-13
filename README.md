
# 🚀 Chat App con OpenRouter

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![OpenRouter](https://img.shields.io/badge/OpenRouter-000000?style=for-the-badge&logo=openai&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

Una aplicación de chat en Flutter que utiliza la API de **OpenRouter** para interactuar con modelos de lenguaje avanzados. Inicialmente, el objetivo era probar la API de **DeepSeek**, pero debido a problemas de pago y restricciones geográficas, se optó por utilizar OpenRouter como alternativa.

---

## 📋 Tabla de Contenidos

1. [Objetivo del Proyecto](#-objetivo-del-proyecto)
2. [Tecnologías Utilizadas](#-tecnologías-utilizadas)
3. [Configuración del Proyecto](#-configuración-del-proyecto)
4. [Uso de la Aplicación](#-uso-de-la-aplicación)
5. [Estructura del Código](#-estructura-del-código)
6. [Problemas y Soluciones](#-problemas-y-soluciones)
7. [Contribución](#-contribución)
8. [Licencia](#-licencia)

---

## 🎯 Objetivo del Proyecto

El objetivo principal de este proyecto fue probar la API de **DeepSeek** para integrar un modelo de lenguaje en una aplicación de chat. Sin embargo, debido a problemas de pago (restricciones geográficas en Bolivia que impiden el uso de PayPal) y la falta de alternativas de pago, se decidió utilizar **OpenRouter** como una API externa para lograr el mismo propósito.

OpenRouter ofrece una interfaz sencilla y acceso a múltiples modelos de lenguaje, lo que permitió continuar con el desarrollo del proyecto sin depender de DeepSeek.

---

## 🛠 Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo multiplataforma para crear aplicaciones móviles y web.
- **Dart**: Lenguaje de programación utilizado en Flutter.
- **OpenRouter API**: Plataforma que proporciona acceso a modelos de lenguaje avanzados.
- **HTTP**: Para realizar solicitudes a la API de OpenRouter.

---

## ⚙ Configuración del Proyecto

### Requisitos Previos

- Flutter SDK instalado (versión estable recomendada).
- Una clave de API de OpenRouter. Puedes obtenerla [aquí](https://openrouter.ai/).

### Pasos para Configurar el Proyecto

1. Clona el repositorio:
   ```bash
   git clone https://github.com/runinbk/DeepSeek-Prueba-T1.git
   cd DeepSeek-Prueba-T1
   ```

2. Instala las dependencias:
   ```bash
   flutter pub get
   ```

3. Configura tu clave de API:
   - Abre el archivo `lib/main.dart`.
   - Reemplaza `'tu_clave_de_api_aqui'` con tu clave de API de OpenRouter.

4. Ejecuta la aplicación:
   ```bash
   flutter run -d chrome
   ```

---

## 📱 Uso de la Aplicación

1. **Iniciar la aplicación**:
   - Al abrir la aplicación, verás una interfaz simple con un campo de texto y un botón de enviar.

2. **Enviar mensajes**:
   - Escribe un mensaje en el campo de texto y presiona el botón de enviar (o presiona `Enter`).
   - La aplicación enviará el mensaje a la API de OpenRouter y mostrará la respuesta en la pantalla.

3. **Salir de la aplicación**:
   - Para salir, simplemente cierra la ventana del navegador o detén la ejecución en la terminal.

---

## 🧩 Estructura del Código

El proyecto está organizado de la siguiente manera:

- **`lib/main.dart`**: Punto de entrada de la aplicación. Contiene la configuración inicial y la interfaz de usuario. Lógica principal de la aplicación, incluyendo el manejo de mensajes y la conexión con la API de OpenRouter.
- **`pubspec.yaml`**: Archivo de configuración de dependencias de Flutter.

---

## 🚨 Problemas y Soluciones

### Problema: Restricciones de Pago con DeepSeek
- **Descripción**: Debido a la crisis económica en Bolivia, los bancos han restringido las compras en línea, especialmente a través de PayPal, que es el método de pago utilizado por DeepSeek.
- **Solución**: Se optó por utilizar **OpenRouter**, que ofrece una API similar y permite el uso de tarjetas de crédito directamente.

### Problema: Errores en Flutter Web
- **Descripción**: Al ejecutar la aplicación en Flutter Web, se presentaron errores relacionados con el manejo de eventos y el entorno de desarrollo.
- **Solución**: Se actualizó Flutter a la última versión estable y se revisó el manejo de eventos en la interfaz de usuario.

---

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Si deseas mejorar este proyecto, sigue estos pasos:

1. Haz un fork del repositorio.
2. Crea una rama con tu nueva funcionalidad (`git checkout -b feature/nueva-funcionalidad`).
3. Realiza tus cambios y haz commit (`git commit -m 'Añadir nueva funcionalidad'`).
4. Haz push a la rama (`git push origin feature/nueva-funcionalidad`).
5. Abre un Pull Request.

---

## 📜 Licencia

Este proyecto está bajo la licencia **MIT**. Para más detalles, consulta el archivo [LICENSE](LICENSE).

---

## 🙏 Agradecimientos

- A **OpenRouter** por proporcionar una API accesible y fácil de usar.
- A la comunidad de **Flutter** por su apoyo y recursos.

---

¡Gracias por usar esta aplicación! Si tienes alguna pregunta o sugerencia, no dudes en contactarme. 😊

