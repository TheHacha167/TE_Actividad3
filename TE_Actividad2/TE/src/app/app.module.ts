import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { AppRoutingModule } from './app-routing.module';

// Angular Material Modules
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu'; // Importación añadida
import { MatToolbarModule } from '@angular/material/toolbar';

// Componentes importados
import { AboutComponent } from './about/about.component';
import { AppComponent } from './app.component';
import { HomeComponent } from './home/home.component';
import { PageNotFoundComponent } from './page-not-found/page-not-found.component';
import { ResultsComponent } from './results/results.component';
import { SearchComponent } from './search/search.component';
import { StationDetailComponent } from './station-detail/station-detail.component';

@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    SearchComponent,
    ResultsComponent,
    StationDetailComponent,
    AboutComponent,
    PageNotFoundComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule,
    BrowserAnimationsModule, // Habilitar animaciones
    MatToolbarModule,        // Toolbar de Angular Material
    MatButtonModule,         // Botones de Angular Material
    MatIconModule,           // Iconos de Angular Material
    MatMenuModule            // Menús de Angular Material (solución del error)
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
