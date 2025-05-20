#!/bin/bash

DEBUG=false  # Cambia a true para ver resultados intermedios

API_URL="https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/"
ns="http://schemas.datacontract.org/2004/07/ServiciosCarburantes"

carburantes=(
    "Precio_x0020_Biodiesel"
    "Precio_x0020_Bioetanol"
    "Precio_x0020_Gas_x0020_Natural_x0020_Comprimido"
    "Precio_x0020_Gas_x0020_Natural_x0020_Licuado"
    "Precio_x0020_Gases_x0020_licuados_x0020_del_x0020_petróleo"
    "Precio_x0020_Gasoleo_x0020_A"
    "Precio_x0020_Gasoleo_x0020_B"
    "Precio_x0020_Gasoleo_x0020_Premium"
    "Precio_x0020_Gasolina_x0020_95_x0020_E10"
    "Precio_x0020_Gasolina_x0020_95_x0020_E5"
    "Precio_x0020_Gasolina_x0020_95_x0020_E5_x0020_Premium"
    "Precio_x0020_Gasolina_x0020_98_x0020_E10"
    "Precio_x0020_Gasolina_x0020_98_x0020_E5"
    "Precio_x0020_Hidrogeno"
)

# Función para envolver XML con raíz
envolver_en_resultados() {
    contenido="$1"
    echo "<Resultados xmlns=\"$ns\">$contenido</Resultados>"
}

echo "Obteniendo datos del XML..."
response=$(curl -s "$API_URL" -H "Accept: application/xml")
[[ -z "$response" ]] && { echo "Error al obtener datos. Saliendo..."; exit 1; }

# === FILTRO OPCIONAL POR CARBURANTE ===
read -p "¿Deseas filtrar por un tipo de carburante? (s/n): " filtrar_carburante

