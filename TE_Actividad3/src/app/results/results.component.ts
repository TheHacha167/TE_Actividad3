// src/app/results/results.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-results',
  templateUrl: './results.component.html',
  styleUrls: ['./results.component.css'],
  standalone: false
})
export class ResultsComponent {
  gasStations = [
    { id: 1, name: 'Gasolinera A', distance: 2.5, price: 1.45 },
    { id: 2, name: 'Gasolinera B', distance: 4.1, price: 1.42 },
    { id: 3, name: 'Gasolinera C', distance: 6.0, price: 1.47 }
  ];

  constructor() { }
}