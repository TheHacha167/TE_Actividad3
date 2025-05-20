// gas-station.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { map } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class GasStationService {

  private API_URL_JSON = 'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/';

  constructor(private http: HttpClient) {}

  getGasStations() {
    return this.http.get<any>(this.API_URL_JSON)
      .pipe(map(response => response.ListaEESSPrecio));
  }

  /**
   * Calcula la distancia en km entre dos coordenadas [lat1, lon1] y [lat2, lon2]
   * usando la fórmula de Haversine.
   */
  calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    // Radio de la Tierra en km
    const R = 6371;
    const dLat = this.deg2rad(lat2 - lat1);
    const dLon = this.deg2rad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private deg2rad(deg: number): number {
    return deg * (Math.PI / 180);
  }
}