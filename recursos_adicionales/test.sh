#!/bin/bash

clear;


export DEV="S";
while [[ $DEV = "S" ]]; do
    echo "-----------------------------------------------";
    echo "1. SEDE APLICACIONES"
    echo "2. GEOPORTAL GASOLINERAS"
    echo "-----------------------------------------------";
    read -p "Elige la web desde la que leer y filtrar datos de gasolineras: " app

    if [[ $app = "1" ]]; then
        # URL de la API
        export API_URL="https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/"

        # Elección del formato
        read -p "¿Quieres usar JSON o XML como referencia para obtener los datos? (json/xml): " formato

        if [[ $formato = "json" || $formato = "JSON" ]]; then
            echo "Formato JSON elegido"
            echo ""

            ./script_precios_json_sede_aplicaciones.sh
        elif [[ $formato = "xml" || $formato = "XML" ]]; then
            echo "Formato XML elegido"
            echo ""

            ./script_precios_xml_sede_aplicaciones.sh
        else
            echo "Formato incorrecto. Saliendo..."
            exit
        fi
    elif [[ $app = "2" ]]; then
        # URL de la API
        export API_URL="https://geoportalgasolineras.es/geoportal/rest/busquedaEstaciones"
        
        # Elección del formato
        read -p "¿Quieres usar JSON o XML como referencia para obtener los datos? (json/xml): " formato

        if [[ $formato = "json" || $formato = "JSON" ]]; then
            echo "Formato JSON elegido"
            echo ""

            ./script_precios_json_geoportal.sh
        elif [[ $formato = "xml" || $formato = "XML" ]]; then
            echo "Formato XML elegido"
            echo ""

            ./script_precios_xml_geoportal.sh
        else
            echo "Formato incorrecto. Saliendo..."
            exit
        fi
    else
        echo "Formato incorrecto. Saliendo..."
        exit
    fi
    

    echo "====================================================================================================="
    read -p "Pulsa Enter para realizar una nueva operacion o Ctrl+C para finalizar -> " DEV

    if [[ $DEV = "" ]]; then
        DEV="S"
    else
        echo "Saliendo del entorno..."

        DEV="N"
    fi
done