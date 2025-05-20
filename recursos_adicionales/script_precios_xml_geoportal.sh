#!/bin/bash

#DEBUG=true

# URL de la API
#API_URL="https://geoportalgasolineras.es/geoportal/rest/busquedaEstaciones"

# Petición a la API
echo "Obteniendo datos del XML..."
response=$(curl -s -k -X POST "$API_URL" \
-H 'Content-Type: application/json' \
-H 'Accept: application/xml' \
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

[[ -z "$response" ]] && { echo "Error al obtener datos. Saliendo..."; exit 1; }

# Mostrar lista de empresas
empresas=$(echo "$response" | xmlstarlet sel -t -m "//estacion" -v "rotulo" -n | sort -u)

echo "Lista de empresas:"
echo "$empresas"
echo ""

read -p "Escribe la empresa que quieres filtrar (o pulsa ENTER para no filtrar): " empresa

if [[ -n "$empresa" ]]; then
    empresa_filtrada=$(echo "$empresa" | sed 's/[<>|]//g' | awk '{$1=$1};1')
    estaciones_filtradas=$(echo "$response" | xmlstarlet sel -t -m "//estacion[rotulo='$empresa_filtrada']" -c "." -n)
    if [[ -z "$estaciones_filtradas" ]]; then
        echo "No se encontraron gasolineras para '$empresa_filtrada'. Usando XML original."
        nuevo_response="$response"
    else
        nuevo_response="<root>$estaciones_filtradas</root>"
        echo "Gasolineras filtradas por empresa '$empresa_filtrada':"
        [[ "$DEBUG" == true ]] && echo "$nuevo_response" | xmlstarlet fo
    fi
else
    nuevo_response="$response"
fi

echo ""

# Provincias
provincias=$(echo "$nuevo_response" | xmlstarlet sel -t -m "//estacion" -v "provincia" -n | sort -u)
if [[ $(echo "$provincias" | wc -l) -eq 1 ]]; then
    provincia=$(echo "$provincias")
    echo "Solo se encontró una provincia: '$provincia'. Seleccionada automáticamente."
else
    echo "Lista de provincias:"
    echo "$provincias"
    read -p "Escribe la provincia que quieres filtrar: " provincia
fi

if [[ -n "$provincia" ]]; then
    estaciones_filtradas=$(echo "$nuevo_response" | xmlstarlet sel -t \
        -m "//estacion[provincia='$provincia']" -c "." -n)
    nuevo_response="<root>$estaciones_filtradas</root>"
    echo "Gasolineras filtradas por provincia '$provincia':"
    [[ "$DEBUG" == true ]] && echo "$nuevo_response" | xmlstarlet fo
fi
echo ""

# Localidades (como puede haber espacios: usar `contains`)
localidades=$(echo "$nuevo_response" | xmlstarlet sel -t -m "//estacion" -v "localidad" -n | sed 's/ *$//' | sort -u)

if [[ $(echo "$localidades" | wc -l) -eq 1 ]]; then
    localidad=$(echo "$localidades")
    echo "Solo se encontró una localidad: '$localidad'. Seleccionada automáticamente."
else
    echo "Lista de localidades:"
    echo "$localidades"
    read -p "Escribe la localidad que quieres filtrar: " localidad
fi

if [[ -n "$localidad" ]]; then
    localidad_limpia=$(echo "$localidad" | sed 's/ *$//')
    estaciones_filtradas=$(echo "$nuevo_response" | xmlstarlet sel -t \
        -m "//estacion[contains(localidad,'$localidad_limpia')]" -c "." -n)
    nuevo_response="<root>$estaciones_filtradas</root>"
    echo "Gasolineras filtradas por localidad '$localidad_limpia':"
    echo "$nuevo_response" | xmlstarlet fo
fi
