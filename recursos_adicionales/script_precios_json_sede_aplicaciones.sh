#!/bin/bash

DEBUG=false  # Cambia a true para ver resultados intermedios

# URL de la API
API_URL="https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/"

# Carburantes posibles
carburantes=(
    "Precio Biodiesel"
    "Precio Bioetanol"
    "Precio Gas Natural Comprimido"
    "Precio Gas Natural Licuado"
    "Precio Gases licuados del petróleo"
    "Precio Gasoleo A"
    "Precio Gasoleo B"
    "Precio Gasoleo Premium"
    "Precio Gasolina 95 E10"
    "Precio Gasolina 95 E5"
    "Precio Gasolina 95 E5 Premium"
    "Precio Gasolina 98 E10"
    "Precio Gasolina 98 E5"
    "Precio Hidrogeno"
)

# Obtener datos JSON
echo "Obteniendo datos del JSON..."
response=$(curl -s "$API_URL" | iconv -f utf-8 -t utf-8 -c)

if [[ -z "$response" ]]; then
    echo "Error al obtener datos. Saliendo..."
    exit 1
fi

# Preguntar si se desea filtrar por carburante
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

    carburante="${carburantes[$((seleccion - 1))]}"
    echo "Carburante seleccionado: $carburante"
    echo ""

    # Filtrar estaciones con precio válido solo para ese carburante
    nuevo_response=$(echo "$response" | jq --arg c "$carburante" '
      .ListaEESSPrecio
      | map(select(.[ $c ] != null and .[ $c ] != ""))
      | map({
          "Rótulo": .["Rótulo"],
          "Provincia": .["Provincia"],
          "Municipio": .["Municipio"],
          "Localidad": .["Localidad"],
          "Dirección": .["Dirección"],
          "Precio": .[$c]
        })
    ')
else
    # Mantener todos los datos sin filtrar carburante
    nuevo_response=$(echo "$response" | jq '.ListaEESSPrecio')
fi

[[ "$DEBUG" == true ]] && echo "Resultado tras filtrar por carburante (si aplica):" && echo "$nuevo_response" | jq
echo ""

# === FILTRADO POR EMPRESA ===
empresas=$(echo "$nuevo_response" | jq -r '.[]."Rótulo"' | sort -u)
echo "Lista de empresas:"
echo "$empresas"
echo ""

read -p "Escribe la empresa que quieres filtrar (o pulsa ENTER para no filtrar): " empresa_filtrada

if [[ -n "$empresa_filtrada" ]]; then
    nuevo_response=$(echo "$nuevo_response" | jq --arg empresa "$empresa_filtrada" \
        '[.[] | select(.["Rótulo"] == $empresa)]')

    echo "Gasolineras filtradas por empresa '$empresa_filtrada':"
    [[ "$DEBUG" == true ]] && echo "$nuevo_response" | jq
fi
echo ""

# === FILTRADO POR PROVINCIA ===
provincias=$(echo "$nuevo_response" | jq -r '.[].Provincia' | sort -u)
if [[ $(echo "$provincias" | wc -l) -eq 1 ]]; then
    provincia_filtrada=$(echo "$provincias")
    echo "Solo se encontró una provincia: '$provincia_filtrada'. Seleccionada automáticamente."
else
    echo "Lista de provincias:"
    echo "$provincias"
    read -p "Escribe la provincia que quieres filtrar: " provincia_filtrada
fi

if [[ -n "$provincia_filtrada" ]]; then
    nuevo_response=$(echo "$nuevo_response" | jq --arg provincia "$provincia_filtrada" \
        '[.[] | select(.Provincia == $provincia)]')
    [[ "$DEBUG" == true ]] && {
        echo "Gasolineras filtradas por la provincia '$provincia_filtrada':"
        echo "$nuevo_response" | jq
    }
fi
echo ""

# === FILTRADO POR MUNICIPIO ===
municipios=$(echo "$nuevo_response" | jq -r '.[].Municipio' | sort -u)
if [[ $(echo "$municipios" | wc -l) -eq 1 ]]; then
    municipio_filtrado=$(echo "$municipios")
    echo "Solo se encontró un municipio: '$municipio_filtrado'. Seleccionado automáticamente."
else
    echo "Lista de municipios:"
    echo "$municipios"
    read -p "Escribe el municipio que quieres filtrar: " municipio_filtrado
fi

if [[ -n "$municipio_filtrado" ]]; then
    nuevo_response=$(echo "$nuevo_response" | jq --arg municipio "$municipio_filtrado" \
        '[.[] | select(.Municipio == $municipio)]')
    [[ "$DEBUG" == true ]] && {
        echo "Gasolineras filtradas por el municipio '$municipio_filtrado':"
        echo "$nuevo_response" | jq
    }
fi
echo ""

# === FILTRADO POR LOCALIDAD ===
localidades=$(echo "$nuevo_response" | jq -r '.[].Localidad' | sort -u)
if [[ $(echo "$localidades" | wc -l) -eq 1 ]]; then
    localidad_filtrada=$(echo "$localidades")
    echo "Solo se encontró una localidad: '$localidad_filtrada'. Seleccionada automáticamente."
else
    echo "Lista de localidades:"
    echo "$localidades"
    read -p "Escribe la localidad que quieres filtrar: " localidad_filtrada
fi

if [[ -n "$localidad_filtrada" ]]; then
    nuevo_response=$(echo "$nuevo_response" | jq --arg localidad "$localidad_filtrada" \
        '[.[] | select(.Localidad == $localidad)]')
    [[ "$DEBUG" == true ]] && {
        echo "Gasolineras filtradas por la localidad '$localidad_filtrada':"
        echo "$nuevo_response" | jq
    }
fi

# === RESULTADO FINAL ===
echo ""
echo "Resultado final filtrado:"
echo "$nuevo_response" | jq