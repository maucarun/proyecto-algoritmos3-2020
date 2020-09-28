import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { service } from '../../service'
@Component({
  selector: 'app-login-form',
  templateUrl: './login-form.component.html',
  styleUrls: ['./login-form.component.css']
})
export class LoginFormComponent implements OnInit {

userName: String
password: String
mostrarLabelInvalido: boolean = false

  constructor(private router: Router) { }
  
  ngOnInit(): void {
  }

  onIngresar() {
    if(service.contieneUsuario(this.userName)) {
      this.navegarHaciaHome()
    } else { this.mostrarLabelInvalido = true }
  }

  navegarHaciaHome(): void {
    this.router.navigate(['/home'])
  }
}
