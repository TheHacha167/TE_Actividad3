import { Component, OnInit } from '@angular/core';
import { GasStationService } from '../services/gas-station.service';

@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.css'],
  standalone: false 
})
export class SearchComponent implements OnInit {

  // Datos crudos (todas las gasolineras)
  allGasStations: any[] = [];
  // Datos filtrados (los que muestra la interfaz)
  filteredGasStations: any[] = [];

  // Catálogos únicos
  empresas: string[] = [];
  carburantes: string[] = [];
  provincias: string[] = [];
  municipios: string[] = [];
  localidades: string[] = [];

  // Modelo de filtros
  filters = {
    empresa: '',
    carburante: '',
    provincia: '',
    municipio: '',
    localidad: ''
  };

  // Controla si ya hemos descargado la info
  dataLoaded = false;
  // Controla si estamos cargando datos (para mostrar spinner)
  isLoading = false;

  // Coordenadas del usuario
  userLat: number | null = null;
  userLng: number | null = null;

  constructor(private gasStationService: GasStationService) { }

  ngOnInit(): void {
    // Al iniciar el componente, cargamos las gasolineras automáticamente
    this.loadAllGasStations();
  }

  /**
   * Descarga la lista de gasolineras y construye catálogos
   */
  loadAllGasStations(): void {
    this.isLoading = true; // Encendemos el spinner
    this.gasStationService.getGasStations().subscribe({
      next: (data: any[]) => {
        // Guardamos la lista completa
        this.allGasStations = data;
        this.filteredGasStations = data; // Sin filtros inicialmente

        // Generar catálogos
        this.empresas = this.getUniqueValues(data, 'Rótulo');
        this.provincias = this.getUniqueValues(data, 'Provincia');
        this.municipios = this.getUniqueValues(data, 'Municipio');
        this.localidades = this.getUniqueValues(data, 'Localidad');
        this.carburantes = this.extractCarburantes(data[0]);  // Extraer carburantes dinámicamente

        // Establecer carburante por defecto y aplicar filtros iniciales
        this.filters.carburante = 'Gasolina 95 E5';
        this.applyFilters();

        this.dataLoaded = true;
        this.isLoading = false; // Apagamos el spinner
      },
      error: (err) => {
        console.error('Error al obtener estaciones de servicio: ', err);
        this.isLoading = false;
      }
    });
  }

