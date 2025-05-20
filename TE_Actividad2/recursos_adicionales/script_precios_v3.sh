#!/bin/bash

clear

# Elección del formato
read -p "¿Quieres usar JSON o XML como referencia para obtener los datos? (json/xml): " formato
if [[ $formato = "json" || $formato = "JSON" ]]; then
    echo "Formato JSON elegido"
elif [[ $formato = "xml" || $formato = "XML" ]]; then
    echo "Por ahora solo se admite JSON. Saliendo..."
    exit 1
else
    echo "Formato incorrecto. Saliendo..."
    exit 1
fi

# URL de la API JSON
API_URL_JSON="https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/"

# Obtención de datos del JSON
echo "Obteniendo datos del JSON..."
response=$(curl -s "$API_URL_JSON" | iconv -f utf-8 -t utf-8 -c)

# Verificar si la respuesta tiene datos
if [[ -z "$response" ]]; then
    echo "Error al obtener datos. Saliendo..."
    exit 1
fi

<< 'Comment'

# Lista de carburantes
carburantes=(
    "Biodiesel" "Bioetanol" "Gas Natural Comprimido" "Gas Natural Licuado"
    "Gases licuados del petróleo" "Gasoleo A" "Gasoleo B" "Gasoleo Premium"
    "Gasolina 95 E10" "Gasolina 95 E5" "Gasolina 95 E5 Premium"
    "Gasolina 98 E10" "Gasolina 98 E5" "Hidrogeno"
)

# Mostrar la lista de carburantes
echo "Lista de carburantes disponibles:"
for c in "${carburantes[@]}"; do
    echo "- $c"
done
echo ""



# Preguntar al usuario por el carburante
read -p "¿Quieres buscar un carburante específico? Escribe el nombre (o pulsa ENTER para no filtrar): " carburante_filtrado

Comment

# Convertir JSON a array de empresas
empresas=$(echo "$response" | jq -r '.ListaEESSPrecio[]."Rótulo"' | sort -u)

# Mostrar la lista de empresas
echo "Lista de empresas:"
echo "$empresas"
echo ""

read -p "Escribe la empresa que quieres filtrar (o pulsa ENTER para no filtrar): " empresa_filtrada

# Filtrar por empresa
if [[ -n "$empresa_filtrada" ]]; then
    nuevo_response=$(echo "$response" | jq --arg empresa "$empresa_filtrada" \
        '[.ListaEESSPrecio[] | select(."Rótulo" == $empresa)]')
    if [[ -z "$nuevo_response" || "$nuevo_response" == "[]" ]]; then
        echo "No se encontraron gasolineras para la empresa '$empresa_filtrada'. Manteniendo el JSON original."
        nuevo_response=$(echo "$response" | jq '.ListaEESSPrecio')
    else
        echo "Gasolineras filtradas por la empresa '$empresa_filtrada':"
        #echo "$nuevo_response" | jq
    fi
else
    echo "No se ha filtrado por empresa. Manteniendo el JSON original."
    nuevo_response=$(echo "$response" | jq '.ListaEESSPrecio')
fi
echo ""






# Filtrar por provincia
provincias=$(echo "$nuevo_response" | jq -r '.[]."Provincia"' | sort -u)
if [[ $(echo "$provincias" | wc -l) -eq 1 ]]; then
    provincia_filtrada=$(echo "$provincias")
    echo "Solo se encontró una provincia: '$provincia_filtrada'. Seleccionada automáticamente."
else
    echo "Lista de provincias:"
    echo "$provincias"
    read -p "Escribe la provincia que quieres filtrar: " provincia_filtrada
fi

# Aplicar el filtro de provincia
if [[ -n "$provincia_filtrada" ]]; then
    nuevo_response=$(echo "$nuevo_response" | jq --arg provincia "$provincia_filtrada" \
        '[.[] | select(."Provincia" == $provincia)]')
    echo "Gasolineras filtradas por la provincia '$provincia_filtrada':"
    #echo "$nuevo_response" | jq
else
    echo "No se ha filtrado por provincia."
fi
echo ""

# Filtrar por municipio
municipios=$(echo "$nuevo_response" | jq -r '.[]."Municipio"' | sort -u)
if [[ $(echo "$municipios" | wc -l) -eq 1 ]]; then
    municipio_filtrado=$(echo "$municipios")
    echo "Solo se encontró un municipio: '$municipio_filtrado'. Seleccionado automáticamente."
else
    echo "Lista de municipios:"
    echo "$municipios"
    read -p "Escribe el municipio que quieres filtrar: " municipio_filtrado
fi

# Aplicar el filtro de municipio
if [[ -n "$municipio_filtrado" ]]; then
    nuevo_response=$(echo "$nuevo_response" | jq --arg municipio "$municipio_filtrado" \
        '[.[] | select(."Municipio" == $municipio)]')
    echo "Gasolineras filtradas por el municipio '$municipio_filtrado':"
    #echo "$nuevo_response" | jq
else
    echo "No se ha filtrado por municipio."
fi
echo ""

# Filtrar por localidad
localidades=$(echo "$nuevo_response" | jq -r '.[]."Localidad"' | sort -u)
if [[ $(echo "$localidades" | wc -l) -eq 1 ]]; then
    localidad_filtrada=$(echo "$localidades")
    echo "Solo se encontró una localidad: '$localidad_filtrada'. Seleccionada automáticamente."
else
    echo "Lista de localidades:"
    echo "$localidades"
    read -p "Escribe la localidad que quieres filtrar: " localidad_filtrada
fi

# Aplicar el filtro de localidad
if [[ -n "$localidad_filtrada" ]]; then
    nuevo_response=$(echo "$nuevo_response" | jq --arg localidad "$localidad_filtrada" \
        '[.[] | select(."Localidad" == $localidad)]')
    echo "Gasolineras filtradas por la localidad '$localidad_filtrada':"
    echo "$nuevo_response" | jq
else
    echo "No se ha filtrado por localidad."
fi