if [[ "$filtrar_carburante" =~ ^[sS]$ ]]; then
    echo ""
    echo "Tipos de carburante disponibles:"
    for i in "${!carburantes[@]}"; do
        echo "$((i+1)). ${carburantes[$i]}"
    done

    read -p "Selecciona el número del tipo de carburante que deseas mostrar: " seleccion

    if ! [[ "$seleccion" =~ ^[0-9]+$ ]] || (( seleccion < 1 || seleccion > ${#carburantes[@]} )); then
        echo "Selección inválida. Saliendo..."
        exit 1
    fi

    seleccionado="${carburantes[$((seleccion - 1))]}"
    [[ "$DEBUG" == true ]] && echo "Carburante seleccionado: $seleccionado"

    # Conservar solo el nodo seleccionado y campos básicos
    #nodos_a_mantener="d:Rótulo d:Provincia d:Municipio d:Localidad d:Dirección d:$seleccionado"
    #nuevo_response=$(echo "$response" | xmlstarlet ed -N d="$ns" $(for tag in "${carburantes[@]}"; do
        #[[ "$tag" != "$seleccionado" ]] && echo "-d //d:EESSPrecio/d:$tag"
    #done))

    # 1. Filtrar solo EESSPrecio con precio válido
    contenido_filtrado=$(echo "$response" | xmlstarlet sel -N d="$ns" -t \
    -m "//d:EESSPrecio[normalize-space(d:$seleccionado) != '']" -c "." -n)

    # 2. Encapsular antes de procesar (crear XML bien formado)
    documento_temporal=$(envolver_en_resultados "$contenido_filtrado")

    # 3. Eliminar nodos de otros carburantes
    carburante_limpio=$(echo "$documento_temporal" | xmlstarlet ed -N d="$ns" $(for tag in "${carburantes[@]}"; do
        [[ "$tag" != "$seleccionado" ]] && echo "-d //d:EESSPrecio/d:$tag"
    done))

    nuevo_response="$carburante_limpio"



    # Mostrar en modo debug
    [[ "$DEBUG" == true ]] && {
        echo "XML tras filtrar por carburante:"
        echo "$nuevo_response" | xmlstarlet fo
    }
else
    nuevo_response="$response"
fi

# === FILTRADO POR EMPRESA ===
empresas=$(echo "$nuevo_response" | xmlstarlet sel -N d="$ns" -t -m "//d:EESSPrecio" -v "d:Rótulo" -n | sort -u)
echo "Lista de empresas:"
echo "$empresas"
echo ""

read -p "Escribe la empresa que quieres filtrar (o pulsa ENTER para no filtrar): " empresa_filtrada

if [[ -n "$empresa_filtrada" ]]; then
    empresa_filtrada_limpia=$(echo "$empresa_filtrada" | sed 's/[<>|]//g' | awk '{$1=$1};1')
    estaciones_filtradas=$(echo "$nuevo_response" | xmlstarlet sel -N d="$ns" -t \
        -m "//d:EESSPrecio[d:Rótulo='$empresa_filtrada_limpia']" -c "." -n)

    if [[ -n "$estaciones_filtradas" ]]; then
        nuevo_response=$(envolver_en_resultados "$estaciones_filtradas")
        [[ "$DEBUG" == true ]] && {
            echo "Gasolineras filtradas por empresa '$empresa_filtrada_limpia':"
            echo "$nuevo_response" | xmlstarlet fo
        }
    fi
fi

# === FILTRADO POR PROVINCIA ===
provincias=$(echo "$nuevo_response" | xmlstarlet sel -N d="$ns" -t -m "//d:EESSPrecio" -v "d:Provincia" -n | sort -u)
if [[ $(echo "$provincias" | wc -l) -eq 1 ]]; then
    provincia_filtrada="$provincias"
    echo "Solo se encontró una provincia: '$provincia_filtrada'. Seleccionada automáticamente."
else
    echo "Lista de provincias:"
    echo "$provincias"
    read -p "Escribe la provincia que quieres filtrar: " provincia_filtrada
fi

if [[ -n "$provincia_filtrada" ]]; then
    contenido_filtrado=$(echo "$nuevo_response" | xmlstarlet sel -N d="$ns" -t \
        -m "//d:EESSPrecio[d:Provincia='$provincia_filtrada']" -c "." -n)
    nuevo_response=$(envolver_en_resultados "$contenido_filtrado")
    [[ "$DEBUG" == true ]] && {
        echo "Gasolineras filtradas por provincia '$provincia_filtrada':"
        echo "$nuevo_response" | xmlstarlet fo
    }
fi

# === FILTRADO POR MUNICIPIO ===
municipios=$(echo "$nuevo_response" | xmlstarlet sel -N d="$ns" -t -m "//d:EESSPrecio" -v "d:Municipio" -n | sort -u)
if [[ $(echo "$municipios" | wc -l) -eq 1 ]]; then
    municipio_filtrado="$municipios"
    echo "Solo se encontró un municipio: '$municipio_filtrado'. Seleccionado automáticamente."
else
    echo "Lista de municipios:"
    echo "$municipios"
    read -p "Escribe el municipio que quieres filtrar: " municipio_filtrado
fi

if [[ -n "$municipio_filtrado" ]]; then
    contenido_filtrado=$(echo "$nuevo_response" | xmlstarlet sel -N d="$ns" -t \
        -m "//d:EESSPrecio[d:Municipio='$municipio_filtrado']" -c "." -n)
    nuevo_response=$(envolver_en_resultados "$contenido_filtrado")
    [[ "$DEBUG" == true ]] && {
        echo "Gasolineras filtradas por municipio '$municipio_filtrado':"
        echo "$nuevo_response" | xmlstarlet fo
    }
fi

# === FILTRADO POR LOCALIDAD ===
localidades=$(echo "$nuevo_response" | xmlstarlet sel -N d="$ns" -t -m "//d:EESSPrecio" -v "d:Localidad" -n | sort -u)
if [[ $(echo "$localidades" | wc -l) -eq 1 ]]; then
    localidad_filtrada="$localidades"
    echo "Solo se encontró una localidad: '$localidad_filtrada'. Seleccionado automáticamente."
else
    echo "Lista de localidades:"
    echo "$localidades"
    read -p "Escribe la localidad que quieres filtrar: " localidad_filtrada
fi

if [[ -n "$localidad_filtrada" ]]; then
    contenido_filtrado=$(echo "$nuevo_response" | xmlstarlet sel -N d="$ns" -t \
        -m "//d:EESSPrecio[d:Localidad='$localidad_filtrada']" -c "." -n)
    nuevo_response=$(envolver_en_resultados "$contenido_filtrado")
    [[ "$DEBUG" == true ]] && {
        echo "Gasolineras filtradas por localidad '$localidad_filtrada':"
        echo "$nuevo_response" | xmlstarlet fo
    }
fi

# === RESULTADO FINAL ===
echo ""
echo "Resultado final filtrado:"
echo "$nuevo_response" | xmlstarlet fo