  /**
   * Pide al navegador la ubicación del usuario
   */
  getUserLocation(): void {
    if ('geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.userLat = position.coords.latitude;
          this.userLng = position.coords.longitude;
          console.log('Ubicación del usuario:', this.userLat, this.userLng);

          // Una vez tengamos la ubicación, podemos calcular las distancias
          this.calculateDistances();
        },
        (error) => {
          console.error('Error al obtener geolocalización:', error);
          alert('No se pudo obtener la ubicación. Por favor, verifica los permisos de tu navegador.');
        },
        { enableHighAccuracy: true }
      );
    } else {
      alert('Geolocalización no soportada por este navegador.');
    }
  }

  /**
   * Calcula la distancia de cada gasolinera a la posición del usuario,
   * guardándola en station.distanceToUser. Luego ordena la lista por distancia.
   */
  calculateDistances(): void {
    if (this.userLat == null || this.userLng == null) return;

    this.allGasStations.forEach(st => {
      const stationLat = parseFloat(st['Latitud'].replace(',', '.'));
      const stationLng = parseFloat(st['Longitud (WGS84)'].replace(',', '.'));

      const dist = this.gasStationService.calculateDistance(
        this.userLat!, this.userLng!, stationLat, stationLng
      );
      st.distanceToUser = dist;
    });

    // Ordenar gasolineras por distancia
    this.allGasStations.sort((a, b) => a.distanceToUser - b.distanceToUser);
    // Actualizar la lista filtrada
    this.filteredGasStations = [...this.allGasStations];

      // Filtrar las gasolineras a menos de 10 km
      this.filterByRadius(10);


  }

  /**
   * Filtra las gasolineras que estén dentro de un radio X (km) respecto al usuario
   */
  filterByRadius(km: number): void {
    if (this.userLat == null || this.userLng == null) {
      alert('Primero obtén tu ubicación.');
      return;
    }
    this.filteredGasStations = this.allGasStations.filter(st => {
      return st.distanceToUser !== undefined && st.distanceToUser <= km;
    });
  }

  /**
   * Extrae valores únicos de una propiedad (p.e. 'Rótulo')
   */
  getUniqueValues(arrayData: any[], property: string): string[] {
    const values = arrayData.map(item => item[property]?.trim() || '');
    const uniqueValues = Array.from(new Set(values)).filter(v => v !== '');
    return uniqueValues.sort();
  }

  /**
   * Detectar claves que empiecen por "Precio "
   */
  extractCarburantes(oneStation: any): string[] {
    if (!oneStation) return [];
    return Object.keys(oneStation)
      .filter(key => key.startsWith('Precio '))
      .map(key => key.replace('Precio ', ''))
      .sort();
  }

  resetFilters(): void {
    // Restablecer todos los filtros excepto carburante
    this.filters = {
      empresa: '',
      provincia: '',
      municipio: '',
      localidad: '',
      carburante: this.filters.carburante // Mantener el carburante actual
    };
  
    // Volver a aplicar los filtros (considerando el estado inicial)
    this.applyFilters();
  }

  applyFilters(): void {
  const carburanteKey = this.filters.carburante ? 'Precio ' + this.filters.carburante : null;

  // Determinar si hay otros filtros activos además de carburante
  const isFiltered =
    this.filters.empresa ||
    this.filters.provincia ||
    this.filters.municipio ||
    this.filters.localidad;

  // Filtrar gasolineras según los filtros seleccionados
  this.filteredGasStations = this.allGasStations.filter(st => {
    if (this.filters.empresa && st['Rótulo'] !== this.filters.empresa) {
      return false;
    }
    if (this.filters.provincia && st['Provincia'] !== this.filters.provincia) {
      return false;
    }
    if (this.filters.municipio && st['Municipio'] !== this.filters.municipio) {
      return false;
    }
    if (this.filters.localidad && st['Localidad'] !== this.filters.localidad) {
      return false;
    }
    if (carburanteKey && !st.hasOwnProperty(carburanteKey)) {
      return false;
    }
    return true;
  });

  // Lógica contextual basada en los filtros aplicados
  if (!isFiltered && carburanteKey) {
    // Si solo se está filtrando por carburante, limitar a 10 km
    this.filteredGasStations = this.filteredGasStations.filter(st => st.distanceToUser <= 10);
  } else if (isFiltered) {
    // Si hay otros filtros activos, limitar a las 20 más cercanas
    this.filteredGasStations = this.filteredGasStations
      .sort((a, b) => a.distanceToUser - b.distanceToUser) // Ordenar por distancia
      .slice(0, 3); // Tomar las primeras 20
  }

  // Actualizar las listas desplegables dinámicas
  this.updateDropdownOptions();
}
          
    
updateDropdownOptions(): void {
  const isOnlyCarburanteActive =
    this.filters.carburante && 
    !this.filters.empresa &&
    !this.filters.provincia &&
    !this.filters.municipio &&
    !this.filters.localidad;

  if (isOnlyCarburanteActive) {
    // Si solo el carburante está activo, usa todos los datos disponibles
    this.municipios = this.getUniqueValues(this.allGasStations, 'Municipio');
    this.localidades = this.getUniqueValues(this.allGasStations, 'Localidad');
  } else {
    if (this.filters.empresa) {
      const filteredByEmpresa = this.filteredGasStations.filter(st => st['Rótulo'] === this.filters.empresa);

      this.provincias = this.getUniqueValues(filteredByEmpresa, 'Provincia');
      this.municipios = this.getUniqueValues(filteredByEmpresa, 'Municipio');
      this.localidades = this.getUniqueValues(filteredByEmpresa, 'Localidad');
    } else {
      if (this.filters.provincia) {
        const filteredByProvince = this.filteredGasStations.filter(st => st['Provincia'] === this.filters.provincia);
        this.municipios = this.getUniqueValues(filteredByProvince, 'Municipio');
      } else {
        this.municipios = this.getUniqueValues(this.filteredGasStations, 'Municipio');
      }

      if (this.filters.municipio) {
        const filteredByMunicipio = this.filteredGasStations.filter(st => st['Municipio'] === this.filters.municipio);
        this.localidades = this.getUniqueValues(filteredByMunicipio, 'Localidad');
      } else {
        this.localidades = this.getUniqueValues(this.filteredGasStations, 'Localidad');
      }
    }
  }
}

    
    onChangeCarburante(): void {
      // Filtrar por carburante únicamente sobre el resultado actual
      const carburanteKey = 'Precio ' + this.filters.carburante;
      if (this.filters.carburante) {
        this.filteredGasStations = this.filteredGasStations.filter(st =>
          st.hasOwnProperty(carburanteKey)
        );
      }

      // Volver a limitar los resultados a los 10 km
      this.filteredGasStations = this.filteredGasStations.filter(st => st.distanceToUser <= 10);

    }
        
      

  
    onChangeEmpresa(): void {
      if (this.filters.empresa) {
        // Filtrar gasolineras por la empresa seleccionada
        const filteredByEmpresa = this.allGasStations.filter(st => st['Rótulo'] === this.filters.empresa);
    
        // Generar provincias, municipios y localidades únicas con gasolineras de la empresa
        this.provincias = this.getUniqueValues(filteredByEmpresa, 'Provincia');
        this.municipios = this.getUniqueValues(filteredByEmpresa, 'Municipio');
        this.localidades = this.getUniqueValues(filteredByEmpresa, 'Localidad');
      } else {
        // Si no hay empresa seleccionada, mostrar todas las opciones
        this.provincias = this.getUniqueValues(this.allGasStations, 'Provincia');
        this.municipios = this.getUniqueValues(this.allGasStations, 'Municipio');
        this.localidades = this.getUniqueValues(this.allGasStations, 'Localidad');
      }
    
      // Limpiar los filtros dependientes
      this.filters.provincia = '';
      this.filters.municipio = '';
      this.filters.localidad = '';
      this.applyFilters(); // Aplicar los filtros actualizados
    }

  onChangeProvince(): void {
    if (this.filters.provincia) {
      // Filtrar gasolineras por la provincia seleccionada
      const filteredByProvince = this.allGasStations.filter(st => st.Provincia === this.filters.provincia);
  
      // Generar municipios únicos con gasolineras
      this.municipios = this.getUniqueValues(filteredByProvince, 'Municipio');
    } else {
      // Si no hay provincia seleccionada, mostramos todos los municipios
      this.municipios = this.getUniqueValues(this.allGasStations, 'Municipio');
    }
  
    // Limpiar los valores dependientes
    this.filters.municipio = '';
    this.filters.localidad = '';
    this.localidades = [];
    this.applyFilters(); // Aplicar los filtros actualizados
  }

    onChangeMunicipio(): void {
      if (this.filters.municipio) {
        // Filtrar gasolineras por el municipio seleccionado
        const filteredByMunicipio = this.allGasStations.filter(st => st.Municipio === this.filters.municipio);
    
        // Generar localidades únicas con gasolineras
        this.localidades = this.getUniqueValues(filteredByMunicipio, 'Localidad');
      } else if (this.filters.provincia) {
        // Si hay una provincia seleccionada pero no un municipio,
        // mostramos las localidades de la provincia
        const filteredByProvince = this.allGasStations.filter(st => st.Provincia === this.filters.provincia);
        this.localidades = this.getUniqueValues(filteredByProvince, 'Localidad');
      } else {
        // Si no hay filtros, mostramos todas las localidades
        this.localidades = this.getUniqueValues(this.allGasStations, 'Localidad');
      }
    
      // Limpiar el valor del filtro localidad
      this.filters.localidad = '';
      this.applyFilters(); // Aplicar los filtros actualizados
    }    
}