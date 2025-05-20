# Gasolineras España - Aplicación Web Angular

## 📖 Introducción
Esta aplicación web permite a los usuarios consultar precios de carburantes en España y localizar gasolineras cercanas utilizando la API del Ministerio para la Transformación Digital y Función Pública.  
Incluye funcionalidades de filtrado por empresa, tipo de carburante y ubicación.

## 🎯 Objetivos del Proyecto
- Implementar una aplicación en Angular basada en componentes.  
- Integrar y procesar datos en tiempo real desde una API REST.  
- Permitir la localización del usuario y aplicar filtros avanzados para mejorar la búsqueda.  
- Asegurar la usabilidad mediante una interfaz intuitiva y diseño responsive.  

## 🛠️ Tecnologías Utilizadas
- **Frontend:** Angular  
- **Lenguaje de programación:** TypeScript  
- **Interfaz de usuario:** HTML, CSS  
- **Consumo de API:** HttpClient de Angular  
- **Geolocalización:** API del navegador  
- **Procesamiento de datos:** JSON y RxJS  
- **Gestión del código:** GitHub  

## 🚀 Descripción de la Aplicación
La aplicación permite:  
- Obtener datos de la API oficial sobre estaciones de servicio en España.  
- Filtrar gasolineras por proximidad, tipo de carburante, empresa y localización.  
- Visualizar datos en tablas con opciones de ordenación y cálculo de distancia usando la fórmula de Haversine.

### 🧩 Componentes
- **HomeComponent:** Página de inicio con acceso a la búsqueda de gasolineras.  
- **SearchComponent:** Página de búsqueda con filtros avanzados y geolocalización.  
- **AboutComponent:** Información sobre la aplicación y sus objetivos.  
- **GasStationService:** Servicio que realiza las llamadas a la API y procesa los datos.  

## 🔗 Integración con la API REST
- **API utilizada:** [API de Precios de Carburantes](https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/)  
- **Llamada a la API:**
```typescript
this.http.get<any>(this.API_URL_JSON)
  .pipe(map(response => response.ListaEESSPrecio))
  .subscribe(data => { this.gasStations = data; });
```

## 🖥️ Interfaz de Usuario
- Diseño responsive adaptado para múltiples dispositivos.  
- Uso de formularios y listas desplegables para mejorar la experiencia de búsqueda.  
- Integración de geolocalización para obtener la ubicación automáticamente.  
- Manejo de errores en la carga de datos.  

## 🧪 Pruebas Realizadas
- **Pruebas unitarias:** Herramientas como Jasmine y Karma.  
- **Pruebas de integración:** Validación de la interacción entre componentes y la API.  
- **Pruebas de usuario:** Verificación manual para asegurar la usabilidad y correcta visualización.  

## 📈 Conclusiones
- Integración exitosa de una API REST en Angular.  
- Filtrado dinámico y uso de geolocalización para optimizar la experiencia del usuario.  
- **Mejoras futuras:** Implementación de mapas interactivos y almacenamiento en caché para mejorar el rendimiento.  

## 📂 Repositorio y Recursos
- **Repositorio GitHub:** [TE-Actividad3](https://github.com/TheHacha167/Dar-Desarrollo-de-Aplicaciones-en-Red-Actividad3)  
- **Aplicación desplegada:** [Enlace a la aplicación](https://thehacha167.github.io/Dar-Desarrollo-de-Aplicaciones-en-Red-Actividad3/)

> Proyecto realizado para la asignatura **Tecnologías Emergentes 3**.