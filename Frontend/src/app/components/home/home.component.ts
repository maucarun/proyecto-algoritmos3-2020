import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Receta } from '../../../../Dominio/src/receta';
import { Service } from 'app/service';
import { Usuario } from '../../../../Dominio/src/usuario';

/* function mostrarError(component, error) {
  const errorMessage = (error.status === 0) ? 'No hay conexión con el backend, revise si el servidor remoto está levantado.' : error.error
  component.errors.push(errorMessage)
} */
@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit {
  recetaABuscar = ''
  isChecked = false
  recetas: Receta[] = []
  usuario: Usuario

  constructor(private route: ActivatedRoute, private router: Router, public service: Service) { }

  async ngOnInit() {
    this.usuario = this.service.getUsuarioLogueado
    /* this.recetas = this.service.getRecetas */
    /* try { */
      this.recetas = await this.service.todasLasRecetas()
    /* } catch (error) {
      mostrarError(this, error)
    } */
  }

  recibirRecetaABuscar(valueEmitted: string): void {
    this.recetaABuscar = valueEmitted
  }

  recibirEstadoCheckbox(valueEmitted: boolean): void {
    this.isChecked = valueEmitted
  }

  nuevaReceta(): void {
    this.router.navigate(['receta/new'])
  }

}
