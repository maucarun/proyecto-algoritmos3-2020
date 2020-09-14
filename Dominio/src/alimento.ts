import { CondicionAlimenticia } from "./condicionAlimenticia"

export class Alimento {

	constructor(
		public nombre = '',
		public descripcion = '',
		public grupo: Grupo = 'HORTALIZAS_FRUTAS_SEMILLAS',
		public condicionesInadecuadas = new Array<CondicionAlimenticia>()) { }

	public agregarCondicionInadecuada(condicion: CondicionAlimenticia) {
		return this.condicionesInadecuadas.push(condicion)
	}

	public esDeGrupo(grupo: Grupo) {
		return this.grupo == grupo
	}

	/* public cumpleCondicionDeBusqueda(valorBusqueda: string) {
	return this.nombre == valorBusqueda || this.descripcion == valorBusqueda
} */

}

export type Grupo = 'HORTALIZAS_FRUTAS_SEMILLAS' | 'CEREALES_LEGUMBRES_DERIVADOS' | 'LACTEOS_DERIVADOS' | 'CARNES_PESCADO_HUEVO' | 'ACEITES_GRASAS_AZUCARES'

/* export enum Grupo {
	HORTALIZAS_FRUTAS_SEMILLAS,
	CEREALES_LEGUMBRES_DERIVADOS,
	LACTEOS_DERIVADOS,
	CARNES_PESCADO_HUEVO,
	ACEITES_GRASAS_AZUCARES
} */