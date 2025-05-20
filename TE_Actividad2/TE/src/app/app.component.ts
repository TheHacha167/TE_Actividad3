import { Component } from '@angular/core';
import { Router } from '@angular/router';


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  standalone: false,
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = 'TE_Actividad3';

  constructor(private router: Router) {}

  reloadPage(): void {
    // Comprobar si ya estamos en la página de Buscar
    if (this.router.url === '/search') {
      window.location.reload(); // Refrescar la página
    } else {
      this.router.navigate(['/search']); // Navegar a la página de Buscar
    }
  }
  
}
