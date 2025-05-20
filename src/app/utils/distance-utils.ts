// src/app/utils/distance-utils.ts

/**
 * Calcula la distancia en kilómetros entre dos puntos geográficos.
 * @param lat1 - Latitud del punto 1.
 * @param lng1 - Longitud del punto 1.
 * @param lat2 - Latitud del punto 2.
 * @param lng2 - Longitud del punto 2.
 * @returns Distancia en kilómetros.
 */
export function calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const toRad = (value: number) => (value * Math.PI) / 180;
    const earthRadiusKm = 6371;
  
    const dLat = toRad(lat2 - lat1);
    const dLng = toRad(lng2 - lng1);
  
    const lat1Rad = toRad(lat1);
    const lat2Rad = toRad(lat2);
  
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.sin(dLng / 2) * Math.sin(dLng / 2) * Math.cos(lat1Rad) * Math.cos(lat2Rad);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  
    return earthRadiusKm * c;
  }