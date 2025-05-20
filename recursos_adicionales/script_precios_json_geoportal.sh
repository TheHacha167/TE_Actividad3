#!/bin/bash

DEBUG=false  # Cambiar a true para ver resultados intermedios

# URL de la API
#API_URL="https://geoportalgasolineras.es/geoportal/rest/busquedaEstaciones"

# Petición a la API
echo "Obteniendo datos del JSON..."
response=$(curl -s -k -X POST "$API_URL" \
-H 'Content-Type:application/json' \
-H 'Accept: application/json' \
--data '{
    "calle": "",
    "codPostal": "",
    "conPlanesDescuento": false,
    "eessEconomicas": false,
    "horarioFinal": "",
    "horarioInicial": "",
    "idMunicipio": "",
    "idOperador": "",
    "idProducto": "",
    "idProvincia": "",
    "idTipoDestinatario": null,
    "nombrePlan": "",
    "numero": "",
    "rotulo": "",
    "tipoEstacion": "EESS",
    "tipoServicio": null,
    "tipoVenta": "P",
    "x0": "",
    "x1": "",
    "y0": "",
    "y1": ""
}' | iconv -f utf-8 -t utf-8 -c)

if [[ -z "$response" ]]; then
    echo "Error al obtener datos. Saliendo..."
    exit
fi

# Inicializar con todas las estaciones
estaciones=$(echo "$response" | jq '[.estaciones[].estacion]')


# 1. Filtrar por empresa (rotulo)
#empresas=$(echo "$estaciones" | jq -r '.rotulo' | sort -u)
empresas=$(echo "$estaciones" | jq -r '.[].rotulo' | sort -u)

echo "Lista de empresas:"
echo "$empresas"
echo ""
read -p "Escribe la empresa que quieres filtrar (o pulsa ENTER para no filtrar): " empresa

if [[ -n "$empresa" ]]; then
    #estaciones=$(echo "$estaciones" | jq --arg empresa "$empresa" 'select(.rotulo == $empresa)')
        estaciones=$(echo "$estaciones" | jq --arg empresa "$empresa" '[.[] | select(.rotulo == $empresa)]')

    echo "Gasolineras filtradas por empresa '$empresa':"
    [[ "$DEBUG" == true ]] && echo "$estaciones" | jq
fi
echo ""

# 2. Filtrar por provincia
#provincias=$(echo "$estaciones" | jq -r '.provincia' | sort -u)
provincias=$(echo "$estaciones" | jq -r '.[].provincia' | sort -u)

if [[ $(echo "$provincias" | wc -l) -eq 1 ]]; then
    provincia=$(echo "$provincias")
    echo "Solo se encontró una provincia: '$provincia'. Seleccionada automáticamente."
else
    echo "Lista de provincias:"
    echo "$provincias"
    read -p "Escribe la provincia que quieres filtrar: " provincia
fi

if [[ -n "$provincia" ]]; then
    #estaciones=$(echo "$estaciones" | jq --arg provincia "$provincia" 'select(.provincia == $provincia)')
   
       estaciones=$(echo "$estaciones" | jq --arg provincia "$provincia" '[.[] | select(.provincia == $provincia)]')
 echo "Gasolineras filtradas por provincia '$provincia':"
    [[ "$DEBUG" == true ]] && echo "$estaciones" | jq
fi
echo ""

# 3. Filtrar por provincia
#provincias=$(echo "$estaciones" | jq -r '.provincia' | sort -u)
localidades=$(echo "$estaciones" | jq -r '.[].localidad' | sort -u)

if [[ $(echo "$localidades" | wc -l) -eq 1 ]]; then
    localidad=$(echo "$localidades")
    echo "Solo se encontró una localidad: '$localidad'. Seleccionada automáticamente."
else
    echo "Lista de localidades:"
    echo "$localidades"
    read -p "Escribe la localidad que quieres filtrar: " localidad
fi

if [[ -n "$localidad" ]]; then
    #estaciones=$(echo "$estaciones" | jq --arg provincia "$provincia" 'select(.provincia == $provincia)')
   
    #estaciones=$(echo "$estaciones" | jq --arg localidad "$localidad" '[.[] | select(.localidad == $localidad)]')
    estaciones=$(echo "$estaciones" | jq --arg localidad "$localidad" '
    [.[] | select((.localidad // "" | ascii_upcase | ltrimstr(" ") | startswith($localidad)))]
    ')


    echo "Gasolineras filtradas por localidad '$localidad':"
    [[ "$DEBUG" == true ]] && echo "$estaciones" | jq
fi
echo ""